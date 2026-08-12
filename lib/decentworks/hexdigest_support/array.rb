# frozen_string_literal: true

class Array
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 要素は#to_hexdigest_sourceではなく#to_hexdigest_inputで文字列化する。
  #       値だけでは型が落ちるため、[:a] と ["a"]、[1] と ["1"] が同じ値になってしまう
  #
  # MEMO: #to_hexdigest_inputは値を#inspectで引用・エスケープ済みのため、ここでの
  #       追加の引用は不要。引用がないと、要素の文字列表現に区切り文字（,）が含まれる
  #       場合に内容が異なる配列同士が同じ文字列になってしまう
  #       （例: ["a,b","c"] と ["a","b,c"] が衝突する）
  def to_hexdigest_source
    return "[]" if empty?

    map(&:to_hexdigest_input)
      .sort
      .join(",")
      .prepend("[")
      .concat("]")
  end
end
