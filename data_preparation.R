library(tidyverse)
library(magrittr)
library(lubridate)

data_path <- scan("data_path", what = "character")

train <- read_csv(paste0(data_path, "train_flat.csv"))
test <- read_csv(paste0(data_path, "test_flat.csv"))

setdiff(colnames(train), colnames(test))

table(train$campaignCode)

train %<>% select(-campaignCode) 

#predicted value - natural logarithm of transactionRevenue column
train %<>% 
  mutate(PredictedLogRevenue = log(transactionRevenue)) %>%  
  mutate(PredictedLogRevenue = ifelse(is.na(PredictedLogRevenue), 0, PredictedLogRevenue))
  
#convert character columns to factors
train %<>% 
  mutate_if(is.character, factor)
test %<>% 
  mutate_if(is.character, factor)

#id columns
id_cols <- c("fullVisitorId", "sessionId", "visitId")

#number of levels for factor columns
nlevels <- sapply(train, function(x) ifelse(is.factor(x), length(levels(x)), 0))

#which columns should be removed due to too many levels (better address the problem than remove them)
too_many_lvls_cols <- setdiff(colnames(train)[which(nlevels > 50)], id_cols)

#columns containing dates
train %<>% 
  mutate(visitStartTime = as.POSIXct(visitStartTime, origin = "1970-01-01"),
         date = ymd(date))
test %<>% 
  mutate(visitStartTime = as.POSIXct(visitStartTime, origin = "1970-01-01"),
         date = ymd(date))

unnecessary_cols <- c("visitStartTime", "transactionRevenue")

#check for columns containg a lot of missing data
percent_missing <- sapply(train, function(x) round(sum(is.na(x))/nrow(train)*100, 2))
missing_val_cols <- colnames(train)[which(percent_missing > 0)]

#check for columns with different levels in test and train set
tr_lvls <- lapply(train[, -which(colnames(train) %in% c("transactionRevenue", "PredictedLogRevenue"))], levels)
te_lvls <- lapply(test, levels)

lvls_diff <- lapply(1:length(tr_lvls), function(x) setdiff(te_lvls[[x]], tr_lvls[[x]]))
names(lvls_diff) <- colnames(test)
lvls_diff_cols <- colnames(test)[which(sapply(lvls_diff, length) > 0)]
lvls_diff_cols <- setdiff(lvls_diff_cols, id_cols)


to_remove <- unique(c(too_many_lvls_cols, unnecessary_cols, missing_val_cols, 
                      lvls_diff_cols))

train %<>% 
  select(-one_of(to_remove))
test %<>% 
  select(-one_of(to_remove))


saveRDS(train, paste0(data_path, "train_clean.rds"))
saveRDS(test, paste0(data_path, "test_clean.rds"))
