# frozen_string_literal: true

class Hash
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: キーも#to_hexdigest_sourceで正規化する。キーをそのままにすると、
  #       キーが#to_s/#inspectをオーバーライドしていないオブジェクトの場合、
  #       オブジェクトIDに依存した非決定的な文字列が混入してしまう
  #
  # MEMO: Hash#to_sには頼らず自前で文字列を組み立てる。ネイティブの#inspectの出力形式は
  #       Rubyのバージョンによって変わりうる（例: Ruby 3.4以降で"=>"の前後にスペースが
  #       入るようになった）ため、バージョンが変わるとダイジェストの値も変わってしまう。
  #       キー・値ともに#inspectで引用・エスケープしてから結合し、区切り文字の衝突も防ぐ
  def to_hexdigest_source
    return "{}" if empty?

    map { |key, value| "#{key.to_hexdigest_source.inspect}=>#{value.to_hexdigest_source.inspect}" }
      .sort
      .join(",")
      .prepend("{")
      .concat("}")
  end
end
