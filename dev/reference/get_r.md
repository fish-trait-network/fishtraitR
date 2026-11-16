# Calculate intrinsic growth rate, generation time, and steepness

Calculate intrinsic growth rate for fishes using size, growth, maturity,
and juvenile density-dependence traits

## Usage

``` r
get_r(
  K,
  Winf,
  a_mat,
  CR,
  M,
  t0 = -0.1,
  a_slope = a_mat/4,
  d = 2/3,
  a_max = 100
)
```

## Arguments

- K:

  von Bertalanffy growth coefficient for length at age

- Winf:

  Asymptotic maximum length

- a_mat:

  age at maturity (in years)

- CR:

  Compensation ratio, i.e., \\CR = 1 + MLER\\ or \\CR = 1 + MAER /
  (1-exp(-M))\\ where MLER and MAER are maximum lifetime and maximum
  annual excess replacement, respectively

- M:

  Natural mortality rate (per year)

- t0:

  Implied age with zero length

- a_slope:

  slope of logistic maturity at age

- d:

  Scaling of catabolism with length (specialized von Bertalanffy growth
  function assumes `d = 2/3`)

- a_max:

  maximum age for computing life table

## Examples

``` r
# Get traits for selected species
download_traits()
#> [1] "C:\\Users\\jtuth\\AppData\\Local/R/cache/R/ftn-distribution/zenodo_24259333"
traits = get_traits( "Lutjanus campechanus" )

# Extract growth rate
get_r(
  K = exp(traits$est['log(growth_coefficient)']),
  Winf = exp(traits$est['log(growth_coefficient)']),
  a_mat = exp(traits$est['log(age_maturity)']),
  CR = 1 + exp(traits$est['phi']),
  M = exp(traits$est['log(natural_mortality)'])
)
#> Error in eigen(LeslieM_numbers, only.values = TRUE): infinite or missing values in 'x'

# Sample from predictive distribution
traits_i = mvtnorm::rmvnorm(
  n = 250,
  mean = traits$est,
  sigma = traits$cov
)
#> Error in UseMethod("isSymmetric"): no applicable method for 'isSymmetric' applied to an object of class "c('array', 'double', 'numeric')"

# Calculate and plot
pred_zi = mapply(
  FUN = get_r,
  K = exp(traits_i[,'log(growth_coefficient)']),
  Winf = exp(traits_i[,'log(growth_coefficient)']),
  a_mat = exp(traits_i[,'log(age_maturity)']),
  CR = 1 + exp(traits_i[,'phi']),
  M = exp(traits_i[,'log(natural_mortality)'])
)
#> Error: object 'traits_i' not found
hist(pred_zi['intrinsic_growth_rate',])
#> Error: object 'pred_zi' not found
```
