### To plot correlation between scaffold lengths and number of SNPs

setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--Stats/SNP-Info/")

library(ggplot2)

a <- read.table("PBGP--GoodSamples_WithAllWGS-GBSPairs--Article--Ultra.ScaffoldInfo_OnlyWithSites.txt")
colnames(a) <- c("Scaffold","ScaffoldLength", "NumberOfSNPs")

Regression <- lm(formula = a$ScaffoldLength ~ a$NumberOfSNPs, data = a)
summary(Regression)

ggplot(a,aes(ScaffoldLength, NumberOfSNPs)) + stat_smooth(method="lm") + geom_point(alpha=0.7, color="#000000", size=1) +
  annotate("text", label = "Multiple R-squared: 0.9896", x = 15000000, y = 175000, size = 5, colour = "#FF0000") +
  annotate("text", label = "P-value: < 2.2e-16", x = 15000000, y = 165000, size = 5, colour = "#FF0000") +
  scale_x_continuous("Scaffold Length",
                     breaks = c(10000000, 20000000, 30000000, 40000000, 50000000, 60000000, 70000000, 80000000, 90000000),
                     labels = c("1e+07", "2e+07", "3e+07", "4e+07", "5e+07", "6e+07", "7e+07", "8e+07", "9e+07"),
                     limits = c(0, 97250000),
                     expand = c(0,0)) +
  scale_y_continuous("# of Sites",
                     breaks = c(25000, 50000, 75000, 100000, 125000, 150000, 175000, 200000),
                     labels = c("25K", "50K", "75K", "100K", "125K", "150K", "175K", "200K"),
                     limits = c(0, 212500),
                     expand = c(0,0)) +
  theme(axis.text.x = element_text(size=10, color="#000000"),
        axis.text.y = element_text(size=10, color="#000000")) +
  theme(axis.title.x = element_text(size = 16, color="#000000", face="bold", margin = margin(t = 20, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size = 16, color="#000000", face="bold", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  theme(panel.background = element_rect(fill = '#FAFAFA')) +
  theme(axis.ticks.x = element_line(size=0.3, color="#000000"),
        axis.ticks.y = element_line(size=0.3, color="#000000")) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor=element_blank(), 
        axis.line=element_line(colour="#000000", size=0.3, color="#000000")) +
  theme(panel.border=element_blank())

ggsave("PBGP--GoodSamples_WithAllWGS-GBSPairs--Article--Ultra.ScaffoldInfo_OnlySites.jpeg", height=2, width=4, scale=3.5, dpi = 150)

