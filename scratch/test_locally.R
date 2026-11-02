
setwd( R'(C:\Users\jtuth\Documents\GitHub\fish-trait-network\fish-traitR)' )
devtools::load_all()

#######################
# TEST
#######################

download_traits()
traits = get_traits("Cyclopterus lumpus")

# Extract growth rate
get_r(
  K = exp(traits$est['log(growth_coefficient)']),
  Winf = exp(traits$est['log(growth_coefficient)']),
  a_mat = exp(traits$est['log(age_maturity)']),
  MASPS = exp(traits$est['logMASPS']),
  M = exp(traits$est['log(natural_mortality)'])
)

# Sample from predictive distribution
traits_i = mvtnorm::rmvnorm(
  n = 250,
  mean = traits$est,
  sigma = traits$cov
)

# Calculate and plot
pred_zi = mapply(
  FUN = get_r,
  K = exp(traits_i[,'log(growth_coefficient)']),
  Winf = exp(traits_i[,'log(growth_coefficient)']),
  a_mat = exp(traits_i[,'log(age_maturity)']),
  MASPS = exp(traits_i[,'logMASPS']),
  M = exp(traits_i[,'log(natural_mortality)'])
)
hist(pred_zi['intrinsic_growth_rate',])
