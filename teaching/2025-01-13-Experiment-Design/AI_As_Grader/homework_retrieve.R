# Homework 1 -------
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


### Roster readin -----------------
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



# Student_Email_Qs --------------------------------------------------------
Student_Email_Qs <- roster_table |> 
  mutate(first_name = toupper(str_split_i(Student, pattern = " ", i = 1))) |> 
  select(first_name, email = `Email Address`) |> 
  left_join(
    {
      survey_data |> 
        select(Name = `Your Names?`, Q1, Q2, Q3) |> 
        mutate(first_name = toupper(str_split_i(Name, pattern = " ", i = 1))) 
    }, by = "first_name"
  )

# LLM as judge
library(ellmer)

System_prompt <- paste(read_lines("teaching/2025-01-13-Experiment-Design/AI_As_Grader/Prompt.md"), collapse = "\n")
# cat(System_prompt)



for (i in 1:nrow(Student_Email_Qs)) {
  client <- chat_openai(model = "gpt-4.1", system_prompt = System_prompt)
  
  stu_name <- Student_Email_Qs$Name[i]
  stu_email <- Student_Email_Qs$email[i]
  
  user_prompts <- paste(c(
    "<Student_answer_Question1>",
    Student_Email_Qs$Q1[i],
    "<End_Student_answer_Question1>",
    "<Student_answer_Question2>",
    Student_Email_Qs$Q2[i],
    "<End_Student_answer_Question2>",
    "<Student_answer_Question3>",
    Student_Email_Qs$Q3[i],
    "<End_Student_answer_Question3>"
  ), collapse = "\n")
  
  stu_evaluation <- client$chat(user_prompts, echo = "none")

  ## Combine name, email, evaluation, grading
  report <- paste0(c(
    "## Student Name: ", stu_name, "\n",
    "## Student Email: ", stu_email, "\n",
    "## Student Evaluation: ", stu_evaluation, "\n"
  ), collapse = "\n")
  
  report_filename <- paste0("Final_Report_Student", i)
  write_file(report, paste0("~/Downloads/ESRM64103_HW1_Report/", report_filename,".md"))
}

### Text mining about student name and total score
report_files <- list.files("~/Downloads/ESRM64103_HW1_Report/", pattern = ".md")
student_name <- rep(0, nrow(Student_Email_Qs))
student_firstname <- rep(0, nrow(Student_Email_Qs))
total_scores <- rep(0, nrow(Student_Email_Qs))

for (f in seq_along(report_files)) { # f = 4
  report_filename <- report_files[f]
  report_text <- readLines(paste0("~/Downloads/ESRM64103_HW1_Report/", report_filename))
  total_score <- str_extract(report_text[str_detect(report_text, "TOTAL_SCORE:")], "\\d+")
  total_scores[f] <- as.numeric(trimws(total_score))
  
  Name <- report_text[which(str_detect(report_text, "Student Name")) + 1]
  student_name[f] <- Name
  
  first_name = toupper(str_split_i(Name, pattern = " ", i = 1))
  student_firstname[f] <- first_name
}

Grading_Homework1 <- 
  Student_Email_Qs |> 
  select(first_name) |> 
  left_join(
    data.frame(
      First_name = student_firstname,
      Name = student_name,
      Score = total_scores
    ), by = c("first_name" = "First_name")
  ) 
  
write.csv(
  Grading_Homework1, "~/Downloads/ESRM64103_HW1_Report/Grading_Homework1.csv", row.names = FALSE
)

