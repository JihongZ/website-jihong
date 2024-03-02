data {
  int<lower=0> N;
  vector[N] y;
}

parameters {
  real beta0;
  real<lower=0> sigma;
}

model {
  beta0 ~ normal(50, 10); // prior for beta0
  sigma ~ uniform(0, 10); // prior for sigma
  y ~ normal(beta0, sigma); // model for observed data
}
