# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport do
  describe "エントリポイント" do
    # MEMO: gem名（decentworks-hexdigest-support）でrequireされた場合も
    #       同じ実装が読み込まれることを担保する
    it "gem名でrequireできる" do
      expect { require "decentworks-hexdigest-support" }.not_to raise_error
      expect(defined?(::Decentworks::HexdigestSupport)).to eq "constant"
    end
  end

  describe "読み込まれる拡張" do
    it "Objectにハッシュ値化のインタフェースが生える" do
      expect(::Object.new).to respond_to(
        :to_md5_hexdigest,
        :to_rmd160_hexdigest,
        :to_sha1_hexdigest,
        :to_sha256_hexdigest,
        :to_sha384_hexdigest,
        :to_sha512_hexdigest,
        :to_md_hexdigest,
        :to_rmd_hexdigest,
        :to_sha_hexdigest,
        :to_hexdigest,
        :to_salted_hexdigest_input,
        :to_hexdigest_input,
        :to_hexdigest_type,
        :to_hexdigest_source
      )
    end

    it "Array・Hash・Rangeが#to_hexdigest_sourceを独自に定義している" do
      expect(::Array.instance_method(:to_hexdigest_source).owner).to eq ::Array
      expect(::Hash.instance_method(:to_hexdigest_source).owner).to eq ::Hash
      expect(::Range.instance_method(:to_hexdigest_source).owner).to eq ::Range
    end
  end
end
