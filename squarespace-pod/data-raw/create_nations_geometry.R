#' Create and export a simple-features object containing typical countries we can sell to

library(magrittr)


# Hard-Coded Region Mapping -----------------------------------------------

regions <- list(
  US = "United States",
  Europe = c(
    "Albania", "Austria", "Belgium", "Bosnia and Herzegovina", "Bulgaria",
    "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland",
    "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia",
    "Lithuania", "Luxembourg", "Macedonia", "Moldova", "Montenegro", "Netherlands",
    "Poland", "Portugal", "Romania", "Serbia", "Slovakia", "Slovenia", "Spain",
    "Sweden", "Ukraine"
  ),
  UK = "United Kingdom",
  EFTA = c("Iceland", "Norway", "Switzerland"),
  Canada = "Canada",
  `Australia / New Zealand` = c("Australia", "New Zealand"),
  Japan = "Japan",
  Brazil = "Brazil",
  Excluded = c(
    "Russian Federation", "Belarus", "Ecuador", "Cuba", "Iran", 
    "Dem. Rep. Korea", "Syria", "Antarctica"
  )
)

# Retrieve Nations Geometry -----------------------------------------------

world_raw <- spData::world %>% 
  dplyr::filter(!continent %in% c("Seven seas (open ocean)", "Antarctica")) %>% 
  dplyr::select(name_long)


# Add Region Labels -------------------------------------------------------

country_to_region <- names(regions) %>% 
  purrr::map(~{
    rep(.x, length(regions[[.x]])) %>% 
      purrr::set_names(regions[[.x]])
  }) %>% 
  unlist()

world <- world_raw %>% 
  dplyr::mutate(region = country_to_region[name_long]) %>% 
  tidyr::replace_na(list(region = "Worldwide")) %>% 
  dplyr::filter(region != "Excluded")

# # check with:
# mapview::mapview(world, zcol = "region")

# Export ------------------------------------------------------------------

saveRDS(world, here::here("squarespace-pod/data/shipping_regions_sf.rds"))
