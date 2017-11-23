library(xgboost)
library(readr)
library(stringr)
library(caret)
library(readxl)
library(xlsx)
library(dplyr)
library(randomForest)
library(hydroGOF)

data <- read_excel("train+submit_pole_use_other.xlsx")

train_typhon <- c("201513","201521","201509","201410","201601","201614","201416","201407")
train_data <- data[data$颱風編號 %in% train_typhon ,]
submit_data_1 <- data[data$颱風編號 %in% 201617 ,]

train <- train_data[,c(8,3:5,11:18,22:35,36)]
colnames(train) <- c("typhone_id","village_lat","village_lng","village_alt","t_rainfall","rainfull_24","rainfull_12","rainfull_6","rainfull_3","rainfull_1","mean_speed","max_speed","households","pole1","pole2","pole3","pole4","pole5","pole6","pole7","pole8","pole9","pole10","pole11","pole_t","ever","blackout")
train <- train[train$ever=="Y", -which(colnames(train)=="ever")]

#將要預測的submit data 資料建好
submit_1 <- submit_data_1[,c(3:5,11:18,22:35)]
colnames(submit_1) <- c("village_lat","village_lng","village_alt","t_rainfall","rainfull_24","rainfull_12","rainfull_6","rainfull_3","rainfull_1","mean_speed","max_speed","households","pole1","pole2","pole3","pole4","pole5","pole6","pole7","pole8","pole9","pole10","pole11","pole_t","ever")
submit_1 <- submit_1[submit_1$ever=="Y", -which(colnames(submit_1)=="ever")]
submit_1 <- xgb.DMatrix(data = as.matrix(submit_1))

# #將資料切割成training and testing
training <- train[, -1]
testing <- train[, -1]
# set.seed(100)
# test.index <- sample(1:nrow(train),0.2*nrow(train))
# training <- train[-test.index, -1]
# testing <- train[test.index, -1]

new_tr <- as.matrix(training[,-grep("blackout",colnames(training))])
new_ts <- as.matrix(testing[,-grep("blackout",colnames(testing))])
labels <- training$blackout
ts_label <- testing$blackout
  
dtrain <- xgb.DMatrix(data = new_tr,label = labels) 
dtest <- xgb.DMatrix(data = new_ts,label=ts_label)

params <- list(booster = "gbtree", objective = "reg:linear", eta=0.2, gamma=0, max_depth=5, min_child_weight=1, subsample=1, colsample_bytree=1)
set.seed(100)
#xgb <- xgboost(params = params, data = dtrain, nrounds = 1000, nfold = 5, showsd = T, stratified = T, print.every.n = 10, early.stop.round = 20, maximize = F)
xgb1 <- xgb.train (params = params, data = dtrain, nrounds = 1200, watchlist = list(val=dtest,train=dtrain), print.every.n = 10, early.stop.round = 10, maximize = F)

#view variable importance plot
mat <- xgb.importance (feature_names = colnames(new_tr),model = xgb1)
xgb.plot.importance (importance_matrix = mat[1:20]) 

#--------測試-----------
pre <- predict(xgb1, dtest)
test_result <- as.data.frame(pre)
test_result$true <- testing$blackout
#到cal_score算分數

#--------calulate rmse-------
RMSE=rmse(test_result$pre,test_result$true)

#-------跑結果----------
results_1 <- predict(xgb1, submit_1)
results <- as.data.frame(results_1)
results$VilCode <- submit_data_1[submit_data_1$曾經停電=="Y", ]$VilCode
write.xlsx(x = results, file = "results.xlsx",sheetName = "TestSheet", row.names = FALSE)
