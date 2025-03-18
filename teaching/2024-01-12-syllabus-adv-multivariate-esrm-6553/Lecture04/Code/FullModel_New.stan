
data{
  int<lower=0> N;         // number of observations
  int<lower=0> P;         // number of predictors (plus column for intercept)
  matrix[N, P] X;         // model.matrix() from R 
  vector[N] weightLB;     // outcome
  real sigmaRate;         // hyperparameter: prior rate parameter for residual standard deviation
}
parameters {
  vector[P] beta;         // vector of coefficients for Beta
  real<lower=0> sigma;    // residual standard deviation
}
model {
  sigma ~ exponential(sigmaRate);         // prior for sigma
  weightLB ~ normal(X*beta, sigma);       // linear model
}

