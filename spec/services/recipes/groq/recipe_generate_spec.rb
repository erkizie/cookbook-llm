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
      let(:ingredients_validation_service) do
        instance_double(
          Recipes::Groq::IngredientsValidate,
          call: nil,
          success?: false,
          errors: ['The input does not contain valid ingredients.']
        )
      end

      before do
        allow(Recipes::Groq::IngredientsValidate).to receive(:new).with(ingredients).and_return(ingredients_validation_service)
      end

      it 'fails with ingredient validation error' do
        service.call(ingredients)

        expect(ingredients_validation_service).to have_received(:call)

        expect(service.success?).to eq(false)
        expect(service.errors).to include('The input does not contain valid ingredients.')
        expect(service.recipe).to be_nil
      end
    end

    context 'when recipe validation fails' do
      let(:ingredients_validation_service) do
        instance_double(
          Recipes::Groq::IngredientsValidate,
          call: nil,
          success?: true,
          errors: []
        )
      end

      let(:recipe_validation_service) do
        instance_double(
          Recipes::Groq::RecipeValidate,
          call: nil,
          success?: false,
          errors: ['The recipe does not match ingredients.']
        )
      end

      before do
        allow(Recipes::Groq::IngredientsValidate).to receive(:new).with(ingredients).and_return(ingredients_validation_service)
        allow(Recipes::Groq::RecipeValidate).to receive(:new).with(anything,
                                                                   ingredients).and_return(recipe_validation_service)
      end

      it 'fails with recipe validation error' do
        service.call(ingredients)

        expect(ingredients_validation_service).to have_received(:call)
        expect(recipe_validation_service).to have_received(:call)

        expect(service.success?).to eq(false)
        expect(service.errors).to include('The recipe does not match ingredients.')
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
