
data {
  int<lower=0> N; // sample size
  array[N] int<lower=0, upper=1> y; // observed data
  real<lower=1> alpha; // hyperparameter alpha
  real<lower=1> beta; // hyperparameter beta
}
parameters {
  real<lower=0,upper=1> p1; // parameters
}
model {
  p1 ~ beta(alpha, beta); // prior distribution
  for(n in 1:N){
    y[n] ~ bernoulli(p1); // model
  }
}

