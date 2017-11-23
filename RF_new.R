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

#觀察一下各變數對blackout之間的關係
cor(train[,c(2:25)] ,train$blackout)

#將要預測的submit data 資料建好
submit_1 <- submit_data_1[,c(3:5,11:18,22:35)]
colnames(submit_1) <- c("village_lat","village_lng","village_alt","t_rainfall","rainfull_24","rainfull_12","rainfull_6","rainfull_3","rainfull_1","mean_speed","max_speed","households","pole1","pole2","pole3","pole4","pole5","pole6","pole7","pole8","pole9","pole10","pole11","pole_t","ever")
submit_1 <- submit_1[submit_1$ever=="Y", -which(colnames(submit_1)=="ever")]


# #將資料切割成training and testing
training <- train[, -1]
testing <- train[, -1]

#random forest
#------------------開始種樹--------------------
formula <- blackout~.
memory.limit(18*1024)
RMSE <- c()
for(i in 2:(length(training)-1)){
  set.seed(100)
  rf <- randomForest(formula, training, importance = TRUE, proximity = FALSE, mtry =i, ntree = 200)
  pre <- predict(rf, testing)
  test_result <- as.data.frame(pre)
  test_result$true <- testing$blackout
  RMSE[i] <- rmse(test_result$pre,test_result$true)
}
set.seed(100)
rf <- randomForest(formula, training, importance = TRUE, proximity = FALSE, mtry =which.min(RMSE), ntree = 200)
print(rf)

#--------測試-----------
pre <- predict(rf, testing)
test_result <- as.data.frame(pre)
test_result$true <- testing$blackout
#到cal_score算分數

#--------calulate rmse-------
RMSE=rmse(test_result$pre,test_result$true)

#-------跑結果----------
results_1 <- predict(rf, submit_1)
results <- as.data.frame(results_1)
results$VilCode <- submit_data_1[submit_data_1$曾經停電=="Y", ]$VilCode
write.xlsx(x = results, file = "results.xlsx",sheetName = "TestSheet", row.names = FALSE)


