library(readxl)
library(dplyr)
wthrstn <- read_excel("wthrstn.xlsx")
rain <- read_excel("rain.xlsx")
rain <- rain %>% left_join(wthrstn,by=c("測站"="站號"))
rain <- rain %>% group_by(颱風名稱,測站) %>% filter(累積雨量 == max(累積雨量)) %>% slice(1)
wind <- read_excel("wind.xlsx")
wind <- wind %>% left_join(wthrstn,by=c("測站"="站號"))
train_new <- read_excel("train_new.xlsx")
train_new$vi_st_no_new <- 0
train_new$vi_st_no_new_wind <- 0
  

ty <- unique(train_new$typhoon_id)
system.time(
  for(j in ty){
    rain_new <- rain[rain$颱風名稱 == j,]
    wind_new <- wind[wind$颱風名稱 == j,]    
    loop = which(train_new$typhoon_id == j)
    for(i in loop){
      train_new$vi_st_no_new[i] <- 
        rain_new$測站[which.min(sqrt((train_new$village_lng[i] - rain_new$經度)^2 + 
                                     (train_new$village_lat[i]-rain_new$緯度)^2))]

      train_new$vi_st_no_new_wind[i] <- 
        wind_new$測站[which.min(sqrt((train_new$village_lng[i] - wind_new$經度)^2 + 
                                     (train_new$village_lat[i]-wind_new$緯度)^2))]
    
    }
    print(j)
  }
)
train_new_ <- train_new %>% left_join(rain[,c(1:4)],by=c("vi_st_no_new"="測站","typhoon_id"="颱風名稱"))
train_new__ <- train_new_ %>% left_join(wind[,c(1:7)],by=c("vi_st_no_new_wind"="測站","typhoon_id"="颱風名稱"))


write.csv(train_new__,"train+submit_new_.csv")
