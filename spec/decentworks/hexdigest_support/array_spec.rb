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
      let(:first) { %w[a,b c] }
      let(:second) { %w[a b,c] }

      it "内容が異なる配列は異なる値になる（衝突しない）" do
        expect(first.to_hexdigest_source).not_to eq second.to_hexdigest_source
      end
    end

    context "入れ子の配列の場合" do
      let(:instance) { [[1, 2], 3] }

      it { is_expected.to eq %q([Array:"[Integer:\"1\",Integer:\"2\"]",Integer:"3"]) }

      it "入れ子と平坦な配列は異なる値になる（衝突しない）" do
        expect([%w[a], %w[b]].to_hexdigest_source).not_to eq %w[a b].to_hexdigest_source
      end
    end

    context "ハッシュを要素に持つ場合" do
      let(:instance) { [{ a: 1 }] }

      it { is_expected.to eq %q([Hash:"{Symbol:\"a\"=>Integer:\"1\"}"]) }
    end

    context "同じ要素が重複する場合" do
      it "重複を落とさない（[1,1] と [1] は異なる値になる）" do
        expect([1, 1].to_hexdigest_source).not_to eq [1].to_hexdigest_source
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

  describe "#to_hexdigest" do
    it "並び順が違っても同じダイジェストになる" do
      expect([1, 2, 3].to_hexdigest).to eq [3, 2, 1].to_hexdigest
    end

    it "空配列と空ハッシュは異なるダイジェストになる" do
      expect([].to_hexdigest).not_to eq({}.to_hexdigest)
    end

    it "同じ内容なら別インスタンスでも同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect([1, [2, { a: 3 }]].to_hexdigest).to eq [1, [2, { a: 3 }]].to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end
  end
end
