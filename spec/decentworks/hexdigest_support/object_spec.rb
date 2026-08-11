# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Object do
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

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq instance }
  end
end
