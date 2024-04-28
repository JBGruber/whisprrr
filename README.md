
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whisprrr

<!-- badges: start -->
<!-- badges: end -->

`whisprrr` is just a minimal wrapper for the Python package
[Whisper](https://github.com/openai/whisper) by OpenAI:

> Whisper is a general-purpose speech recognition model. It is trained
> on a large dataset of diverse audio and is also a multitasking model
> that can perform multilingual speech recognition, speech translation,
> and language identification.

Besides making it possible to transcribe audio to text, the purpose of
this repository is also to have a minimal R wrapper for a Python
package.

## Installation

You can install the development version of whisprrr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JBGruber/whisprrr")
```

Then use `install_whisper` to set up the required Python environment
(and install Python if necessary):

``` r
install_whisper()
```

The process should be fully automatic/guided. By default, the
environment is set up as r-whisper” in the folder returned by
`reticulate::virtualenv_root()`. If you want to change that, the best
way is to set RETICULATE_PYTHON_ENV before running `install_whisper()`:

``` r
Sys.setenv(RETICULATE_PYTHON_ENV = "my-env")
```

Note that you have to set this environment variable in every new session
or put it into your .Renviron file(e.g., with
`usethis::edit_r_environ()`).

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(whisprrr)
download.file("https://github.com/openai/whisper/raw/main/tests/jfk.flac", "jfk.flac")
transcript_df <- transcribe("jfk.flac")
#> ✔ Whisper is transcribing ⠦ [4.7s]
#> 
transcript_df
#> # A tibble: 1 × 11
#>      id  seek start   end text  tokens temperature avg_logprob compression_ratio
#>   <int> <int> <dbl> <dbl> <chr> <list>       <dbl>       <dbl>             <dbl>
#> 1     0     0     0    11 And … <int>            0      -0.297              1.35
#> # ℹ 2 more variables: no_speech_prob <dbl>, language <chr>
transcript_df$text
#> [1] "And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country."
```

# Alternatives

- [audio.whisper](https://github.com/bnosac/audio.whisper)
