# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Set do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "空のSetの場合" do
      let(:instance) { described_class.new }

      it { is_expected.to eq "[]" }
    end

    context "要素がある場合" do
      let(:instance) { described_class[1, "a", :b] }

      it { is_expected.to eq '[Integer:"1",String:"a",Symbol:"b"]' }
    end

    context "挿入順が異なる場合" do
      let(:instance) { described_class[1, 2, 3] }

      it "同じ値になる" do
        is_expected.to eq described_class[3, 1, 2].to_hexdigest_source
      end
    end

    context "同じ要素を重複して渡した場合" do
      let(:instance) { described_class[1, 1] }

      # MEMO: 重複を落とさないArray（array_spec参照）との差を明示する
      it "重複は落ちる" do
        is_expected.to eq described_class[1].to_hexdigest_source
      end
    end

    context "要素の型だけが異なる場合" do
      let(:instance) { described_class[1] }

      it "異なる値になる" do
        is_expected.not_to eq described_class["1"].to_hexdigest_source
      end
    end

    context "nilを含む場合" do
      let(:instance) { described_class[nil, 1] }

      it { is_expected.to eq '[Integer:"1",NilClass:"nil"]' }
    end

    context "入れ子のSetの場合" do
      let(:instance) { described_class[described_class[1]] }

      it { is_expected.to eq %q([Set:"[Integer:\"1\"]"]) }
    end
  end

  describe "#to_hexdigest" do
    it "同じ要素なら同じダイジェストになる" do
      expect(described_class[1, 2].to_hexdigest).to eq described_class[2, 1].to_hexdigest
    end

    it "同じ要素の配列とは異なるダイジェストになる（型で区別される）" do
      expect(described_class[1, 2].to_hexdigest).not_to eq [1, 2].to_hexdigest
    end

    it "要素が異なれば異なるダイジェストになる" do
      expect(described_class[1, 2].to_hexdigest).not_to eq described_class[1, 2, 3].to_hexdigest
    end

    it "ハッシュの値に入れても同じ要素なら同じダイジェストになる" do
      expect({ tags: described_class[1, 2] }.to_hexdigest).to eq({ tags: described_class[2, 1] }.to_hexdigest)
    end
  end
end
