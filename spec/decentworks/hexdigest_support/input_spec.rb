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
        expect(subject).to eq '":a"'
      end
    end

    # MEMO: #inspectは非ASCII文字をEncoding.default_external次第でエスケープするため、
    #       同じ値でもロケールによってダイジェストが変わってしまう。制御文字は
    #       ロケールに関係なく#inspectがエスケープするので、#inspectを使っていない
    #       ことをロケール非依存に固定できる
    context "制御文字を含む場合" do
      let(:value) { "a\nb" }

      it "#inspectのようにエスケープせず、そのまま含める" do
        expect(subject).to eq %("a\nb")
      end
    end

    context "非ASCII文字を含む場合" do
      let(:value) { "あ" }

      it "エスケープせず、そのまま含める" do
        expect(subject).to eq '"あ"'
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

    # MEMO: 検査は「既定のObject#to_sへ落ちていないか」を見るためのもので、値そのものが
    #       文字列であるStringとSymbolは対象外。ログの1行や#inspectの結果を保持した値が
    #       弾かれないことを固定しておく
    context "オブジェクトIDの表記で始まる文字列の場合" do
      let(:value) { "#<User:0x00007f9e0c0d1234>" }

      it "Stringなら例外にならない" do
        expect { described_class.validate_source!(value, value) }.not_to raise_error
      end

      it "Symbolなら例外にならない" do
        expect { described_class.validate_source!(value, value.to_sym) }.not_to raise_error
      end

      it "String以外が同じ値を返した場合は例外になる" do
        expect { described_class.validate_source!(value, ::Object.new) }
          .to raise_error described_class::NonDeterministicSourceError
      end
    end
  end

  describe ".detect_circular_reference" do
    subject { described_class.detect_circular_reference(object) { "done" } }

    let(:object) { [1] }

    context "経路に現れていないオブジェクトの場合" do
      it "ブロックの戻り値をそのまま返す" do
        expect(subject).to eq "done"
      end
    end

    context "組み立てが終わったオブジェクトの場合" do
      before { described_class.detect_circular_reference(object) { nil } }

      it "記録が残らないため例外にならない" do
        expect(subject).to eq "done"
      end
    end

    context "ブロックが例外を投げた場合" do
      before do
        described_class.detect_circular_reference(object) { raise "boom" }
      rescue ::RuntimeError
        nil
      end

      it "記録が残らないため例外にならない" do
        expect(subject).to eq "done"
      end
    end

    context "組み立て中のオブジェクトが再び現れた場合" do
      let(:nested) { -> { described_class.detect_circular_reference(object) { nil } } }

      it "例外になる" do
        expect { described_class.detect_circular_reference(object, &nested) }
          .to raise_error described_class::CircularReferenceError, /自身を含んでいる/
      end
    end
  end

  describe "#to_hexdigest_input経由の循環参照の検出" do
    # MEMO: 検出しないと再帰が終わらずSystemStackErrorになる。SystemStackErrorは
    #       StandardErrorを継承しないため、呼び出し側のrescueをすり抜けてしまう
    it "自身を含む配列は例外になる" do
      values = [1]
      values << values

      expect { values.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    it "自身を含むハッシュは例外になる" do
      attributes = { a: 1 }
      attributes[:self] = attributes

      expect { attributes.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    it "参照しあう配列は例外になる" do
      parent = []
      child  = [parent]
      parent << child

      expect { parent.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    it "ハッシュのキーが自身の場合も例外になる" do
      attributes = {}
      attributes[attributes] = 1

      expect { attributes.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    it "Structのメンバーが自身の場合も例外になる" do
      node = ::Struct.new(:parent).new(nil)
      node.parent = node

      expect { node.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    # MEMO: 独自クラス同士の循環では、要素を辿るハッシュが毎回新しく作られるため
    #       構造だけを見ても検出できない。すべての値が#to_hexdigest_inputを通ることで
    #       検出できている
    it "独自クラス同士が参照しあう場合も例外になる" do
      klass  = ::Class.new { attr_accessor :other; def to_hexdigest_source = { other: }.to_hexdigest_source }
      first  = klass.new
      second = klass.new
      first.other  = second
      second.other = first

      expect { first.to_hexdigest }.to raise_error described_class::CircularReferenceError
    end

    # MEMO: SystemStackErrorのままだと、呼び出し側がrescueで受けても素通りしてしまう
    it "StandardErrorとしてrescueできる" do
      values = []
      values << values

      expect { values.to_hexdigest }.to raise_error ::StandardError
    end

    context "循環ではない場合" do
      it "同じオブジェクトが兄弟として複数回現れても例外にならない" do
        value = [1]

        expect([value, value].to_hexdigest_source).to eq [[1], [1]].to_hexdigest_source
      end

      it "例外の後も通常の値のダイジェストを求められる" do
        values = []
        values << values
        begin
          values.to_hexdigest
        rescue described_class::CircularReferenceError
          nil
        end

        expect([1, 2].to_hexdigest).to eq [2, 1].to_hexdigest
      end
    end
  end

  describe "#to_hexdigest_input経由の検査" do
    it "#to_sも#to_hexdigest_sourceも実装していないオブジェクトは例外になる" do
      expect { ::Object.new.to_hexdigest }
        .to raise_error described_class::NonDeterministicSourceError
    end

    it "Procのようにオブジェクトを独自の#to_sへ含める型も例外になる" do
      expect { proc { }.to_hexdigest }.to raise_error described_class::NonDeterministicSourceError
    end

    it "無名クラス自身を値にした場合も例外になる" do
      expect { ::Class.new.to_hexdigest }.to raise_error described_class::NonDeterministicSourceError
    end

    it "オブジェクトIDの表記で始まる文字列でもダイジェストを求められる" do
      expect { "#<User:0x00007f9e0c0d1234>".to_hexdigest }.not_to raise_error
    end

    it "構造の中のオブジェクトIDの表記で始まる文字列でもダイジェストを求められる" do
      expect { { message: "#<User:0x00007f9e0c0d1234> が見つかりません" }.to_hexdigest }.not_to raise_error
    end

    it "オブジェクトIDの表記で始まる文字列は、値が同じなら同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      # 意図的に同じ表記の別インスタンスの文字列同士を比較している。
      # オブジェクトIDの表記に見える文字列でも、内容（値）が同じなら
      # 同じダイジェストになること（オブジェクトIDではなく値で決まること）を確認するテストのため。
      expect("#<User:0x1>".to_hexdigest).to eq "#<User:0x1>".to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
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
