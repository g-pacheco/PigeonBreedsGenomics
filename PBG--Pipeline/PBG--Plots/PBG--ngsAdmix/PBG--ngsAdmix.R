setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Analyses/PBGP--ngsAdmix/")

library(optparse)
library(grid)
library(ggplot2)
library(RColorBrewer)
library(gtable)

samples <- read.table("PBGP--GoodSamples_WithWGSs_NoCrupestris_SNPCalling--Article--Ultra.txt", stringsAsFactors = FALSE, sep = "\t")

ids <- read.table("PBGP--GoodSamples_WithWGSs_NoCrupestris_SNPCalling--Article--Ultra.annot", stringsAsFactors = FALSE, sep = "\t", header=TRUE)

ids$Breeds <- factor(ids$Breeds, ordered=T, levels=c("American Giant Homer","American Show Racer","Carneau","Egyptian Swift","King","Lahore","Maltese","Polish Lynx","Racing Homer", "Runt","Show Type Homer","Barb","Dragoon","English Carrier","Scandaroon","Spanish Barb","English Pouter","Holle Cropper",
                                                     "Horseman Pouter","Marchenero Pouter","Pomeranian Pouter","Saxon Pouter","Voorburg Shield Cropper", "Archangel","Ice Pigeon","Saxon Monk","Starling","Thuringer Clean Leg","African Owl","Italian Owl", "Old German Owl","Oriental Frill","American Flying Tumbler",
                                                     "Ancient Tumbler", "Berlin Long-faced Tumbler","Budapest Tumbler","Catalonian Tumbler", "Cumulet", "Danish Tumbler", "English Long-faced Tumbler", "Medium-faced Crested Helmet", "Mookee", "Oriental Roller", "Parlor Roller", "Portuguese Tumbler",
                                                     "Temescheburger Schecken", "West of England Tumbler", "Altenburg Trumpeter", "English Trumpeter", "Laugher", "Chinese Owl", "Fantail", "Frillback", "Indian Fantail", "Jacobin", "Old Dutch Capuchine", "Schmalkaldener Mohrenkopf", "Lebanon", "Shakhsharli", "Syrian Dewlap", "Backa Tumbler", "Birmingham Roller",
                                                     "California Color Pigeon", "Iranian Tumbler", "Mindian Fantail", "Pygmy Pouter", "Saxon Fairy Swallow", "Feral"))
sampleid="Sample_ID"
target="Breeds"

data_for_plot <- data.frame()

#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16),
#c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),

x <- list(c(13,8,4,11,1,19,2,6,20,12,17,5,7,10,15,9,3,16,14,18),
          c(2,9,12,13,4,3,5,10,17,7,1,6,11,14,18,8,19,16,15),
          c(9,15,7,8,3,18,14,12,2,11,6,5,17,13,10,16,1,4),
          c(4,11,9,16,13,14,17,2,3,1,15,6,12,10,7,8,5),
          c(14,12,6,15,2,9,7,13,11,10,5,3,8,1,16,4),
          c(14,12,15,3,1,10,6,13,2,5,8,9,7,11,4),
          c(11,7,14,2,13,8,1,5,9,10,3,12,6,4),
          c(5,4,10,1,12,3,13,7,8,9,2,6,11),
          c(5,11,2,6,12,3,10,9,4,7,1,8),
          c(6,9,8,5,1,2,11,4,10,3,7),
          c(10,1,6,8,7,3,4,2,5,9),
          c(2,8,9,5,7,4,6,1,3),
          c(8,5,1,3,4,2,7,6),
          c(2,3,4,6,5,7,1),
          c(2,4,3,1,5,6),
          c(1,2,3,5,4),
          c(1,2,3,4),
          c(3,2,1),
          c(1,2))

for (j in 1:length(samples[,1])){
  data <- read.table(samples[j,1])[,x[[j]]]
  for (i in 1:dim(data)[2]) { 
    temp <- data.frame(value = data[,i])
    temp$k <- as.factor(rep(i, times = length(temp$value)))
    temp[sampleid] <- as.factor(ids[sampleid][,1])
    temp$k_value <- as.factor(rep(paste("k = ", dim(data)[2], sep =""), times = length(temp$value)))
    temp <- merge(ids, temp)
    data_for_plot <- rbind(data_for_plot, temp)
  }
}

x_lab <- (sampleid)

Plot <- ggplot(data_for_plot, aes(x = get(sampleid), y=value, fill=k)) + labs(x=x_lab) +
  geom_bar(stat="identity", width=0.85) +
  facet_grid(k_value ~ get(target), space="free_x", scales="free_x") +
  #scale_fill_manual(values=c("darkcyan", "darkseagreen", "#ffe119", "#0082c8", "#f58231", "#911eb4", "#46f0f0", "#f032e6", "#d2f53c",
                             #"#fabebe", "#008080", "#e6beff", "#aa6e28", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1",
                             #"#000080",  "#808080")) +
  theme(plot.title = element_blank()) +
  theme(panel.spacing=unit(0.2, "lines")) + 
  scale_x_discrete(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0), breaks = NULL) +
  theme(axis.text.x=element_text(colour="#000000", size=6, angle=90, vjust=0.5, hjust=1),
        axis.text.y=element_blank()) +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank()) +
  theme(strip.background=element_rect(colour="#000000", fill='#E6E6E6', size = 0.05)) +
  #theme(strip.text.x=element_text(colour="#000000", face="bold", size=7, margin=margin(0.1, 0, 0.1, 0, "cm")),
        #strip.text.y=element_text(colour="#000000", face="bold", size=7, margin=margin(0, 0.1, 0, 0.1, "cm"))) +
  theme(strip.text.x=element_text(colour="#000000", face="bold", size=7, angle=270, margin=margin(0.1, 0, 0.1, 0, "cm")),
        strip.text.y=element_text(colour="#000000", face="bold", size=7, angle=270, margin=margin(0, 0.175, 0, 0.175, "cm"))) +
  theme(panel.grid.minor=element_blank()) + theme(panel.background=element_rect(fill="#000000")) +
  theme(axis.ticks.x = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor.x = element_blank(), legend.position="none")

Plot_G <- ggplotGrob(Plot)

Plot_G <- gtable_add_rows(Plot_G, unit(0.85, "cm"), pos = 5)

Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#b15928", size = .5, lwd = 0.25)), textGrob("Form", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=4, b=6, r=24, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#1f78b4", size = .5, lwd = 0.25)), textGrob("Wattle", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=26, b=6, r=34, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#b2df8a", size = .5, lwd = 0.25)), textGrob("Croppers & Pouters", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=36, b=6, r=48, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#33a02c", size = .5, lwd = 0.25)), textGrob("Color", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=50, b=6, r=58, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#fb9a99", size = .5, lwd = 0.25)), textGrob("Owls & Frills", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=60, b=6, r=66, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#e31a1c", size = .5, lwd = 0.25)), textGrob("Tumblers, Rollers & High Flyers", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=68, b=6, r=96, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#fdbf6f", size = .5, lwd = 0.25)), textGrob("Trumpeter", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=98, b=6, r=102, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#ff7f00", size = .5, lwd = 0.25)), textGrob("Structure", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=104, b=6, r=116, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#cab2d6", size = .5, lwd = 0.25)), textGrob("Syrian", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=118, b=6, r=122, name = c("a", "b"))
Plot_G <- gtable_add_grob(Plot_G, list(rectGrob(gp = gpar(col = "#000000", fill = "#a6cee3", size = .5, lwd = 0.25)), textGrob("Non-NPA Breeds & Ferals", gp = gpar(cex = .85, fontface = 'bold', col = "black"))), t=6, l=124, b=6, r=138, name = c("a", "b"))

Plot_G <- gtable_add_rows(Plot_G, unit(2/10, "line"), 6)

grid.newpage()
grid.draw(Plot_G)

ggsave(Plot_G, file = "PBGP--GoodSamples_WithWGSs_NoCrupestris_SNPCalling--Article--Ultra_RColours_Colours_Final.jpeg", width=25, height=14, dpi = 150)
