import React, { useState } from 'react';
import axios from 'axios';
import qs from 'qs'; // For URL-encoded data

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
        qs.stringify({ ingredients }), // URL-encoded data
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
    <div>
      <h1>Recipe Generator</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Ingredients:
          <input
            type="text"
            value={ingredients}
            onChange={(e) => setIngredients(e.target.value)}
            placeholder="e.g., chicken, rice, salt"
          />
        </label>
        <button type="submit">Generate Recipe</button>
      </form>

      {recipe && (
        <div>
          <h2>Your Recipe</h2>
          <p>{recipe}</p>
        </div>
      )}

      {error && (
        <div>
          <h2>Error</h2>
          <p>{error}</p>
        </div>
      )}
    </div>
  );
}

export default App;
