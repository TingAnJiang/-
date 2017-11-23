library(readxl)
data <- read_excel("train+submit_pole_use_urban.xlsx")

train_typhon <- c("201513","201521","201509","201410","201601","201614","201416","201407")
train_data <- data[data$颱風編號 %in% train_typhon ,]
submit_data_1 <- data[data$颱風編號 %in% 201709 ,]

train <- train_data[,c(8,5,11:18,22:35,36)]
colnames(train) <- c("typhone_id","village_alt","t_rainfall","rainfull_24","rainfull_12","rainfull_6","rainfull_3","rainfull_1","mean_speed","max_speed","households","pole1","pole2","pole3","pole4","pole5","pole6","pole7","pole8","pole9","pole10","pole11","pole_t","ever","blackout")
train <- train[train$ever=="Y", ]
train$ever <- NULL

#將要預測的submit data 資料建好
submit_1 <- submit_data_1[,c(5,11:18,22:35)]
colnames(submit_1) <- c("village_alt","t_rainfall","rainfull_24","rainfull_12","rainfull_6","rainfull_3","rainfull_1","mean_speed","max_speed","households","pole1","pole2","pole3","pole4","pole5","pole6","pole7","pole8","pole9","pole10","pole11","pole_t","ever")
submit_1 <- submit_1[submit_1$ever=="Y", ]
submit_1$ever <- NULL


# #將資料切割成training and testing
test.index <- which(train$typhone_id == 201410)
training <- train[, -1]
testing <- train[, -1] 

#SVR
#---------------------------------------------
library(e1071)
set.seed(100)
formula <- blackout~.
svr <- svm(formula, training, epsilon = 0.2, cost = 2)
print(svr)

#-------tune modle------
tuneResult <- tune(svm, formula,  data = training,
                   ranges = list(epsilon = seq(0.1,0.3,0.1), cost = 2))
print(tuneResult)
plot(tuneResult)
svr <- tuneResult$best.model

#--------測試-----------
pre <- predict(svr, testing)
test_result <- as.data.frame(pre)
test_result$true <- testing$blackout
#到cal_score算分數

#--------calulate rmse-------
library(hydroGOF)
RMSE=rmse(test_result$pre,test_result$true)

#-------跑結果----------
results_1 <- predict(svr, submit_1)
results <- as.data.frame(results_1)
results$VilCode <- submit_data_1[submit_data_1$曾經停電=="Y", ]$VilCode
library(xlsx)
write.xlsx(x = results, file = "results.xlsx",sheetName = "TestSheet", row.names = FALSE)


