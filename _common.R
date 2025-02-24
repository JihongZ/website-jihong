# inspired by https://github.com/jhelvy/jhelvy_quarto/blob/main/_common.R
library(htmltools)
library(stringr)
library(dplyr)
library(readr)
library(fontawesome)
library(gsheet)

make_citations <- function(pubs) {
  pubs$citation <- unlist(lapply(split(pubs, 1:nrow(pubs)), make_citation))
  return(pubs)
}

make_doi <- function(doi) {
  return(glue::glue('DOI: [{doi}](https://doi.org/{doi})'))
}

make_citation <- function(pub) {
  if (!is.na(pub$journal)) {
    pub$journal <- glue::glue('_{pub$journal}_.')
  }
  if (!is.na(pub$number)) {
    pub$number <- glue::glue('{pub$number}.')
  }
  if (!is.na(pub$doi)) {
    pub$doi <- make_doi(pub$doi)
  }
  pub$year <- glue::glue("({pub$year})")
  pub$title <- glue::glue('"{pub$title}"')
  pub[,which(is.na(pub))] <- ''
  return(paste(
    pub$author, pub$year, pub$title, pub$journal, 
    pub$number, pub$doi
  ))
}

get_pubs <- function() {
  pubs <- gsheet::gsheet2tbl(
    url = 'https://docs.google.com/spreadsheets/d/1xyzgW5h1rVkmtO1rduLsoNRF9vszwfFZPd72zrNmhmU')
  pubs <- make_citations(pubs)
  pubs$summary <- ifelse(is.na(pubs$summary), FALSE, pubs$summary)
  pubs$stub <- make_stubs(pubs)
  pubs$url_summary <- file.path('research', pubs$stub, "index.html")
  pubs$url_scholar <- ifelse(
    is.na(pubs$id_scholar), NA, 
    glue::glue('https://scholar.google.com/citations?view_op=view_citation&hl=en&user=DY2D56IAAAAJ&citation_for_view=DY2D56IAAAAJ:{pubs$id_scholar}')
  )
  return(pubs)
}