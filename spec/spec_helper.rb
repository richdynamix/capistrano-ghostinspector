require 'capistrano'

require 'capistrano-spec'
require 'rspec'

# Add capistrano-spec matchers and helpers to RSpec
RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
end