library(dplyr)
x <- pole %>% group_by(name, 型式) %>% summarise(sum(count))
colnames(x) <- c("name","type","count")
library(tidyr)
xx <- spread(x, key = type, value = count)
library(xlsx)
write.xlsx(x = xx, file = "polecount__.xlsx",sheetName = "TestSheet", row.names = FALSE)
