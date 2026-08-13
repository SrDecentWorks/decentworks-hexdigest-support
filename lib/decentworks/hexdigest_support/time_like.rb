# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # 時刻（ある一瞬）を表す型に共通の入力生成
    #
    # MEMO: Time / DateTime / ActiveSupport::TimeWithZoneへincludeする。Rubyの
    #       クラス階層上は無関係な3つだが、いずれも「ある一瞬」を表す点は同じなので
    #       ダイジェストの入力は共通化する
    module TimeLike
      # ハッシュ値化に用いる型の識別子
      #
      # MEMO: 実装クラス名ではなく"Time"へ正規化する。Railsでは同じ瞬間が経路によって
      #       別のクラスで現れる（Time.zone.nowやActiveRecordのdatetimeカラムは
      #       ActiveSupport::TimeWithZone、Time.nowやFile.mtimeはTime）ため、
      #       クラス名を型にすると入力経路の違いだけでダイジェストが割れてしまう
      #
      # MEMO: 「型で区別する」という本gemの原則に対する意図的な例外。Rangeの端点を
      #       first / lastというキー名に固定しているのと同じく、実装ではなく意味論に
      #       合わせた割り切り
      def to_hexdigest_type = "Time"

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
      # MEMO: Timeはナノ秒より細かい精度を持ちうるが、その桁は切り捨てる。
      #       DBのtimestamp（多くはマイクロ秒）と往復させても値が変わらない粒度に揃えるため
      #
      # MEMO: 先に#to_timeを挟むのは、DateTimeとTimeWithZoneをTimeへ寄せるため。
      #       Time#to_timeは自身を返すので、Timeにとっては実質的に無害
      def to_hexdigest_source = to_time.getutc.strftime("%Y-%m-%dT%H:%M:%S.%9NZ")
    end
  end
end
