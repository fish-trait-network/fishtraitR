
setwd( R'(C:\Users\jtuth\Documents\GitHub\fish-trait-network\fish-traitR)' )
devtools::load_all()

save_dir = R'(C:\Users\jtuth\Documents\GitHub\future_phylosem)'
fit = readRDS( file.path(save_dir, "2026-11-12", "fit.RDS") )


#######################
# TEST
#######################

remotes::install_github("fish-trait-network/fishtraitR")
library(fishtraitR)

Genus_species = "Micromesistius poutassou"
download_traits()
traits = get_traits( Genus_species )   # Blue whiting
exp(traits$est['log(natural_mortality)',1])
sqrt(traits$cov['log(natural_mortality)','log(natural_mortality)',1])

#
fit$data[ which(fit$data_labels == Genus_species), c('log(growth_coefficient)', 'log(natural_mortality)') ]

#
plot(
  traits,
  variables = c( 'log(growth_coefficient)', 'log(natural_mortality)' ),
  data = fit$data,
  data_labels = fit$data_labels
)

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

####################
# 2023
####################

library(FishLife)
edge_names = c( FishBase_and_Morphometrics$tree$tip.label,
                FishBase_and_Morphometrics$tree$node.label[-1] ) # Removing root

#
which_g = match( Genus_species, edge_names )
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
