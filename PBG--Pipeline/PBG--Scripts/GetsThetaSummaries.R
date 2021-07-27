# Define variables:

a1 <- function(n) sum(1/(1:(n-1)))
a2 <- function(n) sum(1/(1:(n-1))^2)

b1 <- function(n) (n+1)/(3*(n-1))
b2 <- function(n) (2*(n^2+n+3))/(9*n*(n-1))

c1 <- function(n) b1(n)-1/a1(n)
c2 <- function(n) b2(n)-(n+2)/(a1(n)*n)+a2(n)/a1(n)^2

e1 <- function(n) c1(n)/a1(n)
e2 <- function(n) c2(n)/(a1(n)^2+a2(n))

## Input is thetaD and number of segregating sites:

tajima.d2 <- function(pairwise,thetaW,n){
    S <- thetaW*a1(n)
    top <- pairwise-thetaW
    bot <- sqrt(e1(n)*S+e2(n)*S*(S-1))
    top/bot
}

# Get summaries:

args <- commandArgs(trailingOnly=TRUE)
file = args[1]
n_ind = args[2]
id = args[3]

data <- read.table(file, sep = "\t", header = FALSE)
colnames(data) <- c("Chr","Pos", "tW", "tP", "ThetaS", "ThetaH", "ThetaL")
Pi <- sum(exp(data$tP))
W <- sum(exp(data$tW))
Td <- tajima.d2(Pi,W,2*as.numeric(n_ind))


cat(paste(id, nrow(data), Pi/nrow(data), W/nrow(data), Td, sep="\t"), fill=TRUE)
#cat("Pi: ", Pi, fill=TRUE)
#cat("Theta_W: ", W, fill=TRUE)
