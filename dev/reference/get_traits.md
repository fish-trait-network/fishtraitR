# Get predicted traits and covariances

Extract values and predictive covariance from trait imputation for
fishes, as stage-3 of the fish-trait-network

## Usage

``` r
get_traits(taxon, record_id = "latest")
```

## Arguments

- taxon:

  "Genus species" (with space between) to extract traits

- record_id:

  Zenodo ID to access

## Examples

``` r
# Get traits for selected species
download_traits()
#> [1] "C:\\Users\\jtuth\\AppData\\Local/R/cache/R/ftn-distribution/zenodo_24259333"
traits = get_traits( c("Gadus morhua", "Gadus chalcogrammus") )
```
