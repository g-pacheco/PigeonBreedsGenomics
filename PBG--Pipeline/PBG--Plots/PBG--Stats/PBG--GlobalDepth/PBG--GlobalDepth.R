setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--Stats/PBGP--Filtering-Confirmation\ of\ Possible\ Paralogs/")

library(ggplot2)
library(scales)

a0 <- read.table("PBGP--GoodSamples_WithAllWGS-GBSPairs_95Ind_ParalogTest_IntersectedWithMerged--Article--Ultra.mean")
colnames(a0) <- c("Loci","Coverage")
#a0[,2] <- round(a0[,2])
b0 <- data.frame(Coverage = a0$Coverage, Type = "All Loci")

a1 <- read.table("PBGP--GoodSamples_WithAllWGS-GBSPairs_95Ind_ParalogTest_IntersectedWithMerged_PossibleParalogs-g800--Article--Ultra.mean")
colnames(a1) <- c("Loci","Coverage")
#a1[,2] <- round(a1[,2])
b1 <- data.frame(Coverage = a1$Coverage, Type = "Possible Paralog Loci")

a2 <- read.table("PBGP--GoodSamples_WithAllWGS-GBSPairs_95Ind_ParalogTest_IntersectedWithMerged_WithoutPossibleParalogs-g800--Article--Ultra.mean")
colnames(a2) <- c("Loci","Coverage")
#a1[,2] <- round(a1[,2])
b2 <- data.frame(Coverage = a2$Coverage, Type = "Loci Without Possible Paralog Loci")

c <- rbind(b0, b1)
  
ggplot(c, aes(x = Coverage, fill = Type, colour = Type)) +
  geom_density(alpha = 0.15, adjust = 0.75, size = 0.3) +
  theme(legend.title=element_blank()) +
  theme(legend.text=element_text(size=12, color="#000000")) +
  theme(legend.position=c(.8, 0.5)) +
  theme(legend.background = element_rect(fill = FALSE)) +
  theme(legend.key = element_blank()) +
  scale_x_continuous("Global Depth (X)",
                     breaks = c(5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000, 65000, 70000, 75000, 80000, 85000, 90000, 95000, 100000),
                     labels = c("5K", "10K", "15K","20K", "25K", "30K", "35K", "40K", "45K", "50K", "55K", "60K", "65K","70K", "75K", "80K", "85K", "90K", "95K", "100K"),
                     expand = c(0,0),
                     limits = c(0, 101200)) +
  scale_y_continuous("Density",
                     breaks = c(0.00001, 0.00002, 0.00003, 0.00004, 0.00005, 0.00006, 0.00007), 
                     expand = c(0,0),
                     labels = c("1e-05", "2e-05", "3e-05", "4e-05", "5e-05", "6e-05", "7e-05"), 
                     limits = c(0, 0.00007075)) +
  theme(axis.text.x = element_text(size=9, color="#000000"),
        axis.text.y = element_text(size=9, color="#000000")) +
  theme(panel.background = element_rect(fill = '#FAFAFA')) +
  theme(axis.ticks.x = element_line(size=0.3, color="#000000"),
        axis.ticks.y = element_line(size=0.3, color="#000000")) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor=element_blank(), 
        axis.line=element_line(colour="#000000", size=0.3, color="#000000")) +
  theme(axis.title.x = element_text(size=16, face="bold", color="#000000", margin = margin(t = 20, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size=16, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  theme(panel.border=element_blank())

ggsave("PBGP--GlobalCov-ParalogCofirmation--Article--Ultra.jpeg", height=2, width=4, scale=3.5)
