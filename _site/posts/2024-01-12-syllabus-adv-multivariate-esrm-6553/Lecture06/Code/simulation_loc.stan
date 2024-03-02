data {
  int<lower=0> N; // number of observations
  int<lower=0> J; // number of items
  int<lower=0> K; // number of latent variables
  matrix[N, J] Y; // item responses
  
  //location of lambda
  array[J] int<lower=0> kk;
  
  //hyperparameter
  real<lower=0> sigmaRate;
  vector[J] meanMu;
  matrix[J, J] covMu;      // prior covariance matrix for coefficients
  vector[K] meanTheta;
  
  vector[J] meanLambda;
  matrix[J, J] covLambda;      // prior covariance matrix for coefficients
  
  real<lower=0> eta; // LKJ shape parameters
}
parameters {
  vector[J] mu;
  vector<lower=0,upper=1>[J] lambda;
  vector<lower=0>[J] sigma; // the unique residual standard deviation for each item
  matrix[N, K] theta;                // the latent variables (one for each person)
  // corr_matrix[K] corrTheta;  // factor correlation matrix
  cholesky_factor_corr[K] L; 
}
transformed parameters{
  matrix[K,K] corrTheta = multiply_lower_tri_self_transpose(L);
}
model {
  mu ~ multi_normal(meanMu, covMu);
  sigma ~ exponential(sigmaRate);                   // Prior for unique standard deviations
  lambda ~ multi_normal(meanLambda, covLambda);
  //corrTheta ~ lkj_corr(eta); // LKJ prior on the correlation matrix of factors
  L ~ lkj_corr_cholesky(eta);
  for (i in 1:N) {
    theta[i,] ~ multi_normal(meanTheta, corrTheta);
  }
  for (j in 1:J) {
    Y[,j] ~ normal(mu[j]+lambda[j]*theta[,kk[j]], sigma[j]);
  }
}
generated quantities {
  vector[N * J] log_lik;
  matrix[N, J] temp;
  matrix[N, J] Y_rep;
  vector[J] Item_Mean_rep;
  for (i in 1:N) {
    for (j in 1:J) {
      temp[i, j] = normal_lpdf(Y[i, j] | mu[j]+lambda[j]*theta[i,kk[j]],  sigma[j]); 
    }
  }
  log_lik = to_vector(temp);
  for (j in 1:J) {
    Y_rep[,j] = to_vector(normal_rng(mu[j]+lambda[j]*theta[,kk[j]], sigma[j]));
    Item_Mean_rep[j] = mean(Y_rep[,j]);
  }
}
