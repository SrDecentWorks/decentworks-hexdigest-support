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

      it { is_expected.to eq '{Symbol:"a"=>Integer:"1",Symbol:"b"=>Integer:"2",Symbol:"c"=>Integer:"3"}' }
    end

    context "キーがオブジェクトの場合（キーも正規化されること）" do
      let(:key_class) do
        Class.new do
          def initialize(label) = @label = label
          def to_s = @label
        end
      end
      let(:instance) { { key_class.new("k") => "v" } }
      # instance とは別インスタンスの等価なハッシュ（キーのオブジェクトも別物）
      let(:equivalent) { { key_class.new("k") => "v" } }

      it "毎回同じ値になる（キーのオブジェクトIDに依存しない）" do
        expect(instance.to_hexdigest_source).to eq equivalent.to_hexdigest_source
      end

      it { is_expected.to eq '{Object:"k"=>String:"v"}' }
    end

    context "キーの型が混在する場合（比較不能で例外にならないこと）" do
      let(:instance) { { "a" => 1, 2 => "x", [3] => "y" } }

      it "例外が発生しない" do
        expect { instance.to_hexdigest_source }.not_to raise_error
      end

      it { is_expected.to eq %q({Array:"[Integer:\"3\"]"=>String:"y",Integer:"2"=>String:"x",String:"a"=>Integer:"1"}) }
    end

    context "SymbolキーとStringキーが混在する場合" do
      let(:instance) { { a: 1, "a" => 2 } }
      let(:swapped) { { "a" => 1, a: 2 } }

      it { is_expected.to eq '{String:"a"=>Integer:"2",Symbol:"a"=>Integer:"1"}' }

      it "キーの型と値の対応が異なるハッシュとは異なる値になる（衝突しない）" do
        expect(instance.to_hexdigest_source).not_to eq swapped.to_hexdigest_source
      end
    end

    context "キーの型だけが異なる場合" do
      it "Symbolキーのハッシュと文字列キーのハッシュは異なる値になる" do
        expect({ a: 1 }.to_hexdigest_source).not_to eq({ "a" => 1 }.to_hexdigest_source)
      end

      it "数値キーのハッシュと文字列キーのハッシュは異なる値になる" do
        expect({ 1 => "v" }.to_hexdigest_source).not_to eq({ "1" => "v" }.to_hexdigest_source)
      end
    end

    context "値の型だけが異なる場合" do
      it "数値の値と文字列の値は異なる値になる" do
        expect({ a: 1 }.to_hexdigest_source).not_to eq({ a: "1" }.to_hexdigest_source)
      end
    end
  end
end
