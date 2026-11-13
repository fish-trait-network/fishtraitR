
setwd( R'(C:\Users\jtuth\Documents\GitHub\fish-trait-network\fish-traitR)' )
devtools::load_all()

#######################
# TEST
#######################

library(fishtraitR)

download_traits()
traits = get_traits( "Cyclopterus lumpus" )

pred = list(
  est = cbind( "Cyclopterus lumpus" = traits$est ),
  cov = array( traits$cov, dim = c(dim(traits$cov),1), dimnames = c(dimnames(traits$cov), "Cyclopterus lumpus") )
)
class(pred) = "predict_phylosem"

#
plot(
  pred,
  variables = c( 'log(growth_coefficient)', 'log(natural_mortality)' )
)

# Extract growth rate
get_r(
  K = exp(traits$est['log(growth_coefficient)']),
  Winf = exp(traits$est['log(weight_infinity)']),
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


####################
# 2023
####################

library(FishLife)
edge_names = c( FishBase_and_Morphometrics$tree$tip.label,
                FishBase_and_Morphometrics$tree$node.label[-1] ) # Removing root

#
which_g = match( "Cyclopterus lumpus", edge_names )
Table2023 = cbind(
  Mean = FishBase_and_Morphometrics$beta_gv[which_g,],
  SE = sqrt(diag(FishBase_and_Morphometrics$Cov_gvv[which_g,,]))
)
knitr::kable( Table2023, digits=3)

####################
# 2020
####################

# Get basic plot for Lutjanus campechanus
Taxa = Search_species( Genus = "Cyclopterus",
                       Species = "lumpus")$match_taxonomy
Predict = Plot_taxa( Taxa,
                     mfrow=c(3,2) )
sqrt(diag(Predict[[1]][[1]]))
Predict[[1]][[2]]
