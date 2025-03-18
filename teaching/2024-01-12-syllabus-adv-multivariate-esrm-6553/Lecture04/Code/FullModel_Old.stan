
data{
    int<lower=0> N;
    vector[N] weightLB;
    vector[N] height60IN;
    vector[N] group2;
    vector[N] group3;
    vector[N] heightXgroup2;
    vector[N] heightXgroup3;
}
parameters {
  real beta0;
  real betaHeight;
  real betaGroup2;
  real betaGroup3;
  real betaHxG2;
  real betaHxG3;
  real<lower=0> sigma;
}
model {
  sigma ~ exponential(.1); // prior for sigma
  weightLB ~ normal(
    beta0 + betaHeight * height60IN + betaGroup2 * group2 + 
    betaGroup3*group3 + betaHxG2*heightXgroup2 +
    betaHxG3*heightXgroup3, sigma);
}

