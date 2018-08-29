responsible <- paste(c("CCW", "Concealed Carry Weapon", "CCL", "Concealed carry license", "FFL", "Federal Firearm License", "Permit to purchase","P2P", "Background check"),collapse = "|")

responsible_count <- sapply(1:9, function(x) length(which(grepl(responsible,compiled[[x]]$postcontent,ignore.case = T)==T)))
total_count <- sapply(1:9, function(x) nrow(compiled[[x]]))

(sum(responsible_count)/sum(total_count))*100

