import React, { useState } from 'react';
import axios from 'axios';
import qs from 'qs';
import './App.css';

function App() {
  const [ingredients, setIngredients] = useState('');
  const [recipe, setRecipe] = useState(null);
  const [error, setError] = useState(null);

  const handleSubmit = async (event) => {
    event.preventDefault();
    setRecipe(null);
    setError(null);

    if (!ingredients.trim()) {
      setError('Ingredients cannot be empty.');
      return;
    }

    try {
      const response = await axios.post(
        'http://localhost:9292/generate_recipe',
        qs.stringify({ ingredients }),
        {
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        }
      );
      setRecipe(response.data.data.recipe);
    } catch (err) {
      setError(err.response?.data.errors?.join(', ') || 'An error occurred.');
    }
  };

  return (
    <div className="container">
      <h1 className="title">Recipe Generator</h1>
      <form className="form" onSubmit={handleSubmit}>
        <label htmlFor="ingredients" className="label">
          Ingredients:
        </label>
        <input
          type="text"
          id="ingredients"
          value={ingredients}
          onChange={(e) => setIngredients(e.target.value)}
          placeholder="e.g., chicken, rice, salt"
          className="input"
        />
        <button type="submit" className="button">
          Generate Recipe
        </button>
      </form>

      {recipe && (
        <div className="output success">
          <h2>Your Recipe</h2>
          <p>{recipe}</p>
        </div>
      )}

      {error && (
        <div className="output error">
          <h2>Error</h2>
          <p>{error}</p>
        </div>
      )}
    </div>
  );
}

export default App;
