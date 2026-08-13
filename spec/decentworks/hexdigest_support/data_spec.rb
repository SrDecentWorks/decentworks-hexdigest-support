# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Data do
  # 名前を持つData（無名Dataとの差を確認するため定数へ代入する）
  let(:coord_class) { stub_const("Coord", ::Data.define(:x, :y)) }

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "メンバーがある場合" do
      let(:instance) { coord_class.new(x: 1, y: "a") }

      it { is_expected.to eq '{Symbol:"x"=>Integer:"1",Symbol:"y"=>String:"a"}' }
    end

    context "位置引数で生成した場合" do
      let(:instance) { coord_class.new(1, "a") }

      it "キーワード引数で生成したものと同じ値になる" do
        expect(instance.to_hexdigest_source).to eq coord_class.new(x: 1, y: "a").to_hexdigest_source
      end
    end

    context "メンバー名だけが異なる場合" do
      it "値が同じでも異なる値になる" do
        expect(::Data.define(:a, :b).new(1, 2).to_hexdigest_source)
          .not_to eq ::Data.define(:x, :y).new(1, 2).to_hexdigest_source
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

    it "同じメンバーを持つStructとは異なるダイジェストになる（型で区別される）" do
      expect(instance.to_hexdigest).not_to eq stub_const("Coord2", ::Struct.new(:x, :y)).new(1, "a").to_hexdigest
    end

    it "同じ内容のハッシュとは異なるダイジェストになる（型で区別される）" do
      expect(instance.to_hexdigest).not_to eq({ x: 1, y: "a" }.to_hexdigest)
    end
  end
end
