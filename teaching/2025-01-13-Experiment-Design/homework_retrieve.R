## Googlesheet ----
library(tidyverse)
library(stringr)
library(googlesheets4)
ss <- "https://docs.google.com/spreadsheets/d/14ksHTcHcJeVBZaI4a14VTFxLO7Y8f0mUefTGjxQr3Qg/edit?gid=1474694440#gid=1474694440"
survey_data <- read_sheet(ss)

question_content <- colnames(survey_data)[10:12]
colnames(survey_data)[10:12] <- paste0("Q", 1:3)

### Q1 
survey_data$Q1

### Q2
survey_data$Q2

### Q3
survey_data$Q3


### Roster
ss2 <- "https://docs.google.com/spreadsheets/d/1voZ9goi-TbMp8FkGEx2GiyXE2L2XAcE-u0lrmuJUEk0/edit?gid=2089919421#gid=2089919421"
roster_table <- read_sheet(ss2)
dim(roster_table)

### Check those who did not submit the response
### Names: chech how many answered
current_names <- survey_data$`Your Names?`
answered_people <- current_names |> 
  stringr::str_split(pattern = " ") |> 
  map(~toupper(.x[1])) |> 
  unlist()
roster_table |> 
  mutate(first_name = toupper(str_split_i(Student, pattern = " ", i = 1))) |> 
  filter(!(first_name %in% answered_people)) |> 
  pull(`Email Address`) |> 
  paste0(collapse = ";")

## Typeform ----
# Example form: https://form.typeform.com/to/jxmop4CX
library(httr2)
library(tidyverse)
library(rtypeform)

forms = get_forms()

attr(forms, "total_items")

# Most recent typeform
form_id = forms$form_id[1]
q = get_responses(form_id, completed = NULL)

question_types = q[-1] %>% # Remove the meta
  map(~select(.x, type)) %>%
  map_df(~slice(.x, 1)) %>%
  pull()

## Responses
q[-1] |> 
  map_df(~slice(.x, 1)) 

## Extract questions
res <- get_response(api = Sys.getenv("typeform_api2"), url = forms[1,]$questions)
res$fields$properties$fields[3:4] |> 
  map(~select(.x, id, title)) |> 
  bind_rows()
