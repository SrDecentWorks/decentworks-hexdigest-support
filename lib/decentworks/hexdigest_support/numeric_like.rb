# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # 数を表す型に共通の入力生成
    #
    # MEMO: Integer / Float / Rational / BigDecimalへincludeする。Rubyのクラス階層上は
    #       それぞれ別の型だが、いずれも「数」を表す点は同じなのでダイジェストの入力は
    #       共通化する
    module NumericLike
      # ハッシュ値化に用いる型の識別子
      #
      # MEMO: 実装クラス名ではなく"Numeric"へ正規化する。Railsでは同じ数が経路によって
      #       別のクラスで現れる（decimalカラムはBigDecimal、integerカラムやJSONの整数は
      #       Integer、JSONの小数はFloat）ため、クラス名を型にすると入力経路の違いだけで
      #       ダイジェストが割れてしまう
      #
      # MEMO: 「型で区別する」という本gemの原則に対する意図的な例外。TimeLikeで
      #       Time / DateTime / TimeWithZoneを"Time"へ寄せているのと同じ割り切り
      def to_hexdigest_type = "Numeric"

      # ハッシュ値を求めるためのオリジナルの値
      #
      # MEMO: 有理数へ寄せてから文字列化する。#to_sの表記はクラスごとに異なり
      #       （1.5は"1.5"、BigDecimal("1.5")は"0.15e1"）、同じ数でも別の値になってしまう
      #
      # MEMO: NaNと±Infinityは有理数にできないため#to_sをそのまま使う。FloatとBigDecimalの
      #       どちらも"NaN" / "Infinity" / "-Infinity"を返すので、型を寄せても表記は揃う
      #
      # MEMO: NaN同士は#==がfalseになるがダイジェストは一致する。値として区別する術が
      #       ない以上、インスタンスごとに異なる入力を作るよりは同一として扱う
      def to_hexdigest_source
        return to_s unless finite?

        ::Decentworks::HexdigestSupport.format_rational(to_hexdigest_rational)
      end

      # 正規化に用いる有理数
      #
      # MEMO: 十進として解釈すべき型（Float）はこのメソッドを上書きする
      def to_hexdigest_rational = to_r
    end

    # 数の正規化
    class << self
      # 有理数を一意な文字列へ整形する
      #
      # MEMO: 有限小数で表せる場合は十進表記、表せない場合は分数表記にする。Rationalは
      #       既約かつ分母が正へ正規化済みのため、どちらの表記も数に対して一意になる
      #
      # MEMO: 分数表記が十進表記と衝突することはない。十進表記に区切り文字（/）は
      #       現れないため
      def format_rational(rational)
        return rational.numerator.to_s if rational.denominator == 1

        scale = decimal_scale(rational.denominator)
        return "#{rational.numerator}/#{rational.denominator}" unless scale

        sign   = rational.negative? ? "-" : ""
        digits = (rational.numerator.abs * (10**scale / rational.denominator)).to_s.rjust(scale + 1, "0")

        "#{sign}#{digits[0...-scale]}.#{digits[-scale..]}"
      end

      private

      # 有限小数で表すのに必要な小数点以下の桁数（表せない場合はnil）
      #
      # MEMO: 分母が2と5のべき乗の積のときだけ有限小数になる。既約分数なので、
      #       2と5で割り切った残りが1かどうかだけで判定できる
      #
      # MEMO: 桁数は2と5の指数の大きい方。これが必要最小の桁数であり、末尾に0が
      #       並ばないため表記が一意になる
      def decimal_scale(denominator)
        rest  = denominator
        twos  = 0
        fives = 0

        while (rest % 2).zero?
          rest /= 2
          twos += 1
        end

        while (rest % 5).zero?
          rest /= 5
          fives += 1
        end

        (rest == 1) ? [twos, fives].max : nil
      end
    end
  end
end
