check_citation_file <- function(file) {
  z <- suppressMessages(readr::read_tsv(file))
  p <- readr::problems(z)
  if (NROW(p) == 0) {
    cli::cat_line(
      crayon::style(paste(cli::symbol$tick, " OK "), "green"), "\n"
    )
  } else {
    cli::cat_line(
      crayon::style(paste(cli::symbol$cross, " WOOPS "), "red"), "\n"
    )
  }
}
