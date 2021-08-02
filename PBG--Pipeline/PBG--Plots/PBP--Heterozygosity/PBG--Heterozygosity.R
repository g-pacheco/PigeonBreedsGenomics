# To Plot Heterozygosity Data Summary

setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--Stats/PBGP--Heterozygosity/")
  
library(ggplot2)
library(scales)

a <- read.table("PBGP--GoodSamples_WithWGSs--Article--Ultra.Heterozygosity.txt", sep = "\t", header = FALSE)
colnames(a) <- c("Sample_ID", "Breeds", "NPA_Groups", "Het")

a$NPA_Groups <- factor(a$NPA_Groups, ordered=T, levels=c("Form","Wattle","Croppers & Pouters","Color","Owls & Frills","Tumblers, Rollers & High Flyers","Trumpeter",
                                                     "Structure", "Syrian", "Non-NPA Breeds", "Ferals", "C. rupestris"))

a$Breeds <- factor(a$Breeds, ordered=T, levels=c("American Giant Homer","American Show Racer","Carneau","Egyptian Swift","King","Lahore","Maltese","Polish Lynx","Racing Homer", "Runt","Show Type Homer","Barb","Dragoon","English Carrier","Scandaroon","Spanish Barb","English Pouter","Holle Cropper",
                                                     "Horseman Pouter","Marchenero Pouter","Pomeranian Pouter","Saxon Pouter","Voorburg Shield Cropper", "Archangel","Ice Pigeon","Saxon Monk","Starling","Thuringer Clean Leg","African Owl","Italian Owl", "Old German Owl","Oriental Frill","American Flying Tumbler",
                                                     "Ancient Tumbler", "Berlin Long-faced Tumbler","Budapest Tumbler","Catalonian Tumbler", "Cumulet", "Danish Tumbler", "English Long-faced Tumbler", "Iranian Tumbler", "Medium-faced Crested Helmet", "Mookee", "Oriental Roller", "Parlor Roller", "Portuguese Tumbler",
                                                     "Temescheburger Schecken", "West of England Tumbler", "Altenburg Trumpeter", "English Trumpeter", "Laugher", "Chinese Owl", "Fantail", "Frillback", "Indian Fantail", "Jacobin", "Old Dutch Capuchine", "Schmalkaldener Mohrenkopf", "Lebanon", "Shakhsharli", "Syrian Dewlap", "Backa Tumbler", "Birmingham Roller",
                                                     "California Color Pigeon", "Mindian Fantail", "Pygmy Pouter", "Saxon Fairy Swallow", "Ferals", "C. rupestris"))

ggplot(a, aes(factor(Breeds), Het)) + geom_boxplot(fill = "#F79999", outlier.size = 1.5, width = 0.3) +
     labs(x = a$Breeds, y = "Proportion of Heterozygous Sites") +
     theme(panel.background = element_rect(fill = '#FAFAFA'), panel.grid.minor=element_blank(), panel.border = element_blank()) +
     theme(axis.line = element_line(colour = "#000000", size = 0.3)) +
     theme(axis.title.x=element_blank(),
           axis.title.y = element_text(size=22, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
     theme(axis.text.x = element_text(colour="#000000", size=18, angle=90, vjust=0.5, hjust=1),
           axis.text.y = element_text(color="#000000", size=18)) +
     theme(axis.ticks.x = element_blank(),
           axis.ticks.y = element_line(color="#000000", size=0.3)) +
     theme(legend.position = "none")

ggsave(file = "PBGP--GoodSamples_WithWGSs--Article--Ultra.Heterozygosity_Breeds.eps", height=3.6, width=6, scale=3, dpi = 1000)
