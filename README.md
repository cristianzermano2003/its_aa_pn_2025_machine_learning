# Quiz Application

An interactive, single-session quiz application built with Elixir, Phoenix v1.8, and LiveView.

## Project Overview

This application presents users with 10 randomly selected multiple-choice questions from a pre-defined database. For each question, users must:
1. Select one of four answer options
2. Provide a written motivation/reasoning for their answer

After submission, the application immediately scores the quiz and displays detailed feedback showing:
- Final score (X/10)
- Correct/incorrect indicators for each answer
- User's selected answer and motivation
- Correct answer with official explanation

## Technology Stack

- **Backend:** Elixir 1.14+, Phoenix 1.8.0
- **Database:** PostgreSQL with Ecto
- **Frontend:** Phoenix LiveView, Tailwind CSS, Heroicons
- **HTTP Client:** Req (built-in to Phoenix)
- **Code Quality:** Credo, Formatter, ExUnit tests

## Project Structure

```
lib/
├── quiz_app/
│   ├── application.ex
│   ├── repo.ex
│   └── quiz/
│       └── question.ex          # Question schema
└── quiz_app_web/
    ├── endpoint.ex
    ├── router.ex
    ├── gettext.ex
    ├── telemetry.ex
    ├── components/
    │   ├── core_components.ex    # Reusable form components
    │   └── layouts/
    │       ├── root.html.heex
    │       └── app.html.heex
    └── live/
        ├── home_live.ex          # Home page
        └── quiz_live.ex          # Main quiz interface

priv/
├── repo/
│   ├── migrations/
│   │   └── 20251113000001_create_questions.exs
│   └── seeds.exs                # Loads seeding.json
└── static/                       # Built assets

config/
├── config.exs
├── dev.exs
├── test.exs
└── prod.exs

assets/
├── css/
│   └── app.css                  # Tailwind CSS
├── js/
│   └── app.js                   # Phoenix LiveView setup
├── vendor/
│   └── topbar.js                # Progress bar
├── tailwind.config.js
└── package.json

test/
├── support/
│   ├── data_case.ex
│   └── conn_case.ex
├── quiz_app/
│   └── quiz/
│       └── question_test.exs    # Schema tests
├── quiz_app_web/
│   └── live/
│       └── quiz_live_test.exs   # LiveView tests
└── quiz_app/
    └── quiz_test.exs            # Context tests
```

## Setup Instructions

### Prerequisites

- Elixir 1.14 or later
- Erlang 25.0 or later
- PostgreSQL 12 or later
- Node.js 16+ (for asset compilation)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd its_aa_pn_2025_machine_learning
   ```

2. **Install dependencies:**
   ```bash
   mix deps.get
   ```

3. **Set up the database:**
   ```bash
   mix ecto.setup
   ```
   This command will:
   - Create the database
   - Run migrations
   - Seed questions from `seeding.json`

4. **Start the development server:**
   ```bash
   mix phx.server
   ```

5. **Open in browser:**
   Navigate to `http://localhost:4000`

## Usage

### Home Page
- Visit `/` to see the welcome page
- Click "Start Quiz" to begin

### Quiz Page
- Read each question carefully
- Select one of four answer options (radio buttons)
- Enter your reasoning for each answer in the textarea
- Submit button will enable once ALL questions are answered with motivations

### Results Page
- View your final score prominently displayed
- See detailed feedback for each question:
  - Your answer (correct/incorrect indicator)
  - Your reasoning
  - The correct answer
  - Official explanation from the source material
- Click "Retake Quiz" to restart with new random questions

## Data Structure

### Question Schema

All questions must follow this structure (validated in `Question` schema):

```elixir
%Question{
  id: 1,
  question: "Question text?",
  options: ["Option A", "Option B", "Option C", "Option D"],
  correct_answer: "Option B",
  motivation: "Detailed explanation of why Option B is correct..."
}
```

**Validation Rules:**
- Exactly 4 options required
- `correct_answer` must be an exact match to one option
- All fields are required

### User Session State

**In-Memory (Not Persisted):**
```elixir
%{
  questions: [Question, ...],            # 10 random questions
  user_answers: %{question_id => answer_string, ...},
  user_motivations: %{question_id => motivation_string, ...},
  quiz_submitted: boolean,
  final_score: integer
}
```

## Development Commands

### Running Tests

Run all tests:
```bash
mix test
```

Run specific test file:
```bash
mix test test/quiz_app/quiz_test.exs
```

Run with coverage:
```bash
mix test --cover
```

### Code Quality

Format code:
```bash
mix format
```

Check code style (strict):
```bash
mix credo --strict
```

Compile with warnings as errors:
```bash
mix compile --all-warnings --warnings-as-errors
```

### Precommit Validation

Run all checks before committing:
```bash
mix precommit
```

This runs:
- Format check
- Credo (strict)
- All tests
- Compilation with warnings as errors

### Database Management

Create database:
```bash
mix ecto.create
```

Drop database:
```bash
mix ecto.drop
```

Recreate and reseed:
```bash
mix ecto.reset
```

Run migrations:
```bash
mix ecto.migrate
```

Rollback last migration:
```bash
mix ecto.rollback
```

## Key Features

### Quiz Logic
✅ 10 randomly selected unique questions per session  
✅ User answer selection (radio buttons)  
✅ User motivation/reasoning input (required)  
✅ Real-time form validation (button enable/disable)  
✅ Immediate scoring on submission  
✅ Case-sensitive, exact-match answer comparison  

### UI/UX
✅ Clean, easy-to-read interface  
✅ Question progress indicator (Question X of 10)  
✅ Visual feedback for correct/incorrect answers  
✅ Color-coded results (green for correct, red for incorrect)  
✅ Responsive design with Tailwind CSS  

### Data & Persistence
✅ Questions loaded from `seeding.json`  
✅ **NO user data persistence** (single-session only)  
✅ No localStorage, sessionStorage, or cookies  
✅ Session data discarded on page reload/close  
✅ Questions stored in PostgreSQL database  

### Testing
✅ Question schema validation tests  
✅ Quiz context (queries) tests  
✅ LiveView integration tests  
✅ Form submission and state management tests  
✅ Scoring logic tests  

## Configuration

### Database Configuration

Edit `config/dev.exs` to change database credentials:

```elixir
config :quiz_app, QuizApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quiz_app_dev",
  pool_size: 10
```

### Server Configuration

Edit `config/dev.exs` to change port:

```elixir
config :quiz_app, QuizAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000]
```

## Deployment

### Production Build

```bash
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate
```

### Environment Variables

Set these for production:

```bash
SECRET_KEY_BASE=<generated-secret>
DATABASE_USER=postgres
DATABASE_PASS=<password>
DATABASE_HOST=localhost
DATABASE_NAME=quiz_app_prod
PHX_HOST=example.com
```

## Troubleshooting

### Port 4000 already in use
```bash
# Linux/Mac
lsof -i :4000
kill -9 <PID>

# Windows
netstat -ano | findstr :4000
taskkill /PID <PID> /F
```

### Database connection errors
- Ensure PostgreSQL is running
- Verify credentials in `config/dev.exs`
- Check database exists: `mix ecto.create`

### Asset compilation issues
```bash
# Clean assets
rm -rf priv/static/assets/

# Rebuild
mix assets.build
```

### Test failures
```bash
# Create test database
MIX_ENV=test mix ecto.create

# Run migrations
MIX_ENV=test mix ecto.migrate

# Run tests
mix test
```

## Architecture Decisions

### Why LiveView?
- Real-time UI updates without full page reloads
- Client-side form validation
- Simple state management via socket assigns
- Excellent for interactive forms like quizzes

### Why no data persistence?
- Single-session assessment tool requirement
- No tracking or user history needed
- Simpler, stateless design
- Privacy-focused (no user data collection)

### Why PostgreSQL?
- Excellent Ecto support
- Array type for storing options
- Robust for production workloads
- Easy randomization with SQL `RANDOM()`

### Why Tailwind CSS?
- Utility-first approach aligns with Phoenix component model
- Minimal CSS footprint
- Easy to maintain responsive design
- Built-in dark mode support (if needed)

## Guidelines Followed

### From `architecture.md`:

✅ **Phoenix v1.8 Guidelines:**
- LiveView templates begin with `<Layouts.app>`
- Using `<.input>` component from `core_components.ex`
- Using `to_form/2` for form handling
- Using `<.link>` for navigation instead of deprecated functions

✅ **Ecto Guidelines:**
- Preloading associations (not needed here)
- Using `import Ecto.Query` in seeds
- Proper field types (`:string` for text fields)
- Using `Ecto.Changeset.get_field/2` for changesets

✅ **HTML/HEEx Guidelines:**
- Using `~H` sigil for templates
- Using `.heex` file extensions
- Using imported components (no inline scripts)
- Using `<%=` for block constructs

✅ **LiveView Guidelines:**
- Using `push_navigate` for navigation
- Using streams for collections (not applicable here)
- Proper form handling with `<.form for={@form}>`
- LiveView mounted correctly with state initialization

✅ **Elixir Guidelines:**
- No list index access via `[]` syntax
- Proper variable binding in conditionals
- No nested modules in single file
- Using `Enum` for list operations
- Proper pattern matching

## Additional Resources

- [Phoenix Documentation](https://phoenixframework.org)
- [LiveView Guide](https://hexdocs.pm/phoenix_live_view)
- [Ecto Documentation](https://hexdocs.pm/ecto)
- [Elixir Guide](https://elixir-lang.org/getting-started)
- [Tailwind CSS](https://tailwindcss.com)

## License

MIT License - See LICENSE file for details

## Authors

- Developed as an educational project for Machine Learning course
- Based on source material from `source.md`
