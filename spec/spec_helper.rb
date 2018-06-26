require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "middleman-prismic"
Dir.glob(File.expand_path("../support/*.rb", __FILE__)).each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"
end
