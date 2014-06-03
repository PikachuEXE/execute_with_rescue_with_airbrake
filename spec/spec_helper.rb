if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!
end

require 'execute_with_rescue_with_airbrake'
require 'airbrake'

require 'fixtures/test_service_classes'
require 'rspec'
require 'rspec/its'

require 'logger'

# Need to configurate it before any `notify_or_ignore`
Airbrake.configure(true) do |config|
  config.test_mode = true
end

RSpec.configure do |config|
end
