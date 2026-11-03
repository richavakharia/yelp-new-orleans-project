# import.R
# Imports the Yelp business and review JSON files, filters to
# New Orleans restaurants, and saves compressed RDS files.
# Raw JSON files are stored in ~/yelp_raw (outside the project and iCloud).

library(tidyverse)
library(jsonlite)

business_file <- "~/yelp_raw/yelp_academic_dataset_business.json"
review_file   <- "~/yelp_raw/yelp_academic_dataset_review.json"

# ---- Business file ----
start_time <- Sys.time()

business_raw <- stream_in(file(business_file), verbose = FALSE)

business <- business_raw |>
  select(business_id, name, address, city, state, postal_code,
         latitude, longitude, stars, review_count, categories)

rm(business_raw)

dim(business)
glimpse(business)

new_orleans_restaurants <- business |>
  filter(
    state == "LA",
    city == "New Orleans",
    !is.na(categories),
    str_detect(categories, regex("Restaurants", ignore_case = TRUE))
  ) |>
  mutate(
    postal_code = na_if(postal_code, ""),
    categories = str_squish(categories),
    business_name = str_squish(name)
  ) |>
  distinct(business_id, .keep_all = TRUE)

new_orleans_restaurants |>
  summarise(
    number_of_restaurants = n(),
    missing_latitude = sum(is.na(latitude)),
    missing_longitude = sum(is.na(longitude)),
    missing_categories = sum(is.na(categories))
  )

Sys.time() - start_time

# ---- Review file (read in chunks to save memory) ----
start_time <- Sys.time()

nola_ids <- new_orleans_restaurants$business_id
review_chunks <- list()
chunk_num <- 0

stream_in(
  file(review_file),
  handler = function(df) {
    chunk_num <<- chunk_num + 1
    review_chunks[[chunk_num]] <<- df |>
      filter(business_id %in% nola_ids) |>
      select(business_id, user_id, stars, date, text, useful, funny, cool)
  },
  pagesize = 50000,
  verbose = TRUE
)

new_orleans_reviews <- bind_rows(review_chunks)
rm(review_chunks)

dim(new_orleans_reviews)
glimpse(new_orleans_reviews)

Sys.time() - start_time

# ---- Save filtered data ----
saveRDS(new_orleans_restaurants,
        "data/new_orleans/business_new_orleans.rds", compress = "xz")

saveRDS(new_orleans_reviews,
        "data/new_orleans/reviews_new_orleans.rds", compress = "xz")

# check they load back in
test_business <- readRDS("data/new_orleans/business_new_orleans.rds")
test_reviews  <- readRDS("data/new_orleans/reviews_new_orleans.rds")
dim(test_business)
dim(test_reviews)