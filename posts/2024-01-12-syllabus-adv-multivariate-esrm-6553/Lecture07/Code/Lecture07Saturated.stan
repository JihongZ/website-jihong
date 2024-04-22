data {

  int<lower=0> nObs;                 // number of observations #<1>
  int<lower=0> nItems;               // number of items #<2>
  matrix[nObs, nItems] Y;            // item responses in a matrix

  vector[nItems] meanMu;
  matrix[nItems, nItems] covMu;      // prior covariance matrix for coefficients #<3>
  


}

parameters {
  vector[nItems] mu;                 // the item intercepts (one for each item)
  cov_matrix[nItems] psi;       // the unique standard deviations (one for each item)   
}

model {
  mu ~ multi_normal(meanMu, covMu);             // Prior for item intercepts
  
  for (i in 1:nObs) {
    Y[i, ] ~ multi_normal(mu, psi);
  }
  
  
}
generated quantities {
  real mean_log_lik;
  real mean_log_lik_rep;
  real D;
  array[nObs] vector[nItems] Y_rep;
  
  for (i in 1:nObs) {
    Y_rep[i] = multi_normal_rng(mu, psi);
    mean_log_lik = multi_normal_lpdf(Y[i,] | mu,  psi); 
    mean_log_lik_rep = multi_normal_lpdf(Y_rep[i] | mu,  psi); 
  }
  D = mean_log_lik - mean_log_lik_rep;
}
