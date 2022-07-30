#' Price Items based on their US Shipping Costs
library(magrittr)

pivot_region <- "USA"
margin <- 1.05
pivot_price <- 1.99 
transaction_fee <- 1.03

# Determine Retail Prices -------------------------------------------------

data <- readRDS(here::here("squarespace-pod/data/production_costs.rds"))

max_pivot <- data %>% 
  dplyr::filter(region == pivot_region) %>% 
  dplyr::mutate(pivot = shipping_cost - additional_shipping) %>% 
  dplyr::pull(pivot) %>% 
  min()

# the "pivot_price" is the shipping price will be set for the pivot_region (USA)
# it will be subtracted from the retail price, after the shipping cost is baked in
# if it is too high, then we will lose money when people order 2 or more items
# for example, suppose someone orders 2 tank tops, cost 3.99 and 2.00 to ship, and we use 3.00 as our pivot_price
# the marginless price of each tank top will be 19.95 + 3.99 - 3.00 = 20.94, 
# the price of the order will be (2*20.94) + 3.00 = 41.88
# the cost of the order will be 19.95 + 3.99 + 19.95 + 2 = 45.89

# effectively, the pivot_region gets close to a 0 shipping price for each product. 
# by setting a non-zero pivot price, the customer pays less for orders with more than one of a product

assertthat::assert_that(pivot_price <= max_pivot)

retail_prices <- data %>% 
  dplyr::filter(region == pivot_region) %>% 
  dplyr::transmute(
    product,
    retail_price = (margin * max_production_cost) + shipping_cost - pivot_price
  ) %>% 
  dplyr::distinct_all()

# Determine Shipping Prices -----------------------------------------------

shipping_prices <- data %>% 
  dplyr::select(region, product_category, product, max_production_cost, shipping_cost) %>% 
  dplyr::left_join(retail_prices, by = "product") %>% 
  dplyr::mutate(macro_region = dplyr::if_else(region == pivot_region, "pivot", "other")) %>% 
  tidyr::pivot_wider(names_from = macro_region, values_from = shipping_cost, names_prefix = "shipping_cost_") %>% 
  dplyr::group_by(product_category) %>% 
  dplyr::mutate(shipping_cost_pivot = mean(shipping_cost_pivot, na.rm = TRUE)) %>% 
  dplyr::filter(region != pivot_region) %>% 
  dplyr::mutate(
    shipping_price_pivot = pivot_price,
    adjusted_shipping_cost_other = shipping_cost_other - (retail_price - max_production_cost)
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(region) %>% 
  dplyr::mutate(
    shipping_price_increase = max(adjusted_shipping_cost_other - shipping_price_pivot),
    shipping_price = shipping_price_pivot + shipping_price_increase
  )
View(shipping_prices)

# Finalize Prices, Compare with Costs -------------------------------------

prices <- data %>% 
  dplyr::left_join(retail_prices, by = "product") %>% 
  dplyr::left_join(dplyr::distinct(shipping_prices, region, shipping_price), by = "region") %>% 
  tidyr::replace_na(list(shipping_price = pivot_price)) %>% 
  dplyr::transmute(
    product_category,
    product,
    region,
    retail_price = ceiling((retail_price * transaction_fee) * 100) / 100,
    shipping_price = ceiling(shipping_price * 100) / 100,
    total_price = retail_price + shipping_price,
    total_cost = max_production_cost + shipping_cost,
    margin = ((total_price / total_cost) - 1)
  )

View(prices)


# Export ------------------------------------------------------------------

shipping_by_region <- prices %>% 
  dplyr::distinct(region, shipping_price)

readr::write_csv(shipping_by_region, "shipping_by_region.csv")

# transaction_fee * ((margin * max_production_cost) + shipping_cost - pivot_price)