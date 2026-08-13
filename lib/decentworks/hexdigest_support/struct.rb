# frozen_string_literal: true

require_relative "hash"

class Struct
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 値の配列（#to_a）ではなく#to_hに委譲する。メンバー名が落ちると、
  #       メンバー構成の異なるStruct同士が同じ値になってしまう
  #       （例: Struct.new(:a, :b)の(1, 2) と Struct.new(:x, :y)の(1, 2) が衝突する）
  #
  # MEMO: 定数へ代入していない無名のStructは#to_hexdigest_typeが"Struct"へ丸まるため、
  #       メンバー名と値が同じなら別々に生成したStruct同士でも同じダイジェストになる。
  #       型で区別したい場合は定数へ代入して名前を与えること
  def to_hexdigest_source = to_h.to_hexdigest_source
end
