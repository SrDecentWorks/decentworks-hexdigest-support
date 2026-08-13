# frozen_string_literal: true

require "bigdecimal"

require_relative "numeric_like"

# MEMO: bigdecimalは条件付きではなく無条件に読み込む。Railsのdecimalカラムの値は常に
#       BigDecimalであり、対応の有無が環境によって変わるとダイジェストが割れてしまうため
#
# MEMO: BigDecimal#to_rは内部表現どおりの厳密な有理数を返すため、Floatのような
#       十進への読み替えは不要
class BigDecimal
  include ::Decentworks::HexdigestSupport::NumericLike
end
