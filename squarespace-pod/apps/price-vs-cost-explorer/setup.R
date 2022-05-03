#' Setup data and environment specific to app
library(sf)

data_dir <- here::here("squarespace-pod/data")


# Read Data ---------------------------------------------------------------

costs <- readRDS(file.path(data_dir, "production_costs.rds"))
regions <- readRDS(file.path(data_dir, "shipping_regions_sf.rds"))

# Create App-Specific Columns ---------------------------------------------

data <- costs %>% 
  dplyr::group_by(region) %>% 
  dplyr::mutate(
    retail_price = max_production_cost + 1,
    shipping_price = max(shipping_cost)
  ) %>% 
  dplyr::arrange(product, region) %>% 
  dplyr::select(product, retail_price, shipping_price, region, shipping_cost, dplyr::everything())

# Export ------------------------------------------------------------------

saveRDS(data, here::here("squarespace-pod/apps/price-vs-cost-explorer/data.rds"))
saveRDS(regions, here::here("squarespace-pod/apps/price-vs-cost-explorer/regions.rds"))
