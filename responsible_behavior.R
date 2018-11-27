library(tidyverse)
library(mosaic)

setwd("~/")
file.info(list.files(pattern="rds")[1])
compiled <- readRDS("chopped.rds")

responsible <- c("CCW", "Concealed Carry Weapon", "CCL", "Concealed carry license", "FFL", "Federal Firearm License", "Permit to purchase","P2P", "Background check", "License", "Permit", "bill of sale", "CHP", "CWP", "CCP", "CCDW", "PTC", "PTP")
responsible <- paste0("\\<",responsible)  
responsible <- paste0(responsible,"\\>")  
responsible <- paste(responsible,collapse = "|")

test <- compiled %>%
  map(~as.tibble(.)) %>%
  map(~mutate(., resp_yn = grepl(responsible, .$postcontent, ignore.case = T))) %>%
  map(~separate(., post.date, into = c("drop", "dow", "month_day", "year"), sep = "[:punct:]")) %>%
  map(~mutate(.,date = as.Date(paste0(.$month_day,.$year), format = c(" %B %d %Y")))) %>%
  map(~filter(., !is.na(.$date))) %>%
  map(~filter(., date > 0))


#Smaller tester
temp <- list()
for(i in 1:9) temp[[i]] <- test[[i]][1:1000,]

sapply(1:9, function(x) table(test[[x]][which(test[[x]]$category=="Gun"),"year"]))


# 
# temp %>%
#   map(~as.tibble(.)) %>%
#   map(~mutate(., resp_yn = grepl(responsible, .$postcontent, ignore.case = T))) %>%
#   map(~separate(., post.date, into = c("drop", "dow", "month_day", "year"), sep = "[:punct:]")) %>%
#   map(~mutate(., date = as.Date(paste0(.$month_day,.$year), format = c(" %B %d %Y")))) %>%
#

sum(unlist(map(test,nrow)))
sum(unlist(map(test,~sum(.x$resp_yn))))

phat <- sum(unlist(map(test,~sum(.x$resp_yn))))/sum(unlist(map(test,nrow)))

#
# resp_prop_byyear <- function(x){
#   records_byyear <- test %>%
#     map(~filter(., date<=paste0(x,"-12-31") & date >= paste0(x,"-01-01")))
#   phat_byyear <- sum(unlist(map(records_byyear,"resp_yn")))/length(unlist(map(records_byyear,"year")))
  #  binom.confint(sum(unlist(map(records_byyear,"resp_yn"))),length(unlist(map(records_byyear,"year"))))
#   res_byyear <- do(5000) * rflip(n=5000, prob=phat_byyear)
#   return(c(phat_byyear, phat_byyear - 2*sd(res_byyear$prop), phat_byyear + 2*sd(res_byyear$prop)))
# }
# as.Date(range(unlist(map(test,"date"))),origin="1970-01-01")
# 
# head(compiled[[1]]$category)
# resp_byyear <- do.call(rbind, lapply(2008:2018, function(x) resp_prop_byyear(x)))
# resp_byyear <- as.data.frame(resp_byyear)
# colnames(resp_byyear) <- c("point","ci_lower","ci_higher")
# resp_byyear["n"] <- table(unlist(map(test,"year")))
# resp_byyear["year"] <- 2008:2018
# 
# range(resp_byyear[,1:3])
# plot(resp_byyear$year[2:11],resp_byyear$point[2:11],ylim=c(0.03,0.14),pch=19,xlab="Year", ylab="Proportion of Intent to be Responsible Behavior")
# for(i in 2:11) lines(x=rep(resp_byyear$year[i],2), y=c(resp_byyear$ci_lower[i],resp_byyear$ci_higher[i]))
#
sort(table(unlist(map(test,"category"))))
sort(table(unlist(map(test,"category"))))*100/sum(unlist(map(test,nrow)))

#
include_category <- c("Tactical",
                      "Rifles",
                      "Shotguns",
                      "Handguns",
                      "Gun",
                      "Muzzle",
                      "NFA",
                      "Antique",
                      "All",
                      "Reloading",
                      "Firearms",
                      "Other")
include_category <- as.data.frame(include_category)
include_category$counts <- NA

for(i in 1:nrow(include_category)){
  include_category[i,2] <- sum(sapply(1:9, function(x) length(which(compiled[[x]]$category==as.character(include_category[i,1])))))
}

include_category <- include_category[order(include_category$counts, decreasing = T),]

resp_prop <- function(x) {
  temp_counts <- sum(unlist(test %>%
                              map(~ filter(., .$category == x)) %>%
                              map(~ sum(.$resp_yn))))
  temp_denom <- include_category[which(include_category[,1]==x),"counts"]
  temp_prop <- 100*temp_counts/temp_denom
  temp_phat <- temp_counts/temp_denom
  temp_flip <- do(5000) * rflip(n=5000, prob=temp_phat)
  return(c(x, temp_denom, temp_counts, temp_phat*100, (temp_phat - 2*sd(temp_flip$prop))*100, (temp_phat + 2*sd(temp_flip$prop))*100))
}

table_row <- sapply(as.character(include_category[1:12,1]),resp_prop)
table_row <- as.tibble(t(table_row))
colnames(table_row) <- c("Gun type", "Total Listings", "Listing contains Responsible Selling Information","%","CI_low","CI_high")
table_row["Percentage of posts displaying responsible selling (95%CI)"] <- 
paste0(round(as.numeric(table_row$`%`),2)," [",round(as.numeric(table_row$CI_low),2),", ",round(as.numeric(table_row$CI_high),2),"]")

setwd("/../Users/eideyliu/Documents/GitHub/SPHStudentProject")
res <- table_row[,c(1,2,3,7)]
write.csv(res,"Table1.csv")



temp_phat <- sum(as.numeric(table_row$`Listing contains Responsible Selling Information`))/sum(as.numeric(table_row$`Total Listings`))
temp_flip <- do(5000) * rflip(n=5000, prob=temp_phat)
c(temp_phat*100, (temp_phat - 2*sd(temp_flip$prop))*100, (temp_phat + 2*sd(temp_flip$prop))*100)
