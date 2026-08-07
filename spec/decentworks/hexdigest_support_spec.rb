# frozen_string_literal: true

require "digest"

require "active_support"
require "active_support/core_ext"

require "spec_helper"
require "decentworks/hexdigest_support"

RSpec.describe ::Decentworks::HexdigestSupport do
  using ::Decentworks::HexdigestSupport

  describe "#to_md5_hexdigest" do
    subject { instance.to_md5_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::MD5.hexdigest(instance) }
  end

  describe "#to_rmd160_hexdigest" do
    subject { instance.to_rmd160_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::RMD160.hexdigest(instance) }
  end

  describe "#to_sha1_hexdigest" do
    subject { instance.to_sha1_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA1.hexdigest(instance) }
  end

  describe "#to_sha256_hexdigest" do
    subject { instance.to_sha256_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA256.hexdigest(instance) }
  end

  describe "#to_sha384_hexdigest" do
    subject { instance.to_sha384_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA384.hexdigest(instance) }
  end

  describe "#to_sha512_hexdigest" do
    subject { instance.to_sha512_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA512.hexdigest(instance) }
  end

  describe "#__to_hexdigest_source" do
    subject { instance.__to_hexdigest_source }

    context "Object" do
      let(:instance) { ::Faker::Lorem.word }

      it { is_expected.to eq instance }
    end

    context "Array" do
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

    context "Hash" do
      context "空ハッシュの場合" do
        let(:instance) { {} }

        it { is_expected.to eq "{}" }
      end

      context "要素がある場合" do
        let(:instance) { {b: 2, a: 1, c: 3} }

        it { is_expected.to eq '{a: "1", b: "2", c: "3"}' }
      end
    end

    context "Range" do
      let(:first) { ::Faker::Lorem.word }
      let(:last) { ::Faker::Lorem.word }

      context "終端を含む" do
        let(:instance) { first..last }

        it { is_expected.to eq({first:, last:, exclude_end: false}.__to_hexdigest_source) }
      end

      context "終端を含まない" do
        let(:instance) { first...last }

        it { is_expected.to eq({first:, last:, exclude_end: true}.__to_hexdigest_source) }
      end
    end
  end
end
