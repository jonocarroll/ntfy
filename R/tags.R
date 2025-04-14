#' Emoji
#'
#' Emoji symbols available in ntfy
#'
#' @format ## `emoji`
#' A data frame with 7,240 rows and 60 columns:
#' \describe{
#'   \item{emoji}{Symbol}
#'   \item{aliases}{Name of the emoji that can be used in a `tag`}
#'   \item{tags}{Alternative names}
#'   \item{category}{Category}
#'   \item{description}{Description}
#'   \item{unicode_version}{Unicode Version}
#'   ...
#' }
#' @source <https://github.com/binwiederhier/ntfy/blob/main/web/src/app/emojis.js>
#'
"emoji"

#' Emoji tags
#'
#' Emoji symbols compatible with ntfy to be used as tags
#'
"tags"

#' Show an emoji symbol, or find one by name
#'
#' @param name name of emoji to either print or find
#' @param search search the `tags` column for this name?
#'
#' @details
#' Emoji are loaded with `data("emoji")` and the `aliases` column
#' contains the names compatible with ntfy. Alternative names are
#' included in the `tags` column and these will be searched if the
#' name is not found in `aliases`.
#'
#' @return nothing, just prints the emoji if one or more are found
#'
#' @examples
#' show_emoji("dog")
#' show_emoji("party")
#'
#' @export
show_emoji <- function(name = NULL, search = FALSE) {
  if (is.null(name)) stop("`name` must be provided")

  emoji <- ntfy::emoji
  if (!name %in% emoji$aliases) {
    message("Unable to find that name directly.")
    search <- TRUE
    found <- FALSE
  } else {
    res <- emoji[emoji$aliases == name, , drop = FALSE]
    cat("\n", paste(res$emoji, res$aliases, "\n"), "\n")
    found <- TRUE
  }
  if (search) {
    in_tags <- sapply(emoji$tags, \(x) name %in% x)
    if (any(in_tags)) {
      found <- TRUE
      message("Did you perhaps want...")
      res <- emoji[in_tags, c("emoji", "aliases")]
      cat("\n", paste(res$emoji, res$aliases, "\n"), "\n")
    } else {
      if (!found) message("Unable to find an emoji with that name or alias.")
      return(invisible())
    }
  }

  invisible()
}
