library(tidyverse)
library(magrittr)
library(randomForest)

data_path <- scan("data_path", what = "character")

train <- readRDS(paste0(data_path, "train_clean.rds"))
test <- readRDS(paste0(data_path, "test_clean.rds"))

#id columns
id_cols <- c("fullVisitorId", "sessionId", "visitId")

rf <- randomForest(PredictedLogRevenue ~ ., data = train[, -which(colnames(train) %in% id_cols)],
                   ntree = 50)

Sys.time()
#0:44
#4:49
#randomForest by default gives error if there are NA values. you can change
#that by argument `na.action`
#By default randomForest cannot handle categorical predictors with more than 53
#categories

preds <- predict(rf, test)

submission <- data.frame(fullVisitorId = test$fullVisitorId, PredictedLogRevenue = preds)
submission %<>% 
  group_by(fullVisitorId) %>% 
  summarise(PredictedLogRevenue = sum(PredictedLogRevenue))

write.csv(submission, paste0(data_path, "submission.csv"), row.names = FALSE)

#2 attitudes - predict every transaction and sum revenue per id or aggregate per user first