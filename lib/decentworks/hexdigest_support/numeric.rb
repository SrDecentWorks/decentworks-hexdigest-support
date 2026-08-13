# frozen_string_literal: true

require_relative "numeric_like"

# MEMO: Numericへ直接includeせず、具体的なクラスごとにincludeする。Numericのサブクラスには
#       有理数へ変換できないものがあり（Complexは実部と虚部の組なので、虚部があると
#       #to_rがRangeErrorになる）、一律に寄せると壊れるため
#
# MEMO: Complexは対象外とする。Complex(1, 0) == 1 が真なので厳密には型で割れるが、
#       アプリケーションで虚数を扱う場面はまれであり、対応のコストに見合わない
class Integer
  include ::Decentworks::HexdigestSupport::NumericLike
end

class Rational
  include ::Decentworks::HexdigestSupport::NumericLike
end

class Float
  include ::Decentworks::HexdigestSupport::NumericLike

  # 正規化に用いる有理数
  #
  # MEMO: #to_rではなく#to_sを経由して十進として読む。#to_rは2進の厳密値を返すため、
  #       0.1が1/10ではなく3602879701896397/36028797018963968になり、
  #       BigDecimal("0.1")やRational(1, 10)と別のダイジェストになってしまう
  #
  # MEMO: Float#to_sは元の値へ復元できる最短の十進表記を返す。よって#==が真になる
  #       Float同士は必ず同じ有理数になり、異なるFloatが同じ有理数になることもない
  def to_hexdigest_rational = ::Kernel.Rational(to_s)
end
