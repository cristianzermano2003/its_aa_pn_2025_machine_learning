# System Architecture - Quiz Application

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Browser (Client)                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phoenix LiveView (JavaScript)                         │  │
│  │  - Real-time WebSocket connection                      │  │
│  │  - DOM updates without full page reloads               │  │
│  │  - Sends events: answer_selected, motivation_changed   │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  UI Components (HEEx Templates)                        │  │
│  │  - Quiz View (questions + inputs)                      │  │
│  │  - Results View (score + feedback)                     │  │
│  │  - Styled with Tailwind CSS                            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↑ ↓
           WebSocket Connection (Phoenix.Socket)
                            ↑ ↓
┌─────────────────────────────────────────────────────────────┐
│                  Phoenix Server (Backend)                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  QuizLive (LiveView Module)                           │  │
│  │  - mount/3: Initialize 10 random questions            │  │
│  │  - handle_event/3: Process answer_selected, etc.      │  │
│  │  - render/1: Generate HEEx templates                  │  │
│  │  - Helper functions: is_quiz_complete?, score calc    │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Quiz Context (quiz.ex)                               │  │
│  │  - get_random_questions/1                             │  │
│  │  - get_all_questions/0                                │  │
│  │  - create_question/1                                  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↑ ↓
                    Ecto.Query Operations
                            ↑ ↓
┌─────────────────────────────────────────────────────────────┐
│                  PostgreSQL Database                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Questions Table                                      │  │
│  │  - id (auto-increment)                                │  │
│  │  - question (text)                                    │  │
│  │  - options (array of strings)                         │  │
│  │  - correct_answer (string)                            │  │
│  │  - motivation (text explanation)                      │  │
│  │  - created_at, updated_at (timestamps)                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Quiz Initialization (Mount)
```
Browser Request (/quiz)
    ↓
Phoenix Router → QuizLive mount/3
    ↓
call Quiz.get_random_questions(10)
    ↓
Ecto Query: SELECT * FROM questions ORDER BY RANDOM() LIMIT 10
    ↓
PostgreSQL executes, returns 10 random rows
    ↓
Questions assigned to socket
    ↓
Render Quiz View (pre-submission)
    ↓
Send to Browser + Establish WebSocket
```

### 2. User Interaction (Answer + Motivation)
```
User selects radio button
    ↓
JavaScript event: phx-click="answer_selected"
    ↓
WebSocket: {event: "answer_selected", question_id: 1, answer: "Option B"}
    ↓
Server receives event → handle_event/3
    ↓
Update socket.assigns.user_answers[1] = "Option B"
    ↓
Render template with updated answer
    ↓
Send DOM update to browser (only changed elements)
    ↓
Update UI (radio button marked as checked)
```

### 3. Form Submission (Submit Quiz)
```
User clicks Submit button
    ↓
JavaScript event: phx-submit="submit_quiz"
    ↓
Server receives event
    ↓
Validation: All 10 questions answered + motivated?
    ↓
YES: Calculate score
    ├─ For each question:
    │  ├─ Get user_answer from socket.assigns
    │  ├─ Compare to question.correct_answer
    │  ├─ If match: score += 1
    │  └─ Continue to next
    ↓
Update socket:
    ├─ quiz_submitted = true
    └─ final_score = X (out of 10)
    ↓
Re-render with render_results/1
    ↓
Send Results View to browser
    ↓
Browser displays score + feedback
```

### 4. Retake Quiz
```
User clicks "Retake Quiz" button
    ↓
Event: phx-click="retake_quiz"
    ↓
Server: call Quiz.get_random_questions(10)
    ↓
Reset socket assigns:
    ├─ questions = [new 10 questions]
    ├─ user_answers = %{}
    ├─ user_motivations = %{}
    ├─ quiz_submitted = false
    └─ final_score = nil
    ↓
Re-render Quiz View
    ↓
Browser shows fresh quiz form
```

## Session State Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    Session Lifecycle                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. USER VISITS /quiz                                       │
│     └─ mount/3 called                                       │
│        └─ 10 random questions loaded                        │
│           └─ Socket assigns initialized                     │
│              ├─ questions: [Q1, Q2, ..., Q10]               │
│              ├─ user_answers: %{}                           │
│              ├─ user_motivations: %{}                       │
│              ├─ quiz_submitted: false                       │
│              └─ final_score: nil                            │
│                                                              │
│  2. USER ANSWERS QUESTIONS (Loop)                           │
│     ├─ Selects answer option                                │
│     │  └─ handle_event("answer_selected", ...)             │
│     │     └─ user_answers[Q.id] = "Option B"               │
│     │                                                       │
│     └─ Types motivation                                     │
│        └─ handle_event("motivation_changed", ...)          │
│           └─ user_motivations[Q.id] = "Because..."         │
│                                                              │
│  3. USER SUBMITS                                            │
│     └─ handle_event("submit_quiz", ...)                    │
│        ├─ is_quiz_complete?() returns true                 │
│        ├─ calculate_score() returns 8                       │
│        ├─ quiz_submitted = true                            │
│        ├─ final_score = 8                                  │
│        └─ render_results() called                          │
│           └─ Display results view                          │
│                                                              │
│  4a. USER CLOSES BROWSER / REFRESHES                        │
│      └─ Session ends                                        │
│         └─ ALL STATE LOST (by design)                       │
│                                                              │
│  4b. USER CLICKS RETAKE                                     │
│      └─ New 10 questions loaded                             │
│         └─ All state reset                                  │
│            └─ Back to Quiz View                             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## No Persistence Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Browser Session                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │ LiveView Socket State (In-Memory)                  │  │
│  │ - questions: [10 Questions]                        │  │
│  │ - user_answers: %{...}                             │  │
│  │ - user_motivations: %{...}                         │  │
│  │ - quiz_submitted: boolean                          │  │
│  │ - final_score: integer                             │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Lifetime: Page Load → Page Close/Refresh                │
│  Storage: Erlang process memory (NOT persisted)          │
│                                                          │
│  ✗ NO localStorage                                       │
│  ✗ NO sessionStorage                                     │
│  ✗ NO cookies                                            │
│  ✗ NO IndexedDB                                          │
│  ✗ NO server database writes                             │
│                                                          │
│  If user:                                                │
│  ├─ Closes browser tab/window → State LOST               │
│  ├─ Refreshes page → State LOST                          │
│  ├─ Navigates away → State LOST                          │
│  ├─ Loses connection → State LOST on reconnect           │
│  └─ Completes quiz → Session ends, state discarded       │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                   Database (Persistent)                   │
├──────────────────────────────────────────────────────────┤
│ questions table (populated once from seeding.json)        │
│                                                          │
│ READ ONLY during quiz session:                           │
│ ├─ Load 10 random questions at quiz start                │
│ └─ Load question explanations at results time            │
│                                                          │
│ NO WRITES from quiz sessions:                            │
│ ├─ User answers NOT saved                                │
│ ├─ Motivations NOT saved                                 │
│ ├─ Scores NOT saved                                      │
│ ├─ Quiz history NOT saved                                │
│ └─ User tracking NOT recorded                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Component Hierarchy

```
Root Layout (root.html.heex)
├─ DOCTYPE, Meta Tags, Assets
└─ <body> inner_content
   └─ App Layout (app.html.heex)
      ├─ Header
      ├─ Main Content (inner_content)
      │  └─ Quiz View OR Results View
      │     ├─ Quiz Form (pre-submission)
      │     │  └─ Question Blocks (10x)
      │     │     ├─ RadioButtons (4x per question)
      │     │     └─ Textarea (motivation)
      │     │
      │     └─ Results View (post-submission)
      │        ├─ Score Card
      │        └─ Feedback Blocks (10x)
      │           ├─ User's Answer
      │           ├─ User's Motivation
      │           ├─ Correct Answer
      │           └─ Official Explanation
      │
      └─ Footer
```

## State Machine

```
                    ┌──────────────┐
                    │ INITIAL STATE│
                    └──────┬───────┘
                           │
                    mount/3 called
                    10 questions loaded
                           │
                           ▼
                    ┌──────────────────┐
                    │ QUIZ VIEW SHOWN  │
                    │ questions: [10]  │
                    │ answers: {}      │
                    │ motivated: {}    │
                    │ submitted: false │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
          answer_selected  motivation_changed
          (repeat 10x)      (repeat 10x)
              │              │              │
              └──────────────┼──────────────┘
                             │
                  All 10 answers selected
                  All 10 motivations filled
                             │
                             ▼
                   ┌───────────────────┐
                   │ Submit button now │
                   │     enabled       │
                   └────────┬──────────┘
                            │
                    User clicks Submit
                            │
                            ▼
                   ┌──────────────────┐
                   │ SCORING PHASE    │
                   │ Calculate score  │
                   │ (string match)   │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌──────────────────────┐
                   │ RESULTS VIEW SHOWN   │
                   │ score: X/10          │
                   │ submitted: true      │
                   │ Feedback for each Q  │
                   └────────┬─────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
      retake_quiz      User closes      User refreshes
      or Restart        browser         page
          │                 │                 │
          ▼                 ▼                 ▼
    Reset to INITIAL  Session ends     Session ends
    Load new 10 Qs   (NO tracking)  (NO tracking)
          │
          └──────────→ New quiz begins
```

---

**Architecture designed for:**
- ✅ Single-session assessments
- ✅ No user data persistence
- ✅ Real-time interactivity
- ✅ Immediate feedback
- ✅ Privacy-focused design
