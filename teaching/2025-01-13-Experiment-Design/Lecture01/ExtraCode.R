# install.packages("tidyverse")

library("tidyverse") # load the packahge called tidyerse

library("ggplot2")

ggplot() +
  geom_point(aes(x = 1:100, y = 100:1), 
               color = "blue",
               linetype = "dashed") +
  geom_line(aes(x = 1:100, y = 100:1),
            color = "red", 
            linewidth = 3, alpha = .3)

ggplot2::ggplot() +
  ggplot2::geom_point(aes(x = 1:100, y = 100:1), 
             color = "blue",
             linetype = "dashed") +
  ggplot2::geom_line(aes(x = 1:100, y = 100:1),
            color = "red", 
            linewidth = 3, alpha = .3) -> some_figure

some_figure
sessionInfo()

# In R, every statement is a function

# The print function prints the contents of what is inside to the console
print(x = 10)

print("hello world")

# You can determine what type of object is returned by using the class function
class(print(x = 10))
class(10)
class("hello")

x = 1
x <- 3
y = 5
x + y
1 + 3
x^2
x + 5

x = c(1:100)
x = c(1.2, 1.3)
x = c(1.2, 1.3, 23)

data_heights <- read.csv("heights.csv", 
                         stringsAsFactors = FALSE)
data_heights$ID
data_heights$HeightIN
data_heights$HeightIN[1] = "I dont know"
class(data_heights$HeightIN)
data_heights$HeightIN[1] = 73
class(data_heights$HeightIN)
as.numeric(c(TRUE, FALSE))

y == 5
y == 3

y <-  5
class(y = 5)

2 -> x -> y

x <- y <- 2
x <- y <- 3
x <- (y == 5)
