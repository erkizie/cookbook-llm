# frozen_string_literal: true

module Recipes
  class RecipeGenerate < BaseService
    attr_reader :recipe

    def initialize(ingredients, llm_client: Recipes::Groq::RecipeGenerate.new)
      super()
      @ingredients = ingredients.strip
      @llm_client = llm_client
      @recipe = nil
    end

    def call
      llm_response = llm_client.call(ingredients)
      if llm_response.success?
        @recipe = llm_response.recipe
      else
        fail!(llm_response.errors.join(', '))
      end
    rescue StandardError => e
      fail!(e.message)
    end

    private

    attr_reader :ingredients, :llm_client
  end
end
