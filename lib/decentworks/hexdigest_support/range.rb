# frozen_string_literal: true

class Range
  # ハッシュ値を求めるためのオリジナルの値
  def to_hexdigest_source
    {
      first: first.to_hexdigest_source,
      last: last.to_hexdigest_source,
      exclude_end: exclude_end?
    }.to_hexdigest_source
  end
end
