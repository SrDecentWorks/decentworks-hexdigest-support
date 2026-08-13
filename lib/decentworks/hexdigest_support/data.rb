# frozen_string_literal: true

class Data
  # ハッシュ値を求めるためのオリジナルの値
  #
  # MEMO: DataはStructのサブクラスではないため、Struct側の実装は継承されない。
  #       メンバー名を落とさない理由はStructと同じ
  #
  # MEMO: 無名のDataが"Data"へ丸まる点もStructと同じ
  def to_hexdigest_source = to_h.to_hexdigest_source
end
