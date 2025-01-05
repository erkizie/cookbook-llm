# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<API_KEY>') { ENV['GROQ_API_KEY'] }
  config.configure_rspec_metadata!
end
