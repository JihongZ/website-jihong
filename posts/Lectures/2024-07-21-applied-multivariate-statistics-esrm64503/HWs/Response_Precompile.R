library(haven)
library(ggplot2)
library(tidyr)
library(dplyr)
library(glue)

hw_resp_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/Responses/" 
hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
assignment_filenames <- list.files(hw_resp_path)


# In-Class Quiz -----------------------------------------------------------
quiz_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_In-class Quiz 1.xlsx"))
colnames(quiz_tbl)
quiz_tbl_clean <- quiz_tbl[, c(2, 7, 8, 9)]
colnames(quiz_tbl_clean) <- c("Starting_Time", "Name", "Question1_Response", "Question2_Response")
quiz_tbl_clean$TotalScore <- 16

quiz_tbl_clean$Name <- toupper(quiz_tbl_clean$Name)
quiz_tbl_clean <- quiz_tbl_clean |> 
  mutate(Name = case_when(
    Name == "SUMAIYA FARZANA" ~ "SUMAIYA FARZANA MISHU",
    Name == "ENIOLA" ~ "ENIOLA OLA",
    TRUE ~ Name
  )) |> 
  group_by(Name) |> 
  filter(Starting_Time == max(Starting_Time)) |> 
  pivot_longer(-c(Starting_Time, Name, TotalScore), names_to = "Questions", values_to = "Responses") |> 
  separate(Questions, into = c("Questions", "Type")) |> 
  pivot_wider(names_from = "Type", values_from = "Responses") |> 
  mutate(HW = "Quiz0")


# Homework 0 --------------------------------------------------------------
assignment_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 0.xlsx"))
colnames(assignment_tbl)
hw0_assignment_tbl_clean <- assignment_tbl[, c(2, 10, 13, 16, 6, 19:21)]
colnames(hw0_assignment_tbl_clean) <- c("Starting_Time", "Name", "Question1_Response", "Question2_Response", "TotalScore" , "Question1_Answer", "Question2_Answer", "Comment")
hw0_assignment_tbl_clean$Name <- toupper(hw0_assignment_tbl_clean$Name)
hw0_assignment_tbl_clean <- hw0_assignment_tbl_clean |> 
  mutate(Name = case_when(
    Name == "SUMAIYA FARZANA" ~ "SUMAIYA FARZANA MISHU",
    Name == "JENNIFFER ROA" ~ "JENNIFFER ROA LOZANO",
    TRUE ~ Name
  )) |> 
  group_by(Name) |> 
  filter(Starting_Time == max(Starting_Time)) |> 
  select(-Comment) |> 
  pivot_longer(-c(Starting_Time, Name, TotalScore), names_to = "Questions", values_to = "Responses") |> 
  separate(Questions, into = c("Questions", "Type")) |> 
  pivot_wider(names_from = "Type", values_from = "Responses") |> 
  mutate(HW = "0")


# Homework 1 --------------------------------------------------------------
assignment_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 1.xlsx"))
colnames(assignment_tbl)
hw1_assignment_tbl_clean <- assignment_tbl[, c(2, 7, 8:13)]
colnames(hw1_assignment_tbl_clean) <- c("Starting_Time", "Name", "Question1_Response", "Question2_Response", "TotalScore", "Question1_Answer", "Question2_Answer", "Comment")
hw1_assignment_tbl_clean$Name <- toupper(hw1_assignment_tbl_clean$Name)
hw1_assignment_tbl_clean <- hw1_assignment_tbl_clean |> 
  mutate(Name = case_when(
    Name == "SUMAIYA FARZANA" ~ "SUMAIYA FARZANA MISHU",
    Name == "JENNIFFER ROA" ~ "JENNIFFER ROA LOZANO",
    TRUE ~ Name
  )) |> 
  group_by(Name) |> 
  filter(Starting_Time == max(Starting_Time)) |> 
  select(-Comment) |> 
  pivot_longer(-c(Starting_Time, Name, TotalScore), names_to = "Questions", values_to = "Responses") |> 
  separate(Questions, into = c("Questions", "Type")) |> 
  pivot_wider(names_from = "Type", values_from = "Responses") |> 
  mutate(HW = "1")


# Homework 2 --------------------------------------------------------------
if (0) { # pre-clean
  assignment_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 2.xlsx"))
  colnames(assignment_tbl)
  hw2_assignment_tbl_clean <- assignment_tbl[, c(2, 7:17)]
  hw2_assignment_tbl_clean <- hw2_assignment_tbl_clean |> 
    rename("Name" = "Your Name is\r\n",
           "Starting_Time" = "开始时间") |> 
    mutate(Name = toupper(Name)) |> 
    group_by(Name) |> # Only keep the lastest record
    filter(Starting_Time == max(Starting_Time)) |> 
    pivot_longer(-c(Starting_Time, Name), names_to = "Questions", values_to = "Response")
  writexl::write_xlsx(hw2_assignment_tbl_clean, path = paste0(hw_resp_path, "ESRM 64503_Homework 2_long.xlsx"))
}

hw2_assignment_tbl_clean <- readxl::read_xlsx(path = paste0(hw_resp_path, "ESRM 64503_Homework 2_long.xlsx"), sheet = 1)
hw2_assignment_tbl_clean <- hw2_assignment_tbl_clean |> 
  group_by(Name) |> 
  mutate(
    TotalScore = ifelse(sum(Score) > 21, 21, sum(Score)),
    Answer = "See Website",
    HW = "2")

## Homework 2B -------------------------------------------------------------
assignment_tbl2B <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 2B.xlsx"))
hw2b_assignment_tbl_clean <- assignment_tbl2B[, c(2, 7:17)]
hw2b_assignment_tbl_clean <- hw2b_assignment_tbl_clean |> 
  rename("Name" = "Your Name is\r\n",
         "Starting_Time" = "开始时间") |> 
  mutate(Name = "SUMAIYA FARZANA MISHU") |> 
  group_by(Name) |> # Only keep the lastest record
  filter(Starting_Time == max(Starting_Time)) |> 
  pivot_longer(-c(Starting_Time, Name), names_to = "Questions", values_to = "Response")
## Scoring
Score_2b <- rep(NA, 10)
hw2b_assignment_tbl_clean$Response[1]
Score_2b[1] = 2
hw2b_assignment_tbl_clean$Response[2]
Score_2b[2] = 2
hw2b_assignment_tbl_clean$Response[3]
Score_2b[3] = 2
hw2b_assignment_tbl_clean$Response[4]
Score_2b[4] = 3
hw2b_assignment_tbl_clean$Response[5]
Score_2b[5] = 2
hw2b_assignment_tbl_clean$Response[6]
Score_2b[6] = 2
hw2b_assignment_tbl_clean$Response[7]
Score_2b[7] = 2
hw2b_assignment_tbl_clean$Response[8]
Score_2b[8] = 3
hw2b_assignment_tbl_clean$Response[9]
Score_2b[9] = 3
hw2b_assignment_tbl_clean$Response[10]
Score_2b[10] = 3

hw2b_assignment_tbl_clean <- hw2b_assignment_tbl_clean |> 
  mutate(
    Score = Score_2b,
    TotalScore = ifelse(sum(Score_2b) > 21, 21, sum(Score_2b)),
    Answer = "See Website",
    HW = "2"
  )

# Combine Homeworks -------------------------------------------------------
hw_all_tbl <- 
  rbind(
    quiz_tbl_clean,
    hw0_assignment_tbl_clean,
    hw1_assignment_tbl_clean,
    hw2_assignment_tbl_clean,
    hw2b_assignment_tbl_clean
  )


set.seed(1234)

# passwords <- data.frame(
#   Name = unique(hw_all_tbl$Name),
#   Code = sample(x = 1000:9999, size = 12)
# ) |> arrange(Name)
# write.csv(passwords, file = paste0(hw_root_path, "ESRM64503_Homework_PW.csv"))
passwords <- read.csv(paste0(hw_root_path, "ESRM64503_Homework_PW.csv"), row.names = NULL)

hw_all_tbl <- hw_all_tbl |> 
  left_join(passwords |> select(-X), by = "Name")

saveRDS(hw_all_tbl, file = paste0(hw_root_path, "ESRM64503_Homework_Combined.rds"))
