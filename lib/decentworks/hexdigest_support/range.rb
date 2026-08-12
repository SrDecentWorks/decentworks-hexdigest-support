# frozen_string_literal: true

class Range
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 端点は文字列化せずそのままHashに渡す。先に#to_hexdigest_sourceで
  #       文字列にしてしまうと型が落ちて、(1..3) と ("1".."3") が同じ値になってしまう
  def to_hexdigest_source
    {
      first:,
      last:,
      exclude_end: exclude_end?
    }.to_hexdigest_source
  end
end
