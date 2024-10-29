library(haven)
library(ggplot2)
library(tidyr)
library(dplyr)
library(glue)

hw_resp_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/Responses/" 
hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
assignment_filenames <- list.files(hw_resp_path)


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
  mutate(HW = 0)


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
  mutate(HW = 1)


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
    HW = 3)


# Combine Homeworks -------------------------------------------------------
hw_all_tbl <- 
  rbind(
    hw0_assignment_tbl_clean,
    hw1_assignment_tbl_clean,
    hw2_assignment_tbl_clean
  )
  


set.seed(1234)

passwords <- data.frame(
  Name = unique(hw_all_tbl$Name),
  Code = sample(x = 1000:9999, size = 13)
) |> arrange(Name)
passwords[passwords$Name == "JIHONG ZHANG", "Code"]= "0000"
write.csv(passwords, file = paste0(hw_root_path, "ESRM64503_Homework_PW.csv"))

hw_all_tbl <- hw_all_tbl |> 
  left_join(passwords, by = "Name")

saveRDS(hw_all_tbl, file = paste0(hw_root_path, "ESRM64503_Homework_Combined.rds"))
