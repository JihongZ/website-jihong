data {

  int<lower=0> nObs;                 // number of observations #<1>
  int<lower=0> nItems;               // number of items #<2>
  matrix[nObs, nItems] Y;            // item responses in a matrix

  vector[nItems] meanMu;
  matrix[nItems, nItems] covMu;      // prior covariance matrix for coefficients #<3>

  vector[nItems] psiRate;            // prior rate parameter for unique standard deviations #<5>
}

parameters {
  vector[nItems] mu;                 // the item intercepts (one for each item)
  vector<lower=0>[nItems] psi;       // the unique standard deviations (one for each item)   
}

model {
  mu ~ multi_normal(meanMu, covMu);             // Prior for item intercepts
  psi ~ exponential(psiRate);                   // Prior for unique standard deviations
  
  
  for (i in 1:nObs) {
    Y[i, ] ~ multi_normal(mu, diag_matrix(psi));
  }
  
  
}
generated quantities {
  real mean_log_lik;
  real mean_log_lik_rep;
  real D;
  array[nObs] vector[nItems] Y_rep;
  
  for (i in 1:nObs) {
    Y_rep[i] = multi_normal_rng(mu, diag_matrix(psi));
    mean_log_lik = multi_normal_lpdf(Y[i,] | mu,  diag_matrix(psi)); 
    mean_log_lik_rep = multi_normal_lpdf(Y_rep[i] | mu,  diag_matrix(psi)); 
  }
  D = mean_log_lik - mean_log_lik_rep;
}
