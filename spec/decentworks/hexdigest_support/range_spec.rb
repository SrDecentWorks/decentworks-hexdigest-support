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
  end
end
