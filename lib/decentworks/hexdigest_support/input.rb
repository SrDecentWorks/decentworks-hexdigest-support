# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # 値がオブジェクトIDを含んでおり、ダイジェストが決定的にならない
    class NonDeterministicSourceError < ::StandardError; end

    # ダイジェストの入力の組み立て
    class << self
      # 既定の#to_sが返す文字列（例: "#<Object:0x00007f9e0c0d1234>"）
      #
      # MEMO: メソッドの定義元（#to_sのowner）ではなく結果の文字列で判定する。
      #       Proc#to_sや無名クラスのModule#to_sのように、独自の#to_sを持ちながら
      #       オブジェクトIDを含む型も拾いたいため
      DEFAULT_TO_S_PATTERN = /\A#<.*:0x\h+/

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
      def validate_source!(source, object)
        return unless DEFAULT_TO_S_PATTERN.match?(source.to_s)

        raise ::Decentworks::HexdigestSupport::NonDeterministicSourceError,
              "#{object.class}の値がオブジェクトIDを含むため、ダイジェストが決定的になりません" \
              "（#{source}）。#to_hexdigest_sourceか#to_sを実装してください"
      end
    end
  end
end
