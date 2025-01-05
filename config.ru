# frozen_string_literal: true

require './app'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i[get post options delete put patch]
  end
end

run App.new
