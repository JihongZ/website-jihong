data {

  int<lower=0> nObs;                 // number of observations #<1>
  int<lower=0> nItems;               // number of items #<2>
  matrix[nObs, nItems] Y;            // item responses in a matrix

  vector[nItems] meanMu;
  matrix[nItems, nItems] covMu;      // prior covariance matrix for coefficients #<3>

  vector[nItems] meanLambda;         // prior mean vector for coefficients
  matrix[nItems, nItems] covLambda;  // prior covariance matrix for coefficients #<4>

  vector[nItems] psiRate;            // prior rate parameter for unique standard deviations #<5>
}

parameters {
  vector[nObs] theta;                // the latent variables (one for each person)
  vector[nItems] mu;                 // the item intercepts (one for each item)
  vector[nItems] lambda;             // the factor loadings/item discriminations (one for each item)
  vector<lower=0>[nItems] psi;       // the unique standard deviations (one for each item)   
}

model {
  lambda ~ multi_normal(meanLambda, covLambda); // Prior for item discrimination/factor loadings
  mu ~ multi_normal(meanMu, covMu);             // Prior for item intercepts
  psi ~ exponential(psiRate);                   // Prior for unique standard deviations
  
  theta ~ normal(0, 1);                         // Prior for latent variable (with mean/sd specified)
  
  for (item in 1:nItems){
    Y[,item] ~ normal(mu[item] + lambda[item]*theta, psi[item]);
  }
}

