# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Set do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "空のSetの場合" do
      let(:instance) { ::Set.new }

      it { is_expected.to eq "[]" }
    end

    context "要素がある場合" do
      let(:instance) { ::Set[1, "a", :b] }

      it { is_expected.to eq '[Integer:"1",String:"a",Symbol:"b"]' }
    end

    context "挿入順が異なる場合" do
      it "同じ値になる" do
        expect(::Set[1, 2, 3].to_hexdigest_source).to eq ::Set[3, 1, 2].to_hexdigest_source
      end
    end

    context "要素の型だけが異なる場合" do
      it "異なる値になる" do
        expect(::Set[1].to_hexdigest_source).not_to eq ::Set["1"].to_hexdigest_source
      end
    end

    context "入れ子のSetの場合" do
      let(:instance) { ::Set[::Set[1]] }

      it { is_expected.to eq %q([Set:"[Integer:\"1\"]"]) }
    end
  end

  describe "#to_hexdigest" do
    it "同じ要素なら同じダイジェストになる" do
      expect(::Set[1, 2].to_hexdigest).to eq ::Set[2, 1].to_hexdigest
    end

    it "同じ要素の配列とは異なるダイジェストになる（型で区別される）" do
      expect(::Set[1, 2].to_hexdigest).not_to eq [1, 2].to_hexdigest
    end

    it "要素が異なれば異なるダイジェストになる" do
      expect(::Set[1, 2].to_hexdigest).not_to eq ::Set[1, 2, 3].to_hexdigest
    end
  end
end
