# frozen_string_literal: true

require "digest"

class Object
  # MD5でハッシュ値化（16進数）
  def to_md5_hexdigest = ::Digest::MD5.hexdigest(to_hexdigest_source)

  # RMD160でハッシュ値化（16進数）
  def to_rmd160_hexdigest = ::Digest::RMD160.hexdigest(to_hexdigest_source)

  # SHA1でハッシュ値化（16進数）
  def to_sha1_hexdigest = ::Digest::SHA1.hexdigest(to_hexdigest_source)

  # SHA256でハッシュ値化（16進数）
  def to_sha256_hexdigest = ::Digest::SHA256.hexdigest(to_hexdigest_source)

  # SHA384でハッシュ値化（16進数）
  def to_sha384_hexdigest = ::Digest::SHA384.hexdigest(to_hexdigest_source)

  # SHA512でハッシュ値化（16進数）
  def to_sha512_hexdigest = ::Digest::SHA512.hexdigest(to_hexdigest_source)

  # MD系のデフォルトアルゴリズム
  alias_method :to_md_hexdigest, :to_md5_hexdigest

  # RMD系のデフォルトアルゴリズム
  alias_method :to_rmd_hexdigest, :to_rmd160_hexdigest

  # SHA系のデフォルトアルゴリズム
  alias_method :to_sha_hexdigest, :to_sha256_hexdigest

  # ハッシュ値化のデフォルトアルゴリズム
  alias_method :to_hexdigest, :to_sha_hexdigest

  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: #to_s以外で値を指定する場合は、本メソッドをオーバーライドすること
  def to_hexdigest_source = to_s
end
