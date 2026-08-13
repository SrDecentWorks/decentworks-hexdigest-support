# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Object do
  describe "#to_md5_hexdigest" do
    subject { instance.to_md5_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::MD5.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_rmd160_hexdigest" do
    subject { instance.to_rmd160_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::RMD160.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_sha1_hexdigest" do
    subject { instance.to_sha1_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA1.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_sha256_hexdigest" do
    subject { instance.to_sha256_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA256.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_sha384_hexdigest" do
    subject { instance.to_sha384_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA384.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_sha512_hexdigest" do
    subject { instance.to_sha512_hexdigest }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq ::Digest::SHA512.hexdigest(instance.to_salted_hexdigest_input) }
  end

  describe "#to_hexdigest" do
    context "値の文字列表現が同じで型が異なる場合" do
      it "IntegerとStringは異なるダイジェストになる" do
        expect(1.to_hexdigest).not_to eq "1".to_hexdigest
      end

      it "SymbolとStringは異なるダイジェストになる" do
        expect(:a.to_hexdigest).not_to eq "a".to_hexdigest
      end
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq instance }
  end

  describe "#to_hexdigest_type" do
    subject { instance.to_hexdigest_type }

    context "名前を持つクラスの場合" do
      let(:instance) { "a" }

      it { is_expected.to eq "String" }
    end

    context "無名クラスの場合" do
      let(:instance) { Class.new.new }

      it "名前を持つ祖先クラスまで遡る" do
        expect(instance.to_hexdigest_type).to eq "Object"
      end
    end

    context "無名クラスがモジュールをincludeしている場合" do
      let(:instance) { Class.new { include ::Comparable }.new }

      it "includeしたモジュール名ではなく祖先クラス名になる" do
        expect(instance.to_hexdigest_type).to eq "Object"
      end
    end
  end

  describe "#to_hexdigest_input" do
    subject { instance.to_hexdigest_input }

    context "文字列の場合" do
      let(:instance) { "a" }

      it { is_expected.to eq 'String:"a"' }
    end

    context "数値の場合" do
      let(:instance) { 1 }

      it { is_expected.to eq 'Integer:"1"' }
    end

    context "シンボルの場合" do
      let(:instance) { :a }

      it { is_expected.to eq 'Symbol:"a"' }
    end

    context "値に区切り文字（:）が含まれる場合" do
      let(:instance) { ":a" }

      it "値が引用されるため型名との境界が曖昧にならない" do
        expect(instance.to_hexdigest_input).to eq 'String:":a"'
      end
    end
  end

  describe "#to_salted_hexdigest_input" do
    subject { instance.to_salted_hexdigest_input }

    after { ::Decentworks::HexdigestSupport.reset_configuration! }

    context "ソルトが未設定の場合" do
      let(:instance) { "a" }

      it { is_expected.to eq instance.to_hexdigest_input }
    end

    context "ソルトが設定されている場合" do
      let(:instance) { "a" }

      before { ::Decentworks::HexdigestSupport.configure { |config| config.salt = "pepper" } }

      it { is_expected.to eq "pepper#{instance.to_hexdigest_input}" }
    end

    context "配列の場合" do
      let(:instance) { %w[a b] }

      before { ::Decentworks::HexdigestSupport.configure { |config| config.salt = "pepper" } }

      it "ソルトは要素ごとではなく先頭に一度だけ付与される" do
        expect(instance.to_salted_hexdigest_input.scan("pepper").size).to eq 1
      end
    end
  end

  describe "ソルトとダイジェスト" do
    after { ::Decentworks::HexdigestSupport.reset_configuration! }

    it "ソルトを変えるとダイジェストが変わる" do
      ::Decentworks::HexdigestSupport.configure { |config| config.salt = "pepper" }
      salted = "a".to_hexdigest

      ::Decentworks::HexdigestSupport.configure { |config| config.salt = "sugar" }

      expect("a".to_hexdigest).not_to eq salted
    end

    it "同じソルトなら同じダイジェストになる" do
      ::Decentworks::HexdigestSupport.configure { |config| config.salt = "pepper" }

      expect("a".to_hexdigest).to eq "a".to_hexdigest
    end
  end
end
