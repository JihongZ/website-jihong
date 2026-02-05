# Set seed for reproducibility
set.seed(42)

# Generate data for three sleep groups
less_than_6_hours <- rnorm(30, mean = 65, sd = 10)
six_to_eight_hours <- rnorm(50, mean = 75, sd = 8)
more_than_8_hours <- rnorm(20, mean = 78, sd = 7)

# Combine data into a single data frame
sleep_data <- data.frame(
  Sleep_Group = factor(c(rep("<6 hours", 30), rep("6-8 hours", 50), rep(">8 hours", 20))),
  Exam_Score = c(less_than_6_hours, six_to_eight_hours, more_than_8_hours)
)

# View the first few rows of the dataset
head(sleep_data)

library(dplyr)
sleep_data |> 
  group_by(Sleep_Group) |> 
  summarise(
    Mean = mean(Exam_Score)
  )
