source('gp_data.R')

gp_stan  <- '
  data{
    int <lower=1> N_ages;
    vector[N_ages] ages;
    int K[N_ages];  // number of those who support gay marriage in that age group
    int N[N_ages];  // number of people in that age group
  }

  transformed data{
    vector[N_ages] mu;
    mu <- rep_vector(0, N_ages);  // prior of the GP
  }

  parameters{
    real<lower=0> theta_1;
    real<lower=0> theta_2;
    real<lower=0> theta_3;
    real<lower=0> theta_4;
    vector[N_ages] y; // variable in the sigmoid function
  }

  model{
    matrix[N_ages, N_ages] Sigma;
    for (i in 1:N_ages){
      for (j in i:N_ages){
        Sigma[i,j] <- theta_1 * exp(-theta_2 * square(ages[i]-ages[j])) + theta_3 + theta_4 * ages[i] * ages[j];
      }
    }
    for (i in 1:N_ages){
      for (j in (i+1):N_ages){
        Sigma[j, i] <- Sigma[i,j];
      }
    }

    // weakly informative priors
    theta_1 ~ cauchy(0,5);
    theta_2 ~ cauchy(0,5);
    theta_3 ~ cauchy(0,5);
    theta_4 ~ cauchy(0,5);

    y ~ multi_normal(mu, Sigma);
    K ~ binomial_logit(N, y);
  } 
  
  generated quantities{
    vector[N_ages] p_post;
    vector[N_ages] kdn_post;  // K given N

    for (i in 1:N_ages){
      p_post[i] <- inv_logit(y[i]); // sigmoid function
      kdn_post[i] <- 1.0 * binomial_rng(N[i], p_post[i]) / N[i];
    }
  }
'

gp_fit <- stan(model_code=gp_stan, data=gp_data, iter=1000, chains=4)