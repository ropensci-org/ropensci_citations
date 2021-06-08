suppressPackageStartupMessages(library(dplyr))
stract <- function(str, pattern) regmatches(str, regexpr(pattern, str))
`%||%` <- function(x, y) if (is.null(x)) y else x

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
  if (is.null(url) || !length(url)) {
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
x_ex <- filter(x, grepl("\\b[Tt]hesis\\b|\\b[Tt]heses\\b|\\b[Dd]issertation\\b|blog|medium|tidytextmining|fromthebottomoftheheap|spatialecology|practicereproducibleresearch|bloomberglp|shareok|globalfactcheck|rohanalexander|huckg|diva-portal|cbpuschmann|univda|oapen|semanticscholar|jee3|researchgate|fmaconferences|rockefeller|ddslab|wp-content|acadpubl|eleonoraperuffo|repositorio|estrela|percomworkshops|iaee2019ljubljana|bit\\.ly|researchsquare|dspace|unescap|downloads|uni-bielefeld|conference\\.corp|sophiemathescom|ualberta|j-asc|books\\.google|econstor|Aviation|Oyungerel", citation))
blog_posts <- c("Mapping waxwings annual migration without Twitter",
  "Heat maps with Divvy data",
  "Ecological Event Miner: mines ecological events from published literature",
  "How to do Optical Character Recognition",
  "Considering Community: What types of community are there",
  "The making of",
  "Open Air Quality Fun with Fireworks",
  "an R package for accessing population health information in England" # citation missing title
)
blog_posts_ex <- filter(x, grepl(paste0(blog_posts, collapse = "|"), citation))
x_all <- rbind(x_ex, blog_posts_ex)
x <- mutate(x, exclude = citation %in% x_all$citation)
x <- filter(x, !exclude)
x <- select(x, -exclude)

# remove various entries: books, urls with "handle" in them (likely reports/white papers)
x <- filter(x, !grepl("handle", url)) # handle in url
x <- filter(x, !parts$type %in% c("book","chapter","paper-conference","report","thesis")) # book/chapter/conf paper/thesis/report

# add year field
for (i in seq_len(NROW(x))) {
  # cat(i, sep = "\n")
  date <- unlist(x[i,]$parts$date)
  if (!is.null(date)) {
    if (length(date) > 1) date <- date[1]
    if (tolower(date) != "in press") {
      date <- format(parsedate::parse_date(date), format="%Y")
    }
  }
  x[i,"year"] <- date %||% NA_character_
}

# tolower "in press"
x$year <- tolower(x$year)
# filter those out with no year (year=NA)
x <- filter(x, !is.na(year))

# try to fill in missing container titles
for (i in seq_len(NROW(x))) {
  # cat(i, sep = "\n")
  title <- unlist(x[i,]$parts$`container-title`)
  if (is.null(title)) {
    if (!is.null(x$parts$doi[[i]])) {
      df <- data.frame(rcrossref::cr_works(x$parts$doi[[i]])$data)
      title <- df$container.title
      if (is.null(title)) title <- df$publisher
    } else if (!is.null(x$url[i])) {
      if (grepl("https?://arxiv\\.org", x$url[[i]])) {
        title <- "arXiv"
      } else if (grepl("https?://psyarxiv\\.", x$url[[i]])) {
        title <- "PsyArXiv"
      } else if (grepl("https?://ecoevorxiv\\.", x$url[[i]])) {
        title <- "EcoEvoRxiv"
      } else if (grepl("r-project", x$url[[i]])) {
        title <- "The R Journal"
      } else if (grepl("ssrn", x$url[[i]])) {
        title <- "SSRN"
      } else if (grepl("preprints\\.org", x$url[[i]])) {
        title <- "Preprints.org"
      } else {
        doi <- sub("https://doi.org/", "", x$url[[i]])
        df <- data.frame(rcrossref::cr_works(doi)$data)
        title <- df$container.title
        if (is.null(title)) title <- df$publisher
      }
    }
    x[i,]$parts$`container-title` <- list(title) %||% list(NA_character_)
  }
}

# put packages in an array instead of a string
x$name <- lapply(x$name, function(w) I(unique(strsplit(w, split = ",")[[1]])))

# authors: convert to string entry
## handle author.literal and array of names
## make "et al." if more than 2 auhors
for (i in seq_len(NROW(x))) {
  # cat(i, sep = "\n")
  if (is.null(x$parts$author[[i]])) x$parts$author[[i]] <- x$parts$editor[[i]]
  auth <- x$parts$author[[i]]
  if ("literal" %in% names(auth)) {
    litauths <- strsplit(auth$literal, "\\.,")[[1]]
    if (length(litauths) > 2) {
      auth1 <- strsplit(litauths[1], ",")[[1]][1]
      litauths <- paste0(auth1, " et al.")
    } else if (length(litauths) <= 2) {
      litauths <- paste0(vapply(litauths, function(z) gsub("\\&|\\s", "", strsplit(z, ",")[[1]][1]), ""), collapse=" & ")
    }
    x$parts$author[[i]] <- litauths
  } else {
    if (NROW(auth) > 2) {
      if (is.na(auth[1,"family"])) auth[1,"family"] <- auth[1,"given"]
      xxx <- paste0(auth[1,"family"], " et al.")
    } else if (NROW(auth) <= 2) {
      xxx <- paste0(auth[,'family'], collapse=" & ")
    }
    x$parts$author[[i]] <- xxx
  }
}

# write to disk
json <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE, null = "null")
back <- jsonlite::fromJSON(json, FALSE)
cleaned <- lapply(back, rlist::list.clean, recursive = TRUE)
json2 <- jsonlite::toJSON(cleaned, pretty = TRUE, auto_unbox = TRUE, null = "null")
writeLines(json2, "citations_all_parts_clean.json")
