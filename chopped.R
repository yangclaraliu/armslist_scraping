library(tidyverse)

setwd("~/")
compiled <- readRDS("compiled.rds")
unlist(map(compiled,nrow))
# 835448 680569 802675 813953 235934 688827 750527 788316 664052

#testers
test <- list()
for(i in 1:9) test[[i]] <- compiled[[i]][1:100,]

#remove due to no type
filter_notype <- function(x) {
  filter(x, !rowSums(cbind(x$category == "no type",
                                       x$action == "no type",
                                       x$caliber == "no type",
                                       x$firearm.type == "no type"))==4)
}
compiled <- map(compiled,filter_notype)

#testing validity
x = 9
which(compiled[[x]]$category == "no type" & compiled[[x]]$action == "no type" & compiled[[x]]$caliber == "no type" & compiled[[x]]$firearm.type == "no type")

unlist(map(compiled,nrow))
#835448 680385 802458 813953 235929 688825 749068 787766 664049

#exclude certain gun types from consideration
all_category <- unique(unlist(map(compiled,"category")))
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
                      "Other",
                      "")
compiled <- map(compiled, ~ filter(.x, .x$category %in% include_category))
unlist(map(compiled,nrow))

#testing validity
any((compiled[[1]]$category %in% include_category)==F)

#exclude ones that want to buy
compiled <- map(compiled, ~filter(.x,!grepl("want to buy",.x$title,ignore.case = T)))
unlist(map(compiled,nrow))
#634661 564472 602894 528705 200171 583632 606130 626047 568881

saveRDS(compiled,"chopped.rds")

#Remove premium sellers
vendors <- read.csv("~/GitHub/SPHStudentProject/premium_vendors.csv", stringsAsFactors = F)[,2]
compiled_vendor <- map(compiled, ~ mutate(.x, vendors_yn = grepl(paste(vendors,collapse="|"),.x$postcontent, ignore.case = T)))
#sum(compiled_vendor[[9]]$vendors_yn)
#range(unlist(map(map(compiled_vendor,"vendors_yn"),sum))/unlist(map(compiled,nrow)))

#save
saveRDS(compiled_vendor,"chopped_vendor.rds")
