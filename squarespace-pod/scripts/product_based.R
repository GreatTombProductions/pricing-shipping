#' Price Items based on their Average Shipping Costs
library(magrittr)
library(ggplot2)

min_margin <- 1.05

data <- readRDS(here::here("squarespace-pod/data/production_costs.rds"))

# step 1: add some proportion of max shipping cost into price
with_retail_price <- data %>% 
  #dplyr::filter(region != "Australia / New Zealand") %>% 
  dplyr::group_by(product) %>% 
  dplyr::mutate(baked_in_shipping_cost = min(shipping_cost) + 0.1 * (max(shipping_cost) - min(shipping_cost))) %>% 
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
    retail_price = dplyr::if_else((total_price / total_cost) >= min_margin, retail_price, min_margin * total_cost - shipping_price)
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(product) %>% 
  dplyr::mutate(
    retail_price = max(retail_price)
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(
    total_price = retail_price + shipping_price,
    margin = (total_price / total_cost)
  )

shipping_prices <- dplyr::distinct(with_shipping_price, region, shipping_price)
product_prices <- dplyr::distinct(with_shipping_price, product, retail_price)

View(shipping_prices, "Shipping Prices")
View(product_prices, "Product Prices")
View(dplyr::select(with_shipping_price, product, region, shipping_cost, max_production_cost, total_cost, retail_price, shipping_price, total_price, margin), "Margins")

ggplot(with_shipping_price, aes(x = factor(region), y = margin)) +
  geom_boxplot() +
  ylim(1, 0.05 + max(with_shipping_price$margin))

ggplot(product_prices, aes(x = retail_price, text = product)) +
  geom_dotplot()
