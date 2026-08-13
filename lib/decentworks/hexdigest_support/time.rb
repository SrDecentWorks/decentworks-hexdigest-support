# frozen_string_literal: true

require_relative "time_like"

class Time
  # MEMO: 直接メソッドを定義せずincludeするのは、DateTime / TimeWithZoneと
  #       実装を1箇所に集めるため
  include ::Decentworks::HexdigestSupport::TimeLike
end
