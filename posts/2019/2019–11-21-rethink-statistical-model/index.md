---
title: Some Thoughts After Reading <Statistical Rethinking>
date: 2019-11-21
draft: false
categories:
  - blog
---

Last night, I read the 1st chapter of *Statistical Rethinking: A Bayesian Course with Examples in R and Stan* from Richard McElreath. I found this is nice book to share with my friends. The core idea of that chapter is the relationship between NULL hypothesis and statistical model. That is, should we trust the statistical models to reject the NULL hypothesis?

It is a long history to use statistical models to figure out what is true? What is false? People found that comparing to prove what is true, prove what is false or falsifying the hypothesis (falsification) is more straightforward. This is because even thought you found thousands of millions of cases that the hypothesis is true ("Swans are white"), it does not guarantee this hypothesis is true. However, only one case that the hypothesis is not true ("A Swan is black") is needed to prove it wrong. Thus, scientists seek to propose a hypothesis and then falsify it.

Another problem related to the falsification is that hypothesis is not model. That is to say, a NULL hypothesis could have several possible process models. These process models may or may not correspond to several statistical models. If we find a statistical model that match the samples. It only indicates it could be come from several process models. These process models may or may not come from the NULL hypothesis. As the author said:

1.  Any given statistical model (M) may correspond to more than one process model (P).
2.  Any given hypothesis (H) may correspond to more than one process model (P).
3.  Any given statistical model (M) may correspond to more than one hypothesis (H).

The traditional approach is to take the "neutral" model as a null hypothesis ("Item Response is not correlated among each other"), if the data (alternative model) are not sufficiently similar to the expectation under the null (NULL model), then we say that we "reject" the null hypothesis. Another explanation is we only have one model based NULL hypothesis but we potentially have a large number of model based on non-NULL hypothesis. Some of these non-NULL hypothesis may have similar model with the one based on NULL hypothesis. If we do not think carefully, we may reject the non-NULL hypothesis rather than NULL hypothesis.

What can be done? The author try to encourage use to "search for a different description of the evidence, a description under which the processes look different." For example, use different model fit indices in factor analysis instead of one because those model fit may depict different process models and different description of the evidence.
