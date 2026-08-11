# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/time"

require "faker"

require "simplecov"
SimpleCov.start

require "decentworks/hexdigest_support"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    ::Time.zone = "Asia/Tokyo"
  end

  config.after do
  end
end
