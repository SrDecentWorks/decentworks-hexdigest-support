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

      it { is_expected.to eq '{"a"=>"1","b"=>"2","c"=>"3"}' }
    end

    context "キーがオブジェクトの場合（キーも正規化されること）" do
      let(:key_class) do
        Class.new do
          def initialize(label) = @label = label
          def to_s = @label
        end
      end
      let(:instance) { { key_class.new("k") => "v" } }

      it "毎回同じ値になる（キーのオブジェクトIDに依存しない）" do
        expect(instance.to_hexdigest_source).to eq instance.to_hexdigest_source
      end

      it { is_expected.to eq '{"k"=>"v"}' }
    end

    context "キーの型が混在する場合（比較不能で例外にならないこと）" do
      let(:instance) { { "a" => 1, 2 => "x", [3] => "y" } }

      it "例外が発生しない" do
        expect { instance.to_hexdigest_source }.not_to raise_error
      end

      it { is_expected.to eq %q({"2"=>"x","[\"3\"]"=>"y","a"=>"1"}) }
    end
  end
end
