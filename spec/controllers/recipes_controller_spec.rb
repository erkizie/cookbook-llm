# frozen_string_literal: true

RSpec.describe RecipesController, :vcr do
  describe 'POST /generate_recipe' do
    context 'when the ingredients are valid and the recipe is successfully generated' do
      let(:ingredients) { 'chicken, rice, salt' }

      it 'returns the generated recipe with status 200 and validates the recipe content' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_body[:success]).to eq(true)
        expect(response_body[:errors]).to be_nil
        expect(response_body[:data][:recipe]).to be_a(String)

        recipe = response_body[:data][:recipe]
        expect(recipe).to include('Instructions')
        expect(recipe).to include('chicken')
        expect(recipe).to include('rice')
      end
    end

    context 'when the ingredients include typos' do
      let(:ingredients) { 'chikcen, rice, saalt' }

      it 'returns the generated recipe with status 200 and validates the recipe content' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_body[:success]).to eq(true)
        expect(response_body[:errors]).to be_nil
        expect(response_body[:data][:recipe]).to be_a(String)

        recipe = response_body[:data][:recipe]
        expect(recipe).to include('Instructions')
        expect(recipe.downcase).to include('chicken')
        expect(recipe.downcase).to include('rice')
      end
    end

    context 'when the API returns an error' do
      before do
        allow_any_instance_of(GroqClient).to receive(:chat).and_raise(StandardError, 'API Error')
      end

      let(:ingredients) { 'chicken, rice, salt' }

      it 'returns an error with status 400' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_body[:success]).to eq(false)
        expect(response_body[:errors]).to include('API Error')
        expect(response_body[:data]).to be_nil
      end
    end

    context 'when the ingredients include extra context' do
      let(:ingredients) { 'chicken, rice, salt, and some random thoughts.' }

      it 'returns the generated recipe with status 200 and validates the recipe content' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body, symbolize_names: true)

        expect(response_body[:success]).to eq(true)
        expect(response_body[:errors]).to be_nil
        expect(response_body[:data][:recipe]).to be_a(String)

        recipe = response_body[:data][:recipe]
        expect(recipe).to include('Instructions')
        expect(recipe.downcase).to include('chicken')
        expect(recipe.downcase).to include('rice')
      end
    end

    context 'when the ingredients are nil' do
      let(:ingredients) { nil }

      it 'returns an error with status 400' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_body[:success]).to eq(false)
        expect(response_body[:errors]).to include('Ingredients cannot be empty')
        expect(response_body[:data]).to be_nil
      end
    end

    context 'when no ingredients parameter is sent' do
      it 'returns an error with status 400' do
        header 'Host', 'localhost'
        post '/generate_recipe'

        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_body[:success]).to eq(false)
        expect(response_body[:errors]).to include('Ingredients cannot be empty')
        expect(response_body[:data]).to be_nil
      end
    end
  end
end
