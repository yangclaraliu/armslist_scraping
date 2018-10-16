library(tidyverse)

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
#binom.confint(sum(unlist(map(test,~sum(.x$resp_yn)))), sum(unlist(map(test,nrow))))

#
res <- do(5000) * rflip(n=5000, prob=phat)
phat + 2*sd(res$prop)
phat - 2*sd(res$prop)
quantile(res$prop, c(0.025,0.975))

#
resp_prop_byyear <- function(x){
  records_byyear <- test %>%
    map(~filter(., date<=paste0(x,"-12-31") & date >= paste0(x,"-01-01")))
  phat_byyear <- sum(unlist(map(records_byyear,"resp_yn")))/length(unlist(map(records_byyear,"year")))
  #  binom.confint(sum(unlist(map(records_byyear,"resp_yn"))),length(unlist(map(records_byyear,"year"))))
  res_byyear <- do(5000) * rflip(n=5000, prob=phat_byyear)
  return(c(phat_byyear, phat_byyear - 2*sd(res_byyear$prop), phat_byyear + 2*sd(res_byyear$prop)))
}
as.Date(range(unlist(map(test,"date"))),origin="1970-01-01")

resp_byyear <- do.call(rbind, lapply(2008:2018, function(x) resp_prop_byyear(x)))
resp_byyear <- as.data.frame(resp_byyear)
colnames(resp_byyear) <- c("point","ci_lower","ci_higher")
resp_byyear["n"] <- table(unlist(map(test,"year")))
resp_byyear["year"] <- 2008:2018

range(resp_byyear[,1:3])
plot(resp_byyear$year[2:11],resp_byyear$point[2:11],ylim=c(0.03,0.14),pch=19,xlab="Year", ylab="Proportion of Intent to be Responsible Behavior")
for(i in 2:11) lines(x=rep(resp_byyear$year[i],2), y=c(resp_byyear$ci_lower[i],resp_byyear$ci_higher[i]))
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

resp_prop <- function(x) {
  100*sum(unlist(test %>%
               map(~ filter(., .$category == x)) %>%
               map(~ sum(.$resp_yn))))/sum(unlist(test %>%
                                                    map(~ filter(., .$category == x)) %>%
                                                    map(~ nrow(.))))
}

for(i in 1:12) {
  print(include_category[i])
  print(resp_prop(include_category[i]))
}

