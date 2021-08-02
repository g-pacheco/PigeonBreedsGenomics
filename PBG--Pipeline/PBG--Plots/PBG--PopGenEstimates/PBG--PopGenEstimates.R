# To Plot PopGen Stats

setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--Statistics/")
  
library(ggplot2)
library(scales)

a <- read.table("PBGP--GoodSamples_WithWGSs_NoCrupestris-DoSaf-WithWrapper-DoThetas-NoWrapper--Article—Ultra.PopGenSummary.txt", sep = "\t", header = FALSE)
colnames(a) <- c("Population", "NSites", "Pi", "tW", "Td")

a$Population <- factor(a$Population, ordered=T, levels=c("RacingHomer", "EnglishCarrier", "Archangel", "Starling", "HelmetMediumFacedCrested", "OrientalRoller",
                                                         "WestofEnglandTumbler", "EnglishTrumpeter", "ChineseOwl", "Fantail",  "IndianFantail", "BirminghamRoller"))

ggplot(a, aes(factor(Population), Pi)) + geom_point(fill = "#F79999", size= 2) +
     labs(x = a$Population, y = "Nucleotide Diversity") +
     theme(panel.background = element_rect(fill = '#FAFAFA'), panel.grid.minor=element_blank(), panel.border = element_blank()) +
     theme(axis.line = element_line(colour = "#000000", size = 0.3)) +
     theme(axis.title.x=element_blank(),
           axis.title.y = element_text(size=22, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
     theme(axis.text.x = element_text(colour="#000000", size=16, angle=90, vjust=0.5, hjust=1),
           axis.text.y = element_text(color="#000000", size=16)) +
     theme(axis.ticks.x = element_blank(),
           axis.ticks.y = element_line(color="#000000", size=0.3)) +
     theme(legend.position = "none")

ggsave(file = "PBGP--GoodSamples_WithWGSs_NoCrupestris-DoSaf-WithWrapper-DoThetas-NoWrapper--Article—Ultra-Pi.eps", height=3.6, width=6, scale=2.5, dpi = 1000)
