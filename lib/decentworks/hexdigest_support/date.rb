# frozen_string_literal: true

require "date"

require_relative "time_like"

class Date
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: 日付は時刻もタイムゾーンも持たないため、Timeのような正規化は不要。
  #       ISO 8601の日付として組み立てる
  #
  # MEMO: 型は"Date"のまま（TimeLikeをincludeしない）。DateはTimeと違って
  #       ある一瞬ではなく1日を指すため、同一視すると意味が壊れる
  def to_hexdigest_source = strftime("%Y-%m-%d")
end

class DateTime
  # MEMO: DateTimeはDateのサブクラスだが、指すものはある一瞬なのでTimeLikeへ寄せる。
  #       includeしないとDate#to_hexdigest_sourceを継承して時刻が丸ごと落ちてしまう
  #
  # MEMO: includeはDateより手前に入るため、Date#to_hexdigest_sourceより優先される
  include ::Decentworks::HexdigestSupport::TimeLike
end
