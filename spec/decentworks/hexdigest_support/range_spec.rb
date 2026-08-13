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

    context "端点を持たない範囲の場合" do
      # MEMO: #firstは終端のみの範囲で、#lastは始端のみの範囲でRangeErrorになる。
      #       現時点では端点を持たない範囲を非対応とし、その挙動をここで固定する
      it "終端のみの範囲はRangeErrorになる" do
        expect { (..3).to_hexdigest_source }.to raise_error ::RangeError
      end

      it "始端のみの範囲はRangeErrorになる" do
        expect { (1..).to_hexdigest_source }.to raise_error ::RangeError
      end
    end
  end

  describe "#to_hexdigest" do
    it "終端を含むかどうかで異なるダイジェストになる" do
      expect((1..3).to_hexdigest).not_to eq (1...3).to_hexdigest
    end

    it "同じ内容の範囲は同じダイジェストになる" do
      expect((1..3).to_hexdigest).to eq (1..3).to_hexdigest
    end

    it "同じ端点を持つハッシュとは異なるダイジェストになる（型で区別される）" do
      expect((1..3).to_hexdigest).not_to eq({ first: 1, last: 3, exclude_end: false }.to_hexdigest)
    end
  end
end
