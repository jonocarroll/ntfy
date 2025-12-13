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
  topic = ntfy_topic(),
  server = ntfy_server(),
  auth = ntfy_auth(),
  username = ntfy_username(),
  password = ntfy_password(),
  markdown = FALSE
)
```

## Arguments

- message:

  text to send as notification

- title:

  title of notification. See
  <https://docs.ntfy.sh/publish/#message-title>

- tags:

  text tags or emoji shortcodes from <https://docs.ntfy.sh/emojis/>,
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

  E-mail address for e-mail notifications??

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

- markdown:

  use markdown formatting (`TRUE` or `FALSE`).

## Value

a [`httr2::response()`](https://httr2.r-lib.org/reference/response.html)
object, invisibly.

## Examples

``` r
if (FALSE) { # interactive()
# send a message to the default topic ('mytopic')
ntfy_send("test from R!")

# can use tags (emoji)
ntfy_send(message = "sending with tags!",
          tags = c(tags$cat, tags$dog)
)
}
```
