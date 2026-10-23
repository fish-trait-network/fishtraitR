

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
#' @param taxon_name "Genus species" (with space between) to extract traits
#'
#' @importFrom dplyr filter collect
#' @importFrom arrow open_dataset
#' @importFrom jsonlite fromJSON
#' @importFrom tools R_user_dir
#' @importFrom utils askYesNo download.file unzip
#'
#' @export
get_traits <-
function( taxon_name,
          record_id = "latest") {

  ds <- get_dataset(record_id)

  res <- ds |>
    dplyr::filter(taxon == !!taxon_name) |>
    dplyr::collect()
  nm  <- get_trait_names(record_id)

  if (nrow(res) == 0) stop("Taxon not found: ", taxon_name)

  est <- res$mu[[1]]
  names(est) <- nm
  p <- length(est)

  lt <- lower.tri(diag(p), diag = TRUE)
  S <- matrix(0, p, p)
  S[lt] <- res$Vlt_vz[[1]]
  cov <- S + t(S) - diag(diag(S))
  dimnames(cov) <- list(nm, nm)

  list(est = est, cov = cov)
}