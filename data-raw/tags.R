## code to prepare `tags` dataset goes here

emoji_file <- "inst/emojis/emojis.js"

cx <- V8::v8()
cx$source(emoji_file) # now the variable 'data' is defined in V8

emoji <- as.data.frame(cx$get("rawEmojis"))
emoji <- tidyr::unnest_longer(emoji, aliases) |>
  dplyr::arrange(aliases)

tags <- emoji$aliases

tags <- as.list(stats::setNames(as.list(tags), tags))

usethis::use_data(emoji, overwrite = TRUE)

usethis::use_data(tags, overwrite = TRUE)
