.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("NTFY_SERVER") == "") {
    Sys.setenv(NTFY_SERVER = "https://ntfy.sh")
  }

  if (Sys.getenv("NTFY_TOPIC") == "") {
    packageStartupMessage("{ntfy}: Topic not yet set - using a demo topic 'mytopic'\n",
    "        Set one with usethis::edit_r_environ()\n",
    "          and set NTFY_TOPIC='<yourSecretTopic>'")
    Sys.setenv(NTFY_TOPIC = "mytopic")
  }

  invisible()
}
