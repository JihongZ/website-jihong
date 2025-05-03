##Parts of this code are adapted from Fried et al. (2018), Forbes et al. (2017a), Borsboom et al. (2017), Epskamp et al. (2017), and Epskamp and Fried (in press)

# Packages to load:
library("bootnet")
library("qgraph")
library("NetworkComparisonTest")
library("psych")

# Set the random seed:
set.seed(123)

# Load time1 dataset:
time1and2data <- read.csv("time1and2data_wide.csv", header=FALSE)
time1and2data<-as.data.frame(time1and2data)
time1data<- time1and2data[c(2:17)]
time1data<-as.data.frame(time1data)
colnames(time1data)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                       "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                       "GAD6","GAD7")
time2data<- time1and2data[c(18:33)]
time2data<-as.data.frame(time2data)
colnames(time2data)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                       "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                       "GAD6","GAD7")
Labels<- c("interest", "feel down", "sleep", "tired", "appetite", "self-esteem", 
            "concentration", "psychomotor", "suicidality", "feel nervous", 
            "uncontrollable worry", "worry a lot", "trouble relax", "restless", 
            "irritable", "something awful")
time1dep<-time1data[c(1:9)]
time1anx<-time1data[c(10:16)]
time2dep<-time2data[c(1:9)]
time2anx<-time2data[c(10:16)]

##Sample means and sds
means1 <- colMeans(time1data, na.rm=T)
sds1 <- as.vector(sapply(time1data, sd, na.rm=T))

means2 <- colMeans(time2data, na.rm=T)
sds2 <- as.vector(sapply(time2data, sd, na.rm=T))

#Correlate (spearman) means of symptoms from each data set for similarity
cor(means1,means2, method="spearman")


##Estimate GGM networks
network1 <- estimateNetwork(time1data, default="EBICglasso")
network2 <- estimateNetwork(time2data, default="EBICglasso")
layout(t(1:1))
centw1w2<-centralityPlot(list(Wave_1 = network1, Wave_2 = network2), labels=c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                                                                    "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                                                                    "GAD6","GAD7"))
L <- averageLayout(network1,network2)

centw1w2$data<-subset(centw1w2$data, centw1w2$data$measure == "Strength")
centw1w2$data<-centw1w2$data[order(centw1w2$data$type, centw1w2$data$node),]
centw1<-subset(centw1w2$data, centw1w2$data$type == "Wave_1")
centw2<-subset(centw1w2$data, centw1w2$data$type == "Wave_2")
min(centw1$value)
max(centw1$value)
min(centw2$value)
max(centw2$value)


#Plot networks with average layout and edges comparable in weight
maxIsing<-max(c(network1$graph, network2$graph))
layout(t(1:2))
network1plot_average <- qgraph(network1$graph, layout=L, title="Wave 1 average layout", maximum=maxIsing)
network2plot_average <- qgraph(network2$graph, layout=L, title="Wave 2 average layout", maximum=maxIsing)

##Estimate GGM networks anx
network1anx <- estimateNetwork(time1anx, default="EBICglasso")
network2anx <- estimateNetwork(time2anx, default="EBICglasso")
Lanx <- L[10:16,]

#Plot networks with average layout and edges comparable in weight
maxIsing<-max(c(network1$graph, network2$graph, network1anx$graph, network2anx$graph))
layout(t(1:2))
network1plotanx_average <- qgraph(network1anx$graph, layout=Lanx, title="Wave 1 average layout", maximum=maxIsing)
network2plotanx_average <- qgraph(network2anx$graph, layout=Lanx, title="Wave 2 average layout", maximum=maxIsing)


##Estimate GGM networks dep
network1dep <- estimateNetwork(time1dep, default="EBICglasso")
network2dep <- estimateNetwork(time2dep, default="EBICglasso")
Ldep <- L[1:9,]
is.matrix(Ldep)
#Plot networks with average layout and edges comparable in weight
maxIsing<-max(c(network1$graph, network2$graph, network1anx$graph, network2anx$graph, network1dep$graph, network2dep$graph))
layout(t(1:2))
network1plotdep_average <- qgraph(network1dep$graph, layout=Ldep, title="Wave 1 average layout", maximum=maxIsing)
network2plotdep_average <- qgraph(network2dep$graph, layout=Ldep, title="Wave 2 average layout", maximum=maxIsing)

#Plot unreplicated edges in each network with orange = unreplicated and red = changed direction
coloursunrepT1<-c("transparent", "transparent", "dark orange", "transparent", "transparent", "dark orange", "transparent", "transparent", "dark orange", "transparent", "transparent", 
             "transparent", "transparent", "transparent", "transparent", "transparent", "transparent", "transparent", "transparent", "red", "transparent", "transparent", "transparent", 
             "transparent", "transparent", "transparent", "dark orange", "transparent", "dark orange", "transparent", "transparent", "transparent", "transparent", "transparent", 
             "dark orange", "dark orange", "dark orange", "transparent", "transparent", "red", "transparent", "dark orange", "transparent", "dark orange", 
             "transparent", "dark orange", "red", "transparent", "transparent", "dark orange", "transparent", "transparent", "transparent", "dark orange", "transparent", 
             "transparent", "transparent", "dark orange", "transparent", "transparent", "dark orange", "transparent", "dark orange", "red", "transparent", "transparent", 
             "dark orange", "transparent", "transparent", "transparent", "dark orange", "transparent", "transparent", "transparent", "transparent", "dark orange", "transparent", 
             "transparent")
qgraph(network1$graph, layout=L, edge.color = coloursunrepT1, negDashed=TRUE,
       fade=FALSE, title="Unreplicated Wave 1", maximum=maxIsing)

coloursunrepT2<-c("transparent", "transparent", "transparent", "transparent", "dark orange", 
             "transparent", "transparent", "transparent", "dark orange", "transparent", 
             "transparent", "dark orange", "transparent", "transparent", "transparent", 
             "transparent", "dark orange", "transparent", "transparent", "dark orange", 
             "transparent", "red", "dark orange", "transparent", "transparent", 
             "transparent", "transparent", "transparent", "transparent", "transparent", 
             "transparent", "transparent", "transparent", "dark orange", "transparent", 
             "dark orange", "dark orange", "transparent", "dark orange", "dark orange", 
             "transparent", "dark orange", "transparent", "red", "dark orange", 
             "transparent", "transparent", "transparent", "red", "transparent", 
             "dark orange", "transparent", "transparent", "dark orange", "transparent", 
             "transparent", "transparent", "dark orange", "transparent", "transparent", 
             "transparent", "transparent", "transparent", "red", "dark orange", 
             "dark orange", "transparent", "transparent", "dark orange", "transparent", 
             "transparent", "transparent", "transparent", "transparent", "transparent", 
             "transparent", "transparent", "transparent")
qgraph(network2$graph, layout=L, edge.color = coloursunrepT2, negDashed=TRUE,
       fade=FALSE, title="Unreplicated Wave 2", maximum=maxIsing)


##Network characteristics
#edge lists
edgesT1 <- network1$graph[upper.tri(network1$graph)] 
edgesT2 <- network2$graph[upper.tri(network2$graph)]

#node strength
strengthT1<-centrality(network1$graph)$OutDegree
strengthT2<-centrality(network2$graph)$OutDegree
max(strengthT1)
max(strengthT2)
min(strengthT1)
min(strengthT2)

# Number of total possible edges
totalT1 <- length(edgesT1)
totalT2 <- length(edgesT2)
totalT1
totalT2

# Number of estimated edges:
nEdgesT1<- sum(edgesT1!=0)
nEdgesT2 <- sum(edgesT2!=0)
nEdgesT1
nEdgesT2

#Connectivity
connectT1<-round(nEdgesT1/totalT1 * 100, 1)
connectT2<-round(nEdgesT2/totalT2 * 100, 1)
connectT1
connectT2

#Number of zero edges
n0EdgesT1<- sum(edgesT1==0)
n0EdgesT2 <- sum(edgesT2==0)
n0EdgesT1
n0EdgesT2

#Number of positive edges
nposEdgesT1<- sum(edgesT1>0)
nposEdgesT2 <- sum(edgesT2>0)
nposEdgesT1
nposEdgesT2

#Number of negative edges
nnegEdgesT1<- sum(edgesT1<0)
nnegEdgesT2 <- sum(edgesT2<0)
nnegEdgesT1
nnegEdgesT2


##Bootnet analyses
boot1a <- bootnet(network1, nBoots = 1000, nCores = 8)
boot1b <- bootnet(network1, nBoots = 1000, type = "case",  nCores = 8)

boot2a <- bootnet(network2, nBoots = 1000, nCores = 8)
boot2b <- bootnet(network2, nBoots = 1000, type = "case",  nCores = 8)

#Plot edge weight CIs (Fig S1)
plot(boot1a, labels = FALSE, order = "sample") 
plot(boot2a, labels = FALSE, order = "sample") 
write.csv(summary(boot1a), "edge weight CIs T1.csv") 
write.csv(summary(boot2a), "edge weight CIs T2.csv") #These two .csvs were used to create the file "Comparing edges between networks.xlsx"

#Plot edge weight diff tests (Fig S2)
plot(boot1a, "edge", plot = "difference", onlyNonZero = TRUE, order = "sample")
plot(boot2a, "edge", plot = "difference", onlyNonZero = TRUE, order = "sample")

#Plot centrality stability (Fig S3)
plot(boot1b)
plot(boot2b)

#Centrality stability coefficient
cs1 <- corStability(boot1b)  
cs2 <- corStability(boot2b) 
cs <- matrix(NA,2,3)
cs[1,1:3] <- round(cs1, digits=2)
cs[2,1:3] <- round(cs2, digits=2)
colnames(cs) <- c("Betweenness", "Closeness", "Strength")
rownames(cs) <- c("Time 1", "Time 2")
cs

#Plot strength centrality diff tests (Fig S4)
plot(boot1a, "strength", order="sample", labels=TRUE) 
plot(boot2a, "strength", order="sample", labels=TRUE) 

#Plot only "bootnet-significant" edges
write.csv(network1$graph, "edgesGGMT1.csv") #we censored these edges in excel (see file bootnet edges T1.csv)
write.csv(network2$graph, "edgesGGMT2.csv") #we censored these edges in excel (see file bootnet edges T2.csv)
bootnetedgesT1 <- read.csv("bootnet edges T1.csv", 
                           header = FALSE)
colnames(bootnetedgesT1)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                            "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                            "GAD6","GAD7")
rownames(bootnetedgesT1)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                            "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                            "GAD6","GAD7")
qgraph(bootnetedgesT1, layout=L, directed=FALSE, 
       title="Wave 1 bootnet significant", maximum=maxIsing)

bootnetedgesT2 <- read.csv("bootnet edges T2.csv", 
                           header = FALSE)
colnames(bootnetedgesT2)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                            "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                            "GAD6","GAD7")
rownames(bootnetedgesT2)<-c("PHQ1","PHQ2","PHQ3","PHQ4","PHQ5","PHQ6","PHQ7",
                            "PHQ8","PHQ9","GAD1","GAD2","GAD3","GAD4","GAD5",
                            "GAD6","GAD7")
qgraph(bootnetedgesT2, layout=L, directed=FALSE, 
       title="Wave 2 bootnet significant", maximum=maxIsing)

#Plot differences between bootnet networks with orange = unreplicated
edgecolT1<-c("transparent", "transparent", "transparent", "dark orange", "transparent", "dark orange", "transparent", "dark orange", "transparent", "dark orange", 
             "dark orange", "transparent", "transparent", "dark orange", "transparent", "transparent", "dark orange", "dark orange", "transparent")
qgraph(bootnetedgesT1, layout=L, directed=FALSE, edge.color = edgecolT1, negDashed=TRUE,
       fade=FALSE, title="Wave 1 bootnet unrep", maximum=maxIsing)

edgecolT2<-c("transparent", "transparent", "transparent", "dark orange", "transparent", "dark orange", "transparent", "transparent", "dark orange", 
             "transparent", "transparent", "dark orange", "dark orange", "transparent", "transparent", "transparent", "dark orange")
qgraph(bootnetedgesT2, layout=L, directed=FALSE, edge.color = edgecolT2, negDashed=TRUE,
       fade=FALSE, title="Wave 2 bootnet unrep", maximum=maxIsing)

##NCT analyses
#Compare polychoric and Pearson per Fried et al. (2018)
c1 <- cor(time1data)
c1b <- cor_auto(time1data)
c1c <-cor(time1data, method=c("spearman"))
cor(c1[lower.tri(c1)], 	c1b[lower.tri(c1b)],	method="spearman")
cor(c1[lower.tri(c1)], 	c1c[lower.tri(c1c)],	method="spearman")
cor(c1b[lower.tri(c1b)], c1c[lower.tri(c1c)],	method="spearman")

c2 <- cor(time2data)
c2b <- cor_auto(time2data)
cor(c2[lower.tri(c2)], 	c2b[lower.tri(c2b)], 	method="spearman")

#run NCT
set.seed(1337)
compare_12 <- NCT(time1data, time2data, it=5000, binary.data=FALSE, paired=TRUE, test.edges=TRUE, edges='all', progressbar=TRUE)

#omnibus network structure test
compare_12$nwinv.pval 

#number of significantly different edges with Holm-Bonferroni correction
sum(compare_12$einv.pvals$"p-value" < 0.05)

#global strength test
compare_12$glstrinv.sep #The global strength values of the individual networks
compare_12$glstrinv.pval #The p value resulting from the permutation test concerning difference in global strength.

#correlate edge lists (coefficient of similarity)
cor(edgesT1, edgesT2, method = "spearman")
cor(edgesT1[edgesT1!=0&edgesT2!=0],edgesT2[edgesT1!=0&edgesT2!=0], method="spearman") #non-zero edges per Borsboom et al. (2017)

##Compare strength centrality between waves
#Most central node
centT1 <- centrality(network1) 
centT2 <- centrality(network2)  
orAll <- function(x, all0 = FALSE){
  if (length(x)==16){
    if (all0){
      return("All centrality = 0")
    } else return("All nodes equally central")
  } else {
    return(paste(x, collapse = ";"))
  }
}
orAll(Labels[which(centT1$OutDegree == max(centT1$OutDegree))]) #max strength at wave 1
orAll(Labels[which(centT2$OutDegree == max(centT2$OutDegree))]) #max strength at wave 2

##Rank-order correlations for strength
cor(centT1$OutDegree,centT2$OutDegree, method="spearman")
cor(centT1$OutDegree,centT2$OutDegree, method="kendall")

##% matches in rank-order for strength, allowing multiple simultaneous ranks
rankMatch2 <- function(x,y){
  minx <- rank(round(x,14), ties.method = "min")
  miny <- rank(round(y,14), ties.method = "min")
  
  maxx <- rank(round(x,14), ties.method = "max")
  maxy <- rank(round(y,14), ties.method = "max")
  
  (minx <= maxy & maxx >= miny) |
    (miny <= maxx & maxy >= minx)
} 
sum(rankMatch2(centT1$OutDegree,centT2$OutDegree)) #number of nodes with matching rank-order
100*mean(rankMatch2(centT1$OutDegree,centT2$OutDegree)) #proportion of nodes with matching rank-order



##ESEM model
#input factor loadings from unconstrained model estimated in MPlus
DepW1<- c(0.819,0.788,0.681,0.783,0.915,0.656,0.729,0.756,1.079,0.012,-0.031,0.007,
        0.215,0.299,0.555,0.187) 
AnxW1<-c(0.012,0.119,0.12,0.02,-0.238,0.192,0.062,-0.012,-0.3,0.814,0.971,0.94,0.651,
      0.497,0.193,0.616)
DepW2<-c(0.882,0.758,0.627,0.812,0.924,0.774,0.733,0.696,1.158,0.004,-0.028,0.059,
      0.257,0.282,0.515,0.119)
AnxW2<-c(-0.003,0.132,0.13,0.042,-0.186,0.068,0.051,0.102,-0.355,0.863,0.962,0.843,
      0.633,0.488,0.277,0.71)
DepW1<-as.matrix(DepW1)
AnxW1<-as.matrix(AnxW1)
DepW2<-as.matrix(DepW2)
AnxW2<-as.matrix(AnxW2)
#compute Tucker's factor congruence coefficient
factor.congruence(DepW1, DepW2) #1.00
factor.congruence(AnxW1, AnxW2) #.99



#plot Spearman networks

c1 <- cor(time1data)
c1b <- cor_auto(time1data)
c1c <-cor(time1data, method=c("spearman"))
cor(c1[lower.tri(c1)], 	c1b[lower.tri(c1b)],	method="spearman")
cor(c1[lower.tri(c1)], 	c1c[lower.tri(c1c)],	method="spearman")
cor(c1b[lower.tri(c1b)], c1c[lower.tri(c1c)],	method="spearman")
Originaltime1<-qgraph(c1b, graph = "EBICglasso", layout = Ldepanx, sampleSize = 403, maximum=maxIsing, title = "Polychorics Wave 1", filetype = "tiff")
Spearmantime1<-qgraph(c1c, graph = "EBICglasso", layout = Ldepanx, sampleSize = 403, maximum=maxIsing, title = "Spearman Wave 1", filetype = "tiff")
Spearmantime1
layout(t(1:2))
network1plot_average <- qgraph(network1$graph, layout=L, title="Wave 1 average layout", maximum=maxIsing)

c2 <- cor(time2data)
c2b <- cor_auto(time2data)
c2c <-cor(time2data, method=c("spearman"))
cor(c2[lower.tri(c2)], 	c2b[lower.tri(c2b)],	method="spearman")
cor(c2[lower.tri(c2)], 	c2c[lower.tri(c2c)],	method="spearman")
cor(c2b[lower.tri(c2b)], c2c[lower.tri(c2c)],	method="spearman")
Spearmantime2<-qgraph(c2c, graph = "EBICglasso", layout = L, sampleSize = 403, maximum=maxIsing)
Spearmantime2
layout(t(1:2))
network2plot_average <- qgraph(network2$graph, layout=L, title="Wave 2 average layout", maximum=maxIsing)

Originaltime2<-qgraph(c2b, graph = "EBICglasso", layout = Ldepanx, sampleSize = 403, maximum=maxIsing, title = "Polychorics Wave 2", filetype = "tiff")
Spearmantime2<-qgraph(c2c, graph = "EBICglasso", layout = Ldepanx, sampleSize = 403, maximum=maxIsing, title = "Spearman Wave 2", filetype = "tiff")
















### Simulate data from Latent-variable model example in be careful what you wish for ###
# Discrimination matrix:
A <- structure(c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
                 0, 1.1, -1.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.1, -1.1, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.75, 0, 0, 0, 0, 0, 0, 0, 0, 0.75
), .Dim = c(19L, 8L))

# Latent variance-covariance matrix:
Psi <- structure(c(1, 0.55, 0, 0, 0, 0, 0, 0, 0.55, 1, 0, 0, 0, 0, 0, 
                   0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 
                   1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 
                   0, 0, 0, 0, 0, 0, 1), .Dim = c(8L, 8L))

# Function to simulate data:
simData <- function(n, A, Psi){
  nFact <- ncol(A)
  nItem <- nrow(A)
  
  # Simulate theta:
  Theta <- rmvnorm(n,rep(0,nFact),Psi)
  
  # Simulate data:
  Data <- 1*(matrix(runif(n*nItem),n,nItem) < exp(Theta %*% t(A)) / (1 + exp(Theta %*% t(A))))
  
  return(Data)
}

library("mvtnorm")

# Second data (N = 1000):
set.seed(3)
simdata5000_1 <- simData(5000, A, Psi)
set.seed(3)
simdata5000_2 <- simData(5000, A, Psi)

networksim1 <- estimateNetwork(simdata5000_1, default = c("IsingFit"))
networksim2 <- estimateNetwork(simdata5000_2, default = c("IsingFit"))

Lsim <- averageLayout(networksim1,networksim2)

#Plot networks with average layout and edges comparable in weight
maxedge<-max(c(networksim1$graph, networksim2$graph))
layout(t(1:2))
networksim1plot <- qgraph(networksim1$graph, layout=Lsim, title="Sim 1 n = 5000", maximum=maxedge)
networksim2plot <- qgraph(networksim2$graph, layout=Lsim, title="Sim 2 n = 5000", maximum=maxedge)


##Bootnet analyses
boots1a <- bootnet(networksim1, nBoots = 1000, nCores = 8)
boots1b <- bootnet(networksim1, nBoots = 1000, type = "case",  nCores = 8)

boots2a <- bootnet(networksim2, nBoots = 1000, nCores = 8)
boots2b <- bootnet(networksim2, nBoots = 1000, type = "case",  nCores = 8)

#Plot edge weight CIs (Fig S1)
plot(boots1a, labels = FALSE, order = "sample") 
plot(boots2a, labels = FALSE, order = "sample") 

#Plot edge weight diff tests (Fig S2)
plot(boots1a, "edge", plot = "difference", onlyNonZero = TRUE, order = "sample")
plot(boots2a, "edge", plot = "difference", onlyNonZero = TRUE, order = "sample")

#Plot centrality stability (Fig S3)
plot(boots1b)
plot(boots2b)

#Plot strength centrality diff tests (Fig S4)
plot(boots1a, "strength", order="sample", labels=TRUE) 
plot(boots2a, "strength", order="sample", labels=TRUE) 

#Centrality stability coefficient
css1 <- corStability(boots1b)  
css2 <- corStability(boots2b) 
cs <- matrix(NA,2,3)
cs[1,1:3] <- round(css1, digits=2)
cs[2,1:3] <- round(css2, digits=2)
colnames(cs) <- c("Betweenness", "Closeness", "Strength")
rownames(cs) <- c("Time 1", "Time 2")
cs

##Compare strength centrality between waves
#Most central node
centralityPlot(networksim1, networksim2)
centS1 <- centrality(networksim1) 
centS2 <- centrality(networksim2) 
vars<-c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", 
          "V15", "V16", "V17", "V18", "V19")
orAll <- function(x, all0 = FALSE){
  if (length(x)==19){
    if (all0){
      return("All centrality = 0")
    } else return("All nodes equally central")
  } else {
    return(paste(x, collapse = ";"))
  }
}
orAll(vars[which(centS1$OutDegree == max(centS1$OutDegree))]) #max strength at wave 1
orAll(vars[which(centS2$OutDegree == max(centS2$OutDegree))]) #max strength at wave 2

##Rank-order correlations for strength
cor(centS1$OutDegree,centS2$OutDegree, method="spearman")
cor(centS1$OutDegree,centS2$OutDegree, method="kendall")

##% matches in rank-order for strength, allowing multiple simultaneous ranks
rankMatch2 <- function(x,y){
  minx <- rank(round(x,14), ties.method = "min")
  miny <- rank(round(y,14), ties.method = "min")
  
  maxx <- rank(round(x,14), ties.method = "max")
  maxy <- rank(round(y,14), ties.method = "max")
  
  (minx <= maxy & maxx >= miny) |
    (miny <= maxx & maxy >= minx)
} 
sum(rankMatch2(centS1$OutDegree,centS2$OutDegree)) #number of nodes with matching rank-order
100*mean(rankMatch2(centS1$OutDegree,centS2$OutDegree)) #proportion of nodes with matching rank-order



##NCT analyses
#Compare polychoric and Pearson per Fried et al. (2018)

#run NCT
set.seed(1337)
compare_s12 <- NCT(simdata5000_1, simdata5000_2, it=5000, binary.data=TRUE, paired=FALSE, test.edges=TRUE, edges='all', progressbar=TRUE)
compare_s12fix<-NCTbasicfix(simdata5000_1, simdata5000_2, it=5000, binary.data=TRUE, paired=FALSE, test.edges=TRUE, edges='all', progressbar=TRUE)

#omnibus network structure test
compare_s12$nwinv.pval 

#number of significantly different edges with Holm-Bonferroni correction
sum(compare_s12$einv.pvals$"p-value" < 0.05)

#uncorrected p=values
compare_s12fix$edges.pvalmattemp 
compare_s12fix$edges.pvalmattemp[!lower.tri(compare_s12fix$edges.pvalmattemp)] <- NA
length(which(compare_s12fix$edges.pvalmattemp < 0.05))

#global strength test
compare_s12$glstrinv.sep #The global strength values of the individual networks
compare_s12$glstrinv.pval #The p value resulting from the permutation test concerning difference in global strength.

#correlate edge lists (coefficient of similarity)
#edge lists
edgesS1 <- networksim1$graph[upper.tri(networksim1$graph)] 
edgesS2 <- networksim2$graph[upper.tri(networksim2$graph)]
cor(edgesS1, edgesS2, method = "spearman")
cor(edgesS1[edgesS1!=0&edgesS2!=0],edgesS2[edgesS1!=0&edgesS2!=0], method="spearman") #non-zero edges per Borsboom et al. (2017)



#######COMPARING THE DETAILED FEATURES OF THE NETWORKS

#recode matrix to positive, negative, zero, and only lower triangle (symmetric matrices)
networksim1qual<-networksim1$graph
networksim1qual[networksim1qual<0] <- -2
networksim1qual[networksim1qual==0] <- 0
networksim1qual[networksim1qual>0] <- 1
networksim1qual[!lower.tri(networksim1qual)] <- NA
networksim1qual

networksim2qual<-networksim2$graph
networksim2qual[networksim2qual<0] <- -2
networksim2qual[networksim2qual==0] <- 0
networksim2qual[networksim2qual>0] <- 1
networksim2qual[!lower.tri(networksim2qual)] <- NA
networksim2qual

edgediffssim<-networksim1qual!=networksim2qual #matrix of differences in estimated edges (TRUE = difference)
edgediffssim
identical(networksim1qual,networksim2qual) #are they identical
which(networksim1qual != networksim2qual) #list of unreplicated edges (including unreplicated zeroes)
length(which(networksim1qual != networksim2qual)) #number of unreplicated edges (uncluding unreplicated zeroes)

#positive edges
np1<-length(which(networksim1qual>0)) #number of positive edges network 1
replpossim1<-((edgediffssim == FALSE) & (networksim1qual==1)) #replicated positive edges network1 = TRUE
rp1<-length(which(replpossim1==TRUE)) #number of replicated positive edges network1
prp1<-rp1/np1*100 #proportion of replicated positive edges
np1
rp1
prp1
unreplpossim1<-((edgediffssim == TRUE) & (networksim1qual==1)) #unreplicated positive edges network1 = TRUE
up1<-length(which(unreplpossim1==TRUE)) #number of unreplicated positive edges network1
pup1<-up1/np1*100 #proportion of unreplicated positive edges
up1
pup1

#negative edges
nn1<-length(which(networksim1qual<0)) #number of negative edges network 1
replnegsim1<-((edgediffssim == FALSE) & (networksim1qual==-2)) #replicated negative edges network1 = TRUE
rn1<-length(which(replnegsim1==TRUE)) #number of replicated negative edges network1
prn1<-rn1/nn1*100 #proportion of replicated negative edges
nn1
rn1
prn1
unreplnegsim1<-((edgediffssim == TRUE) & (networksim1qual==-2)) #unreplicated negative edges network1 = TRUE
un1<-length(which(unreplnegsim1==TRUE)) #number of unreplicated negative edges network1
pun1<-un1/nn1*100 #proportion of unreplicated negative edges
un1
pun1

#zero edges
nz1<-length(which(networksim1qual==0)) #number of zero edges network 1
replzsim1<-((edgediffssim == FALSE) & (networksim1qual==0)) #replicated zero edges network1 = TRUE
rz1<-length(which(replzsim1==TRUE)) #number of replicated zero edges network1
prz1<-rz1/nz1*100 #proportion of replicated zero edges
nz1
rz1
prz1
unreplzsim1<-((edgediffssim == TRUE) & (networksim1qual==0)) #unreplicated zero edges network1 = TRUE
uz1<-length(which(unreplzsim1==TRUE)) #number of unreplicated zero edges network1
puz1<-uz1/nz1*100 #proportion of unreplicated zero edges
uz1
puz1


#consistent edges (including zeroes)
ne1<-length(which(!is.na(networksim1qual))) #number of possible edges network 1
replesim1<-((edgediffssim == FALSE) & (!is.na(networksim1qual))) #consistent edges (including zeroes) in network1 = TRUE
re1<-length(which(replesim1==TRUE)) #number of consistent edges (including zeroes) network1
pre1<-re1/ne1*100 #proportion of consistent edges (including zeroes)
ne1
re1
pre1
unreplesim1<-((edgediffssim == TRUE) & (!is.na(networksim1qual))) #inconsistent zero edges network1 = TRUE
ue1<-length(which(unreplesim1==TRUE)) #number of inconsistent zero edges network1
pue1<-ue1/ne1*100 #proportion of inconsistent edges
ue1
pue1

#replicated estimated edges (positive and negative in same direction)
(rp1+rn1)/nEdgesS1*100

#subset bridging edges
bridgesim1qual<-networksim1qual[c(11:19), c(1:10)]
bridgesim2qual<-networksim2qual[c(11:19), c(1:10)]
bridgediffssim<-bridgesim1qual!=bridgesim2qual #matrix of differences in estimated edges (TRUE = difference)
bridgediffssim
identical(bridgesim1qual,bridgesim2qual) #are they identical
which(bridgesim1qual != bridgesim2qual) #list of unreplicated edges (uncluding unreplicated zeroes)
length(which(bridgesim1qual != bridgesim2qual)) #number of unreplicated edges (uncluding unreplicated zeroes)

#positive edges
npb1<-length(which(bridgesim1qual>0)) #number of positive edges network 1
replposbridge1<-((bridgediffssim == FALSE) & (bridgesim1qual==1)) #replicated positive edges network1 = TRUE
rpb1<-length(which(replposbridge1==TRUE)) #number of replicated positive edges network1
prpb1<-rpb1/npb1*100 #proportion of replicated positive edges
npb1
rpb1
prpb1
unreplposbridge1<-((bridgediffssim == TRUE) & (bridgesim1qual==1)) #unreplicated positive edges network1 = TRUE
upb1<-length(which(unreplposbridge1==TRUE)) #number of unreplicated positive edges network1
pupb1<-upb1/npb1*100 #proportion of unreplicated positive edges
upb1
pupb1

#negative edges
nnb1<-length(which(bridgesim1qual<0)) #number of negative edges network 1
replnegbridge1<-((bridgediffssim == FALSE) & (bridgesim1qual==-2)) #replicated negative edges network1 = TRUE
rnb1<-length(which(replnegbridge1==TRUE)) #number of replicated negative edges network1
prnb1<-rnb1/nnb1*100 #proportion of replicated negative edges
nnb1
rnb1
prnb1
unreplnegbridge1<-((bridgediffssim == TRUE) & (bridgesim1qual==-2)) #unreplicated negative edges network1 = TRUE
unb1<-length(which(unreplnegbridge1==TRUE)) #number of unreplicated negative edges network1
punb1<-unb1/nnb1*100 #proportion of unreplicated negative edges
unb1
punb1

#zero edges
nzb1<-length(which(bridgesim1qual==0)) #number of zero edges network 1
replzbridge1<-((bridgediffssim == FALSE) & (bridgesim1qual==0)) #replicated zero edges network1 = TRUE
rzb1<-length(which(replzbridge1==TRUE)) #number of replicated zero edges network1
przb1<-rzb1/nzb1*100 #proportion of replicated zero edges
nzb1
rzb1
przb1
unreplzbridge1<-((bridgediffssim == TRUE) & (bridgesim1qual==0)) #unreplicated zero edges network1 = TRUE
uzb1<-length(which(unreplzbridge1==TRUE)) #number of unreplicated zero edges network1
puzb1<-uzb1/nzb1*100 #proportion of unreplicated zero edges
uzb1
puzb1


#consistent edges (including zeroes)
ncb1<-length(which(!is.na(bridgesim1qual))) #number of possible edges network 1
replcbridge1<-((bridgediffssim == FALSE) & (!is.na(bridgesim1qual))) #consistent edges (including zeroes) in network1 = TRUE
rcb1<-length(which(replcbridge1==TRUE)) #number of consistent edges (including zeroes) network1
prcb1<-rcb1/ncb1*100 #proportion of consistent edges (including zeroes)
ncb1
rcb1
prcb1
unreplcbridge1<-((bridgediffssim == TRUE) & (!is.na(bridgesim1qual))) #inconsistent zero edges network1 = TRUE
ucb1<-length(which(unreplcbridge1==TRUE)) #number of inconsistent zero edges network1
pucb1<-ucb1/ncb1*100 #proportion of inconsistent edges
ucb1
pucb1

#replicated estimated edges (positive and negative in same direction)
(rpb1+rnb1)/length(which(bridgesim1qual!=0))
  

#determine bootnet sig
bootnetsummary1<-summary(boots1a) #data frame of bootnet results
is.data.frame(bootnetsummary1)
bootnetsummary1<-subset(bootnetsummary1, bootnetsummary1$type == "edge")
#recode V1 etc into numeric so we can sort the edges
bootnetsummary1$node1[bootnetsummary1$node1 == "V1"]<-1
bootnetsummary1$node1[bootnetsummary1$node1 == "V2"]<-2
bootnetsummary1$node1[bootnetsummary1$node1 == "V3"]<-3
bootnetsummary1$node1[bootnetsummary1$node1 == "V4"]<-4
bootnetsummary1$node1[bootnetsummary1$node1 == "V5"]<-5
bootnetsummary1$node1[bootnetsummary1$node1 == "V6"]<-6
bootnetsummary1$node1[bootnetsummary1$node1 == "V7"]<-7
bootnetsummary1$node1[bootnetsummary1$node1 == "V8"]<-8
bootnetsummary1$node1[bootnetsummary1$node1 == "V9"]<-9
bootnetsummary1$node1[bootnetsummary1$node1 == "V10"]<-10
bootnetsummary1$node1[bootnetsummary1$node1 == "V11"]<-11
bootnetsummary1$node1[bootnetsummary1$node1 == "V12"]<-12
bootnetsummary1$node1[bootnetsummary1$node1 == "V13"]<-13
bootnetsummary1$node1[bootnetsummary1$node1 == "V14"]<-14
bootnetsummary1$node1[bootnetsummary1$node1 == "V15"]<-15
bootnetsummary1$node1[bootnetsummary1$node1 == "V16"]<-16
bootnetsummary1$node1[bootnetsummary1$node1 == "V17"]<-17
bootnetsummary1$node1[bootnetsummary1$node1 == "V18"]<-18
bootnetsummary1$node1[bootnetsummary1$node1 == "V19"]<-19
bootnetsummary1$node2[bootnetsummary1$node2 == "V1"]<-1
bootnetsummary1$node2[bootnetsummary1$node2 == "V2"]<-2
bootnetsummary1$node2[bootnetsummary1$node2 == "V3"]<-3
bootnetsummary1$node2[bootnetsummary1$node2 == "V4"]<-4
bootnetsummary1$node2[bootnetsummary1$node2 == "V5"]<-5
bootnetsummary1$node2[bootnetsummary1$node2 == "V6"]<-6
bootnetsummary1$node2[bootnetsummary1$node2 == "V7"]<-7
bootnetsummary1$node2[bootnetsummary1$node2 == "V8"]<-8
bootnetsummary1$node2[bootnetsummary1$node2 == "V9"]<-9
bootnetsummary1$node2[bootnetsummary1$node2 == "V10"]<-10
bootnetsummary1$node2[bootnetsummary1$node2 == "V11"]<-11
bootnetsummary1$node2[bootnetsummary1$node2 == "V12"]<-12
bootnetsummary1$node2[bootnetsummary1$node2 == "V13"]<-13
bootnetsummary1$node2[bootnetsummary1$node2 == "V14"]<-14
bootnetsummary1$node2[bootnetsummary1$node2 == "V15"]<-15
bootnetsummary1$node2[bootnetsummary1$node2 == "V16"]<-16
bootnetsummary1$node2[bootnetsummary1$node2 == "V17"]<-17
bootnetsummary1$node2[bootnetsummary1$node2 == "V18"]<-18
bootnetsummary1$node2[bootnetsummary1$node2 == "V19"]<-19
bootnetsummary1$node1<-as.numeric(bootnetsummary1$node1)
bootnetsummary1$node2<-as.numeric(bootnetsummary1$node2)
bootnetsummary1<-bootnetsummary1[order(bootnetsummary1$node1, bootnetsummary1$node2),]
bootnetsummary1<-bootnetsummary1[,-1]
bootnetsummary1$sample[(bootnetsummary1$q2.5<=0)&(bootnetsummary1$q97.5>=0)]<-NA

#bind bootnet sig edges into lower triangle of a matrix and plot
bootsig1= matrix(NA, 19, 19)
bootsig1[lower.tri(bootsig1, diag=FALSE)]=bootnetsummary1$sample
bootsig1
qgraph(bootsig1, layout=Lsim, directed = FALSE, maximum =maxedge)

#estimated in either network
totaledges<-networksim1qual+networksim2qual
length(which(totaledges<0|totaledges>0))

#swap direction 
length(which((networksim1qual>0 & networksim2qual<0)|(networksim1qual<0 & networksim2qual>0)))

#now want to plot the edges that were unreplicated
unreplesim1
unreplicated1<-networksim1$graph
unreplicated1[unreplesim1==FALSE]<-0 ##0 not NA
unreplicated1
qgraph(unreplicated1, layout="spring", directed = FALSE) #need to hold layout and max value consistent
















##Network characteristics
#edge lists
edgesS1 <- networksim1$graph[upper.tri(networksim1$graph)] 
edgesS2 <- networksim2$graph[upper.tri(networksim2$graph)]
edgesS1
edgesS2

#node strength
strengthS1<-centrality(networksim1$graph)$OutDegree
strengthS2<-centrality(networksim2$graph)$OutDegree
strengthS1
strengthS2

# Number of total possible edges
totalS1 <- length(edgesS1)
totalS2 <- length(edgesS2)
totalS1
totalS2

# Number of estimated edges:
nEdgesS1<- sum(edgesS1!=0)
nEdgesS2 <- sum(edgesS2!=0)
nEdgesS1
nEdgesS2

#Connectivity
connectS1<-round(nEdgesS1/totalS1 * 100, 1)
connectS2<-round(nEdgesS2/totalS2 * 100, 1)
connectS1
connectS2

#Number of zero edges
n0EdgesS1<- sum(edgesS1==0)
n0EdgesS2 <- sum(edgesS2==0)
n0EdgesS1
n0EdgesS2

#Number of positive edges
nposEdgesS1<- sum(edgesS1>0)
nposEdgesS2 <- sum(edgesS2>0)
nposEdgesS1
nposEdgesS2

#Number of negative edges
nnegEdgesS1<- sum(edgesS1<0)
nnegEdgesS2 <- sum(edgesS2<0)
nnegEdgesS1
nnegEdgesS2



NCTbasicfix=function (data1, data2, gamma, it = 100, binary.data = FALSE, 
                      paired = FALSE, weighted = TRUE, AND = TRUE, test.edges = FALSE, 
                      edges, progressbar = TRUE) 
{
  if (missing(gamma)) {
    if (binary.data) {
      gamma <- 0.25
    }
    else {
      gamma <- 0.5
    }
  }
  if (progressbar == TRUE) 
    pb <- txtProgressBar(max = it, style = 3)
  x1 <- data1
  x2 <- data2
  nobs1 <- nrow(x1)
  nobs2 <- nrow(x2)
  dataall <- rbind(x1, x2)
  data.list <- list(x1, x2)
  b <- 1:(nobs1 + nobs2)
  nvars <- ncol(x1)
  nedges <- nvars * (nvars - 1)/2
  glstrinv.perm <- glstrinv.real <- nwinv.real <- nwinv.perm <- c()
  diffedges.perm <- matrix(0, it, nedges)
  diffedges.permtemp <- matrix(0, nvars, nvars)
  einv.perm.all <- array(NA, dim = c(nvars, nvars, it))
  edges.pval.HBall <- matrix(NA, nvars, nvars)
  edges.pvalmattemp <- matrix(0, nvars, nvars)
  if (binary.data == FALSE) {
    nw1 <- EBICglasso(cor(x1), nrow(x1), gamma = gamma)
    nw2 <- EBICglasso(cor(x2), nrow(x2), gamma = gamma)
    if (weighted == FALSE) {
      nw1 = (nw1 != 0) * 1
      nw2 = (nw2 != 0) * 1
    }
    glstrinv.real <- abs(sum(abs(nw1[upper.tri(nw1)])) - 
                           sum(abs(nw2[upper.tri(nw2)])))
    glstrinv.sep <- c(sum(abs(nw1[upper.tri(nw1)])), sum(abs(nw2[upper.tri(nw2)])))
    diffedges.real <- abs(nw1 - nw2)[upper.tri(abs(nw1 - 
                                                     nw2))]
    diffedges.realmat <- matrix(diffedges.real, it, nedges, 
                                byrow = TRUE)
    diffedges.realoutput <- abs(nw1 - nw2)
    nwinv.real <- max(diffedges.real)
    
    
    
    
    
    
    
    for (i in 1:it) {
      if (paired == FALSE) {
        s <- sample(1:(nobs1 + nobs2), nobs1, replace = FALSE)
        x1perm <- dataall[s, ]
        x2perm <- dataall[b[-s], ]
        r1perm <- EBICglasso(cor(x1perm), nrow(x1perm), 
                             gamma = gamma)
        r2perm <- EBICglasso(cor(x2perm), nrow(x2perm), 
                             gamma = gamma)
        if (weighted == FALSE) {
          r1perm = (r1perm != 0) * 1
          r2perm = (r2perm != 0) * 1
        }
      }
      if (paired == TRUE) {
        s <- sample(c(1, 2), nobs1, replace = TRUE)
        x1perm <- x1[s == 1, ]
        x1perm <- rbind(x1perm, x2[s == 2, ])
        x2perm <- x2[s == 1, ]
        x2perm <- rbind(x2perm, x1[s == 2, ])
        r1perm <- EBICglasso(cor(x1perm), nrow(x1perm), 
                             gamma = gamma)
        r2perm <- EBICglasso(cor(x2perm), nrow(x2perm), 
                             gamma = gamma)
        if (weighted == FALSE) {
          r1perm = (r1perm != 0) * 1
          r2perm = (r2perm != 0) * 1
        }
      }
      
      
      
      
      glstrinv.perm[i] <- abs(sum(abs(r1perm[upper.tri(r1perm)])) - 
                                sum(abs(r2perm[upper.tri(r2perm)])))
      
      diffedges.permtemp <- matrix(0, nvars, nvars) ##CHANGE
      diffedges.perm[i, ] <- abs(r1perm - r2perm)[upper.tri(abs(r1perm - 
                                                                  r2perm))]
      diffedges.permtemp[upper.tri(diffedges.permtemp, 
                                   diag = FALSE)] <- diffedges.perm[i, ]
      diffedges.permtemp <- diffedges.permtemp + t(diffedges.permtemp)
      einv.perm.all[, , i] <- diffedges.permtemp
      nwinv.perm[i] <- max(diffedges.perm[i, ])
      if (progressbar == TRUE) 
        setTxtProgressBar(pb, i)
    }
    
    
    
    
    
    if (test.edges == TRUE) {
      edges.pvaltemp1 <- colSums(diffedges.perm >= diffedges.real) #CHANGE
      edges.pvaltemp<-edges.pvaltemp1/it ##CHANGE
      edges.pvalmattemp[upper.tri(edges.pvalmattemp, diag = FALSE)] <- edges.pvaltemp
      edges.pvalmattemp <- edges.pvalmattemp + t(edges.pvalmattemp)
      if (is.character(edges)) {
        ept.HBall <- p.adjust(edges.pvaltemp, method = "holm")
        edges.pval.HBall[upper.tri(edges.pval.HBall, 
                                   diag = FALSE)] <- ept.HBall
        rownames(edges.pval.HBall) <- colnames(edges.pval.HBall) <- colnames(data1)
        einv.pvals <- melt(edges.pval.HBall, na.rm = TRUE, 
                           value.name = "p-value")
        einv.perm <- einv.perm.all
        einv.real <- diffedges.realoutput
      }
      if (is.list(edges)) {
        einv.perm <- matrix(NA, it, length(edges))
        colnames(einv.perm) <- edges
        uncorrpvals <- einv.real <- c()
        for (j in 1:length(edges)) {
          uncorrpvals[j] <- edges.pvalmattemp[edges[[j]][1], 
                                              edges[[j]][2]]
          einv.real[j] <- diffedges.realoutput[edges[[j]][1], 
                                               edges[[j]][2]]
          for (l in 1:it) {
            einv.perm[l, j] <- einv.perm.all[, , l][edges[[j]][1], 
                                                    edges[[j]][2]]
          }
        }
        HBcorrpvals <- p.adjust(uncorrpvals, method = "holm")
        einv.pvals <- HBcorrpvals
      }
      edges.tested <- colnames(einv.perm)
      res <- list(glstrinv.real = glstrinv.real, glstrinv.sep = glstrinv.sep, 
                  glstrinv.pval = sum(glstrinv.perm >= glstrinv.real)/it, 
                  glstrinv.perm = glstrinv.perm, nwinv.real = nwinv.real, 
                  nwinv.pval = sum(nwinv.perm >= nwinv.real)/it, 
                  nwinv.perm = nwinv.perm, edges.tested = edges.tested, 
                  einv.real = einv.real, einv.pvals = einv.pvals, 
                  einv.perm = einv.perm, 
                  edges.pvalmattemp=edges.pvalmattemp, edges.pvaltemp1=edges.pvaltemp1,
                  edges.pvaltemp=edges.pvaltemp, ept.HBall=ept.HBall, diffedges.realmat=diffedges.realmat,
                  diffedges.real=diffedges.real)
    }
    if (progressbar == TRUE) 
      close(pb)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    if (test.edges == FALSE) {
      res <- list(glstrinv.real = glstrinv.real, glstrinv.sep = glstrinv.sep, 
                  glstrinv.pval = sum(glstrinv.perm >= glstrinv.real)/it, 
                  glstrinv.perm = glstrinv.perm, nwinv.real = nwinv.real, 
                  nwinv.pval = sum(nwinv.perm >= nwinv.real)/it, 
                  nwinv.perm = nwinv.perm)
    }
  }
  if (binary.data == TRUE) {
    IF1 <- IsingFit(x1, AND = AND, gamma = gamma, plot = FALSE, 
                    progressbar = FALSE)
    IF2 <- IsingFit(x2, AND = AND, gamma = gamma, plot = FALSE, 
                    progressbar = FALSE)
    nw1 <- IF1$weiadj
    nw2 <- IF2$weiadj
    if (weighted == FALSE) {
      nw1 = (nw1 != 0) * 1
      nw2 = (nw2 != 0) * 1
    }
    glstrinv.real <- abs(sum(abs(nw1[upper.tri(nw1)])) - 
                           sum(abs(nw2[upper.tri(nw2)])))
    glstrinv.sep <- c(sum(abs(nw1[upper.tri(nw1)])), sum(abs(nw2[upper.tri(nw2)])))
    diffedges.real <- abs(nw1 - nw2)[upper.tri(abs(nw1 - 
                                                     nw2))]
    diffedges.realmat <- matrix(diffedges.real, it, nedges, 
                                byrow = TRUE)
    diffedges.realoutput <- abs(nw1 - nw2)
    nwinv.real <- max(diffedges.real)
    for (i in 1:it) {
      if (paired == FALSE) {
        checkN = 0
        while (checkN == 0) {
          s <- sample(1:(nobs1 + nobs2), nobs1, replace = FALSE)
          x1perm <- dataall[s, ]
          x2perm <- dataall[b[-s], ]
          cm1 <- colMeans(x1perm)
          cm2 <- colMeans(x2perm)
          checkN = ifelse(any(cm1 < (1/nobs1)) | any(cm1 > 
                                                       (nobs1 - 1)/nobs1) | any(cm2 < (1/nobs2)) | 
                            any(cm2 > (nobs2 - 1)/nobs2), 0, 1)
        }
        IF1perm <- IsingFit(x1perm, AND = AND, gamma = gamma, 
                            plot = FALSE, progressbar = FALSE)
        IF2perm <- IsingFit(x2perm, AND = AND, gamma = gamma, 
                            plot = FALSE, progressbar = FALSE)
        r1perm <- IF1perm$weiadj
        r2perm <- IF2perm$weiadj
        if (weighted == FALSE) {
          r1perm = (r1perm != 0) * 1
          r2perm = (r2perm != 0) * 1
        }
      }
      if (paired == TRUE) {
        checkN = 0
        while (checkN == 0) {
          s <- sample(c(1, 2), nobs1, replace = TRUE)
          x1perm <- x1[s == 1, ]
          x1perm <- rbind(x1perm, x2[s == 2, ])
          x2perm <- x2[s == 1, ]
          x2perm <- rbind(x2perm, x1[s == 2, ])
          cm1 <- colMeans(x1perm)
          cm2 <- colMeans(x2perm)
          checkN = ifelse(any(cm1 < (1/nobs1)) | any(cm1 > 
                                                       (nobs1 - 1)/nobs1) | any(cm2 < (1/nobs2)) | 
                            any(cm2 > (nobs2 - 1)/nobs2), 0, 1)
        }
        IF1perm <- IsingFit(x1perm, AND = AND, gamma = gamma, 
                            plot = FALSE, progressbar = FALSE)
        IF2perm <- IsingFit(x2perm, AND = AND, gamma = gamma, 
                            plot = FALSE, progressbar = FALSE)
        r1perm <- IF1perm$weiadj
        r2perm <- IF2perm$weiadj
        if (weighted == FALSE) {
          r1perm = (r1perm != 0) * 1
          r2perm = (r2perm != 0) * 1
        }
      }
      glstrinv.perm[i] <- abs(sum(abs(r1perm[upper.tri(r1perm)])) - 
                                sum(abs(r2perm[upper.tri(r2perm)])))
      diffedges.perm[i, ] <- abs(r1perm - r2perm)[upper.tri(abs(r1perm - 
                                                                  r2perm))]
      diffedges.permtemp[upper.tri(diffedges.permtemp, 
                                   diag = FALSE)] <- diffedges.perm[i, ]
      diffedges.permtemp <- diffedges.permtemp + t(diffedges.permtemp)
      einv.perm.all[, , i] <- diffedges.permtemp
      nwinv.perm[i] <- max(diffedges.perm[i, ])
      if (progressbar == TRUE) 
        setTxtProgressBar(pb, i)
    }
    if (test.edges == TRUE) {
      edges.pvaltemp <- colSums(diffedges.perm >= diffedges.realmat)/it
      edges.pvalmattemp[upper.tri(edges.pvalmattemp, diag = FALSE)] <- edges.pvaltemp
      edges.pvalmattemp <- edges.pvalmattemp + t(edges.pvalmattemp)
      if (is.character(edges)) {
        ept.HBall <- p.adjust(edges.pvaltemp, method = "holm")
        edges.pval.HBall[upper.tri(edges.pval.HBall, 
                                   diag = FALSE)] <- ept.HBall
        rownames(edges.pval.HBall) <- colnames(edges.pval.HBall) <- colnames(data1)
        einv.pvals <- melt(edges.pval.HBall, na.rm = TRUE, 
                           value.name = "p-value")
        einv.perm <- einv.perm.all
        einv.real <- diffedges.realoutput
      }
      if (is.list(edges)) {
        einv.perm <- matrix(NA, it, length(edges))
        colnames(einv.perm) <- edges
        uncorrpvals <- einv.real <- c()
        for (j in 1:length(edges)) {
          uncorrpvals[j] <- edges.pvalmattemp[edges[[j]][1], 
                                              edges[[j]][2]]
          einv.real[j] <- diffedges.realoutput[edges[[j]][1], 
                                               edges[[j]][2]]
          for (l in 1:it) {
            einv.perm[l, j] <- einv.perm.all[, , l][edges[[j]][1], 
                                                    edges[[j]][2]]
          }
        }
        HBcorrpvals <- p.adjust(uncorrpvals, method = "holm")
        einv.pvals <- HBcorrpvals
      }
      edges.tested <- colnames(einv.perm)
      res <- list(glstrinv.real = glstrinv.real, glstrinv.sep = glstrinv.sep, 
                  glstrinv.pval = sum(glstrinv.perm >= glstrinv.real)/it, 
                  glstrinv.perm = glstrinv.perm, nwinv.real = nwinv.real, 
                  nwinv.pval = sum(nwinv.perm >= nwinv.real)/it, 
                  nwinv.perm = nwinv.perm, edges.tested = edges.tested, 
                  einv.real = einv.real, einv.pvals = einv.pvals, 
                  edges.pvalmattemp=edges.pvalmattemp, einv.perm = einv.perm)
    }
    if (progressbar == TRUE) 
      close(pb)
    if (test.edges == FALSE) {
      res <- list(glstrinv.real = glstrinv.real, glstrinv.sep = glstrinv.sep, 
                  glstrinv.pval = sum(glstrinv.perm >= glstrinv.real)/it, 
                  glstrinv.perm = glstrinv.perm, nwinv.real = nwinv.real, 
                  nwinv.pval = sum(nwinv.perm >= nwinv.real)/it, 
                  edges.pvalmattemp=edges.pvalmattemp, nwinv.perm = nwinv.perm)
    }
  }
  # class(res) <- "NCT"
  return(res)
}