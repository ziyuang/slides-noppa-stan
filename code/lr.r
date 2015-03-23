library(rstan)
N <- 100; x <- 1:N; alpha <- 50; beta <- 0.2
y <- alpha + beta * x + rnorm(n, mean=0, sd=4)
lr_data <- list(N=N, x=x, y=y)
lr_code <- '
data {
  int<lower=0> N;
  vector[N] x; 
  vector[N] y;
}
parameters {
  real alpha;
  real beta; 
  real<lower=0> sigma_sqrt;
}
model {
  y ~ normal(alpha + beta * x, sigma_sqrt); 
}
'

lr_fit <- stan(model_code=lr_code, data=lr_data, iter=1000, chains=4)