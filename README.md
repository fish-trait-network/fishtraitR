# fish-traitR
Access imputed trait values and predictive variance for fishes, as Distribution stage for the fish-trait-network

### Example

```R
# Install
pak::pak("fish-trait-network/fish-traitR")
library("fish-traitR")

# Download database from Zenodo
download_traits()

# Access traits
get_traits("Aapticheilichthys websteri")
```


