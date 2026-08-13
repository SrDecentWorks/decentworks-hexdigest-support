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

    it "設定オブジェクトをブロックへ渡す" do
      described_class.configure do |config|
        expect(config).to equal described_class.configuration
      end
    end

    it "複数回の設定は後勝ちになる" do
      described_class.configure { |config| config.salt = "pepper" }
      described_class.configure { |config| config.salt = "sugar" }

      expect(described_class.salt).to eq "sugar"
    end
  end

  describe "Configuration#salt" do
    let(:configuration) { ::Decentworks::HexdigestSupport::Configuration.new }

    it "初期値は空文字" do
      expect(configuration.salt).to eq ""
    end

    it "代入した値を保持する" do
      configuration.salt = "pepper"

      expect(configuration.salt).to eq "pepper"
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

  describe ".salt（文字列以外）" do
    before { described_class.configure { |config| config.salt = :pepper } }

    it "文字列へ変換して扱う" do
      expect(described_class.salt).to eq "pepper"
    end
  end

  describe ".reset_configuration!" do
    before { described_class.configure { |config| config.salt = "pepper" } }

    it "設定を初期状態に戻す" do
      described_class.reset_configuration!

      expect(described_class.salt).to eq ""
    end

    it "リセット後は新しい設定オブジェクトになる" do
      configuration = described_class.configuration
      described_class.reset_configuration!

      expect(described_class.configuration).not_to equal configuration
    end
  end
end
