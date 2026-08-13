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

  describe "ダイジェストの形式" do
    let(:instance) { ::Faker::Lorem.word }

    it "アルゴリズムごとに定められた長さの16進文字列になる" do
      expect(instance.to_md5_hexdigest).to match(/\A[0-9a-f]{32}\z/)
      expect(instance.to_rmd160_hexdigest).to match(/\A[0-9a-f]{40}\z/)
      expect(instance.to_sha1_hexdigest).to match(/\A[0-9a-f]{40}\z/)
      expect(instance.to_sha256_hexdigest).to match(/\A[0-9a-f]{64}\z/)
      expect(instance.to_sha384_hexdigest).to match(/\A[0-9a-f]{96}\z/)
      expect(instance.to_sha512_hexdigest).to match(/\A[0-9a-f]{128}\z/)
    end
  end

  describe "#to_md_hexdigest" do
    let(:instance) { ::Faker::Lorem.word }

    it "MD系のデフォルトはMD5" do
      expect(instance.to_md_hexdigest).to eq instance.to_md5_hexdigest
    end
  end

  describe "#to_rmd_hexdigest" do
    let(:instance) { ::Faker::Lorem.word }

    it "RMD系のデフォルトはRMD160" do
      expect(instance.to_rmd_hexdigest).to eq instance.to_rmd160_hexdigest
    end
  end

  describe "#to_sha_hexdigest" do
    let(:instance) { ::Faker::Lorem.word }

    it "SHA系のデフォルトはSHA256" do
      expect(instance.to_sha_hexdigest).to eq instance.to_sha256_hexdigest
    end
  end

  describe "#to_hexdigest" do
    let(:instance) { ::Faker::Lorem.word }

    it "デフォルトのアルゴリズムはSHA系のデフォルト" do
      expect(instance.to_hexdigest).to eq instance.to_sha_hexdigest
    end

    it "同じ内容の別インスタンスは同じダイジェストになる" do
      expect(+"a").not_to equal(+"a")

      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect((+"a").to_hexdigest).to eq (+"a").to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    context "値の文字列表現が同じで型が異なる場合" do
      it "IntegerとStringは異なるダイジェストになる" do
        expect(1.to_hexdigest).not_to eq "1".to_hexdigest
      end

      it "SymbolとStringは異なるダイジェストになる" do
        expect(:a.to_hexdigest).not_to eq "a".to_hexdigest
      end

      it "nilと空文字は異なるダイジェストになる" do
        expect(nil.to_hexdigest).not_to eq "".to_hexdigest
      end

      it "真偽値と文字列は異なるダイジェストになる" do
        expect(true.to_hexdigest).not_to eq "true".to_hexdigest
        expect(false.to_hexdigest).not_to eq "false".to_hexdigest
      end
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    let(:instance) { ::Faker::Lorem.word }

    it { is_expected.to eq instance }

    context "オーバーライドした場合" do
      let(:klass) do
        Class.new do
          def initialize(label) = @label = label
          def to_hexdigest_source = @label
        end
      end

      it "オーバーライド側で型を意識しなくても型が添えられる" do
        expect(klass.new("k").to_hexdigest_input).to eq 'Object:"k"'
      end

      it "同じ値なら別インスタンスでも同じダイジェストになる（オブジェクトIDに依存しない）" do
        # rubocop:disable RSpec/IdenticalEqualityAssertion
        expect(klass.new("k").to_hexdigest).to eq klass.new("k").to_hexdigest
        # rubocop:enable RSpec/IdenticalEqualityAssertion
      end

      it "値が異なれば異なるダイジェストになる" do
        expect(klass.new("k").to_hexdigest).not_to eq klass.new("other").to_hexdigest
      end
    end
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

    context "名前を持つクラスを継承した無名クラスの場合" do
      let(:instance) { Class.new(::String).new("a") }

      it "直近の名前を持つ祖先クラス名になる" do
        expect(instance.to_hexdigest_type).to eq "String"
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

      it { is_expected.to eq 'Numeric:"1"' }
    end

    context "シンボルの場合" do
      let(:instance) { :a }

      it { is_expected.to eq 'Symbol:"a"' }
    end

    context "nilの場合" do
      let(:instance) { nil }

      it { is_expected.to eq 'NilClass:"nil"' }
    end

    context "真偽値の場合" do
      let(:instance) { true }

      it { is_expected.to eq 'TrueClass:"true"' }
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

      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect("a".to_hexdigest).to eq "a".to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    it "すべてのアルゴリズムにソルトが効く" do
      unsalted = %i[
        to_md5_hexdigest
        to_rmd160_hexdigest
        to_sha1_hexdigest
        to_sha256_hexdigest
        to_sha384_hexdigest
        to_sha512_hexdigest
      ].to_h { |name| [name, "a".public_send(name)] }

      ::Decentworks::HexdigestSupport.configure { |config| config.salt = "pepper" }

      unsalted.each do |name, digest|
        expect("a".public_send(name)).not_to eq digest
      end
    end
  end
end
