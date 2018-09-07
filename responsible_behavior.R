setwd("~/")
compiled <- readRDS("chopped.rds")

responsible <- paste(c("CCW", "Concealed Carry Weapon", "CCL", "Concealed carry license", "FFL", "Federal Firearm License", "Permit to purchase","P2P", "Background check"),collapse = "|")

#total
responsible_count <- sapply(1:9, function(x) length(which(grepl(responsible,compiled[[x]]$postcontent,ignore.case = T)==T)))
total_count <- sapply(1:9, function(x) nrow(compiled[[x]]))

sum(responsible_count)
sum(total_count)
(sum(responsible_count)/sum(total_count))*100

#by gun category
gun_category <- unique(unlist(sapply(1:9, function(x) unique(compiled[[x]]$category))))
compiled_bycategory <- list()

for(j in 1:length(gun_category)){
  temp <- list()
  for(i in 1:9){
    temp[[i]] <- compiled[[i]][compiled[[i]]$category==gun_category[j],]
  }
  compiled_bycategory[[j]] <- temp
  rm(temp)
}
names(compiled_bycategory) <- gun_category

res_tab <- matrix(NA,ncol=3,nrow=length(gun_category)+1)
colnames(res_tab) <- c("responsible","total","proportion")

res_tab[1,] <- c(sum(responsible_count),sum(total_count),(sum(responsible_count)/sum(total_count))*100)

for(i in 2:20){
  temp_responsible_count <- sapply(1:9, function(x) length(which(grepl(responsible,compiled_bycategory[[i-1]][[x]]$postcontent,ignore.case = T)==T)))
  temp_total_count <- sapply(1:9, function(x) nrow(compiled_bycategory[[i-1]][[x]]))
  res_tab[i,] <- c(sum(temp_responsible_count), sum(temp_total_count), (sum(temp_responsible_count)/sum(temp_total_count))*100)
}

rownames(res_tab) <- c("Total",gun_category)

