# frozen_string_literal: true

require_relative "lib/decentworks/hexdigest_support/version"

Gem::Specification.new do |spec|
  spec.name = "decentworks-hexdigest-support"
  spec.version = ::Decentworks::HexdigestSupport::VERSION
  spec.authors = ["decentworks"]
  spec.email = [""]

  spec.summary = "Hash値拡張ライブラリ"
  spec.description = "Hash値拡張ライブラリ"
  spec.homepage = "https://github.com/SrDecentWorks/decentworks-hexdigest-support/tree/main"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/SrDecentWorks/decentworks-hexdigest-support/blob/main/CHANGELOG.md"
  # gem pushに多要素認証を必須にする
  spec.metadata["rubygems_mfa_required"] = "true"

  # gemに含めるファイル
  #
  # 除外の指定漏れで開発用ファイルが同梱されることを避けるため、ホワイトリストで指定する。
  # 対象は実装（lib）・型定義（sig）・実行ファイル（exe）とドキュメントのみ。
  # spec / bin / Rakefile / Gemfile / gemspec、および .claude .rubocop.yml .ruby-version .rspec
  # CODE_OF_CONDUCT.md などの開発用ファイルは含めない。
  distributed_files = %w[README.md CHANGELOG.md LICENSE]
  distributed_directories = %w[lib/ sig/ exe/]
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      distributed_files.include?(f) || f.start_with?(*distributed_directories)
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # ActiveSupport::TimeWithZone への対応で必要。Rails 上では同じ瞬間が Time ではなく
  # TimeWithZone として現れるため、条件付き対応ではなく依存として扱う
  spec.add_dependency "activesupport", ">= 8.0"

  # BigDecimal への対応で必要。Ruby 3.4 以降 bigdecimal は default gem ではなく
  # bundled gem のため、依存として明示する
  spec.add_dependency "bigdecimal", ">= 3.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
