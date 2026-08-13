# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Range do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    let(:first) { ::Faker::Lorem.word }
    let(:last) { ::Faker::Lorem.word }

    context "終端を含む" do
      let(:instance) { first..last }

      it { is_expected.to eq({ first:, last:, exclude_end: false }.to_hexdigest_source) }
    end

    context "終端を含まない" do
      let(:instance) { first...last }

      it { is_expected.to eq({ first:, last:, exclude_end: true }.to_hexdigest_source) }
    end

    context "端点の型だけが異なる場合" do
      it "数値の範囲と文字列の範囲は異なる値になる" do
        expect((1..3).to_hexdigest_source).not_to eq ("1".."3").to_hexdigest_source
      end
    end

    context "始端のみの範囲の場合" do
      let(:instance) { 1.. }

      it "例外が発生しない" do
        expect { instance.to_hexdigest_source }.not_to raise_error
      end

      it "終端はnilとして扱う" do
        expect(instance.to_hexdigest_source).to eq({ first: 1, last: nil, exclude_end: false }.to_hexdigest_source)
      end
    end

    context "終端のみの範囲の場合" do
      let(:instance) { ..3 }

      it "例外が発生しない" do
        expect { instance.to_hexdigest_source }.not_to raise_error
      end

      it "始端はnilとして扱う" do
        expect(instance.to_hexdigest_source).to eq({ first: nil, last: 3, exclude_end: false }.to_hexdigest_source)
      end
    end

    context "両端を持たない範囲の場合" do
      let(:instance) { nil..nil }

      it "両端をnilとして扱う" do
        expect(instance.to_hexdigest_source).to eq({ first: nil, last: nil, exclude_end: false }.to_hexdigest_source)
      end
    end

    context "端点の有無だけが異なる場合" do
      it "始端のみの範囲と終端のみの範囲は異なる値になる" do
        expect((1..).to_hexdigest_source).not_to eq (..1).to_hexdigest_source
      end

      it "端点のない側と端点がnil以外の値である範囲は異なる値になる" do
        expect((1..).to_hexdigest_source).not_to eq (1..3).to_hexdigest_source
      end
    end
  end

  describe "#to_hexdigest" do
    it "終端を含むかどうかで異なるダイジェストになる" do
      expect((1..3).to_hexdigest).not_to eq (1...3).to_hexdigest
    end

    it "同じ内容の範囲は同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect((1..3).to_hexdigest).to eq (1..3).to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    it "端点を持たない範囲でも算出できる" do
      expect((1..).to_hexdigest).to match(/\A[0-9a-f]{64}\z/)
      expect((..3).to_hexdigest).to match(/\A[0-9a-f]{64}\z/)
    end

    it "終端の有無で異なるダイジェストになる" do
      expect((1..).to_hexdigest).not_to eq (1...).to_hexdigest
    end

    it "同じ端点を持つハッシュとは異なるダイジェストになる（型で区別される）" do
      expect((1..3).to_hexdigest).not_to eq({ first: 1, last: 3, exclude_end: false }.to_hexdigest)
    end
  end
end
