data {
  int<lower=0> nObs;                            // number of observations
  int<lower=0> nItems;                          // number of items
  array[nItems] int<lower=0> maxItem;
  
  array[nItems, nObs] int<lower=0>  Y; // item responses in an array

  vector[nItems] meanMu;             // prior mean vector for intercept parameters
  matrix[nItems, nItems] covMu;      // prior covariance matrix for intercept parameters
  
  vector[nItems] meanLambda;         // prior mean vector for discrimination parameters
  matrix[nItems, nItems] covLambda;  // prior covariance matrix for discrimination parameters
}

parameters {
  vector[nObs] theta;                // the latent variables (one for each person)
  vector[nItems] mu;                 // the item intercepts (one for each item)
  vector[nItems] lambda;             // the factor loadings/item discriminations (one for each item)
}

model {
  lambda ~ multi_normal(meanLambda, covLambda); // Prior for item discrimination/factor loadings
  mu ~ multi_normal(meanMu, covMu);             // Prior for item intercepts
  theta ~ normal(0, 1);                         // Prior for latent variable (with mean/sd specified)
  for (item in 1:nItems){
    Y[item] ~ binomial(maxItem[item], inv_logit(mu[item] + lambda[item]*theta));
  }
}


