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
  end
end
