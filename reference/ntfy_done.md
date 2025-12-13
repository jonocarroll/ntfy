# Notify on Completion of a Process

`ntfy_done()` tells you when the code completed, and
`ntfy_done_with_timing()` tells you how long it took.

## Usage

``` r
ntfy_done(
  x,
  message = paste0("Process completed at ", format(Sys.time())),
  title = "ntfy_done()",
  tags = "white_check_mark",
  topic = ntfy_topic(),
  server = ntfy_server(),
  auth = ntfy_auth(),
  username = ntfy_username(),
  password = ntfy_password(),
  ...
)

ntfy_done_with_timing(
  x,
  message = paste0("Process completed in ", format(time_result), "s"),
  title = "ntfy_done_with_timing()",
  tags = "stopwatch",
  topic = ntfy_topic(),
  server = ntfy_server(),
  auth = ntfy_auth(),
  username = ntfy_username(),
  password = ntfy_password(),
  ...
)
```

## Arguments

- x:

  a result (ignored)

- message:

  text to send as notification

- title:

  title of notification. See
  <https://docs.ntfy.sh/publish/#message-title>

- tags:

  text tags or emoji shortcodes from <https://docs.ntfy.sh/emojis/>,
  provided as a list

- topic:

  subscribed topic to which to send notification

- server:

  ntfy server

- auth:

  logical indicating if the topic requires password authorization

- username:

  username with access to a protected topic.

- password:

  password with access to a protected topic.

- ...:

  other arguments passed to
  [`ntfy_send()`](https://jonocarroll.github.io/ntfy/reference/ntfy_send.md)

## Value

The input `x` (for further piping). A notification will be sent as a
side-effect.

## Examples

``` r
if (FALSE) { # interactive()
# report that a process has completed
Sys.sleep(3) |> ntfy_done("Woke up")

# report that a process has completed, and how long it took
Sys.sleep(3) |> ntfy_done_with_timing()
}
```
