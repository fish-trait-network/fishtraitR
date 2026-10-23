
setwd( R'(C:\Users\jtuth\Documents\GitHub\fish-trait-network\fish-traitR)' )
devtools::load_all()

#######################
# TEST
#######################

download_traits()
get_traits("Aapticheilichthys websteri")
get_traits("Sebastes pinniger")

