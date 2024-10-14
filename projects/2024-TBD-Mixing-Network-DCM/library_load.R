library_load <-
function(){
  if(!require(pacman)){install.packages("pacman")}
  pacman::p_load(
    "tidyverse",
    "modeltime",
    "psychonetrics",
    "kableExtra"
  )
}
library_load()