# Plot predicted traits and covariances

Plot extracted traits

## Usage

``` r
# S3 method for class 'get_traits'
plot(x, variables, y, ...)
```

## Arguments

- x:

  output from
  [`get_traits`](https://fish-trait-network.github.io/fishtraitR/dev/reference/get_traits.md)

- variables:

  which traits to plot

- y:

  not used

- ...:

  not used

## Examples

``` r
# Get traits for selected species
download_traits()
#> [1] "C:\\Users\\jtuth\\AppData\\Local/R/cache/R/ftn-distribution/zenodo_24259333"
traits = get_traits( c("Gadus morhua", "Gadus chalcogrammus") )

# Plot single traits
plot( traits, variables = "phi" )


# Plot pair of traits
plot( traits, variables = c("log(natural_mortality)", "log(growth_coefficient)") )
```
