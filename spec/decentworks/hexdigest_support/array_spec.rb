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

      it { is_expected.to eq "[1,2,3]" }
    end

    context "配列の場合（並び違い）" do
      let(:instance) { [3, 2, 1] }

      it { is_expected.to eq "[1,2,3]" }
    end
  end
end
