require "bundler/setup"
require "pry-byebug"
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:", encoding: "utf8")
ActiveRecord::Migration.verbose = false

require "wharel"

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
