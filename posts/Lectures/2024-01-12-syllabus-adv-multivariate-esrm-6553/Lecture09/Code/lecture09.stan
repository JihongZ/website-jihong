//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> nObs;                            // number of observations
  int<lower=0> nItems;                          // number of items
  array[nItems, nObs] int<lower=0, upper=1>  Y; // item responses in an array

  vector[nItems] meanMu;             // prior mean vector for intercept parameters
  matrix[nItems, nItems] covMu;      // prior covariance matrix for intercept parameters
  
  vector[nItems] meanLambda;         // prior mean vector for discrimination parameters
  matrix[nItems, nItems] covLambda;  // prior covariance matrix for discrimination parameters
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  vector[nObs] theta;                // the latent variables (one for each person)
  vector[nItems] mu;                 // the item intercepts (one for each item)
  vector[nItems] lambda;             // the factor loadings/item discriminations (one for each item)
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  
  lambda ~ multi_normal(meanLambda, covLambda); // Prior for item discrimination/factor loadings
  mu ~ multi_normal(meanMu, covMu);             // Prior for item intercepts
  
  theta ~ normal(0, 1);                         // Prior for latent variable (with mean/sd specified)
  
  for (item in 1:nItems){
    Y[item] ~ bernoulli_logit(mu[item] + lambda[item]*theta);
  }
  
}

