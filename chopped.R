setwd("~/")
load("compiled.RData")
exclude <- c("tactical gear","vehicles", "ammo reloading gear","paintball","optics","magazines","knives","holsters","fishing","air gun","ammo","miscellaneous","events","archery","services")

for(i in 1:9){
  total_range <- 1:nrow(compiled[[i]])
  to_exclude <- which(tolower(compiled[[i]]$category)%in%exclude)
  print(paste("The list component", i, "is shrinked by",round((1-(length(total_range)-length(to_exclude))/length(total_range))*100,2),"%."))
  compiled[[i]] <- compiled[[i]][setdiff(total_range,to_exclude),]
}


for(i in 1:9){
  total_range <- 1:nrow(compiled[[i]])
  to_exclude <- which(grepl("in store|in-store|instore",compiled[[i]]$postcontent,ignore.case = T)==T)
  print(paste("The list component", i, "is shrinked by",round((1-(length(total_range)-length(to_exclude))/length(total_range))*100,2),"%."))
  compiled[[i]] <- compiled[[i]][setdiff(total_range,to_exclude),]
}

for(i in 1:9){
  total_range <- 1:nrow(compiled[[i]])
  to_exclude <- which(grepl("want to buy",compiled[[i]]$title,ignore.case = T)==T)
  print(paste("The list component", i, "is shrinked by",round((1-(length(total_range)-length(to_exclude))/length(total_range))*100,2),"%."))
  compiled[[i]] <- compiled[[i]][setdiff(total_range,to_exclude),]
}

saveRDS(compiled,"chopped.rds")

