# frozen_string_literal: true

class Array
  # ハッシュ値を求めるためのオリジナルの値
  def to_hexdigest_source
    return "[]" if empty?

    map(&:to_hexdigest_source)
      .sort
      .join(",")
      .prepend("[")
      .concat("]")
  end
end
