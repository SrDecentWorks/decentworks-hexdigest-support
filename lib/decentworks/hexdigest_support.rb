# frozen_string_literal: true

require_relative "hexdigest_support/version"
require_relative "hexdigest_support/configuration"
require_relative "hexdigest_support/object"
require_relative "hexdigest_support/nil_class"
require_relative "hexdigest_support/array"
require_relative "hexdigest_support/hash"
require_relative "hexdigest_support/range"
require_relative "hexdigest_support/struct"
require_relative "hexdigest_support/data"
require_relative "hexdigest_support/time"

# MEMO: Set / Date / DateTimeへの拡張は、それらが読み込まれている場合にだけ適用する。
#       本gemより後にrequireした場合は.apply!を明示的に呼ぶ必要がある
require_relative "hexdigest_support/optional_extensions"
