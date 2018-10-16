home <-"~/GitHub/SPHStudentProject/"
setwd(home)
subf <- paste(home,list.files(pattern="[0-9]m"),sep="")

#ready to compile
ready <- c(1:9)
compiled <- list()
  
for(i in 5:9){
  setwd(subf[i])
  read_list <- list()
  for(j in 1:length(list.files())){
    read_list[[j]] <- read.csv(list.files()[j], stringsAsFactors = F)
  }
  compiled[[i]] <- do.call(rbind,read_list)
  setwd("~/")
  saveRDS(compiled,file="compiled.rds")
}




