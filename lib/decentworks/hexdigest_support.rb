# frozen_string_literal: true

require "digest"

module Decentworks
  module HexdigestSupport
    refine ::Object do
      # MD5でハッシュ値化（16進数）
      def to_md5_hexdigest = ::Digest::MD5.hexdigest(__to_hexdigest_source)

      # RMD160でハッシュ値化（16進数）
      def to_rmd160_hexdigest = ::Digest::RMD160.hexdigest(__to_hexdigest_source)

      # SHA1でハッシュ値化（16進数）
      def to_sha1_hexdigest = ::Digest::SHA1.hexdigest(__to_hexdigest_source)

      # SHA256でハッシュ値化（16進数）
      def to_sha256_hexdigest = ::Digest::SHA256.hexdigest(__to_hexdigest_source)

      # SHA384でハッシュ値化（16進数）
      def to_sha384_hexdigest = ::Digest::SHA384.hexdigest(__to_hexdigest_source)

      # SHA512でハッシュ値化（16進数）
      def to_sha512_hexdigest = ::Digest::SHA512.hexdigest(__to_hexdigest_source)

      # MD系のデフォルトアルゴリズム
      alias_method :to_md_hexdigest, :to_md5_hexdigest

      # RMD系のデフォルトアルゴリズム
      alias_method :to_rmd_hexdigest, :to_rmd160_hexdigest

      # SHA系のデフォルトアルゴリズム
      alias_method :to_sha_hexdigest, :to_sha256_hexdigest

      # ハッシュ値化のデフォルトアルゴリズム
      alias_method :to_hexdigest, :to_sha256_hexdigest

      # ハッシュ値を求めるためのオリジナルの値
      #
      # MEMO: #to_s以外で値を指定する場合は、本メソッドをオーバーライドすること
      def __to_hexdigest_source = to_s
    end

    refine ::Array do
      # ハッシュ値を求めるためのオリジナルの値
      def __to_hexdigest_source
        return "[]" if empty?

        map(&:__to_hexdigest_source)
          .sort
          .join(",")
          .prepend("[")
          .concat("]")
      end
    end

    refine ::Hash do
      # ハッシュ値を求めるためのオリジナルの値
      def __to_hexdigest_source
        return "{}" if empty?

        transform_values { it.__to_hexdigest_source }
          .sort
          .to_h
          .to_s
      end
    end

    refine ::Range do
      # ハッシュ値を求めるためのオリジナルの値
      def __to_hexdigest_source
        {
          first: first.__to_hexdigest_source,
          last: last.__to_hexdigest_source,
          exclude_end: exclude_end?
        }.__to_hexdigest_source
      end
    end
  end
end
