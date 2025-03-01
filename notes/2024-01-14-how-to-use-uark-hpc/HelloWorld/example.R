if(!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if(!require("igraph", quietly = TRUE)) install.packages("igraph")
if(!require("impute", quietly = TRUE)) BiocManager::install("impute")
if(!require("SPIA", quietly = TRUE)) BiocManager::install("SPIA")
if(!require("graphite", quietly = TRUE)) BiocManager::install("graphite")
if(!require("org.Hs.eg.db", quietly = TRUE)) BiocManager::install("org.Hs.eg.db")

library(samr)
library(SPIA)
library(graphite)
library(igraph)

# database
database <- "kegg" #选择数据库，目前仅支持kegg

# species
specieslist <-
  pathwayDatabases()[pathwayDatabases()[, 2] == 'kegg', 1] #all species
speciesname <- "hsapiens"
kegg <- pathways(speciesname, "kegg")
kegg <- convertIdentifiers(kegg, "ENTREZID")

# data
data <-
  read.table(
    "MS_entrez_id_alldata.txt",
    sep = "\t",
    row.names = 1,
    header = T
  )
rownames(data) <-
  paste("ENTREZID", rownames(data), sep = ":")# output显示

# label
output <- c(rep(1, 15), rep(2, 12)) # output显示, 控制组1，实验组2,  sam 格式需要
group <- output - 1 # 控制组0，实验组1


# delta
delta <- 1


# pathway
pathwaylist <- names(kegg) #all pathway
name_pat <- "" #交互选择，默认值见后文

# MI
MIchoice <- '' # 交互选择，默认值见后文

# 转化为list格式
data_sam <-
  list(
    x = as.matrix(data),
    y = output,
    geneid = as.character(1:nrow(data)),
    genenames = paste("g", as.character(1:nrow(data)), sep = ""),
    logged2 = TRUE
  )
# SAM
samr.obj <- samr(data_sam, resp.type = "Two class unpaired", nperms = 400)
delta.table <- samr.compute.delta.table(samr.obj)


del <- delta
siggenes.table <-
  samr.compute.siggenes.table(samr.obj, del, data_sam, delta.table, min.foldchange =
                                2)
#Genes upregulated
gene_up <-
  siggenes.table$genes.up
head(gene_up) # output: Genes upregulated table
#Genes downregulated
gene_lo <-
  siggenes.table$genes.lo
head(gene_lo) # output: Genes downregulated table

write.table(gene_up, "gene_up.txt", sep = "\t", quote = F)
