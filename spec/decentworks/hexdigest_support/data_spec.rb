# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Data do
  # 名前を持つData（無名Dataとの差を確認するため定数へ代入する）
  let(:coord_class) { stub_const("Coord", described_class.define(:x, :y)) }

  describe "#to_hexdigest_type" do
    it "定数へ代入されたDataは定数名になる" do
      expect(coord_class.new(1, 2).to_hexdigest_type).to eq "Coord"
    end

    it "無名のDataはDataへ丸まる" do
      expect(described_class.define(:x, :y).new(1, 2).to_hexdigest_type).to eq "Data"
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "メンバーがある場合" do
      let(:instance) { coord_class.new(x: 1, y: "a") }

      it { is_expected.to eq '{Symbol:"x"=>Integer:"1",Symbol:"y"=>String:"a"}' }
    end

    context "位置引数で生成した場合" do
      let(:instance) { coord_class.new(1, "a") }

      it "キーワード引数で生成したものと同じ値になる" do
        is_expected.to eq coord_class.new(x: 1, y: "a").to_hexdigest_source
      end
    end

    context "メンバー名だけが異なる場合" do
      let(:instance) { described_class.define(:a, :b).new(1, 2) }

      it "値が同じでも異なる値になる" do
        is_expected.not_to eq described_class.define(:x, :y).new(1, 2).to_hexdigest_source
      end
    end

    context "同じメンバーを持つStructと比べた場合" do
      let(:instance) { described_class.define(:x, :y).new(1, "a") }

      # MEMO: 値の文字列表現は一致し、型識別子だけが衝突を防いでいることを明示する
      it "値は完全に一致する" do
        is_expected.to eq ::Struct.new(:x, :y).new(1, "a").to_hexdigest_source
      end
    end
  end

  describe "#to_hexdigest" do
    let(:instance) { coord_class.new(x: 1, y: "a") }

    it "同じ内容なら別インスタンスでも同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq coord_class.new(x: 1, y: "a").to_hexdigest
    end

    it "メンバーの値が違えば異なるダイジェストになる" do
      expect(instance.to_hexdigest).not_to eq coord_class.new(x: 2, y: "a").to_hexdigest
    end

    it "無名のDataと無名のStructは異なるダイジェストになる（型で区別される）" do
      expect(described_class.define(:x, :y).new(1, "a").to_hexdigest)
        .not_to eq ::Struct.new(:x, :y).new(1, "a").to_hexdigest
    end

    it "同じ内容のハッシュとは異なるダイジェストになる（型で区別される）" do
      expect(instance.to_hexdigest).not_to eq({ x: 1, y: "a" }.to_hexdigest)
    end
  end
end
