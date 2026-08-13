# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport do
  describe ".quote" do
    subject { described_class.quote(value) }

    context "通常の文字列の場合" do
      let(:value) { "a" }

      it { is_expected.to eq '"a"' }
    end

    context "引用符を含む場合" do
      let(:value) { %(a"b) }

      it { is_expected.to eq '"a\\"b"' }
    end

    context "バックスラッシュを含む場合" do
      let(:value) { "a\\b" }

      it { is_expected.to eq '"a\\\\b"' }
    end

    context "区切り文字（:）を含む場合" do
      let(:value) { ":a" }

      it "引用されるため型名との境界が曖昧にならない" do
        is_expected.to eq '":a"'
      end
    end

    # MEMO: #inspectは非ASCII文字をEncoding.default_external次第でエスケープするため、
    #       同じ値でもロケールによってダイジェストが変わってしまう。制御文字は
    #       ロケールに関係なく#inspectがエスケープするので、#inspectを使っていない
    #       ことをロケール非依存に固定できる
    context "制御文字を含む場合" do
      let(:value) { "a\nb" }

      it "#inspectのようにエスケープせず、そのまま含める" do
        is_expected.to eq %("a\nb")
      end
    end

    context "非ASCII文字を含む場合" do
      let(:value) { "あ" }

      it "エスケープせず、そのまま含める" do
        is_expected.to eq '"あ"'
      end
    end
  end

  describe ".validate_source!" do
    context "オブジェクトIDを含む値の場合" do
      it "例外になる" do
        expect { described_class.validate_source!("#<Object:0x00007f9e0c0d1234>", ::Object.new) }
          .to raise_error described_class::NonDeterministicSourceError, /オブジェクトIDを含む/
      end
    end

    context "決定的な値の場合" do
      it "例外にならない" do
        expect { described_class.validate_source!("a", "a") }.not_to raise_error
      end
    end

    context "オブジェクトIDに見えるだけの通常の文字列の場合" do
      it "例外にならない" do
        expect { described_class.validate_source!("Object:0x1234", "x") }.not_to raise_error
      end
    end
  end

  describe "#to_hexdigest_input経由の検査" do
    it "#to_sも#to_hexdigest_sourceも実装していないオブジェクトは例外になる" do
      expect { ::Object.new.to_hexdigest }
        .to raise_error described_class::NonDeterministicSourceError
    end

    it "Procのようにオブジェクトを独自の#to_sへ含める型も例外になる" do
      expect { proc {}.to_hexdigest }.to raise_error described_class::NonDeterministicSourceError
    end

    it "無名クラス自身を値にした場合も例外になる" do
      expect { ::Class.new.to_hexdigest }.to raise_error described_class::NonDeterministicSourceError
    end

    it "#to_sを実装していれば例外にならない" do
      klass = ::Class.new { def to_s = "k" }

      expect(klass.new.to_hexdigest_input).to eq 'Object:"k"'
    end

    context "構造の中に含まれる場合" do
      it "ハッシュの値でも例外になる" do
        expect { { a: ::Object.new }.to_hexdigest }
          .to raise_error described_class::NonDeterministicSourceError
      end

      it "配列の要素でも例外になる" do
        expect { [::Object.new].to_hexdigest }
          .to raise_error described_class::NonDeterministicSourceError
      end

      it "ハッシュのキーでも例外になる" do
        expect { { ::Object.new => 1 }.to_hexdigest }
          .to raise_error described_class::NonDeterministicSourceError
      end

      it "Structのメンバーでも例外になる" do
        expect { ::Struct.new(:x).new(::Object.new).to_hexdigest }
          .to raise_error described_class::NonDeterministicSourceError
      end

      it "Setの要素でも例外になる" do
        expect { ::Set[::Object.new].to_hexdigest }
          .to raise_error described_class::NonDeterministicSourceError
      end
    end
  end
end
