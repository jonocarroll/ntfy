# Show an emoji symbol, or find one by name

Show an emoji symbol, or find one by name

## Usage

``` r
show_emoji(name = NULL, search = FALSE)
```

## Arguments

- name:

  name of emoji to either print or find

- search:

  search the `tags` column for this name?

## Value

nothing, just prints the emoji if one or more are found

## Details

Emoji are loaded with `data("emoji")` and the `aliases` column contains
the names compatible with ntfy. Alternative names are included in the
`tags` column and these will be searched if the name is not found in
`aliases`.

## Examples

``` r
show_emoji("dog")
#> 
#>  🐶 dog 
#>  
show_emoji("party")
#> Unable to find that name directly.
#> Did you perhaps want...
#> 
#>  🎈 balloon 
#>  🎂 birthday 
#>  🎉 tada 
#>  
```
