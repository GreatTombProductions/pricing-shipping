#' Price Items based on their Average Shipping Costs
library(magrittr)

margin <- 1.03

data <- readRDS(here::here("squarespace-pod/data/production_costs.rds"))

# step 1: add some proportion of max shipping cost into price
with_retail_price <- data %>% 
  dplyr::group_by(product) %>% 
  dplyr::mutate(baked_in_shipping_cost = min(shipping_cost) + 0.2 * (max(shipping_cost) - min(shipping_cost))) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(
    retail_price = max_production_cost + baked_in_shipping_cost,
    total_cost = max_production_cost + shipping_cost
  )


# step 2: set shipping per region as the minimum price needed to bring the price for all items above their total cost
with_shipping_price <- with_retail_price %>% 
  dplyr::group_by(region) %>% 
  dplyr::mutate(
    shipping_price = max(total_cost - retail_price),
    total_price = retail_price + shipping_price
  ) %>% 
  dplyr::mutate(
    retail_price = dplyr::if_else((total_price / total_cost) >= margin, retail_price, retail_price * margin),
    total_price = retail_price + shipping_price
  ) %>% 
  dplyr::ungroup()

shipping_prices <- dplyr::distinct(with_shipping_price, region, shipping_price)
product_prices <- dplyr::distinct(with_shipping_price, product, retail_price)

View(shipping_prices)
View(product_prices)
View(with_shipping_price)
