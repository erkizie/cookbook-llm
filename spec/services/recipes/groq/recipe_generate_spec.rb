# frozen_string_literal: true

RSpec.describe Recipes::Groq::RecipeGenerate, :vcr do
  let(:client) { GroqClient.new }
  let(:service) { described_class.new(client: client) }
  let(:ingredients) { 'chicken, rice, salt' }

  describe '#call' do
    context 'when the recipe is successfully generated' do
      before do
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: true, errors: [])
        )
        allow_any_instance_of(Recipes::Groq::RecipeValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: true, errors: [])
        )
      end

      it 'returns a generated recipe using real API' do
        service.call(ingredients)
        expect(service.success?).to eq(true)
        expect(service.recipe).to be_a(String)
        expect(service.recipe).to include('recipe')
        expect(service.errors).to be_empty
      end
    end

    context 'when ingredient validation fails' do
      before do
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: false, errors: ['The input does not contain valid ingredients.'])
        )
      end

      it 'fails with ingredient validation error' do
        service.call(ingredients)
        expect(service.success?).to eq(false)
        expect(service.errors).to include('The input does not contain valid ingredients.')
        expect(service.recipe).to be_nil
      end
    end

    context 'when recipe validation fails' do
      before do
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: true, errors: [])
        )
        allow_any_instance_of(Recipes::Groq::RecipeValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: false, errors: ['Recipe does not match ingredients'])
        )
      end

      it 'fails with recipe validation error' do
        service.call(ingredients)
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Recipe does not match ingredients')
      end
    end

    context 'when the ingredients are empty' do
      let(:ingredients) { '' }

      before do
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: false, errors: ['Ingredients cannot be empty'])
        )
      end

      it 'fails with an ingredient validation error' do
        service.call(ingredients)
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Ingredients cannot be empty')
        expect(service.recipe).to be_nil
      end
    end

    context 'when the ingredients are nil' do
      let(:ingredients) { nil }

      before do
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: false, errors: ['Ingredients cannot be nil'])
        )
      end

      it 'fails with an ingredient validation error' do
        service.call(ingredients)
        expect(service.success?).to eq(false)
        expect(service.errors).to include('Ingredients cannot be nil')
        expect(service.recipe).to be_nil
      end
    end

    context 'when the client raises an error during recipe generation' do
      before do
        allow(client).to receive(:chat).and_raise(StandardError, 'API Error')
        allow_any_instance_of(Recipes::Groq::IngredientsValidate).to receive(:call).and_return(
          instance_double(BaseService, success?: true, errors: [])
        )
      end

      it 'fails with an API error' do
        service.call(ingredients)
        expect(service.success?).to eq(false)
        expect(service.errors).to include('API Error')
        expect(service.recipe).to be_nil
      end
    end
  end
end
