library(tidyverse)
library(jsonlite)

data_path <- scan("data_path", what = "character")

train <- read_csv(paste0(data_path, "train.csv"))
test <- read_csv(paste0(data_path, "test.csv"))

tr_device <- paste("[", paste(train$device, collapse = ","), "]") %>% fromJSON(flatten = T)
tr_geoNetwork <- paste("[", paste(train$geoNetwork, collapse = ","), "]") %>% fromJSON(flatten = T)
tr_totals <- paste("[", paste(train$totals, collapse = ","), "]") %>% fromJSON(flatten = T)
tr_trafficSource <- paste("[", paste(train$trafficSource, collapse = ","), "]") %>% fromJSON(flatten = T)

te_device <- paste("[", paste(test$device, collapse = ","), "]") %>% fromJSON(flatten = T)
te_geoNetwork <- paste("[", paste(test$geoNetwork, collapse = ","), "]") %>% fromJSON(flatten = T)
te_totals <- paste("[", paste(test$totals, collapse = ","), "]") %>% fromJSON(flatten = T)
te_trafficSource <- paste("[", paste(test$trafficSource, collapse = ","), "]") %>% fromJSON(flatten = T)

train <- train %>%
  cbind(tr_device, tr_geoNetwork, tr_totals, tr_trafficSource) %>%
  select(-device, -geoNetwork, -totals, -trafficSource)

test <- test %>%
  cbind(te_device, te_geoNetwork, te_totals, te_trafficSource) %>%
  select(-device, -geoNetwork, -totals, -trafficSource)

rm(tr_device); rm(tr_geoNetwork); rm(tr_totals); rm(tr_trafficSource)
rm(te_device); rm(te_geoNetwork); rm(te_totals); rm(te_trafficSource)

write.csv(train, paste0(data_path, "train_flat.csv"), row.names = F)
write.csv(test, paste0(data_path, "test_flat.csv"), row.names = F)
