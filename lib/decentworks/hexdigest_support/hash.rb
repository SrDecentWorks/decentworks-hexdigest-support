# frozen_string_literal: true

class Hash
  # ハッシュ値を求めるためのオリジナルの値
  def to_hexdigest_source
    return "{}" if empty?

    transform_values(&:to_hexdigest_source)
      .sort
      .to_h
      .to_s
  end
end
