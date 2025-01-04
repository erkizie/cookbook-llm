# frozen_string_literal: true

module Recipes
  module Groq
    class IngredientsValidate < BaseService
      def initialize(ingredients, llm_client: GroqClient.new)
        super()
        @ingredients = ingredients&.strip
        @llm_client = llm_client
      end

      def call
        pre_validate!
        validate_ingredients!
      rescue StandardError => e
        fail!(e.message)
      end

      private

      attr_reader :ingredients, :llm_client

      def pre_validate!
        return unless ingredients.nil? || ingredients.empty?

        raise 'The input does not contain valid ingredients.'
      end

      def validate_ingredients!
        response = fetch_validation_response
        process_response(response)
      end

      def fetch_validation_response
        llm_client.chat(messages: build_prompt)
      end

      def process_response(response)
        return if response.downcase.include?('accepted')

        raise 'The input does not contain valid ingredients.'
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
        'Determine if the following input represents a valid list of cooking ingredients. ' \
        'Focus only on identifying ingredients even if the input contains typos or misspellings. ' \
        'Do NOT attempt to correct typos or suggest alternative spellings. Ignore extra context, quantities, or casual phrasing. ' \
        "Respond ONLY in one word with 'accepted' if the input contains valid ingredients, or 'rejected' otherwise. Input: #{ingredients}."
      end
    end
  end
end
