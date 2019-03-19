check_citation_file <- function(file) {
  if (grepl("tweet", file)) {
    z <- suppressMessages(readr::read_tsv(file, col_names = FALSE))
    names(z) <- c("name", "doi", "citation", "img_path", "research_snippet")
  } else {
    z <- suppressMessages(readr::read_tsv(file))
  }

  # file formatting problems
  p <- readr::problems(z)
  if (NROW(p) == 0) {
    cli::cat_line(
      "Formatting: ", crayon::style(paste(cli::symbol$tick, " OK "), "green")
    )
  } else {
    cli::cat_line(
      "Formatting: ", crayon::style(paste(cli::symbol$cross, " WOOPS "), "red")
    )
  }

  # images exist when given
  img_paths <- as.character(na.omit(z$img_path))
  mtchs <- vapply(img_paths, file.exists, logical(1))
  if (all(mtchs)) {
    cli::cat_line(
      "Images: ", crayon::style(paste(cli::symbol$tick, " OK "), "green")
    )
  } else {
    cli::cat_line(
      "Images: ", crayon::style(paste(cli::symbol$cross, " WOOPS "), "red")
    )
  }
}
