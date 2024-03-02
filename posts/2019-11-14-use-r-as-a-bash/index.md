---
title: Use R as a bash language
date: 2019-11-14
draft: false
categories:
  - blog
tags:
  - Blog
---

R language could be easily used as a bash script using `Rscript *.R`. `system()` is a R base function which could run command line within R. 

Below is a simple example which allows to automate create a new blog post:
(1) Ask users to type in filename, title and language
(2) Create a new markdown file in specific directory (i.e. your local posts saved path)
(3) Add some metadata in .md file
(4) Open the file using your favorite markdown editor.

```python
cat('Your filename > ')
filename <- scan(file = "stdin", what = "character", n=1, sep = "-")

cat("Your post's title > ")
title <- scan("stdin", what = "character", n=1, sep = "-")

cat("language is zh or en > ")
lang <- scan("stdin", character(), n=1)

draft = TRUE

md.metadata =
  paste0("---
title: ", title,"
date: ",Sys.Date(),"
draft: ", tolower(draft) ,"
categories:
  - blog
tags:
  - Blog
---")

if (lang == "zh"){
  ## create a file name
  postname = paste0(Sys.Date(), "-",gsub(" ", "-", filename, fixed = TRUE), "." ,lang,".md")
  ## Chinese Path
   filepath = paste0(
    "/Users/jihong/Documents/hugo-academic-jihong/content/post/zh/",
    postname)

   cmd = paste0("cd /Users/jihong/Documents/hugo-academic-jihong/content/post/zh/ && open ", postname)
} else {
  postname = paste0(Sys.Date(), "-",gsub(" ", "-", filename, fixed = TRUE), ".md")
  ## English Path
  filepath = paste0(
    "/Users/jihong/Documents/hugo-academic-jihong/content/post/",
    postname)

  cmd = paste0("cd /Users/jihong/Documents/hugo-academic-jihong/content/post/ && open ", postname)
}


write.table(md.metadata, file = filepath, quote = FALSE, row.names = FALSE,col.names = FALSE)

system(cmd)
```

