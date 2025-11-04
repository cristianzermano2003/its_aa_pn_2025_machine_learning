# Requirements Document

## 1. 🏛️ Core Data Structure (The Assessment Model)

To function, the application requires a clearly defined data model for the quiz content. Each of the 10 questions must be structured as an object containing the following properties:

* **`questionID`**: A unique identifier (e.g., `q1`, `q2`).
* **`questionText`**: The full text of the question (e.g., "Which principle of design emphasizes...").
* **`options`**: An array of four (4) string-based answer choices.
* **`correctOptionIndex`**: The index (0-3) of the correct answer within the `options` array.
* **`expertRationale`**: A pre-authored, comprehensive text explaining *why* the correct answer is correct.

---

## 2. 💻 User Interaction & Workflow

This section defines the mandatory user flow from start to submission.

### Quiz Interface
* The quiz shall present the 10 questions to the user. This can be a single, scrolling page or a paginated "one-question-at-a-time" view.
* For each of the 10 questions, the UI must display:
    1.  The **`questionText`**.
    2.  The four **`options`** (e.g., as radio buttons).
    3.  A mandatory **free-text input field** (e.g., `<textarea>`) for the user's justification.

### Input Validation & Progression
* **Mandatory Fields**: Progression to the next question (in a paginated view) or final submission (in a single-page view) must be programmatically blocked until the user has interacted with *both* components of the current question.
* **Constraint Logic**: For each question, the user *must* select one multiple-choice option AND type at least one character into the justification text field.
* **Final Submission**: A single "Submit Quiz" button will be present. Clicking this button initiates the grading process and locks the quiz from further edits.

---

## 3. ⚙️ Backend Processing & Scoring Logic

Upon user submission, the system must execute the following logic:

1.  **Data Capture**: The system collects the user's 10 answers. Each answer object will contain:
    * The `questionID`.
    * The `selectedOptionIndex` (the user's MCQ choice).
    * The `userJustification` (the user's free text).
2.  **Scoring Loop**: The system initializes a `score` variable to 0.
3.  **Comparison**: It iterates through the user's 10 answers. For each answer, it retrieves the corresponding `questionID` from the Core Data Structure.
4.  **Accuracy Check**: It compares the user's `selectedOptionIndex` with the stored `correctOptionIndex`.
    * **If match**: `score = score + 1`.
    * **If no match**: No points are awarded.
5.  **Ignore Justification**: The `userJustification` text is **explicitly ignored** for numerical scoring. It is saved alongside the answer for the feedback phase.
6.  **Final Score Calculation**: The system computes the final numerical score (e.g., "8/10" or "80%").

---

## 4. 📊 Post-Submission Feedback Display

Immediately after processing, the system must redirect the user to a "Results" page. This page is non-editable and purely informational.

### Summary View
* The user's final **numerical score** (e.g., "7/10") must be prominently displayed at the top of the page.

### Detailed Question Review
* Below the score, the application must display a review section for **all 10 questions**, regardless of whether the user answered them correctly or incorrectly.
* Each question's review card provides the core feedback loop by presenting a direct comparison.



* **Each review card must contain:**
    1.  **The Question**: The original `questionText`.
    2.  **Your Answer**: The `option` the user selected (e.g., "B. Homeostasis").
    3.  **Your Justification**: The `userJustification` text the user provided.
    4.  **Correct Answer**: The correct `option` from the data model.
    5.  **Expert Rationale**: The pre-authored `expertRationale`.

This structure allows the student to immediately cross-reference their own critical reasoning (their justification) against the expert's, which is the primary objective of the qualitative feedback.
