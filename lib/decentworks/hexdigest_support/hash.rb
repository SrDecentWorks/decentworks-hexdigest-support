# frozen_string_literal: true

require_relative "object"

class Hash
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: キーも値と同じく#to_hexdigest_inputで正規化する。キーをそのまま文字列へ
  #       埋めると、#to_sを実装していないオブジェクトがキーの場合にオブジェクトIDが
  #       混入して非決定的になる。#to_hexdigest_input経由なら検出して例外になる
  #
  # MEMO: キー・値ともに#to_hexdigest_sourceではなく#to_hexdigest_inputを使う。
  #       値だけでは型が落ちるため、{ a: 1 } と { "a" => 1 }、
  #       { a: 1, "a" => 2 } と { "a" => 1, a: 2 } が同じ値になってしまう
  #
  # MEMO: Hash#to_sには頼らず自前で文字列を組み立てる。ネイティブの#inspectの出力形式は
  #       Rubyのバージョンによって変わりうる（例: Ruby 3.4以降で"=>"の前後にスペースが
  #       入るようになった）ため、バージョンが変わるとダイジェストの値も変わってしまう
  #
  # MEMO: ブロック引数をSteepの型注釈（#:）で::Objectへ明示している。RBSではHash[K, V]の
  #       K・Vに上限境界を持たせられず（組み込みクラスの型引数を後から再宣言できないため）、
  #       ブロック内で#to_hexdigest_inputを呼べる保証が型上は得られない。実体は必ず
  #       Objectのインスタンス（#to_hexdigest_inputはObjectへ定義済み）なので、
  #       ここでのみ型を絞って呼び出す
  def to_hexdigest_source
    return "{}" if empty?

    map { |key, value|
      hex_key   = key #: ::Object
      hex_value = value #: ::Object

      "#{hex_key.to_hexdigest_input}=>#{hex_value.to_hexdigest_input}"
    }
      .sort
      .join(",")
      .prepend("{")
      .concat("}")
  end
end
