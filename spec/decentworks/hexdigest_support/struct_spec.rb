# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Struct do
  # 名前を持つStruct（無名Structとの差を確認するため定数へ代入する）
  let(:point_class) { stub_const("Point", ::Struct.new(:x, :y)) }

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "メンバーがある場合" do
      let(:instance) { point_class.new(1, "a") }

      it { is_expected.to eq '{Symbol:"x"=>Integer:"1",Symbol:"y"=>String:"a"}' }
    end

    context "メンバーがnilの場合" do
      let(:instance) { point_class.new(1, nil) }

      it { is_expected.to eq '{Symbol:"x"=>Integer:"1",Symbol:"y"=>NilClass:"nil"}' }
    end

    context "keyword_initのStructの場合" do
      let(:instance) { ::Struct.new(:x, :y, keyword_init: true).new(x: 1, y: "a") }

      it "位置引数のStructと同じ値になる" do
        expect(instance.to_hexdigest_source).to eq ::Struct.new(:x, :y).new(1, "a").to_hexdigest_source
      end
    end

    context "メンバー名だけが異なる場合" do
      it "値が同じでも異なる値になる" do
        expect(::Struct.new(:a, :b).new(1, 2).to_hexdigest_source)
          .not_to eq ::Struct.new(:x, :y).new(1, 2).to_hexdigest_source
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
      expect(instance.to_hexdigest).not_to eq ::Struct.new(:x, :y).new(1, "a").to_hexdigest
    end

    it "無名のStruct同士はメンバー名と値が同じなら同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect(::Struct.new(:x, :y).new(1, "a").to_hexdigest)
        .to eq ::Struct.new(:x, :y).new(1, "a").to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end
  end
end
