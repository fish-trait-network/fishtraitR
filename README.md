# fishtraitR
Access imputed trait values and predictive variance for fishes, as Distribution stage for the fish-trait-network

### Example

```R
# Install
pak::pak("fish-trait-network/fishtraitR")
library("fishtraitR")

# Download database from Zenodo
download_traits()

# Access traits
get_traits("Aapticheilichthys websteri")
```


