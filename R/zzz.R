#' @include utils.R
NULL

#' Package Loading and Data Initialization
#'
#' @description Handles package initialization including loading required datasets
#' from GitHub or local fallback files.
#' @keywords internal
#' @returns
#' nothing, loads data from external repository that will be needed by other package functions
#' @importFrom utils download.file
#' @importFrom tools R_user_dir
#' @noRd
#'
.onLoad <- function(libname, pkgname) {
  # Create package environment
  pkg_env <- asNamespace(pkgname)

  # Critical datasets download from SemanticDistance_Data/data repo
  critical_datasets <- c('Monologue_Typical', 'Dialogue_Typical', 'Unordered_List',
                         'Word_Pairs', 'Grandfather_Passage', 'glowca_25', 'SD15_2025_complete',
                         'Temple_stops25')

  # Load from GitHub repo
  loaded_from <- tryCatch({
    repo_url <- "https://raw.githubusercontent.com/Reilly-ConceptsCognitionLab/SemanticDistance_Data/main/data/"
    temp_dir <- tempdir()

    for(ds in critical_datasets) {
      temp_file <- file.path(temp_dir, paste0(ds, ".rda"))
      utils::download.file(
        url = paste0(repo_url, ds, ".rda"),
        destfile = temp_file,
        mode = "wb",
        quiet = TRUE
      )

      # Create a temporary environment to load into first
      temp_env <- new.env()
      load(temp_file, envir = temp_env)

      # Get the loaded object (assuming it has same name as file)
      loaded_data <- get(ds, envir = temp_env)

      # Assign to package namespace
      assign(ds, loaded_data, envir = pkg_env)

      # Also export to package environment
      assign(ds, loaded_data, envir = parent.env(pkg_env))

      unlink(temp_file)
    }
    "github"
  }, error = function(e) {
    # Fallback to cache
    cache_dir <- tools::R_user_dir(pkgname, which = "cache")
    cached_files <- file.path(cache_dir, paste0(critical_datasets, ".rda"))

    available <- file.exists(cached_files)
    if(any(available)) {
      for(cf in cached_files[available]) {
        temp_env <- new.env()
        load(cf, envir = temp_env)
        ds <- sub("\\.rda$", "", basename(cf))
        loaded_data <- get(ds, envir = temp_env)
        assign(ds, loaded_data, envir = pkg_env)
        assign(ds, loaded_data, envir = parent.env(pkg_env))
      }
      "cache"
    } else {
      "none"
    }
  })

  # Set package option
  options(SemanticDistance.data_source = loaded_from)

  # Explicitly export the datasets
  for(ds in critical_datasets) {
    if(exists(ds, envir = pkg_env)) {
      assign(ds, get(ds, envir = pkg_env), envir = parent.env(pkg_env))
    }
  }
}
