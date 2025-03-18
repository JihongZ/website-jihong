data {
  int<lower=0> nObs;                            // number of observations
  int<lower=0> nItems;                          // number of items
  int<lower=0> maxCategory; 
  
  array[nItems, nObs] int<lower=1, upper=5>  Y; // item responses in an array

  array[nItems] vector[maxCategory-1] meanThr;   // prior mean vector for intercept parameters
  array[nItems] matrix[maxCategory-1, maxCategory-1] covThr;      // prior covariance matrix for intercept parameters
  
  vector[nItems] meanLambda;         // prior mean vector for discrimination parameters
  matrix[nItems, nItems] covLambda;  // prior covariance matrix for discrimination parameters
}
parameters {
  vector[nObs] theta;                // the latent variables (one for each person)
  array[nItems] ordered[maxCategory-1] thr; // the item thresholds (one for each item category minus one)
  vector[nItems] lambda;             // the factor loadings/item discriminations (one for each item)
}
model {
  
  lambda ~ multi_normal(meanLambda, covLambda); // Prior for item discrimination/factor loadings
  theta ~ normal(0, 1);                         // Prior for latent variable (with mean/sd specified)
  
  for (item in 1:nItems){
    thr[item] ~ multi_normal(meanThr[item], covThr[item]);             // Prior for item intercepts
    Y[item] ~ ordered_logistic(lambda[item]*theta, thr[item]);
  }
  
}
generated quantities{
  array[nItems] vector[maxCategory-1] mu;
  for (item in 1:nItems){
    mu[item] = -1*thr[item];
  }
}

