# frozen_string_literal: true

class GroqClient
  MODEL_ID = 'mixtral-8x7b-32768'

  def initialize(api_key = ENV['GROQ_API_KEY'])
    @client = Groq::Client.new(api_key: api_key)
  end

  def chat(messages:, model_id: MODEL_ID)
    response = @client.chat(messages, model_id: model_id)
    response['content']
  rescue StandardError => e
    raise e.message
  end
end
