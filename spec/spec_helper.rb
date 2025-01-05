# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require './app'
require 'vcr'
require_relative 'support/vcr_helper'
require 'dotenv/load'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    App.new
  end
end
