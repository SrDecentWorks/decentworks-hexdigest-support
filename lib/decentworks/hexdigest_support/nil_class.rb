# frozen_string_literal: true

class NilClass
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: NilClass#to_sは空文字を返すため、既定のままでは入力がNilClass:""となり、
  #       空文字を持つ他の型（String:""）とは型でしか区別できない。#inspectと同じ
  #       "nil"を明示することで、入力を目視したときに値の不在だと分かるようにする
  #
  # MEMO: true / falseはTrueClass#to_s / FalseClass#to_sが"true" / "false"を返すため、
  #       既定のObject#to_hexdigest_sourceのままで意図した入力になる
  def to_hexdigest_source = "nil"
end
