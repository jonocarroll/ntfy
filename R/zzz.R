.onLoad <- function(libname, pkgname) {
  if (Sys.getenv("NTFY_SERVER") == "") {
    Sys.setenv(NTFY_SERVER = "https://ntfy.sh")
  }

  if (Sys.getenv("NTFY_TOPIC") == "") {
    message("Topic not yet set - using a demo topic 'mytopic'")
    message("Set one with usethis::edit_r_environ()")
    message(" and set NTFY_TOPIC='<yourSecretTopic>'")
    Sys.setenv(NTFY_TOPIC = "mytopic")
  }

  invisible()
}
