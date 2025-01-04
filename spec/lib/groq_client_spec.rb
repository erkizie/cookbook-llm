# frozen_string_literal: true

RSpec.describe GroqClient, :vcr do
  subject { described_class.new }

  let(:valid_messages) do
    {
      messages: [
        { role: 'user', content: 'Generate a recipe for chicken and rice.' }
      ]
    }
  end

  context 'when the API call is successful' do
    it 'returns the recipe content' do
      result = subject.chat(messages: valid_messages[:messages])
      expect(result).to include('recipe')
    end
  end

  context 'when the API call fails' do
    before do
      allow_any_instance_of(Groq::Client).to receive(:chat).and_raise(StandardError, 'API Error')
    end

    it 'raises an error' do
      expect { subject.chat(messages: valid_messages[:messages]) }.to raise_error(StandardError, 'API Error')
    end
  end
end
