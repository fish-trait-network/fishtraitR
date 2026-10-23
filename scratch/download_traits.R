

.traits_env <- new.env(parent = emptyenv())

download_traits <- function(record_id,
                            cache = getOption("yourpkg.cache", NA),
                            force = FALSE,
                            quiet = FALSE) {

  key <- as.character(record_id)
  persistent <- file.path(tools::R_user_dir("yourpkg", "cache"),
                          paste0("zenodo_", key))

  # 1. Reuse an existing copy (persistent first, then this session's tempdir)
  if (!force) {
    if (file.exists(file.path(persistent, ".complete"))) return(persistent)
    tmp <- .traits_env[[key]]
    if (!is.null(tmp) && file.exists(file.path(tmp, ".complete"))) return(tmp)
  }

  # 2. Decide where to store it: TRUE/FALSE via argument or option, otherwise ask
  if (is.na(cache)) {
    if (interactive()) {
      cache <- isTRUE(utils::askYesNo(
        paste0("Cache the traits data (~130 MB) in\n  ", persistent,
               "\nso it is not re-downloaded in future sessions?\n",
               "(No = use a temporary folder deleted when R closes)"),
        default = FALSE))
    } else {
      cache <- FALSE
    }
  }
  target <- if (isTRUE(cache)) persistent else tempfile("traits_")

  # 3. Look up the file on Zenodo
  rec <- jsonlite::fromJSON(paste0("https://zenodo.org/api/records/", key))
  files <- rec$files
  i <- grep("\\.zip$", files$key)[1]
  if (is.na(i)) i <- 1
  url <- files$links$self[i]

  # 4. Download and extract into a staging folder, then move into place
  old <- options(timeout = max(600, getOption("timeout")))
  on.exit(options(old), add = TRUE)

  dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
  stage <- paste0(target, ".partial")
  unlink(stage, recursive = TRUE)
  dir.create(stage)
  zipfile <- tempfile(fileext = ".zip")
  on.exit(unlink(c(zipfile, stage), recursive = TRUE), add = TRUE)

  if (!quiet) message("Downloading traits from Zenodo record ", key, " ...")
  utils::download.file(url, zipfile, mode = "wb", quiet = quiet)
  utils::unzip(zipfile, exdir = stage)
  file.create(file.path(stage, ".complete"))   # written last

  unlink(target, recursive = TRUE)
  if (!file.rename(stage, target)) stop("Could not move download into ", target)

  if (!isTRUE(cache)) .traits_env[[key]] <- target
  if (!quiet) message("Traits stored in ", target)
  target
}

