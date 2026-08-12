# frozen_string_literal: true

require "digest"

class Object
  # MD5でハッシュ値化（16進数）
  def to_md5_hexdigest = ::Digest::MD5.hexdigest(to_hexdigest_input)

  # RMD160でハッシュ値化（16進数）
  def to_rmd160_hexdigest = ::Digest::RMD160.hexdigest(to_hexdigest_input)

  # SHA1でハッシュ値化（16進数）
  def to_sha1_hexdigest = ::Digest::SHA1.hexdigest(to_hexdigest_input)

  # SHA256でハッシュ値化（16進数）
  def to_sha256_hexdigest = ::Digest::SHA256.hexdigest(to_hexdigest_input)

  # SHA384でハッシュ値化（16進数）
  def to_sha384_hexdigest = ::Digest::SHA384.hexdigest(to_hexdigest_input)

  # SHA512でハッシュ値化（16進数）
  def to_sha512_hexdigest = ::Digest::SHA512.hexdigest(to_hexdigest_input)

  # MD系のデフォルトアルゴリズム
  alias_method :to_md_hexdigest, :to_md5_hexdigest

  # RMD系のデフォルトアルゴリズム
  alias_method :to_rmd_hexdigest, :to_rmd160_hexdigest

  # SHA系のデフォルトアルゴリズム
  alias_method :to_sha_hexdigest, :to_sha256_hexdigest

  # ハッシュ値化のデフォルトアルゴリズム
  alias_method :to_hexdigest, :to_sha_hexdigest

  # ハッシュ値化の入力（型 + 値）
  #
  # MEMO: #to_hexdigest_sourceは値を文字列へ射影するだけなので単射にならない。
  #       型を添えないと :a と "a"、1 と "1" が同じ入力になり、内容の異なる
  #       オブジェクト同士が同じダイジェストになってしまう
  #
  # MEMO: 値は#inspectで引用・エスケープする。引用しないと、値の文字列表現に
  #       区切り文字（:）が含まれる場合に型名との境界が曖昧になる
  #       （例: Foo::Barの"x" と Fooの":Bar:x" が衝突する）
  def to_hexdigest_input = "#{to_hexdigest_type}:#{to_hexdigest_source.inspect}"

  # ハッシュ値化に用いる型の識別子
  #
  # MEMO: 無名クラスは#nameがnilのため、名前を持つ祖先クラスまで遡る。
  #       #ancestorsではなく#superclassを辿るのは、無名クラスがincludeしている
  #       モジュール名を型として拾ってしまうのを避けるため
  def to_hexdigest_type
    klass = self.class
    klass = klass.superclass until klass.name
    klass.name
  end

  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: #to_s以外で値を指定する場合は、本メソッドをオーバーライドすること。
  #       型の識別は#to_hexdigest_inputが担うため、オーバーライド側で
  #       型を意識する必要はない
  def to_hexdigest_source = to_s
end
