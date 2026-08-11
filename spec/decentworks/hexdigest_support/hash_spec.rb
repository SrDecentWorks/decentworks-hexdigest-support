# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Hash do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "空ハッシュの場合" do
      let(:instance) { {} }

      it { is_expected.to eq "{}" }
    end

    context "要素がある場合" do
      let(:instance) { { b: 2, a: 1, c: 3 } }

      it { is_expected.to eq '{a: "1", b: "2", c: "3"}' }
    end
  end
end
