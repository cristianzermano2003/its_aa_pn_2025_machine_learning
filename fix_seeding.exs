alias QuizApp.Repo
alias QuizApp.Quiz.Question

# First, load and parse the JSON directly with string manipulation
content = File.read!("seeding.json")

# Simple string-based fix: replace the 5-option RLHF with 4-option version
fixed_content = String.replace(
  content,
  ~S{"question": "What is 'RLHF' (Reinforcement Learning from Human Feedback)?",
        "options": [
            "The initial unsupervised training step on web-scale data",
            "The process of breaking text into numerical tokens",
            "A 2017 paper that introduced the Transformer architecture",
            "A fine-tuning step where human rankings of model outputs are used to train a 'reward model' to make the LLM more helpful and aligned",
            "A fine-tuning step where human rankings of model outputs are used to train a 'reward model' to make the LLM more helpful and aligned"
        ],},
  ~S{"question": "What is 'RLHF' (Reinforcement Learning from Human Feedback)?",
        "options": [
            "The initial unsupervised training step on web-scale data",
            "The process of breaking text into numerical tokens",
            "A 2017 paper that introduced the Transformer architecture",
            "A fine-tuning step where human rankings of model outputs are used to train a 'reward model' to make the LLM more helpful and aligned"
        ],}
)

File.write!("seeding.json", fixed_content)
IO.puts("✓ Fixed seeding.json in root directory")

# Also copy to priv/repo
File.cp!("seeding.json", "priv/repo/seeding.json")
IO.puts("✓ Copied to priv/repo/seeding.json")
