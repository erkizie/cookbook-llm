# frozen_string_literal: true

# Base class for all service objects
class BaseService
  attr_reader :errors

  def initialize
    @errors = []
  end

  def success?
    errors.empty?
  end

  private

  def fail!(message)
    errors << message
  end
end
