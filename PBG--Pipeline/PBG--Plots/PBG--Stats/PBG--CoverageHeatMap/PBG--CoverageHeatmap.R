### To Plot Coverage Heatmap Based on Stats Reasults:

setwd("/Users/hintze/Desktop/PhD\ Action\ Plan/Core\ Projects/Finishing/PBGP--FINAL/Anaysis/Stats/CoverageHeatMap/")

data=read.table("Loci_Merged.coverage.km.tsv", sep="\t", check.names=FALSE)

# Treat all negative values as zero:

data <- as.matrix(data)
data[data < 0] <- 0

# Get get distance matrix: 
dist = dist(t(data), method="manhattan")

pheatmap(data, border_color="black", cluster_rows=TRUE, cluster_cols=TRUE, clustersing_distance_cols="manhattan", clustering_distance_rows="manhattan",
         treeheight_row=135, treeheight_col=135, cellwidth=10, cellheight=10, cutree_rows=6, cutree_cols=6,
         filename="Loci_Merged.coverage.TREE.NonWeighted.Local.pdf")
  