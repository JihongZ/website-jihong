library(haven)
library(ggplot2)
library(tidyr)
library(dplyr)
library(glue)

hw_resp_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/Responses/" 
hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
assignment_filenames <- list.files(hw_resp_path)

## Homework 0
assignment_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 0.xlsx"))
colnames(assignment_tbl)
hw0_assignment_tbl_clean <- assignment_tbl[, c(2, 10, 13, 16, 6, 19:21)]
colnames(hw0_assignment_tbl_clean) <- c("Starting_Time", "Name", "Question1_Response", "Question2_Response", "Score_PerHW" , "Question1_Answer", "Question2_Answer", "Comment")
hw0_assignment_tbl_clean$Name <- toupper(hw0_assignment_tbl_clean$Name)
hw0_assignment_tbl_clean <- hw0_assignment_tbl_clean |> 
  mutate(Name = case_when(
    Name == "SUMAIYA FARZANA" ~ "SUMAIYA FARZANA MISHU",
    Name == "JENNIFFER ROA" ~ "JENNIFFER ROA LOZANO",
    TRUE ~ Name
  )) |> 
  group_by(Name) |> 
  mutate(Test_Times_HW0 = n()) |> 
  filter(Starting_Time == max(Starting_Time))

## Homework 1
assignment_tbl <- readxl::read_xlsx(paste0(hw_resp_path, "ESRM 64503_Homework 1.xlsx"))
colnames(assignment_tbl)
hw1_assignment_tbl_clean <- assignment_tbl[, c(2, 7, 8:13)]
colnames(hw1_assignment_tbl_clean) <- c("Starting_Time", "Name", "Question1_Response", "Question2_Response", "Score_PerHW", "Question1_Answer", "Question2_Answer", "Comment")
hw1_assignment_tbl_clean$Name <- toupper(hw1_assignment_tbl_clean$Name)
### Only keep the lastest record
hw1_assignment_tbl_clean <- hw1_assignment_tbl_clean |> 
  mutate(Name = case_when(
    Name == "SUMAIYA FARZANA" ~ "SUMAIYA FARZANA MISHU",
    Name == "JENNIFFER ROA" ~ "JENNIFFER ROA LOZANO",
    TRUE ~ Name
  )) |> 
  group_by(Name) |> 
  mutate(Test_Times_HW1 = n()) |> 
  filter(Starting_Time == max(Starting_Time))

## Combine Homeworks
hw_all_wide <- hw0_assignment_tbl_clean |> 
  left_join(hw1_assignment_tbl_clean, by = "Name", suffix = c("_HW0", "_HW1")) |> 
  mutate(across(everything(), \(x) as.character(x))) 
## Add jihong zhang for showcase
JihongZhang_case <- hw_all_wide[2, ]
JihongZhang_case$Name = "JIHONG ZHANG"
hw_all_wide <- rbind(hw_all_wide, JihongZhang_case)

hw_all_tbl <- hw_all_wide |> 
  pivot_longer(c(ends_with("_HW0"), ends_with("_HW1"))) |> 
  separate(name, into = c("Variable", "HW"), sep = "_HW") |> 
  pivot_wider(names_from = "Variable", values_from = "value") |> 
  mutate(
    across(starts_with("Question"),\(x) gsub(pattern = "\r\n", replacement = "<br/>", x = x))
  )

set.seed(1234)

passwords <- data.frame(
  Name = unique(hw_all_tbl$Name),
  Code = sample(x = 1000:9999, size = 13)
) |> arrange(Name)
passwords[passwords$Name == "JIHONG ZHANG", "Code"]= "0000"

hw_all_tbl <- hw_all_tbl |> 
  left_join(passwords, by = "Name")

saveRDS(hw_all_tbl, file = paste0(hw_root_path, "ESRM64503_Homework_Combined.rds"))

library(glue)
name = passwords$Name
code = passwords$Code
message_text <- glue("
Hi {name},

Now you can check your grade, feedback and original responses of homeworks here (https://jihongzhang.org/posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/Grading_ShinyApp.html).

To have access to your grade, please use your 4-digit unique code -- {code}. Note that this homework system is still under developing. Thus, if you notice some bugs or have any comments/suggestions, feel free to let me know.

Best,

")
message_text