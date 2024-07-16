
data{
  int<lower=0> N;         // number of observations
  int<lower=0> P;         // number of predictors (plus column for intercept)
  matrix[N, P] X;         // model.matrix() from R 
  vector[N] weightLB;     // outcome
  real sigmaRate;         // hyperparameter: prior rate parameter for residual standard deviation
  int<lower=0> nContrasts;
  matrix[nContrasts, P] contrast; // C matrix 
}
parameters {
  vector[P] beta;         // vector of coefficients for Beta
  real<lower=0> sigma;    // residual standard deviation
}
model {
  sigma ~ exponential(sigmaRate);         // prior for sigma
  weightLB ~ normal(X*beta, sigma);       // linear model
}
generated quantities{
  vector[nContrasts] computedEffects;
  computedEffects = contrast*beta;
  // compute R2
  real rss;
  real tss;
  real R2;
  real R2adj;
  {// anything in these brackets will not appear in summary table
    vector[N] pred = X*beta;
    rss = dot_self(weightLB-pred); // dot_self is stan function for matrix square
    tss = dot_self(weightLB-mean(weightLB));
  }
  R2 = 1-rss/tss;
  R2adj = 1-(rss/(N-P))/(tss/(N-1));
}

