# frozen_string_literal: true

class Range
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 端点は文字列化せずそのままHashに渡す。先に#to_hexdigest_sourceで
  #       文字列にしてしまうと型が落ちて、(1..3) と ("1".."3") が同じ値になってしまう
  #
  # MEMO: 端点の取得に#first/#lastではなく#begin/#endを使う。#firstは始端のない範囲で、
  #       #lastは終端のない範囲でRangeErrorになるため、(1..) や (..3) を扱えない。
  #       #begin/#endは端点がなければnilを返すので、端点なしをNilClassとして表現できる
  #
  # MEMO: 有界な範囲では#first/#lastと#begin/#endの戻り値は一致し、キー名もfirst/lastの
  #       ままとしているため、この実装で既存のダイジェストは変わらない
  def to_hexdigest_source
    {
      first:       self.begin,
      last:        self.end,
      exclude_end: exclude_end?
    }.to_hexdigest_source
  end
end
