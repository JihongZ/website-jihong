---
title: "EFA v.s. CFA"
date: 2017-11-20
categories:
- blog
tags:
- Statistics
- Education
---

## Big question

> I always found exploratory tools and confirmatory tools have distinct fans. The fans of exploratory tools believe the conclusion should be data-driven, nothing else beyond data is needed in order to keep object. On the other hand, some confirmatory fans believe that data could provide nothing without context.

Daniel (1988) stated that factor analysis is "designed to examine the covariance structure of a set of variables and to provide an explanation of the relationships among those variables in terms of a smaller number of unobserved latent variables called factors."

Recently, when I was working on my project about Confirmatory Factor Analysis, I found the model indicated very bad model fit (e.g. CFI, TLI, RMSEA, SRMR). Then, should I use modification indices or go back to exploratory factor analysis to find some potential structural issues? Both paths have their own supporters and opposers. EFA path supports claim that EFA could provide some data structure that CFA couldn't. Allowing cross-loading items, communalities could be calculated. But its disadvantage is that data-driven method are strongly influenced by data. If the data is bad, the EFA will give you wrong answers.

### CFA

CFA is a confirmatory technique - it is theory driven. Therefore, the planning of the analysis is driven by the theoretical relationships among the observed and unobserved variables. When a CFA is conducted, the researcher uses a hypothesized model to estimate a population covariance matrix that is compared with the observed covariance matrix. Technically, the researcher wants to minimize the difference between the estimated and observed matrices.

CFA model believe that context of the research should be guild line to data. Thus, the model specification should be theory-driven. If the model does not fit the data very well, modification as well as residual variance-covariance matrix could be use to inspect the issues. The problem is that model modification does not lead the final model to true model according to many simulation studies. In that way, CFA models are as similar as EFA.

## Which one should be trust?

I think it depends on your research project. If your research project has strong theoretical support then CFA should be first step. If your research is new, there're few related researches about that. Then try EFA first.
