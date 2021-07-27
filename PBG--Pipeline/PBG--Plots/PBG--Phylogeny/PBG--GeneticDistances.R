setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--GeneticDistances/")

library(ggplot2)

#data <- read.table("distINFO.ngsDist.tsv", header=TRUE)
data <- read.table("PBGP--GoodSamples_WithAllWGS-GBSPairs--Article--Ultra.ngsDist.raxml.bestTree_NEW.tsv", header=TRUE)
data <- data[data[,1] != data[,2],]

#
feral_data <- subset(data, grepl("Feral", data$Sp1) | grepl("Feral", data$Sp2))
# Remove all ferals
data <- subset(data, !grepl("^Feral", data$Sp1) & !grepl("^Feral", data$Sp2))
# Remove WGS-GBS

# IndianFantail 03 => Cumulet
ifant_data <- subset(data, grepl("^IndianFantail_03", data$Sp1) & grepl("^IndianFantail_(0[12]-WGS|(0[3456789]|1[0123456789]|20)-GBS)$", data$Sp2) |
                           grepl("^IndianFantail_(0[12]-WGS|(0[3456789]|1[0123456789]|20)-GBS)$", data$Sp1) & grepl("^IndianFantail_03", data$Sp2))
ifant03_data <- subset(data, grepl("^IndianFantail_03", data$Sp1) & grepl("Cumulet_(01-WGS|0[23]-GBS)$", data$Sp2) |
                              grepl("Cumulet_(01-WGS|0[23]-GBS)$", data$Sp1) & grepl("^IndianFantail_03", data$Sp2))
# Remove IndianFantail_03-GBS
#data <- subset(data, !grepl("^IndianFantail_03", data$Sp1) & !grepl("^IndianFantail_03", data$Sp2))

# IranianTumbler_01 and IranianTumbler_02 (not same breed)
# IranianTumbler_01 => Shakhsharli
#iran_data <- subset(data, grepl("^IranianTumbler", data$Sp1) | grepl("^IranianTumbler", data$Sp2))
#iran_data <- subset(data, grepl("^IranianTumbler_01", data$Sp1) | grepl("^IranianTumbler_01", data$Sp2))
iran_data <- subset(data, grepl("^IranianTumbler_01-WGS$", data$Sp1) & grepl("^Shakhsharli_01-WGS$", data$Sp2) |
                          grepl("^Shakhsharli_01-WGS$", data$Sp1) & grepl("^IranianTumbler_01-WGS$", data$Sp2))

# Fantail 02 and 09 => siblings of over related parents or inbred population (same indiv?)
#fant02_data <- subset(data, grepl("^Fantail_02", data$Sp1) | grepl("^Fantail_02", data$Sp2))
#fant09_data <- subset(data, grepl("^Fantail_09", data$Sp1) | grepl("^Fantail_09", data$Sp2))
fant_data <- subset(data, grepl("^Fantail_02-GBS", data$Sp1) & grepl("^Fantail_09-GBS", data$Sp2) |
                          grepl("^Fantail_09-GBS", data$Sp1) & grepl("^Fantail_02-GBS", data$Sp2))

# Scandaroon 01 and 02 => siblings of related parents or inbred population
# Scandaroon 01 and 02, very similar to Carneau_01 and SpanishBarb_01 (does not agree with ngsAdmix)
scand01_data <- subset(data, grepl("Scandaroon_01", data$Sp1) | grepl("Scandaroon_01", data$Sp2))
scand02_data <- subset(data, grepl("Scandaroon_02", data$Sp1) 
                       | grepl("Scandaroon_02", data$Sp2))
scand_data <- subset(data, grepl("Scandaroon_01", data$Sp1) & grepl("Scandaroon_02", data$Sp2) |
                           grepl("Scandaroon_02", data$Sp1) & grepl("Scandaroon_01", data$Sp2))

# Jacobin_01 and OldDutchCapuchine are VERY similar (genetically the same breed)
jacobin_data <- subset(data, grepl("Jacobin", data$Sp1) | grepl("Jacobin", data$Sp2))
jacobin_data <- subset(data, grepl("Jacobin_(01-WGS|0[23]-GBS)$", data$Sp1) & grepl("OldDutchCapuchine", data$Sp2) |
                             grepl("OldDutchCapuchine", data$Sp1) & grepl("Jacobin_(01-WGS|0[23]-GBS)$", data$Sp2))

# EnglishLongFacedTumbler <=> ParlorRoller (genetically the same breed)
eLFtumbler01_data <- subset(data, grepl("EnglishLongFacedTumbler", data$Sp1) | grepl("EnglishLongFacedTumbler", data$Sp2))
eLFtumbler01_data <- subset(data, grepl("EnglishLongFacedTumbler", data$Sp1) & grepl("ParlorRoller_(01-WGS|0[24]-GBS)$", data$Sp2) |
                                  grepl("ParlorRoller_(01-WGS|0[24]-GBS)$", data$Sp1) & grepl("EnglishLongFacedTumbler", data$Sp2))

# Laugher <=> MarcheneroPouter (genetically the same breed)
laugher_data <- subset(data, grepl("Laugher", data$Sp1) | grepl("Laugher", data$Sp2))
laugher_data <- subset(data, grepl("MarcheneroPouter_01-WGS$", data$Sp1) & grepl("Laugher_01-WGS$", data$Sp2) |
                             grepl("Laugher_01-WGS$", data$Sp1) & grepl("MarcheneroPouter_01-WGS$", data$Sp2))

# OldDutchCapuchine <=> Jacobin (genetically the same breed)
test_data <- subset(data, grepl("OldDutchCapuchine", data$Sp1) | grepl("OldDutchCapuchine", data$Sp2))

data$Relatedness <- factor(data$Relatedness, ordered=T, levels=c("Intra-replicates","Intra-breeds","Inter-breeds","Inter-species"))

ggplot() + geom_violin(aes(x = Relatedness, y = Distance, fill = Relatedness), alpha = 0.20, size = 0.3, data) +
  scale_fill_manual(values=c("#f4cae4", "#b3e2cd", "#fdcdac", "#cbd5e8")) +
  geom_point(aes(x=Relatedness,y=Distance), ifant_data, size = 1.85, colour="#e41a1c", alpha = 0.85) + # RED
  geom_point(aes(x=Relatedness,y=Distance), ifant03_data, size = 1.85, colour="#e41a1c", alpha = 0.85) + # RED
  geom_point(aes(x=Relatedness,y=Distance), iran_data, size=1.85, colour="#377eb8", alpha = 0.85) + # BLUE 
  geom_point(aes(x = Relatedness, y = Distance), fant_data, size = 1.85, colour = "#ff7f00", alpha = 0.85) + #ORANGE
  geom_point(aes(x = Relatedness, y = Distance), scand_data, size = 1.85, colour = "#a65628", alpha = 0.85) + #BROWN 
  geom_point(aes(x=Relatedness,y=Distance), jacobin_data, size = 1.85, colour="#984ea3", alpha = 0.85) + #PURPLE
  geom_point(aes(x=Relatedness,y=Distance), eLFtumbler01_data, size = 1.85, colour="#a1d76a", alpha = 0.85) + #LIGHTGREEN
  geom_point(aes(x=Relatedness,y=Distance), laugher_data, size = 1.85, colour="#4daf4a", alpha = 0.85) + #DARKGREEN
  #geom_point(aes(x = Relatedness, y = Distance), data, alpha = 0.35) +
  #geom_point(aes(x=Relatedness,y=Distance), feral_data, size=0.5, colour="red") +
  #geom_point(aes(x=Relatedness,y=Distance), fant02_data, size=0.5, colour="orange") +
  #geom_point(aes(x=Relatedness,y=Distance), fant09_data, size=0.5, colour="brown") +
  #geom_point(aes(x=Relatedness,y=Distance), scand01_data, size=0.5, colour="green") +
  #geom_point(aes(x=Relatedness,y=Distance), scand02_data, size=0.5, colour="orange") +
  #geom_point(aes(x=Relatedness,y=Distance), test_data, size=0.5, colour="grey") +
  scale_y_continuous("Genetic Distance",
                     breaks = c(0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16), 
                     expand = c(0,0),
                     labels = c("0.02", "0.04", "0.06", "0.08", " 0.1", "0.12", "0.14", "0.16"), 
                     limits = c(0, 0.1675)) +
  theme(legend.key = element_blank()) +
  theme(legend.background = element_rect(fill = '#FAFAFA')) +
  theme(legend.text=element_text(size=14)) +
  theme(legend.title = element_blank()) +
  theme(panel.background = element_rect(fill = '#FAFAFA'), panel.grid.minor=element_blank(), panel.border = element_blank()) +
  theme(axis.line = element_line(colour = "#000000", size = 0.3)) +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(size=16, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_text(color="#000000", size=10)) +
  theme(axis.ticks.x = element_blank(),
        axis.ticks.y = element_line(color="#000000", size=0.3)) +
  theme(panel.border = element_blank())

ggsave("PBGP--GoodSamples_WithAllWGS-GBSPairs--Article--Ultra_GeneticDistances.jpeg", height=2.2, width=4, scale=2.85, dpi = 250)

