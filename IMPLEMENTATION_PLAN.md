# Implementation Plan - Quiz Application

## Project Overview

**Application:** Interactive Multiple-Choice Quiz with Motivation Feedback  
**Technology Stack:** Elixir + Phoenix v1.8 + LiveView + Tailwind CSS + DaisyUI  
**Data Source:** JSON-based question database (`seeding.json`)  
**Scope:** Single-session, client-side assessment tool (no data persistence)  
**Questions:** 10 randomly selected from seeded database  
**User Inputs:** Selected answer + written motivation per question

---

## Architecture Overview

### High-Level Flow

```
User Load Quiz Page
    ↓
Load 10 Random Questions (from seeding.json)
    ↓
Quiz View (All 10 Questions Displayed)
    ↓
User Selects Answer + Enters Motivation (per question)
    ↓
Submit Button Enabled (when all questions complete)
    ↓
User Clicks Submit
    ↓
Score Calculated (Client-side)
    ↓
Results View (Score + Detailed Feedback per Question)
```

### Data Flow

1. **Data Loading:** Questions from `seeding.json` → Phoenix LiveView initialization
2. **State Management:** In-memory socket assigns (LiveView handles state)
3. **Scoring:** Client-side calculation on submit
4. **No Persistence:** Session data discarded on page reload/close

---

## Implementation Tasks

### Phase 1: Project Setup & Data Infrastructure

#### 1.1 Create Question Schema and Seed Data
- **File:** `lib/my_app/quiz/question.ex`
- **Task:**
  - Define Ecto schema for Question (matches seeding.json structure)
  - Fields: `question`, `options`, `correct_answer`, `motivation`
  - Add validation for required fields and option count (exactly 4)
  - Create Ecto migration to create questions table
  - **Status:** not-started

#### 1.2 Seed Database with Questions
- **File:** `priv/repo/seeds.exs`
- **Task:**
  - Load `seeding.json` from disk
  - Parse JSON and insert all questions into database
  - Verify no duplicates exist
  - Test seed data is queryable
  - **Status:** not-started

#### 1.3 Create Question Query Module
- **File:** `lib/my_app/quiz.ex`
- **Task:**
  - Create context module for quiz domain
  - Add function: `get_random_questions/1` - returns N random questions
  - Add function: `get_all_questions/0` - for admin/debugging
  - Use `Ecto.Query.order_by(fragment("RANDOM()"))` for randomization
  - **Status:** not-started

---

### Phase 2: LiveView Structure

#### 2.1 Create Main Quiz LiveView
- **File:** `lib/my_app_web/live/quiz_live.ex`
- **Task:**
  - Module: `MyAppWeb.QuizLive` (alias will be handled by Phoenix router)
  - Initialize with 10 random questions on mount
  - Maintain socket assigns:
    - `:questions` - list of 10 Question structs
    - `:user_answers` - map of question_id → user_answer string
    - `:user_motivations` - map of question_id → motivation string
    - `:quiz_submitted` - boolean flag (false initially)
    - `:final_score` - integer (nil until submitted)
  - Implement event handlers:
    - `"answer_selected"` - update user_answers map
    - `"motivation_changed"` - update user_motivations map
    - `"submit_quiz"` - validate, score, transition to results view
  - Implement validation logic: all questions answered + all motivations filled
  - **Status:** not-started

#### 2.2 Create Quiz Template (Pre-Submission View)
- **File:** `lib/my_app_web/live/quiz_live.html.heex`
- **Task:**
  - Wrap all content with `<Layouts.app flash={@flash} current_scope={...}>`
  - Display header with "Quiz" title and question count indicator
  - Create loop for each question:
    ```heex
    <%= for {question, index} <- Enum.with_index(@questions) do %>
      <div class="question-block">
        <!-- Question number and text -->
        <!-- Radio buttons for 4 options -->
        <!-- Textarea for motivation -->
      </div>
    <% end %>
    ```
  - Use `.input` component from `core_components.ex` for radio buttons and textarea
  - Add unique DOM IDs to form elements (e.g., `id="question_#{index}_answer"`)
  - "Submit Quiz" button:
    - Disabled by default: `:disabled={not is_quiz_complete?(@user_answers, @user_motivations)}`
    - Enabled when all 10 questions have answers + motivations
    - `phx-click="submit_quiz"`
  - Style with Tailwind + DaisyUI for clean, professional look
  - **Status:** not-started

#### 2.3 Create Results Template (Post-Submission View)
- **File:** Create as conditional render in `quiz_live.html.heex` OR as separate component
- **Task:**
  - Conditionally render based on `@quiz_submitted` flag
  - Display score prominently: "**Your Score: X/10**" (use DaisyUI alert/badge)
  - For each question, display feedback block:
    ```
    Question: [text]
    Your Answer: [user's selected answer]
    Your Motivation: [user's entered motivation]
    ✓ Correct Answer: [correct answer] (highlighted in green if user was correct)
    ✗ Correct Answer: [correct answer] (highlighted in red if user was incorrect)
    Explanation: [official motivation from data]
    ```
  - Use `.icon` component for visual indicators (✓/✗)
  - Add "Retake Quiz" button that resets state and reloads questions
  - Use Tailwind conditional classes for styling correct/incorrect answers
  - **Status:** not-started

---

### Phase 3: Core Business Logic

#### 3.1 Implement Quiz Completion Validation
- **File:** `lib/my_app_web/live/quiz_live.ex`
- **Task:**
  - Create helper function: `is_quiz_complete?/2`
  - Check: all 10 questions have a non-empty answer selected
  - Check: all 10 questions have non-empty motivation text
  - Return boolean
  - **Status:** not-started

#### 3.2 Implement Scoring Algorithm
- **File:** `lib/my_app_web/live/quiz_live.ex`
- **Task:**
  - Create function: `calculate_score/3` (questions, user_answers, user_motivations)
  - Algorithm:
    ```
    score = 0
    for each question in questions:
      user_answer = user_answers[question.id]
      if user_answer == question.correct_answer:
        score += 1
    return score
    ```
  - Ensure string comparison is case-sensitive and exact-match only
  - Return integer 0-10
  - **Status:** not-started

#### 3.3 Implement Quiz Reset/Retake
- **File:** `lib/my_app_web/live/quiz_live.ex`
- **Task:**
  - Create handler: `"retake_quiz"` event
  - Fetch 10 new random questions
  - Reset socket assigns to initial state:
    - `:questions` = new questions
    - `:user_answers` = empty map
    - `:user_motivations` = empty map
    - `:quiz_submitted` = false
    - `:final_score` = nil
  - Transition UI back to Quiz View
  - **Status:** not-started

---

### Phase 4: UI/UX Polish

#### 4.1 Styling & Responsive Design
- **File:** `assets/css/app.css` (if needed) + templates
- **Task:**
  - Ensure Tailwind imports are correct per guidelines
  - Create polished, world-class design using Tailwind + DaisyUI
  - Implement responsive layout (mobile-first)
  - Add subtle micro-interactions:
    - Hover effects on buttons
    - Smooth transitions between Quiz View ↔ Results View
    - Loading states if needed
  - Ensure proper spacing, typography, and visual hierarchy
  - **Status:** not-started

#### 4.2 Accessibility & UX
- **File:** Templates + LiveView
- **Task:**
  - Ensure proper form labels and ARIA attributes
  - Make submission button state clear (disabled/enabled visual indicator)
  - Display validation feedback if user tries to submit incomplete quiz
  - Add question progress indicator (e.g., "Question 5 of 10")
  - Ensure keyboard navigation works
  - **Status:** not-started

---

### Phase 5: Testing

#### 5.1 Unit Tests for Question Schema
- **File:** `test/my_app/quiz_test.exs`
- **Task:**
  - Test Question validation (required fields, 4 options, matching correct_answer)
  - Test database seeding completes without errors
  - Test `get_random_questions/1` returns exactly N questions
  - Test questions are truly random (statistical check, optional)
  - **Status:** not-started

#### 5.2 Unit Tests for Scoring Logic
- **File:** `test/my_app_web/live/quiz_live_test.exs`
- **Task:**
  - Test `calculate_score/3` with various scenarios:
    - Perfect score (10/10)
    - Partial score (5/10)
    - No score (0/10)
    - Motivation field ignored in scoring
  - **Status:** not-started

#### 5.3 LiveView Integration Tests
- **File:** `test/my_app_web/live/quiz_live_test.exs`
- **Task:**
  - Test initial render loads 10 questions
  - Test Submit button disabled until all questions answered
  - Test form submission triggers scoring
  - Test Results View displays correct score
  - Test Results View displays correct/incorrect answers with feedback
  - Test Retake Quiz resets state and shows new questions
  - Use `element/2`, `has_element/2`, LazyHTML for assertions
  - Reference key DOM IDs from templates
  - **Status:** not-started

---

### Phase 6: Router & Final Integration

#### 6.1 Define Quiz Route
- **File:** `lib/my_app_web/router.ex`
- **Task:**
  - Add route to quiz LiveView in appropriate scope:
    ```elixir
    scope "/", MyAppWeb do
      pipe_through :browser
      live "/quiz", QuizLive, :index
    end
    ```
  - Ensure routing is consistent with Phoenix conventions
  - **Status:** not-started

#### 6.2 Integration & Final Testing
- **File:** All files
- **Task:**
  - Run `mix precommit` to validate:
    - No compile errors
    - All tests pass
    - Formatter compliance
    - Credo static analysis
  - Manual testing:
    - Navigate to `/quiz`
    - Complete quiz workflow (answer all questions, submit, see results)
    - Verify score calculation is correct
    - Test retake functionality
    - Verify no data persists after page reload
  - **Status:** not-started

---

## File Structure Summary

```
lib/
├── my_app/
│   └── quiz/
│       └── question.ex                    # Schema
└── my_app_web/
    └── live/
        └── quiz_live.ex                   # LiveView + handlers
        └── quiz_live.html.heex            # Templates (Quiz + Results)

priv/
└── repo/
    ├── migrations/
    │   └── XXXXX_create_questions.exs    # Migration
    └── seeds.exs                          # Seed script

test/
├── my_app/
│   └── quiz_test.exs                     # Schema/context tests
└── my_app_web/
    └── live/
        └── quiz_live_test.exs            # LiveView tests

seeding.json                              # Question data source
```

---

## Key Implementation Details

### Data Validation
- Question must have exactly 4 options
- `correct_answer` must be an exact string match to one of the options
- User motivation field must be non-empty (min 1 character)

### Scoring
- String comparison is case-sensitive and exact-match only
- Motivation text does NOT affect score
- Maximum score: 10
- Minimum score: 0

### State Management
- All state held in LiveView socket assigns
- No database writes for user answers/motivations
- No localStorage, sessionStorage, cookies, or IndexedDB usage
- Data discarded on page reload/close

### UI Behavior
- Submit button disabled until all 10 questions have answers + motivations
- Results View replaces Quiz View immediately upon submission
- Retake Quiz button allows user to restart with new random questions
- All navigation client-side (no page reloads)

---

## Decisions Confirmed

✅ **Question ID Generation**: Use auto-generated database IDs for user answer tracking  
✅ **Randomization Strategy**: Use `RANDOM()` at database query time (no issues)  
✅ **Question Uniqueness**: All 10 questions must be unique per quiz session  
✅ **Styling**: Simple, easy-to-read style (no complex design requirements)  
✅ **Error Handling**: No edge-case handling needed at this stage  
✅ **Admin Features**: No admin endpoints or testing utilities needed  

---

## Deliverables Checklist

- [ ] Question schema and migrations
- [ ] Database seeding from seeding.json
- [ ] Quiz context module with query functions
- [ ] Quiz LiveView with state management
- [ ] Quiz template (pre-submission view)
- [ ] Results template (post-submission view)
- [ ] Scoring logic and validation
- [ ] Styling and responsive design
- [ ] Unit tests (schema, context, scoring)
- [ ] LiveView integration tests
- [ ] Router configuration
- [ ] `mix precommit` validation
- [ ] Manual end-to-end testing

---

## Timeline Estimate

**Phases 1-2:** 2-3 hours (setup, data infrastructure, basic LiveView)  
**Phase 3:** 1-2 hours (business logic)  
**Phase 4:** 1-2 hours (styling and UX)  
**Phase 5:** 2-3 hours (testing)  
**Phase 6:** 1 hour (routing, final validation)  

**Total:** ~8-12 hours (depending on complexity preferences and testing rigor)

---

## Phase 1 Completion Status ✓

**All Phase 1 tasks completed:**

✅ Question schema created (`lib/quiz_app/quiz/question.ex`) with:
  - Ecto schema definition
  - Validation for 4 options requirement
  - Validation that correct_answer matches one of the options

✅ Database migration created (`priv/repo/migrations/20251113000001_create_questions.exs`)
  - Creates questions table with proper field types
  - Array type for options, text type for motivation

✅ Quiz context module created (`lib/quiz_app/quiz.ex`) with:
  - `get_random_questions/1` - returns N random questions using RANDOM()
  - `get_all_questions/0` - retrieves all questions
  - `get_question_count/0` - returns total count
  - `create_question/1` - for seeding
  - `delete_all_questions/0` - for reseeding

✅ Seeds file created (`priv/repo/seeds.exs`)
  - Loads seeding.json from priv directory
  - Parses JSON and inserts all questions into database
  - Handles errors gracefully

✅ Complete Phoenix v1.8 project structure:
  - Application, Repo, Endpoint, Router modules
  - Configuration files (config.exs, dev.exs, test.exs, prod.exs)
  - Web module with plug pipelines
  - Layout and CoreComponents modules
  - Basic home page LiveView
  - Error handlers
  - Asset configuration (Tailwind, esbuild)
  - Basic styling with Tailwind CSS

### Ready for Phase 2

The project is now ready for Phase 2 implementation of the Quiz LiveView.

---

## Notes

- Follow all Phoenix v1.8 and Elixir guidelines from `architecture.md`
- Use Tailwind v4 with DaisyUI for components
- Leverage `.input` and `.icon` components from `core_components.ex`
- Ensure proper LiveView forms using `to_form/2` and `<.form>` components
- Reference DOM IDs in tests for robust, maintainable test suite
- Avoid nested modules in single files to prevent cyclic dependencies
- Use `mix precommit` as final validation gate
