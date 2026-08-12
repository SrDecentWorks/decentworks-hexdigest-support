# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Array do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "空配列の場合" do
      let(:instance) { [] }

      it { is_expected.to eq "[]" }
    end

    context "配列の場合" do
      let(:instance) { [1, 2, 3] }

      it { is_expected.to eq '[Integer:"1",Integer:"2",Integer:"3"]' }
    end

    context "配列の場合（並び違い）" do
      let(:instance) { [3, 2, 1] }

      it { is_expected.to eq '[Integer:"1",Integer:"2",Integer:"3"]' }
    end

    context "要素の文字列表現に区切り文字（,）が含まれる場合" do
      let(:first) { ["a,b", "c"] }
      let(:second) { ["a", "b,c"] }

      it "内容が異なる配列は異なる値になる（衝突しない）" do
        expect(first.to_hexdigest_source).not_to eq second.to_hexdigest_source
      end
    end

    context "要素の型だけが異なる場合" do
      it "Symbolの配列と文字列の配列は異なる値になる" do
        expect([:a].to_hexdigest_source).not_to eq ["a"].to_hexdigest_source
      end

      it "数値の配列と文字列の配列は異なる値になる" do
        expect([1].to_hexdigest_source).not_to eq ["1"].to_hexdigest_source
      end
    end
  end
end
