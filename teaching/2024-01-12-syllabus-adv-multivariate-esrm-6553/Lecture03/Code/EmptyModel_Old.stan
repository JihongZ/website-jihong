data {
  int<lower=0> N;
  vector[N] weightLB;
}

parameters {
  real beta0;
  real<lower=0> sigma;
}

model {
  beta0 ~ normal(0, 1000); // prior for beta0
  sigma ~ uniform(0, 100000); // prior for sigma
  weightLB ~ normal(beta0, sigma); // model for observed data
}
generated quantities{
  // simulated data
  vector[N] weightLB_pred; // predicted value (conditional mean)
  // WAIC and LOO for model comparison
  array[N] real log_lik;
  for (person in 1:N){
    weightLB_pred[person] = beta0;
    log_lik[person] = normal_lpdf(weightLB[person] | weightLB_pred[person], sigma);
  }
}
