## Googlesheet ----
library(tidyverse)
library(stringr)
library(googlesheets4)

## Homework 1
hw1_google_sheet_url <- "https://docs.google.com/spreadsheets/d/19K54jzmto40qUIzLdW4izNhmVo-0hsrQykR_6w1SjDw/edit?resourcekey=&gid=1650869889#gid=1650869889"

hw1_data_raw <- read_sheet(hw1_google_sheet_url) 

hw1_data_clean <- hw1_data_raw |> 
  mutate(Timestamp = as.POSIXct(Timestamp, format = "%Y-%m-%d %H:%M:%S")) |> 
  group_by(`Your Workday ID is`) |> 
  filter(Timestamp == max(Timestamp)) |> 
  ungroup()

colnames(hw1_data_clean) <- c("Time", "Name", "ID", paste0("Q", 1:3))

hw1_data_clean <- 
  hw1_data_clean |> 
  mutate(Q3 = as.character(Q3))

## Answer
# Q1: 82.36(0.54)
# Q2: 87.96(0.54)
# Q3: 0.76
library(stringr)

hw1_data_final <- hw1_data_clean |> 
  mutate(
    Q1_estimate = ifelse(str_detect(hw1_data_clean$Q1, "82.36"), "", "Q1 has incorrect estimate. The answer is 82.36."),
    Q1_strr = ifelse(str_detect(hw1_data_clean$Q1, "0.54"), "", "Q1 has incorrect standard error. The answer is 0.54."),
    Q2_estimate = ifelse(str_detect(hw1_data_clean$Q2, "87.96"), "", "Q2 has incorrect estimate. The answer is 87.96."),
    Q2_strr = ifelse(str_detect(hw1_data_clean$Q2, "0.54"), "", "Q2 has incorrect standard error. The answer is 0.54."),
    Q3_strr = ifelse(str_detect(hw1_data_clean$Q3, "0.76"), "", "Q3 has incorrect standard error. The answer is 0.76.")
  ) |> 
  rowwise() |> 
  mutate(
    Feedback = paste0(Q1_estimate, Q1_strr, Q2_estimate, Q2_strr, Q3_strr),
    Answer = paste0(c(Q1, Q2, Q3), collapse = " ;"))

hw1_data_final |> select(Name, Answer, Feedback) |> View()

## Homework 2 ----
hw2_google_sheet_url <- "https://docs.google.com/spreadsheets/d/1Tlxx-vKLW14ZuPbzrL7MtlPMtqGwdeW7Fzuv0f_hqWc/edit?resourcekey=&gid=2095410061#gid=2095410061"

hw2_data_raw <- read_sheet(hw2_google_sheet_url) 

hw2_data_clean <- hw2_data_raw |> 
  mutate(Timestamp = as.POSIXct(Timestamp, format = "%Y-%m-%d %H:%M:%S")) |> 
  group_by(`Your first name is`) |> 
  filter(Timestamp == max(Timestamp)) |> 
  ungroup()

hw2_answers <- hw2_data_clean[, 3:12]

colnames(hw2_answers) <- c("Name", paste0("Q", 1:9))

write_csv(hw2_answers, "hw2_answers.csv")
