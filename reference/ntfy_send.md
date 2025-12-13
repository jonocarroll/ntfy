# Send a Notification

Send a Notification

## Usage

``` r
ntfy_send(
  message = "test",
  title = NULL,
  tags = NULL,
  priority = 3,
  actions = NULL,
  click = NULL,
  image = NULL,
  attach = NULL,
  filename = NULL,
  delay = NULL,
  email = NULL,
  markdown = ntfy_md(),
  topic = ntfy_topic(),
  server = ntfy_server(),
  auth = ntfy_auth(),
  username = ntfy_username(),
  password = ntfy_password()
)
```

## Arguments

- message:

  Text to send as notification

- title:

  Title of notification. See
  <https://docs.ntfy.sh/publish/#message-title>

- tags:

  Text tags or emoji shortcodes from <https://docs.ntfy.sh/emojis/>,
  provided as a list

- priority:

  Message priority with 1=min, 3=default and 5=max. See
  <https://docs.ntfy.sh/publish/#message-priority>

- actions:

  Custom user action buttons for notifications. See
  <https://docs.ntfy.sh/publish/#action-buttons>

- click:

  Website opened when notification is clicked. See
  <https://docs.ntfy.sh/publish/#click-action>

- image:

  Image to include in the body of the notification. Either a `ggplot`
  object or a filename.

- attach:

  URL of an attachment, see attach via URL. See
  <https://docs.ntfy.sh/publish/#attach-file-from-url>

- filename:

  File name of the attachment

- delay:

  Timestamp or duration for delayed delivery

- email:

  E-mail address for e-mail notifications

- markdown:

  (logical) use markdown formatting (`TRUE` or `FALSE`). May not be
  supported on all platforms

- topic:

  Subscribed topic to which to send notification

- server:

  ntfy server (when not using <https://ntfy.sh>)

- auth:

  (logical) indicating if the topic requires password authorization

- username:

  username with access to a protected topic

- password:

  password with access to a protected topic

## Value

a [`httr2::response()`](https://httr2.r-lib.org/reference/response.html)
object, invisibly.

## Details

`topic`, `server`, `auth`, `username`, `password`, and `markdown` can be
set via environment variables `NTFY_TOPIC`, `NTFY_SERVER`, `NTFY_AUTH`,
`NTFY_USERNAME`, `NTFY_PASSWORD`, and `NTFY_MD`, respectively.

## See also

[`ntfy_topic()`](https://jonocarroll.github.io/ntfy/reference/ntfy_topic.md)

## Examples

``` r
if (FALSE) { # interactive()
# send a message to the default topic ('mytopic')
ntfy_send("test from R!")

# can use tags (emoji)
ntfy_send(message = "sending with tags!",
          tags = c(tags$cat, tags$dog)
)

# if supported, can use markdown
ntfy_send(message = "**Important**: see _details_ [here](https://example.com)")
}
```
