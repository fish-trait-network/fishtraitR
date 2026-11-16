

get_dataset <- function(record_id = "23590966", ...) {
  key <- paste0("ds_", record_id)
  ds <- .traits_env[[key]]
  if (is.null(ds)) {
    dir <- download_traits(record_id, ...)
    files <- list.files(dir, pattern = "parquet$",
                        recursive = TRUE, full.names = TRUE)
    if (length(files) == 0) stop("No parquet files found in ", dir)
    ds <- arrow::open_dataset(files)
    .traits_env[[key]] <- ds
  }
  ds
}

get_trait_names <- function(record_id = "latest") {
  key <- paste0("names_", record_id)
  nm <- .traits_env[[key]]
  if (is.null(nm)) {
    dir <- download_traits(record_id)
    f <- list.files(dir, pattern = "trait_names\\.txt$",
                    recursive = TRUE, full.names = TRUE)
    if (length(f) == 0) stop("trait_names.txt not found in ", dir)
    nm <- readLines(f[1])
    .traits_env[[key]] <- nm
  }
  nm
}

#' @title Get predicted traits and covariances
#'
#' @description Extract values and predictive covariance from trait imputation
#'   for fishes, as stage-3 of the fish-trait-network
#'
#' @inheritParams download_traits
#'
#' @param taxon "Genus species" (with space between) to extract traits
#'
#' @importFrom dplyr filter collect
#' @importFrom arrow open_dataset
#' @importFrom jsonlite fromJSON
#' @importFrom tools R_user_dir
#' @importFrom utils askYesNo download.file unzip
#' @importFrom stats weighted.mean
#' @importFrom mvtnorm rmvnorm
#' @importFrom graphics hist
#'
#' @examples
#' # Get traits for selected species
#' download_traits()
#' traits = get_traits( c("Gadus morhua", "Gadus chalcogrammus") )
#'
#' @export
get_traits <-
function( taxon,
          record_id = "latest") {

  do_one = function( taxon_name ){
    ds <- get_dataset(record_id)
  
    res <- ds |>
      dplyr::filter(taxon == !!taxon_name) |>
      dplyr::collect()
    nm  <- get_trait_names(record_id)
  
    if (nrow(res) == 0) stop("Taxon not found: ", taxon_name)
  
    est <- res$mu[[1]]
    names(est) <- nm
    p <- length(est)
  
    #cov = matrix( res$Vlt_vz[[1]], p, p)
    lt <- lower.tri(diag(p), diag = TRUE)
    S <- matrix(0, p, p)
    S[lt] <- res$Vlt_vz[[1]]
    cov <- S + t(S) - diag(diag(S))
    dimnames(cov) <- list(nm, nm)
    list( est = est, cov = cov )
  }
  all = lapply( taxon, do_one )
  est = sapply( all, \(x)x$est )
  cov = sapply( all, \(x)x$cov )
  cov = array( cov, dim = c(nrow(est), nrow(est), ncol(est)) )
  dimnames(est) = list( names(all[[1]]$est), taxon )
  dimnames(cov) = list( names(all[[1]]$est), names(all[[1]]$est), taxon )
  out = list( est = est, cov = cov )
  class(out) = "get_traits"
  return(out)
}

#' @title Plot predicted traits and covariances
#'
#' @description Plot extracted traits
#'
#' @param x output from \code{\link{get_traits}}
#' @param variables which traits to plot
#' @param y not used
#' @param ... not used
#'
#' @importFrom stats plogis
#'
#' @examples
#' # Get traits for selected species
#' download_traits()
#' traits = get_traits( c("Gadus morhua", "Gadus chalcogrammus") )
#' plot( traits, variables = "phi" )
#' plot( traits, variables = c("log(natural_mortality)", "log(growth_coefficient)") )
#' @export
plot.get_traits = 
function( x, 
          variables, 
          y,
          ... ){
  
  if( !requireNamespace("phylosem", quietly = TRUE) ){
    stop("Please install phylosem to use this function")
  }
  class(x) = "predict_phylosem"
  plot(x, variables = variables)

}
