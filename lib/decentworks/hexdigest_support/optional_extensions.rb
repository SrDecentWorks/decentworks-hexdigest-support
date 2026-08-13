# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # 読み込まれている場合にだけ適用する拡張
    #
    # MEMO: Set / Dateは本gem側でrequireしない。使っていない利用側にまで読み込みを
    #       強いることになるため。代わりに、適用済みかどうかを都度判定する
    #
    # MEMO: 本gemより後にrequire "date"などをした場合、拡張は適用されないまま
    #       Object#to_hexdigest_source（＝#to_s）にフォールバックする。Date#to_sは
    #       たまたまISO 8601の日付なので気付きにくいが、DateTime#to_sはオフセットを
    #       含むため、同じ瞬間でもタイムゾーン次第でダイジェストが変わってしまう。
    #       順序を制御できない場合は.apply!を明示的に呼ぶこと
    module OptionalExtensions
      class << self
        # 読み込み済みの型に対して拡張を適用する
        #
        #   require "date"
        #   ::Decentworks::HexdigestSupport::OptionalExtensions.apply!
        #
        # MEMO: 適用済みの型は再定義しないため、何度呼んでも安全
        def apply!
          apply_set!
          apply_date!
          apply_date_time!
        end

        private

        # 対象のクラス自身が#to_hexdigest_sourceを持つか
        #
        # MEMO: Object#to_hexdigest_sourceは常に存在するため、メソッドの有無ではなく
        #       定義元のクラスで判定する
        def applied?(klass) = klass.instance_method(:to_hexdigest_source).owner == klass

        def apply_set!
          return unless defined?(::Set)
          return if applied?(::Set)

          ::Set.class_eval do
            # ハッシュ値を求めるためのオリジナルの値
            #
            # MEMO: 要素の文字列化はArrayへ委譲する。Array#to_hexdigest_sourceが要素を
            #       ソートするため、挿入順が違っても同じ値になる
            #
            # MEMO: 型は#to_hexdigest_inputが付与するため、同じ要素を持つArrayとは
            #       別のダイジェストになる
            def to_hexdigest_source = to_a.to_hexdigest_source
          end
        end

        def apply_date!
          return unless defined?(::Date)
          return if applied?(::Date)

          ::Date.class_eval do
            # ハッシュ値を求めるためのオリジナルの値
            #
            # MEMO: 日付は時刻もタイムゾーンも持たないため、Timeのような正規化は不要。
            #       ISO 8601の日付として組み立てる
            def to_hexdigest_source = strftime("%Y-%m-%d")
          end
        end

        def apply_date_time!
          return unless defined?(::DateTime)
          return if applied?(::DateTime)

          ::DateTime.class_eval do
            # ハッシュ値を求めるためのオリジナルの値
            #
            # MEMO: DateTimeはDateのサブクラスのため、明示しないとDate#to_hexdigest_sourceを
            #       継承して時刻が丸ごと落ちてしまう
            #
            # MEMO: Timeへ変換して委譲する。UTCへの正規化と精度の扱いをTimeに一本化するため
            def to_hexdigest_source = to_time.to_hexdigest_source
          end
        end
      end
    end
  end
end

::Decentworks::HexdigestSupport::OptionalExtensions.apply!
