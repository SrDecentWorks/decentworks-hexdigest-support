# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport do
  after { described_class.reset_configuration! }

  describe ".configure" do
    it "ソルトを設定できる" do
      described_class.configure { |config| config.salt = "pepper" }

      expect(described_class.salt).to eq "pepper"
    end

    it "設定を跨いで同じ設定オブジェクトを返す" do
      expect(described_class.configuration).to equal described_class.configuration
    end
  end

  describe ".salt" do
    context "未設定の場合" do
      it { expect(described_class.salt).to eq "" }
    end

    context "nilを設定した場合" do
      before { described_class.configure { |config| config.salt = nil } }

      it "空文字として扱う" do
        expect(described_class.salt).to eq ""
      end
    end
  end

  describe ".reset_configuration!" do
    before { described_class.configure { |config| config.salt = "pepper" } }

    it "設定を初期状態に戻す" do
      described_class.reset_configuration!

      expect(described_class.salt).to eq ""
    end
  end
end
