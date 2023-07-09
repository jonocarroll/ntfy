
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ntfy <img src="man/figures/logo.png" align="right" height="102" />

<!-- badges: start -->
<!-- badges: end -->

**ntfy** (pronounce: *notify*) is a simple HTTP-based pub-sub
notification service. It allows you to send notifications to your phone
or desktop via scripts from any computer, entirely without signup, cost
or setup. It’s also [open source](https://github.com/binwiederhier/ntfy)
if you want to run your own. Visit [ntfy.sh](https://ntfy.sh) for more
details.

{ntfy} is a lightweight R wrapper for this service. The magic sauce is
just `POST` and `GET` calls equivalent to

    curl -d "Process Complete 😀" ntfy.sh/yourSecretTopic 

but made to work nicely in an R workflow.

## Installation

You can install the development version of ntfy like so:

``` r
# install.packages("remotes")
remotes::install_github("jonocarroll/ntfy")
```

## Functionality

Follow the instructions at [ntfy.sh](https://ntfy.sh) to install any of
the mobile apps or use the web app. No sign-up or account is necessary.

Choose a topic (note: this isn’t a password-protected service, so choose
something obscure) and subscribe to it on your device.

Add the topic as an environment variable, e.g.

``` r
usethis::edit_r_environ()

[...]

NTFY_TOPIC='yourSecretTopic'
#NTFY_SERVER='https://ntfy.sh'
```

The server will automatically be set to <https://ntfy.sh> unless you
specify another.

This can be confirmed with

``` r
ntfy_server()
#> [1] "https://ntfy.sh"
```

With the package loaded, you can now send notifications which should
appear on your device

``` r
library(ntfy)
ntfy_send("test from R!")
#> Response [https://ntfy.sh/]
#>   Date: 2023-07-04 07:37
#>   Status: 200
#>   Content-Type: application/json
#>   Size: 136 B
#> {"id":"LBSejrjeGeIV","time":1688456239,"expires":1688499439,"event":"message"...
```

This can be used in many ways. One would be to notify the completion of
a process. The `ntfy_done()` function sends a notification with the
(default) body

    Process completed at <Sys.time()>

``` r
slow_process <- function(x) {
  Sys.sleep(8) # sleep for 8 seconds
  x
}

mtcars |> 
  head() |> 
  slow_process() |> 
  ntfy_done()
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

which results in a notification on subscribed devices

    Process completed at 2023-07-04 17:00

When using the base R pipe `|>` the piped commands are composed together
by the parser, so

    f() |> 
      g() |> 
        h()

becomes

    h(g(f()))

We can use this fact to time the running of a process if the last
function (above, `h()`) is `system.time()`. The
`ntfy_done_with_timing()` function does exactly this

``` r
mtcars |> 
  head() |> 
  slow_process() |> 
  ntfy_done_with_timing()
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

which sends the notification

    Process completed in 8.003s

Note: the {magrittr} pipe `%>%` works differently and does not compose
the same way, so this will result in a very short time report. Wrapping
an entire pipeline with `ntfy_done_with_timing()` will work, though

``` r
library(magrittr)
#> Warning: package 'magrittr' was built under R version 4.2.0
ntfy_done_with_timing(
  mtcars %>%
    head() %>% 
    slow_process()
)
#>                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

sends

    Process completed in 8.004s

The history of the notifications sent can be retrieved as well, with
control over how far back to search

``` r
ntfy_history(since = "1h")
```

    #>             id       time   event           topic
    #> 1 0oDpk4oisfNO 1667988383 message yourSecretTopic
    #> 2 4Fcy9kIL0m6Z 1667988413 message yourSecretTopic
    #> 3 AGXn4q0CirFT 1667990983 message yourSecretTopic
    #>                                    message
    #> 1                             test from R!
    #> 2 Process completed at 2022-11-09 17:31:03
    #> 3              Process completed in 8.003s

## API

The full ntfy.sh API should be supported, including sending a title and
[tags](https://docs.ntfy.sh/publish/#tags-emojis)

<img src="man/figures/notification1.png" width="300" />

<img src="man/figures/notification2.png" width="300" />

## Emoji

Supported tags (emoji) can be sent with the `tags` argument (one or
more). These can be searched or shown with `show_emoji()` which will
look for a given name in the compatible values, or search for it in the
compatible metadata.

The compatible data is stored as `emoji`

``` r
data("emoji")
head(emoji)
#>   emoji         aliases             tags          category     description
#> 1    👎              -1 disapprove, bury     People & Body     thumbs down
#> 2    👍              +1      approve, ok     People & Body       thumbs up
#> 3    💯             100   score, perfect Smileys & Emotion  hundred points
#> 4    🔢            1234          numbers           Symbols   input numbers
#> 5    🥇 1st_place_medal             gold        Activities 1st place medal
#> 6    🥈 2nd_place_medal           silver        Activities 2nd place medal
#>   unicode_version
#> 1             6.0
#> 2             6.0
#> 3             6.0
#> 4             6.0
#> 5             9.0
#> 6             9.0
```

with the tags stored as `tags` for easy auto-complete

``` r
ntfy_send(message = "sending with tags!", 
          tags = c(tags$cat, tags$dog)
)
#> Response [https://ntfy.sh/]
#>   Date: 2023-07-04 07:37
#>   Status: 200
#>   Content-Type: application/json
#>   Size: 163 B
#> {"id":"kwRrK0UJu8v7","time":1688456264,"expires":1688499464,"event":"message"...
```

The compatible emoji can be shown with

``` r
show_emoji("rofl")
#> 
#>  🤣 rofl 
#> 
```

If the name is not found in `aliases` (the compatible names) it will be
searched in `tags`

``` r
show_emoji("lol")
#> Unable to find that name directly.
#> Did you perhaps want...
#> 
#>  🤣 rofl 
#> 

show_emoji("pet")
#> Unable to find that name directly.
#> Did you perhaps want...
#> 
#>  🐱 cat 
#>  🐶 dog 
#>  🐹 hamster 
#> 
```

You can force this behaviour with

``` r
show_emoji("dog", search = TRUE)
#> 
#>  🐶 dog 
#> 
#> Did you perhaps want...
#> 
#>  🐩 poodle 
#> 
```

## Similar Services

- [{Rpushbullet}](https://cran.r-project.org/web/packages/RPushbullet/index.html)
  offers similar functionality, but requires sign-up / an API key
- [{beepr}](https://cran.r-project.org/web/packages/beepr/index.html)
  can play a sound when a process completes
- [IFTTT](https://ifttt.com/docs/connect_api) has an API and can be
  configured to send messages with
  e.g. [nifffty](https://github.com/hrbrmstr/nifffty)
- [This blog
  post](https://rviews.rstudio.com/2020/06/18/how-to-have-r-notify-you/)
  details many ways to send notifications, via email, text, Slack, and
  MS Teams

## Privacy

Q: *“Will you know what topics exist, can you spy on me?”*

A: Refer to the
[FAQ](https://ntfy.sh/docs/faq/#will-you-know-what-topics-exist-can-you-spy-on-me)

## Contributing

If this service is useful to you, consider donating to [the
developer](https://github.com/sponsors/binwiederhier) via GitHub
sponsors. If this package is useful to you, [I also accept
donations](https://github.com/sponsors/jonocarroll) via GitHub sponsors.
