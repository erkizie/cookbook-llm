# frozen_string_literal: true

class RecipesController < Sinatra::Base
  helpers ResponseHelper

  post '/generate_recipe' do
    service = Recipes::RecipeGenerate.new(params[:ingredients])
    service.call

    if service.success?
      status 200
      json success_response(recipe: service.recipe)
    else
      status 400
      json failure_response(service.errors)
    end
  end
end
