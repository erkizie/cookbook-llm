# frozen_string_literal: true

module Recipes
  module Groq
    class RecipeValidate < BaseService
      def initialize(recipe, ingredients, llm_client: GroqClient.new)
        super()
        @recipe = recipe&.strip
        @ingredients = ingredients&.strip
        @llm_client = llm_client
      end

      def call
        pre_validate!
        validate_recipe!
      rescue StandardError => e
        fail!(e.message)
      end

      private

      attr_reader :recipe, :ingredients, :llm_client

      def pre_validate!
        if recipe.nil? || recipe.empty?
          fail!('The recipe cannot be empty.')
        elsif ingredients.nil? || ingredients.empty?
          fail!('The ingredients cannot be empty.')
        end
      end

      def validate_recipe!
        response = fetch_validation_response
        process_response(response)
      end

      def fetch_validation_response
        llm_client.chat(messages: build_prompt)
      end

      def process_response(response)
        response.downcase.include?('accepted') || fail!('The generated recipe is not valid based on the provided ingredients.')
      end

      def build_prompt
        [
          {
            role: 'user',
            content: build_prompt_content
          }
        ]
      end

      def build_prompt_content
        "Check if this recipe is valid based on these ingredients: #{ingredients}. " \
        "Recipe: #{recipe}. Respond with 'accepted' if the recipe matches the ingredients or 'rejected' otherwise."
      end
    end
  end
end
