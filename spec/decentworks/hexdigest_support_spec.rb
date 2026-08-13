# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport do
  describe "エントリポイント" do
    # MEMO: gem名（decentworks-hexdigest-support）でrequireされた場合も
    #       同じ実装が読み込まれることを担保する
    it "gem名でrequireできる" do
      expect { require "decentworks-hexdigest-support" }.not_to raise_error

      # rubocop:disable RSpec/DescribedClass
      expect(defined?(::Decentworks::HexdigestSupport)).to eq "constant"
      # rubocop:enable RSpec/DescribedClass
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

    # MEMO: ownerを見るのは、Object#to_hexdigest_sourceへフォールバックしていないこと
    #       （＝各型の実装が読み込まれていること）を確かめるため
    it "各型が#to_hexdigest_sourceを独自に定義している" do
      classes = [::NilClass, ::Array, ::Hash, ::Range, ::Struct, ::Data, ::Set, ::Date]

      expect(classes.to_h { |klass| [klass, klass.instance_method(:to_hexdigest_source).owner] })
        .to eq classes.to_h { |klass| [klass, klass] }
    end

    # rubocop:disable RSpec/DescribedClass
    it "時刻を表す型にTimeLikeがincludeされている" do
      expect([::Time, ::DateTime, ::ActiveSupport::TimeWithZone])
        .to all(satisfy { |klass| klass.include?(::Decentworks::HexdigestSupport::TimeLike) })
    end

    it "数を表す型にNumericLikeがincludeされている" do
      expect([::Integer, ::Float, ::Rational, ::BigDecimal])
        .to all(satisfy { |klass| klass.include?(::Decentworks::HexdigestSupport::NumericLike) })
    end
    # rubocop:enable RSpec/DescribedClass
  end
end
