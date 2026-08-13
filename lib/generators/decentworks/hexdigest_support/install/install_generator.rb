# frozen_string_literal: true

require "rails/generators/base"

module Decentworks
  module HexdigestSupport
    module Generators
      # 初期化ファイルを生成するジェネレータ
      #
      #   bin/rails generate decentworks:hexdigest_support:install
      #
      # MEMO: 本ファイルはlib/decentworks/hexdigest_support.rbからはrequireしない。
      #       Railsのジェネレータ探索（lib/generators配下）から呼ばれた時にだけ
      #       読み込まれるため、railtiesを導入していない環境でも利用できる
      #
      # MEMO: gem本体はactivesupportに依存する（ActiveSupport::TimeWithZone対応のため）が、
      #       railtiesには依存しない。この遅延読み込みが担保しているのは後者
      class InstallGenerator < ::Rails::Generators::Base
        source_root ::File.expand_path("templates", __dir__)

        desc "config/initializers/decentworks_hexdigest_support.rb を生成する"

        class_option :salt_key,
                     type:    :string,
                     default: "hexdigest_support_salt",
                     desc:    "credentialsから読み出すキー名（decentworks配下）"

        def create_initializer_file
          template "decentworks_hexdigest_support.rb", "config/initializers/decentworks_hexdigest_support.rb"
        end

        private

        def salt_key = options[:salt_key]
      end
    end
  end
end
