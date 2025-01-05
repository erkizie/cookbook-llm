# Cookbook LLM

Cookbook LLM is a back-end application designed to generate step-by-step recipes using AI. It validates user-provided ingredients and ensures the generated recipe matches the provided input. The project is built using Sinatra, adheres to clean architecture principles, and employs external API integrations for recipe generation and validation.

---

## Features

- **Generate Recipes:** Submit ingredients and receive a recipe.
- **Ingredient Validation:** Validates whether the provided input is a list of ingredients.
- **Recipe Validation:** Ensures the generated recipe matches the provided ingredients.

---

## Tech Stack

- **Ruby**
- **Sinatra**
- **RSpec** (for testing)
- **React** (for the front-end application)

---

## Setup Instructions

### Prerequisites

Ensure you have the following installed:

- Ruby (>= 3.0.0)
- Bundler
- Node.js and npm (for React front-end application)

### Steps to Run the Project

#### Back-End Setup

1. **Clone the Repository**

   ```bash
   git clone git@github.com:erkizie/cookbook-llm.git
   cd cookbook-llm
   ```

2. **Install Dependencies**

   ```bash
   bundle install
   ```

3. **Setup Environment Variables**
   Create a `.env` file in the root directory:

   ```env
   GROQ_API_KEY=<your_groq_api_key>
   ```

4. **Run the Application**
   Start the server:

   ```bash
   rackup config.ru
   ```

   By default, the server runs on [http://localhost:9292](http://localhost:9292).

5. **Test the Endpoint**
   You can test the API using `curl` or any API client (e.g., Postman).

   Example using `curl`:

   ```bash
   curl -X POST -H "Host: localhost" -d "ingredients=chicken,rice,salt" http://localhost:9292/generate_recipe
   ```

#### Front-End Setup

1. **Navigate to the React Application Directory**

   ```bash
   cd client
   ```

2. **Install Dependencies**

   ```bash
   npm install
   ```

3. **Run the Application**

   ```bash
   npm start
   ```

   By default, the React application runs on [http://localhost:3000](http://localhost:3000). Ensure the back-end server is running to interact with the API.

---

## API Endpoints

### **POST /generate_recipe**

#### Request

- **Parameters:**
  - `ingredients` (string): List of ingredients.

#### Response

- **Success (200):**
  ```json
  {
    "success": true,
    "data": {
      "recipe": "<generated_recipe>"
    },
    "errors": null
  }
  ```
- **Failure (400):**
  ```json
  {
    "success": false,
    "errors": ["<error_message>"],
    "data": null
  }
  ```

---

## Running Tests

1. **Run All Tests**

   ```bash
   rspec
   ```

2. **Test Coverage**
   The project includes:
   - Unit tests for individual services.
   - Integration tests for controllers.
   - VCR-backed tests to mock external API interactions.

---

## Project Structure

```
.
├── app.rb                     # Main application entry point
├── config.ru                  # Rack configuration
├── controllers/               # Controllers for routing
│   ├── helpers/               # Shared helpers
│   └── recipes_controller.rb  # Recipes controller
├── lib/                       # Libraries and utility classes
│   └── groq_client.rb         # Wrapper for Groq API
├── services/                  # Service objects
│   ├── base_service.rb        # Base service class
│   ├── recipes/               # Recipe-specific services
│   │   ├── groq/              # AI-powered sub-services
│   │   │   ├── ingredients_validate.rb
│   │   │   ├── recipe_generate.rb
│   │   │   └── recipe_validate.rb
│   │   └── recipe_generate.rb # High-level recipe generator
├── client/                    # React front-end application
│   ├── public/                # Public static files
│   └── src/                   # React source files
│       ├── App.js             # Main React component
│       └── index.js           # React entry point
├── spec/                      # Test suite
│   ├── controllers/           # Controller tests
│   ├── lib/                   # Library tests
│   ├── services/              # Service tests
│   └── support/               # Test helpers and configurations
│       └── vcr_helper.rb
└── Gemfile                    # Project dependencies
```
