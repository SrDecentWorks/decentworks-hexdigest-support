# frozen_string_literal: true

require_relative "array"

class Set
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 要素の文字列化はArrayへ委譲する。Array#to_hexdigest_sourceが要素を
  #       ソートするため、挿入順が違っても同じ値になる
  #
  # MEMO: 型は#to_hexdigest_inputが付与するため、同じ要素を持つArrayとは
  #       別のダイジェストになる
  def to_hexdigest_source = to_a.to_hexdigest_source
end
