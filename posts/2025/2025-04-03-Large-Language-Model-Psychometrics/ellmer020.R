################################ ---
# ellmer 0.2.0 updates
# https://www.tidyverse.org/blog/2025/05/ellmer-0-2-0/
################################ ---
library(ellmer)
chat <- chat_openai()
#> Using model = "gpt-4.1".
#> state.name is a variable in the environment inclduing all 50 states
prompts <- interpolate("
  What do people from {{state.name}} bring to a potluck dinner?
  Give me the top three things.
")

results <- parallel_chat(chat, prompts)
# [working] (32 + 0) -> 10 -> 8 | ■■■■■■                            16%


chat <- chat_anthropic(echo = "output")
#> Using model = "claude-3-7-sonnet-latest".
chat$set_tools(btw::btw_tools("session"))
chat$chat("Do I have bslib installed?")