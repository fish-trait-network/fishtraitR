
#' @title Calculate intrinsic growth rate, generation time, and steepness
#'
#' @description Calculate intrinsic growth rate for fishes using
#'   size, growth, maturity, and juvenile density-dependence traits
#'
#' @param K von Bertalanffy growth coefficient for length at age
#' @param Winf Asymptotic maximum length
#' @param a_mat age at maturity (in years)
#' @param MASPS Maximum annual spawners per spawner above replacement
#' @param M Natural mortality rate (per year)
#' @param t0 Implied age with zero length
#' @param a_slope slope of logistic maturity at age
#' @param d Scaling of catabolism with length (specialized von Bertalanffy
#'   growth function assumes \code{d = 2/3})
#' @param a_max maximum age for computing life table
#'
#' @examples
#' # Get traits for selected species
#' download_traits()
#' traits = get_traits( "Lutjanus campechanus" )
#'
#' # Extract growth rate
#' get_r(
#'   K = exp(traits$est['log(growth_coefficient)']),
#'   Winf = exp(traits$est['log(growth_coefficient)']),
#'   a_mat = exp(traits$est['log(age_maturity)']),
#'   MASPS = exp(traits$est['logMASPS']),
#'   M = exp(traits$est['log(natural_mortality)'])
#' )
#'
#' # Sample from predictive distribution
#' traits_i = mvtnorm::rmvnorm(
#'   n = 250,
#'   mean = traits$est,
#'   sigma = traits$cov
#' )
#'
#' # Calculate and plot
#' pred_zi = mapply(
#'   FUN = get_r,
#'   K = exp(traits_i[,'log(growth_coefficient)']),
#'   Winf = exp(traits_i[,'log(growth_coefficient)']),
#'   a_mat = exp(traits_i[,'log(age_maturity)']),
#'   MASPS = exp(traits_i[,'logMASPS']),
#'   M = exp(traits_i[,'log(natural_mortality)'])
#' )
#' hist(pred_zi['intrinsic_growth_rate',])
#'
#' @export
get_r <-
function( K,
          Winf,
          a_mat,
          MASPS,
          M,
          t0 = -0.1,
          a_slope = a_mat / 4,
          d = 2/3, # Exponent for generalized VBGF
          a_max = 100
){

  # vector of ages
  age_vec = 0:a_max
  nages = length(age_vec)

  # Length-at-age
  #length_a = Linf * (1 - exp( -K*(age_vec-t0)))
  # Biomass-at-age
  mass_a = Winf * (1 - exp( -K*(1-d)*(age_vec-t0)))^(1/(1-d))
  #biomass_a = W_a * length_a^W_b
  # Maturity-at-age
  #maturity_a = 1 / (1+exp(-(age_vec-a_mat)/a_slope))
  maturity_a = plogis( (age_vec-a_mat) / a_slope)
  # Spawning-biomass-at-age
  SB_a = mass_a * maturity_a

  # Survival per recruit given no fishing
  n0_a = rep(0,nages)
  for(aI in 1:nages){
    if(aI==1) n0_a[aI] = 1
    if(aI>=2) n0_a[aI] = n0_a[aI-1]*exp(-M)
    if(aI==nages) n0_a[aI] = n0_a[aI] / (1-exp(-M))
  }

  # Maximum lifetime spawners per spawner (MLSPS)
  MLSPS = 1 + MASPS / (1 - exp(-M))
  # Maximum lifetime spawners per spawner (MLSPS)
  #MLSPS = 4 / ( 1/h - 1 )
  # Steepness
  h = MLSPS / (4 + MLSPS)
  # Unfished spawning biomass per recruit
  SBPR0 = sum( n0_a * SB_a )
  # Maximum annual recruits per spawning biomass (Alpha)
  Alpha = MLSPS / SBPR0   # Alpha * SBPR_F=0 = MLSPS

  # Make Leslie matrix
  LeslieM_numbers = matrix(0, nrow=nages, ncol=nages)
  LeslieM_numbers[1,] = Alpha * SB_a # maximum recruits per spawning biomass * unfished spawning biomass per recruit

  # fill rest of Matrix with Survival
  for(i  in 2:nages){
    LeslieM_numbers[i,(i-1)] = exp(-M)
  }

  # return intrinsic rate of population increase r and generation GT
  r_numbers = log( Re(eigen(LeslieM_numbers,only.values=TRUE)$values[1]) )
  generation_time = weighted.mean( x=age_vec, w=n0_a * SB_a )
  out = c(
    intrinsic_growth_rate = r_numbers,
    generation_time = generation_time,
    steepness_h = h
  )

  # Generate Leslie matrix in biomass
  if( FALSE ){
    Bratio_aa = outer( biomass_a, biomass_a^-1 )
    LeslieM_biomass = LeslieM_numbers * Bratio_aa
    r_biomass = log( Re(eigen(LeslieM_biomass,only.values=TRUE)$values[1]) )
    out = c(out, "r_biomass"=r_biomass)
  }

  return(out)
}
