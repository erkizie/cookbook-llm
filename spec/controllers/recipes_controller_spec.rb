# frozen_string_literal: true

RSpec.describe RecipesController, :vcr do
  describe 'POST /generate_recipe' do
    context 'when the ingredients are valid and the recipe is successfully generated' do
      let(:ingredients) { 'chicken, rice, salt' }

      it 'returns the generated recipe with status 200' do
        header 'Host', 'localhost'
        post '/generate_recipe', ingredients: ingredients

        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body, symbolize_names: true)
        expect(response_body[:success]).to eq(true)
        expect(response_body[:data][:recipe]).to be_a(String)
        expect(response_body[:errors]).to be_nil
      end
    end

    context 'when the ingredients are invalid' do
      let(:ingredients) { '' }

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
  end
end
