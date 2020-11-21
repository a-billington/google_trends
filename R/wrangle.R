require(here)
source(here::here("/R/packages.r"))

# Set Google Trends argument values
keyword <- c("divorce", "probate", "money claims", "pangolin")
country_code <- "GB" # see data("countries") for country codes
start_date <- Sys.Date() - months(24)
end_date <- Sys.Date()
date_range <- paste0(start_date, " ", end_date)
gprop <- "web"
category <- 0 # see data("categories")

# Download trends data
gtrends <- gtrendsR::gtrends(
  keyword = keyword,
  geo = country_code,
  time = date_range,
  gprop = gprop,
  category = category
)

# interest_time - data frame of interest over time
interest_time <- gtrends %>%
  purrr::pluck("interest_over_time") %>%
  tibble::as_tibble() %>%
  dplyr::select(date,
    value = hits,
    keyword
  ) %>%
  dplyr::mutate(date = lubridate::ymd(date))


interest_wide <- interest_time %>%
  tidyr::pivot_wider(
    names_from = "keyword",
    values_from = "value"
  )

# interest_xts
interest_xts <- xts::xts(
  x = interest_wide[, -1],
  order.by = interest_wide$date
)

base::saveRDS(
  object = interest_xts,
  file = here("/data/interest_xts.rds")
)
