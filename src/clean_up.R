suppressPackageStartupMessages(library(dplyr))
stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

# read data
x <- tibble::as_tibble(jsonlite::fromJSON("citations_all_parts.json"))

# remove gender citations
x <- filter(x, name != "gender")

# reduce duplicates to one per paper, citing many pkgs
x <- group_by(x, citation) %>% 
  mutate(name2 = paste0(name, collapse = ",")) %>% 
  distinct(citation, .keep_all = TRUE) %>% 
  ungroup()
x$name <- NULL
x <- rename(x, name = name2) %>% select(name, everything())

# add url field
for (i in seq_len(NROW(x))) {
  # cat(i, sep = "\n")
  url <- x[i,]$parts$url[[1]]
  if (is.null(url)) {
    doi <- x[i,]$parts$doi[[1]]
    if (!is.null(doi)) url <- paste0("https://doi.org/", doi)
    if (is.null(doi)) {
      cite <- x[i,]$citation
      if (grepl("<https?", cite)) {
        url <- gsub("<|>", "", stract(cite, "<https?.+>"))
      } else if (grepl("\\[https?", cite)) {
        url <- gsub("\\[|\\]", "", stract(cite, "\\[https?.+\\]"))
      } else {
        url <- ""
      }
    }
  }
  x[i,"url"] <- url
}

# remove records w/o urls
x <- x[nchar(x$url) != 0,]

# remove records that aren't journal articles
## too time-consuming to label all records accurately for their type
## just exclude all records that aren't journal articles/pre-prints
x_ex <- filter(x, grepl("\\b[Tt]hesis\\b|\\b[Tt]heses\\b|\\b[Dd]issertation\\b|blog", citation))
blog_posts <- c("Mapping waxwings annual migration without Twitter",
  "Heat maps with Divvy data",
  "Ecological Event Miner: mines ecological events from published literature",
  "How to do Optical Character Recognition",
  "Considering Community: What types of community are there",
  "The making of")
blog_posts_ex <- filter(x, grepl(paste0(blog_posts, collapse = "|"), citation))
x_all <- rbind(x_ex, blog_posts_ex)
x <- mutate(x, exclude = citation %in% x_all$citation)
x <- filter(x, !exclude)
x <- select(x, -exclude)

# write to disk
json <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE, null = "null")
back <- jsonlite::fromJSON(json, FALSE)
cleaned <- lapply(back, rlist::list.clean, recursive = TRUE)
json2 <- jsonlite::toJSON(cleaned, pretty = TRUE, auto_unbox = TRUE, null = "null")
writeLines(json2, "citations_all_parts_clean.json")
