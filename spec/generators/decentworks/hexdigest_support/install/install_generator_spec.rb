# frozen_string_literal: true

require "spec_helper"

RSpec.describe "decentworks:hexdigest_support:install ジェネレータ", type: :generator do
  let(:generator_root) { ::File.expand_path("../../../../../lib/generators/decentworks/hexdigest_support/install", __dir__) }
  let(:generator_path) { ::File.join(generator_root, "install_generator.rb") }
  let(:template_path) { ::File.join(generator_root, "templates", "decentworks_hexdigest_support.rb.tt") }

  it "Railsのジェネレータ探索パスに配置されている" do
    expect(::File).to exist(generator_path)
  end

  it "テンプレートが配置されている" do
    expect(::File).to exist(template_path)
  end

  describe "本体のrequireでは読み込まれないこと" do
    # MEMO: gem本体はactivesupportには依存するがrailtiesには依存しない。ジェネレータを
    #       常時requireするとrailties未導入の環境でLoadErrorになるため、
    #       遅延読み込みであることを担保する
    it { expect(defined?(::Decentworks::HexdigestSupport::Generators::InstallGenerator)).to be_nil }
  end

  describe "テンプレート" do
    subject(:rendered) { ::ERB.new(::File.read(template_path), trim_mode: "-").result(binding) }

    let(:salt_key) { "hexdigest_support_salt" }

    it "credentialsからソルトを読み出す初期化コードを生成する" do
      expect(rendered).to include(
        "::Decentworks::HexdigestSupport.configure do |config|",
        "config.salt = ::Rails.application.credentials.dig(:decentworks, :hexdigest_support_salt)"
      )
    end

    it "構文として妥当なRubyを生成する" do
      expect { ::RubyVM::InstructionSequence.compile(rendered) }.not_to raise_error
    end

    context "salt_keyを指定した場合" do
      let(:salt_key) { "custom_salt" }

      it "指定したキーを参照する" do
        expect(rendered).to include("::Rails.application.credentials.dig(:decentworks, :custom_salt)")
      end
    end
  end
end
