# Retrieve History of Notifications

Retrieve History of Notifications

## Usage

``` r
ntfy_history(
  since = "all",
  topic = ntfy_topic(),
  server = ntfy_server(),
  auth = ntfy_auth(),
  username = ntfy_username(),
  password = ntfy_password(),
  ...
)
```

## Arguments

- since:

  duration (e.g. `"10m"` or `"30s"`), a Unix timestamp (e.g.
  `"1635528757"`), a message ID (e.g. `"nFS3knfcQ1xe"`), or `"all"` (all
  cached messages)

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

  any other (named) query parameters to add to the request

## Value

a [`data.frame()`](https://rdrr.io/r/base/data.frame.html) with one row
per notification, with columns as described in the documentation

## See also

<https://ntfy.sh/docs/subscribe/api/#json-message-format>

## Examples

``` r
if (FALSE) { # interactive()
# get the last hour of notifications
ntfy_history(since = "1h")
}
```
