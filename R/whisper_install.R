#' Install OpenAI's Whisper plus dependencies
#'
#' @param envname The name of, or path to, a Python virtual environment. Default
#'   is to use "r-whisper" unless set in environment variable WHISPER_PYTHON
#'   (through `Sys.setenv()`).
#' @param whisper_version give a specific version if you want.
#' @param gpu install packages needed for GPU usage.
#' @param ask set `FALSE` for unattended install.
#'
#' @return `TRUE` if everything worked.
#' @export
install_whisper <- function(envname = NULL,
                            whisper_version = NULL,
                            gpu = FALSE,
                            ask = TRUE) {
  if (is.null(envname))
    envname <- Sys.getenv("WHISPER_PYTHON", unset = "r-whisper")
  if (!whisper_installed(envname, is_error = FALSE)) safe_create(envname, ask)
  if (is.null(whisper_version)) {
    whisper_version <- "openai-whisper"
  } else {
    whisper_version <- paste0("openai-whisper==", whisper_version)
  }
  if (gpu) whisper_version <- c(whisper_version, "torch",
                                "torchvision", "torchaudio")
  reticulate::virtualenv_install(envname,
                                 packages = whisper_version,
                                 ignore_installed = TRUE)

  if (!got_ffmpeg()) cli::cli_abort("You need to install ffmpeg")
  whisper_version <- get_whisper_version(envname)
  cli::cli_alert_success(
    "Whisper version v{cli::style_italic(whisper_version)} succesfully installed!"
  )
  invisible(TRUE)
}


#' Check the version of Whisper
#'
#' @inheritParams install_whisper
#'
#' @return string with version of Whisper
#' @export
get_whisper_version <- function(envname = NULL) {
  if (is.null(envname))
    envname <- Sys.getenv("WHISPER_PYTHON", unset = "r-whisper")
  packages <- reticulate::py_list_packages(envname)
  packages$version[packages$package == "openai-whisper"]
}


whisper_installed <- function(envname = NULL, is_error = TRUE) {
  if (is.null(envname))
    envname <- Sys.getenv("WHISPER_PYTHON", unset = "r-whisper")
  if (!reticulate::virtualenv_exists(envname)) {
    if (is_error) {
      cli::cli_abort("Whisper environment not found. Try calling {.code install_whisper()} first.")
    }
    return(FALSE)
  }
  return(TRUE)
}


safe_create <- function(envname, ask) {
  t <- try(reticulate::virtualenv_create(envname), silent = TRUE)
  if (methods::is(t, "try-error")) {
    install_python()
    safe_create()
  }
}


install_python <- function(ask) {
  permission <- TRUE
  if (ask) permission <- utils::askYesNo(paste0(
    "No suitable Python installation was found on your system. ",
    "Do you want to run `reticulate::install_python()` to install it?"
  ))

  if (permission) {
    if (utils::packageVersion("reticulate") < "1.19")
      cli::cli_abort("Your version or reticulate is too old for this action. Please update it")
    python <- reticulate::install_python()
  } else {
    cli::cli_abort("Aborted by user")
  }
}


got_ffmpeg <- function() {
  tryCatch(system2("ffmpeg", stdout = FALSE, stderr = FALSE),
           error = function(e) NULL, warning = function(w) NULL) |>
    identical(1L)
}
