# fishtraitR

[![docs (main)](https://img.shields.io/badge/docs-fishtraitR-orange.svg?colorB=E91E63)](https://fish-trait-network.github.io/fishtraitR/)


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


