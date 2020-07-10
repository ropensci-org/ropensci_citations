library(jsonlite)
library(readr)

to_json <- function(file) {
  df <- readr::read_tsv(file)
  json <- toJSON(df, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json, "citations_all.json")
}
