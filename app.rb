# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'json'
require 'groq'
require 'dotenv/load'
require 'pry'

Dir[File.join(__dir__, 'lib/**/*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'services/**/*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'controllers/**/*.rb')].sort.each { |file| require file }

class App < Sinatra::Base
  use RecipesController
end
