# frozen_string_literal: true

class Hash
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: キーも#to_hexdigest_inputで正規化する。キーをそのままにすると、
  #       キーが#to_s/#inspectをオーバーライドしていないオブジェクトの場合、
  #       オブジェクトIDに依存した非決定的な文字列が混入してしまう
  #
  # MEMO: キー・値ともに#to_hexdigest_sourceではなく#to_hexdigest_inputを使う。
  #       値だけでは型が落ちるため、{ a: 1 } と { "a" => 1 }、
  #       { a: 1, "a" => 2 } と { "a" => 1, a: 2 } が同じ値になってしまう
  #
  # MEMO: Hash#to_sには頼らず自前で文字列を組み立てる。ネイティブの#inspectの出力形式は
  #       Rubyのバージョンによって変わりうる（例: Ruby 3.4以降で"=>"の前後にスペースが
  #       入るようになった）ため、バージョンが変わるとダイジェストの値も変わってしまう
  def to_hexdigest_source
    return "{}" if empty?

    map { |key, value| "#{key.to_hexdigest_input}=>#{value.to_hexdigest_input}" }
      .sort
      .join(",")
      .prepend("{")
      .concat("}")
  end
end
