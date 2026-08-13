# frozen_string_literal: true

# MEMO: active_support/timeを読み込むのは、ActiveSupport::TimeWithZoneがActiveSupportの
#       autoload経由でしか解決できないため。内部のファイルパスに依存しない公開の入口として
#       この行を使う
require "active_support/time"

require_relative "time_like"

# MEMO: TimeWithZoneはTimeのサブクラスではない（#is_a?(Time)がtrueを返すのは
#       TimeWithZone側の偽装）ため、Timeへの拡張は届かない。明示的にincludeする
#
# MEMO: これを入れないとObject#to_hexdigest_source（＝#to_s）へフォールバックし、
#       オフセットを含む文字列が入力になる。Rails上ではTime.zone.nowやActiveRecordの
#       datetimeカラムがこのクラスなので、実質ほぼ全ての時刻が該当する
#
# MEMO: class ... endで開き直さず.includeを呼ぶのは、万一TimeWithZoneが未解決だった場合に
#       autoloadを潰して空のクラスを新規定義してしまうのを避けるため
::ActiveSupport::TimeWithZone.include(::Decentworks::HexdigestSupport::TimeLike)
