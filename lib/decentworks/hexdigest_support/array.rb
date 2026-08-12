# frozen_string_literal: true

class Array
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 要素は#inspectで引用・エスケープしてから結合する。引用しないと、
  #       要素の文字列表現に区切り文字（,）が含まれる場合に、内容が異なる配列同士が
  #       同じ文字列になってしまう（例: ["a,b","c"] と ["a","b,c"] が衝突する）
  def to_hexdigest_source
    return "[]" if empty?

    map(&:to_hexdigest_source)
      .sort
      .map(&:inspect)
      .join(",")
      .prepend("[")
      .concat("]")
  end
end
