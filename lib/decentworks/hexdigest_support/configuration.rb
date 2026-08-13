# frozen_string_literal: true

module Decentworks
  module HexdigestSupport
    # ハッシュ値化の設定
    #
    # MEMO: 初期化時（Railsならconfig/initializers配下）で以下のように設定する
    #
    #   ::Decentworks::HexdigestSupport.configure do |config|
    #     config.salt = ::Rails.application.credentials.hexdigest_salt
    #   end
    class Configuration
      # ハッシュ値化の入力に前置するソルト
      attr_accessor :salt

      def initialize
        @salt = ""
      end
    end

    class << self
      # 設定
      def configuration = @configuration ||= ::Decentworks::HexdigestSupport::Configuration.new

      # 設定の変更
      #
      # MEMO: ダイジェストの値はソルトに依存するため、永続化済みの値がある状態で
      #       ソルトを変更すると過去の値と一致しなくなる点に注意
      def configure = yield(configuration)

      # 設定のリセット（主にテスト用）
      def reset_configuration! = @configuration = nil

      # ハッシュ値化の入力に前置するソルト
      #
      # MEMO: 未設定（nil）はソルトなし（空文字）として扱う
      def salt = configuration.salt.to_s
    end
  end
end
