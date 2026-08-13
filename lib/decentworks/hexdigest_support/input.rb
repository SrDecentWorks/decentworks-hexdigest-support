# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # 値がオブジェクトIDを含んでおり、ダイジェストが決定的にならない
    class NonDeterministicSourceError < ::StandardError; end

    # 値が自身を含んでおり、入力の組み立てが終わらない
    class CircularReferenceError < ::StandardError; end

    # ダイジェストの入力の組み立て
    class << self
      # 既定の#to_sが返す文字列（例: "#<Object:0x00007f9e0c0d1234>"）
      #
      # MEMO: メソッドの定義元（#to_sのowner）ではなく結果の文字列で判定する。
      #       Proc#to_sや無名クラスのModule#to_sのように、独自の#to_sを持ちながら
      #       オブジェクトIDを含む型も拾いたいため
      DEFAULT_TO_S_PATTERN = /\A#<.*:0x\h+/

      # 組み立て中のオブジェクトを記録するキー
      #
      # MEMO: Thread.current[]はスレッドではなくFiber単位で値を持つ。組み立ての
      #       途中でFiberをまたぐことはないため、これで取り違えは起きない
      VISITING_KEY = :decentworks_hexdigest_support_visiting

      # 値を引用・エスケープする
      #
      # MEMO: #inspectを使わない。#inspectは非ASCII文字をEncoding.default_externalが
      #       印字可能かどうかでエスケープするか決めるため、同じ値でも実行環境の
      #       ロケール次第で異なる入力になってしまう
      #       （UTF-8環境では"あ"、US-ASCII環境では"あ"）
      #
      # MEMO: エスケープ対象は引用符とバックスラッシュのみ。UTF-8環境の#inspectと
      #       同じ出力になるため、制御文字を含まない値のダイジェストは変わらない
      #
      # MEMO: 引用しないと、値に区切り文字（:）が含まれる場合に型名との境界が
      #       曖昧になる（例: Foo::Barの"x" と Fooの":Bar:x" が衝突する）
      def quote(value) = %("#{value.to_s.gsub(/[\\"]/) { |char| "\\#{char}" }}")

      # 値が決定的かを検査する
      #
      # MEMO: 既定のObject#to_sはオブジェクトIDを含むため、#to_sも
      #       #to_hexdigest_sourceも実装していないオブジェクトのダイジェストは
      #       プロセスごとに変わる。永続化した後で気付くと復旧できないため、
      #       黙って通さず例外にする
      #
      # MEMO: StringとSymbolは検査しない。検査は「既定のObject#to_sへ落ちていないか」を
      #       見るためのものだが、この2つは値そのものが文字列であり、オブジェクトIDが
      #       混入する経路がない。除外しないと "#<User:0x00007f9e0c0d1234>" のような
      #       正当な文字列（ログの1行や#inspectの結果を保持した値）が例外になってしまう
      #
      # MEMO: 裏を返すと、利用側が自分でオブジェクトを文字列化して渡した場合は検出
      #       できない。gemから見ればただの文字列であり、他の文字列と区別できないため
      def validate_source!(source, object)
        return if object.is_a?(::String) || object.is_a?(::Symbol)
        return unless DEFAULT_TO_S_PATTERN.match?(source.to_s)

        raise ::Decentworks::HexdigestSupport::NonDeterministicSourceError,
              "#{object.class}の値がオブジェクトIDを含むため、ダイジェストが決定的になりません" \
              "（#{source}）。#to_hexdigest_sourceか#to_sを実装してください"
      end

      # 組み立て中のオブジェクトを記録しながらブロックを実行する
      #
      # MEMO: 自身を含む値をそのまま辿ると再帰が終わらず、StandardErrorを継承しない
      #       SystemStackErrorになる。呼び出し側のrescueをすり抜けてプロセスを
      #       落としてしまうため、自前で検出して例外にする
      #
      # MEMO: 記録するのは現在辿っている経路だけで、組み立てが終わった時点で取り除く。
      #       同じオブジェクトが兄弟として複数回現れるのは循環ではないため、経路に
      #       残っている場合だけを循環とみなす
      #
      # MEMO: 自身を含まない深いネスト（1万段など）はSystemStackErrorのまま。循環と
      #       違って有限であり、深さの上限を決め打ちすると正当な構造まで弾いてしまう
      def detect_circular_reference(object)
        visiting = (::Thread.current[VISITING_KEY] ||= [])
        raise_circular_reference(object) if visiting.include?(object.object_id)

        visiting.push(object.object_id)

        begin
          yield
        ensure
          visiting.pop
        end
      end

      private

      def raise_circular_reference(object)
        raise ::Decentworks::HexdigestSupport::CircularReferenceError,
              "#{object.class}の値が自身を含んでいるため、ダイジェストを求められません。" \
              "循環参照を取り除いてください"
      end
    end
  end
end
