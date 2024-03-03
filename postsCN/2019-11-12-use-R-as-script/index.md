---
title: 将R当作系统脚本来使用
date: 2019-11-12
draft: false
categories:
  - play
  - R
tags:
  - R
---

有没有想过只要在terminal里面输入下面命令，就可以自动生成一个markdown文件，并使用你喜欢的文本编辑器打开它呢。其实R可以像python或者bash shell一样，用来做脚本语言当然是绰绰有余的。
```
blogpost "use R as script" "将R当作系统脚本来使用"
```
![](/img/photos/Rscript-1.png)
![](/img/photos/Rscript-2.png)

## 1. 创建一个R script文件
首先你要做的是创建一个空的R script文件，重命名为一个性感的名字(e.g. blogpost.R)。这个R文件是用来存放你的所有指令的。在下面的例子中，我创建了一个blogpost.R文件，可以用来实现：

（1）在指定目录（我的博客文件夹）新建一个.md文件。markdown文件的名字以及文章标题由用户自己设定。在下面的例子中，我使用了`scan()`命令来自动读取用户的输入，并且给filename以及title赋值。
（2）自动生成metadata。如果你使用blogdown包来创建博客，你也许需要在markdown文件的开头写上metadata。当然，你可以写上任何你想放进去的信息。比如下面的`md.metadata`里，我放进了title, date, draft, categories以及tags的信息。
（3）最后用你默认的文件编辑器打开。比如，我的默认markdown编辑器是iA writer，所以`cmd`中我使用的`open`命令就会用iA writer自动打开这个文件。 

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

## 2. 创建一个command line命令来调用这个.R文件

创建完R脚本后，你接下来只需要将上述的.R（blogpost.R）文件保存到一个固定的路径（e.g. ~/Documents/),之后就可以在Terminal里使用`Rscript ~/Documents/blogpost.R`命令行来调用这个脚本。

另外如果你还使用bash或者zsh，还可以在`~/.zshrc`或者`~/.bashrc`配置文档中添加一行`alias blogpost="Rscript ~/Desktop/blogpost.R"`。这可以将以上的命令行替换成很简单的“blogpost”命令。

如果你还有其他疑问，欢迎在下方的评论区给我留言。
