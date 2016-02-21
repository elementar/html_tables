require 'html_tables'
require 'rspec-html-matchers'
require 'active_record'
require 'enumerize'
require 'symbolize'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.{rb,yml}')]
I18n.available_locales = ["pt"]
I18n.default_locale = :"pt"

ActiveRecord::Base.send :include, Symbolize::ActiveRecord

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include RSpecHtmlMatchers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end
