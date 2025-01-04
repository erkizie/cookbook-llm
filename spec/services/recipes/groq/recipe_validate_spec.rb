# frozen_string_literal: true

RSpec.describe Recipes::Groq::RecipeValidate, :vcr do
  let(:llm_client) { GroqClient.new }
  let(:recipe) { 'Step 1: Boil rice. Step 2: Cook chicken. Step 3: Mix together.' }
  let(:ingredients) { 'chicken, rice, salt' }

  subject { described_class.new(recipe, ingredients, llm_client: llm_client) }

  describe '#call' do
    context 'when the recipe is valid' do
      it 'returns success' do
        subject.call
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
      end
    end

    context 'when the recipe is invalid' do
      let(:recipe) { 'Step 1: Boil pasta. Step 2: Add cheese.' }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The generated recipe is not valid based on the provided ingredients.')
      end
    end

    context 'when the recipe is empty' do
      let(:recipe) { '' }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The recipe cannot be empty.')
      end
    end

    context 'when the recipe is nil' do
      let(:recipe) { nil }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The recipe cannot be empty.')
      end
    end

    context 'when the ingredients are empty' do
      let(:ingredients) { '' }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The ingredients cannot be empty.')
      end
    end

    context 'when the ingredients are nil' do
      let(:ingredients) { nil }

      it 'returns failure' do
        subject.call
        expect(subject.success?).to eq(false)
        expect(subject.errors).to include('The ingredients cannot be empty.')
      end
    end

    context 'when the input includes extra context' do
      let(:recipe) { 'Step 1: Boil rice. Step 2: Cook chicken. Step 3: Mix together. Serve hot.' }

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
