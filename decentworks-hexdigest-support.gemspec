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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
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
