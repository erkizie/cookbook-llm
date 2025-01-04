# frozen_string_literal: true

RSpec.describe Recipes::Groq::IngredientsValidate, :vcr do
  let(:llm_client) { GroqClient.new }
  let(:ingredients) { 'chicken, rice, salt' }

  subject { described_class.new(ingredients, llm_client: llm_client) }

  describe '#call' do
    context 'when the input is valid ingredients' do
      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the input contains quantities' do
      let(:ingredients) { 'I have 400g of chicken, 200g of rice, and a pinch of salt.' }

      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the input is a casual list' do
      let(:ingredients) { 'chicken rice salt' }

      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the input includes typos' do
      let(:ingredients) { 'chikcen, rice, saalt' }

      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the input is invalid (random text)' do
      let(:ingredients) { 'What is the capital of France?' }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The input does not contain valid ingredients.')
      end
    end

    context 'when the input is a mix of ingredients and non-ingredients' do
      let(:ingredients) { 'chicken, rice, salt, and some random thoughts about life.' }

      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the API raises an error' do
      before do
        allow(llm_client).to receive(:chat).and_raise(StandardError, 'API Error')
      end

      it 'returns failure with API error' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('API Error')
      end
    end
  end
end
