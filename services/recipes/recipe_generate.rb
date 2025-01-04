# frozen_string_literal: true

module Recipes
  class RecipeGenerate < BaseService
    attr_reader :recipe

    def initialize(ingredients, llm_client: Recipes::Groq::RecipeGenerate.new)
      super()
      @ingredients = ingredients&.strip
      @llm_client = llm_client
      @recipe = nil
    end

    def call
      validate_ingredients!
      generate_recipe

      @recipe = llm_client.recipe
    rescue StandardError => e
      fail!(e.message)
    end

    private

    attr_reader :ingredients, :llm_client

    def generate_recipe
      llm_client.call(ingredients)
      return if llm_client.success?

      raise llm_client.errors.join(', ')
    end

    def validate_ingredients!
      raise 'Ingredients cannot be empty' if ingredients.nil? || ingredients.empty?
    end
  end
end
