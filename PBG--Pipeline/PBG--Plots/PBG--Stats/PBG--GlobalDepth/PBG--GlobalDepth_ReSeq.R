setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--Stats/PBGP--Filtering-Confirmation\ of\ Possible\ Paralogs/")

library(ggplot2)
library(scales)

a <- read.table("PBGP--OnlyRe-Seqed_100Ind_PossibleParalogs_IntersectedWithMerged--Article--Ultra.mean")
colnames(a) <- c("Loci","Coverage")
a[,2] <- round(a[,2])

ggplot(a, aes(x = Coverage, group = 1)) +
  geom_density(colour = "orange", fill = "orange", alpha = 0.15, adjust = 0.75, size = 0.3) +
  theme(legend.position = "none") +
  scale_x_continuous("Global Depth (X)",
                     breaks = c(50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900),
                     expand = c(0,0),
                     labels = c("50X", "100X", "150X", "200X", "250X", "300X", "350X", "400X", "450X", "500X", "550X", "600X", "650X", "700X", "750X", "800X", "850X", "900X"),
                     limits = c(0,913)) +
  scale_y_continuous("Density",
                     breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007), 
                     expand = c(0,0),
                     labels = c("1e-03", "2e-03", "3e-03", "4e-03", "5e-03", "6e-03", "7e-03"),
                     limits = c(0, 0.007075)) +
  theme(axis.text.x = element_text(size=9, color="#000000"),
        axis.text.y = element_text(size=9, color="#000000")) +
  theme(panel.background = element_rect(fill = '#FAFAFA')) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "#000000", size = 0.3)) +
  theme(axis.ticks.x = element_line(size=0.3, color="#000000"), 
        axis.ticks.y = element_line(color="#000000", size=0.3)) +
  theme(axis.title.x = element_text(size=16, face="bold", color="#000000", margin = margin(t = 20, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size=16, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  theme(panel.border = element_blank())

ggsave("PBGP--GlobalCoverage--ParalogTest--Article--Ultra.jpeg", height=2, width=4, scale=3.5)

