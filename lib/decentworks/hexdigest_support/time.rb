# frozen_string_literal: true

class Time
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: UTCへ変換してから文字列化する。#to_sはタイムゾーンのオフセットを含むため、
  #       同じ瞬間を指す時刻でも実行環境やTime.zoneの設定次第で異なる値になってしまう
  #
  # MEMO: 精度はナノ秒で固定する。秒へ丸めると同一秒内の異なる時刻が衝突し、
  #       小数部を可変長にすると1.0秒と1秒が異なる値になってしまう
  #
  # MEMO: time（stdlib）の#iso8601ではなく#strftimeで組み立てる。ネイティブの
  #       文字列表現に依存させないという方針はHash#to_hexdigest_sourceと同じ
  #
  # MEMO: Rubyのtimeはナノ秒より細かい精度を持ちうるが、その桁は切り捨てる。
  #       DBのtimestamp（多くはマイクロ秒）と往復させても値が変わらない粒度に揃えるため
  def to_hexdigest_source = getutc.strftime("%Y-%m-%dT%H:%M:%S.%9NZ")
end
