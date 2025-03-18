
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
generated quantities{
  // simulated data
  vector[N] weightLB_pred = X*beta; // predicted value (conditional mean)
  array[N] real weightLB_rep = normal_rng(weightLB_pred, sigma);
  // posterior predictive distribution for mean and SD
  real mean_weightLB = mean(weightLB);
  real sd_weightLB = sd(weightLB);
  real mean_weightLB_rep = mean(to_vector(weightLB_rep));
  real<lower=0> sd_weightLB_rep = sd(to_vector(weightLB_rep));
  // ppp-values for mean and sd
  int<lower=0, upper=1> ppp_mean = (mean_weightLB_rep > mean_weightLB);
  int<lower=0, upper=1> ppp_sd = (sd_weightLB_rep > sd_weightLB);
  // WAIC and LOO for model comparison
  array[N] real log_lik;
  for (person in 1:N){
    log_lik[person] = normal_lpdf(weightLB[person] | weightLB_pred[person], sigma);
  }
}

