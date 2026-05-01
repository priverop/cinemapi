# frozen_string_literal: true

require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<AUTH_TOKEN>") { ENV.fetch("CINESA_AUTH_TOKEN", nil) }
  config.default_cassette_options = { record: :none }
  config.allow_http_connections_when_no_cassette = false
end
