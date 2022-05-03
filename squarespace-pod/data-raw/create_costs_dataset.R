#' Create Costs Dataset

library(magrittr)


# Read in CSVs ------------------------------------------------------------

production <- readr::read_csv(here::here("squarespace-pod/data-raw/Shipping - Production Costs.csv"))

shipping <- readr::read_csv(here::here("squarespace-pod/data-raw/Shipping - Shipping Costs.csv"))

# Join CSVs ---------------------------------------------------------------

data <- shipping %>% 
  dplyr::left_join(production, by = c("Product Category" = "Category")) %>% 
  dplyr::mutate_at(
    dplyr::all_of(c("Shipping Cost", "Additional Shipping", "Min Production Cost", "Max Production Cost")),
    ~as.numeric(stringr::str_sub(., start = 2))
  ) %>% 
  dplyr::rename_with(janitor::make_clean_names)

# Export ------------------------------------------------------------------

saveRDS(data, here::here("squarespace-pod/data/production_costs.rds"))