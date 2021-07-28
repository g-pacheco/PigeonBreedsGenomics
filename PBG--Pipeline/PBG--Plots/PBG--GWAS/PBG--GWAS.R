setwd("D:/Data/Layka/Lost_Files/Lost_Partition/PhD/Core_Projects/Finishing/PBGP--FINAL/Analyses/PBGP--GWAS/")

library(ggman)
library(mvnpermute)

### To Permute PHENO File:

# Obtained from LOG file:
HeadCrest_vg = 0.318919
HeadCrest_ve = 3.18919e-06

#FootFeathering_vg = 0.347366
#FootFeathering_ve = 3.47366e-06

# Read Relatedness Matrix:
K = read.table("PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest.cXX.txt")
K = as.matrix(K)

# Compute the Variance-covariance Matrix:
cv.matrix = K*(HeadCrest_vg) + diag(nrow(K))*HeadCrest_ve

# Read Phenotype File:
pheno = read.table("PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest.pheno")
pheno = as.numeric(pheno$V1)

## Covariate (just ones in this case,for intercept):
covars = matrix(rep(1, nrow(K)), nr=nrow(K), nc=1)

## Permutation Taking into Account the Correlation Structure of the Samples: 
permuted.phenos = mvnpermute(pheno, covars, cv.matrix, 100) # take this phenotype, run gemma, generate p-value

write.table(permuted.phenos, "PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest.Permuted.pheno",
            sep=" ",  col.names = FALSE, row.names = FALSE)

### To Generate Auxiliary Plots:

# Import Data:
gwas_results_perm <- read.table("cutPBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest-BS_ALL.assoc.txt", as.is=T, header=T)
head(gwas_results_perm)
gwas_results_perm$log10 <- -log10(gwas_results_perm$p_lrt)

## Generate straight line
SNP <- nrow(gwas_results_perm)
expected <- seq(1/SNP,1,1/SNP)
expected <- rev(-log10(expected))

# Qqplot
jpeg(file="PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest_QqplotPermutation.jpg")
plot(expected, sort(gwas_results_perm$log10),pch=21, cex=0.8)
abline(a=0,b=1,col=2)
dev.off()

# Histogram
jpeg(file="PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest_HistogramPermutation.jpg")
hist(gwas_results_perm$p_lrt, breaks=c(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0), freq=FALSE, right=FALSE)
dev.off()

# Get a 5% Percentile Based on Permuted Results
pvalues <- gwas_results_perm$p_lrt
pvalues_0.05 <- quantile(pvalues, 0.05)
Npvalues <- nrow(gwas_results_perm)

SigLine <- -log10(pvalues_0.05/Npvalues)

pvalues_0.05/Npvalues

SigLine

### To Plot GWAS Results:

Assoc <- read.table("PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_HeadCrest.Edited.assoc.txt", sep="\t", stringsAsFactors = F)
colnames(Assoc) <- c("SNP","CHR", "BP", "P")

head(Assoc)

for (chr in 1:nrow(Assoc)){
  Assoc$CHR[chr]=sub("_[^_]*$","",Assoc$SNP[chr])
  Assoc$SNP[chr]=paste(Assoc$CHR[chr],Assoc$BP[chr],sep=":")}

Labels <- Assoc[-log10(Assoc$P)>SigLine,]

Plot <- ggman(Assoc, snp="SNP",bp="BP",chrom="CHR",pvalue="P", sigLine = SigLine, pointSize=1, lineColour="#82BA40") +
  scale_x_continuous("Scaffolds",
                     #breaks = NULL,
                     labels = NULL,
                     expand = c(0,0)) +
                     #limits = NULL) +
  scale_y_continuous("-log10 (P-value)",
                     breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13), 
                     expand = c(0,0),
                     labels = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"), 
                     limits = c(0, 13.1)) +
  theme(plot.title = element_blank()) +
  theme(panel.background = element_rect(fill = '#FAFAFA')) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor=element_blank()) +
  theme(axis.title.x = element_text(size=14, face="bold", color="#000000", margin = margin(t = 20, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(size=14, face="bold", color="#000000", margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  theme(axis.ticks.x = element_blank(),
        axis.ticks.y = element_line(size=0.3, color="#000000")) +
  theme(axis.line = element_line(colour="#000000", size=0.3, color="#000000"), panel.border = element_blank())

ggmanLabel(Plot, labelDfm = Labels, snp="SNP", label = "SNP")

ggsave("PBGP--GoodSamples_WithWGSs_NoOddSamplesNoFerals_SNPCalling--Article--Ultra_FootFeathering.eps", height=2.5, width=4, scale=3.5, dpi = 1000)