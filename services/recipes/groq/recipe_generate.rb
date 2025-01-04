# frozen_string_literal: true

module Recipes
  module Groq
    class RecipeGenerate < BaseService
      attr_reader :recipe

      def initialize(client: GroqClient.new)
        super()
        @client = client
        @recipe = nil
      end

      def call(ingredients)
        validate_ingredients!(ingredients)
        @recipe = generate_recipe(ingredients)
        validate_recipe!(ingredients)
      rescue StandardError => e
        fail!(e.message)
      end

      private

      attr_reader :client

      def generate_recipe(ingredients)
        client.chat(messages: build_prompt(ingredients))
      end

      def validate_ingredients!(ingredients)
        validation = Recipes::Groq::IngredientsValidate.new(ingredients)
        validation.call
        raise validation.errors.join(', ') unless validation.success?
      end

      def validate_recipe!(ingredients)
        validation = Recipes::Groq::RecipeValidate.new(recipe, ingredients)
        validation.call
        raise validation.errors.join(', ') unless validation.success?
      end

      def build_prompt(ingredients)
        [
          {
            role: 'user',
            content: "Generate a step-by-step recipe using these ingredients: #{ingredients}."
          }
        ]
      end
    end
  end
end
