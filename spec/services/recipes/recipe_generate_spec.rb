# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recipes::RecipeGenerate do
  let(:llm_client) { instance_double(Recipes::Groq::RecipeGenerate) }
  let(:service) { described_class.new(ingredients, llm_client: llm_client) }
  let(:ingredients) { 'chicken, rice, salt' }
  let(:recipe) { 'Step 1: Boil rice. Step 2: Cook chicken. Step 3: Mix together.' }

  describe '#call' do
    context 'when the ingredients are valid and the recipe is successfully generated' do
      before do
        allow(llm_client).to receive(:call).with(ingredients).and_return(nil)
        allow(llm_client).to receive(:success?).and_return(true)
        allow(llm_client).to receive(:recipe).and_return(recipe)
      end

      it 'sets the recipe and marks the service as successful' do
        service.call
        expect(service.success?).to eq(true)
        expect(service.recipe).to eq(recipe)
        expect(service.errors).to be_empty
      end
    end

    context 'when the ingredients are empty' do
      let(:ingredients) { '' }

      it 'fails with an ingredient validation error' do
        service.call
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Ingredients cannot be empty')
        expect(service.recipe).to be_nil
      end
    end

    context 'when the ingredients are nil' do
      let(:ingredients) { nil }

      it 'fails with an ingredient validation error' do
        service.call
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Ingredients cannot be empty')
        expect(service.recipe).to be_nil
      end
    end

    context 'when the low-level LLM client fails during the call' do
      before do
        allow(llm_client).to receive(:call).with(ingredients).and_raise(StandardError, 'LLM Error')
      end

      it 'fails with an LLM error' do
        service.call
        expect(service.success?).to eq(false)
        expect(service.errors).to include('LLM Error')
        expect(service.recipe).to be_nil
      end
    end

    context 'when the low-level LLM client returns failure' do
      before do
        allow(llm_client).to receive(:call).with(ingredients).and_return(nil)
        allow(llm_client).to receive(:success?).and_return(false)
        allow(llm_client).to receive(:errors).and_return(['LLM returned failure'])
        allow(llm_client).to receive(:recipe).and_return(nil)
      end

      it 'fails with the LLM client error' do
        service.call
        expect(service.success?).to eq(false)
        expect(service.errors).to include('LLM returned failure')
        expect(service.recipe).to be_nil
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(llm_client).to receive(:call).with(ingredients).and_raise(StandardError, 'Unexpected Error')
      end

      it 'fails with a general error message' do
        service.call
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Unexpected Error')
        expect(service.recipe).to be_nil
      end
    end
  end
end
