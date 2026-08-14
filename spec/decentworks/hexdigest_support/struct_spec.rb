# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Struct do
  # 名前を持つStruct（無名Structとの差を確認するため定数へ代入する）
  let(:point_class) { stub_const("Point", described_class.new(:x, :y)) }

  describe "#to_hexdigest_type" do
    it "定数へ代入されたStructは定数名になる" do
      expect(point_class.new(1, 2).to_hexdigest_type).to eq "Point"
    end

    it "無名のStructはStructへ丸まる" do
      expect(described_class.new(:x, :y).new(1, 2).to_hexdigest_type).to eq "Struct"
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "メンバーがある場合" do
      let(:instance) { point_class.new(1, "a") }

      it { is_expected.to eq '{Symbol:"x"=>Numeric:"1",Symbol:"y"=>String:"a"}' }
    end

    context "メンバーが未設定の場合" do
      let(:instance) { point_class.new(1) }

      it "未設定のメンバーはnilとして含まれる" do
        expect(subject).to eq '{Symbol:"x"=>Numeric:"1",Symbol:"y"=>NilClass:"nil"}'
      end
    end

    context "keyword_initのStructの場合" do
      let(:instance) { described_class.new(:x, :y, keyword_init: true).new(x: 1, y: "a") }

      it "位置引数のStructと同じ値になる" do
        expect(subject).to eq described_class.new(:x, :y).new(1, "a").to_hexdigest_source
      end
    end

    context "メンバーに構造を持つ場合" do
      let(:instance) { point_class.new([1, 2], { a: 1 }) }

      it "メンバーも再帰的に正規化される" do
        expect(subject).to eq %q({Symbol:"x"=>Array:"[Numeric:\"1\",Numeric:\"2\"]",Symbol:"y"=>Hash:"{Symbol:\"a\"=>Numeric:\"1\"}"})
      end
    end

    context "メンバー名だけが異なる場合" do
      let(:instance) { described_class.new(:a, :b).new(1, 2) }

      it "値が同じでも異なる値になる" do
        expect(subject).not_to eq described_class.new(:x, :y).new(1, 2).to_hexdigest_source
      end
    end
  end

  describe "#to_hexdigest" do
    let(:instance) { point_class.new(1, "a") }

    it "同じ内容なら別インスタンスでも同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq point_class.new(1, "a").to_hexdigest
    end

    it "メンバーの値が違えば異なるダイジェストになる" do
      expect(instance.to_hexdigest).not_to eq point_class.new(2, "a").to_hexdigest
    end

    it "同じ内容のハッシュとは異なるダイジェストになる（型で区別される）" do
      expect(instance.to_hexdigest).not_to eq({ x: 1, y: "a" }.to_hexdigest)
    end

    it "名前を持つStructと無名のStructは異なるダイジェストになる" do
      expect(instance.to_hexdigest).not_to eq described_class.new(:x, :y).new(1, "a").to_hexdigest
    end

    it "無名のStruct同士はメンバー名と値が同じなら同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect(described_class.new(:x, :y).new(1, "a").to_hexdigest)
        .to eq described_class.new(:x, :y).new(1, "a").to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    it "ハッシュの値に入れても同じ内容なら同じダイジェストになる" do
      expect({ point: instance }.to_hexdigest).to eq({ point: point_class.new(1, "a") }.to_hexdigest)
    end
  end
end
