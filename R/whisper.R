#' Transcribe an audio file
#'
#' @param audio path to a file that contains audio (e.g., .mp3, .mp4).
#' @param model name of the model. One of "tiny", "base", "small", "medium", or
#'   "large". Or an English-only models, which have the same names but with the
#'   suffix ".en" (e.g. "tiny.en").
#' @param device "cpu" or "cuda" to run transcription on the GPU (which is
#'   faster, if you have one).
#' @param background run in a background process?
#' @param envname name of the virtual environment used for whisperrr.
#' @param verbose whether status messages should be printed to screen.
#'
#' @return as data.frame with transcriptions
#' @export
#'
#' @examples
#' \dontrun{
#' transcription <- transcribe("audio.mp3")
#' }
transcribe <- function(audio,
                       model = "base",
                       device = getOption("CUDA_AVAILABLE", default = "cpu"),
                       background = TRUE,
                       envname = NULL,
                       verbose = TRUE) {

  if (!file.exists(audio))
    cli::cli_abort("File {audio} does not exist")

  if (is.null(envname))
    envname <- Sys.getenv("WHISPER_PYTHON", unset = "r-whisper")

  if (background) {
    if (verbose) cli::cli_progress_step("Whisper is transcribing {cli::pb_spin}")
    rx <- callr::r_bg(func = .transcribe, args = list(envname = envname,
                                                      audio = audio,
                                                      model = model,
                                                      device = device),
                      package = TRUE)
    while (rx$is_alive()) {
      cli::cli_progress_update()
      Sys.sleep(2 / 100)
    }
    out <- rx$get_result() |>
      parse_transcription()
  } else {
    if (verbose) cli::cli_progress_step("Whisper is transcribing")
    out <- .transcribe(envname, audio, model, device) |>
      parse_transcription()
  }
  if (verbose) cli::cli_progress_done()
  return(out)
}

.transcribe <- function(envname, audio, model, device) {
  reticulate::use_virtualenv(envname)
  if (!"transcribe" %in% names(reticulate::py))
    reticulate::py_run_file(system.file("python", "funs.py",
                                        package = "whisprrr"))
  reticulate::py$transcribe(audio = audio,
                            model = model,
                            device = device)
}

parse_transcription <- function(resp) {
  purrr::pluck(resp, "segments") |>
    purrr::map(function(s) tibble::tibble(
      id                = s$id,
      seek              = s$seek,
      start             = s$start,
      end               = s$end,
      text              = trimws(s$text),
      tokens            = list(s$tokens),
      temperature       = s$temperature,
      avg_logprob       = s$avg_logprob,
      compression_ratio = s$compression_ratio,
      no_speech_prob    = s$no_speech_prob,
      language          = resp$language
    )) |>
    purrr::list_rbind()
}
