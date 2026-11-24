# fishtraitR

[![docs (main)](https://img.shields.io/badge/docs-fishtraitR-orange.svg?colorB=E91E63)](https://fish-trait-network.github.io/fishtraitR/dev/)


Access imputed trait values and predictive variance for fishes, as Distribution stage for the fish-trait-network

### Example

```R
# Install
pak::pak("fish-trait-network/fishtraitR")
library("fishtraitR")

# Download database from Zenodo
download_traits()

# Access traits
traits = get_traits("Lutjanus campechanus")

# Extract growth rate
get_r(
  K = exp(traits$est['log(growth_coefficient)',1]),
  Winf = exp(traits$est['log(weight_infinity)',1]),
  a_mat = exp(traits$est['log(age_maturity)',1]),
  CR = 1 + exp(traits$est['phi',1]),
  M = exp(traits$est['log(natural_mortality)',1])
)

# Sample from predictive distribution
traits_i = mvtnorm::rmvnorm(
  n = 250,
  mean = traits$est[,1],
  sigma = traits$cov[,,1]
)

# Calculate and plot
pred_zi = mapply(
  FUN = get_r,
  K = exp(traits_i[,'log(growth_coefficient)']),
  Winf = exp(traits_i[,'log(growth_coefficient)']),
  a_mat = exp(traits_i[,'log(age_maturity)']),
  CR = 1 + exp(traits_i[,'phi']),
  M = exp(traits_i[,'log(natural_mortality)'])
)
hist(pred_zi['intrinsic_growth_rate',])

# Bivariate plot
plot(
  traits,
  variables = c( 'log(growth_coefficient)', 'log(natural_mortality)' )
)
```


