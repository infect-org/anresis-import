#!/usr/bin/env Rscript

####################################################

# INFECT @alpascal. what is happening in this file?

# install foreign package: sudo apt install r-cran-foreign
# call using: Rscript import.R in.csv out.csv

####################################################


# does what?
library(foreign)


validateData <- function() {
    inFilePath <- commandArgs(TRUE)[1]
    outFilePath <- commandArgs(TRUE)[2]


    # read from disk
    infile <- read.csv(inFilePath, header = TRUE , sep="," , na.strings=c(""))


    # importing csv file (foreign package must be installed)
    infile <- read.csv("test-infile.csv", header = TRUE , sep="," , na.strings=c(""))


    # drop a variable from dataset
    #infile$isnew <- NULL

    infile$hasError <- ifelse(infile$isNosocoial == 1 & infile$isHospitalized == 0, c(1) , c(0))
    infile$errorCode <- ifelse(infile$isNosocoial == 1 & infile$isHospitalized == 0, c('Hospitalisation/Nosocomial: implausible value') , c(''))


    infile$hasError <- ifelse(is.na(infile$bacteriaName) | is.na(infile$id) | is.na(infile$sampleYear) | is.na(infile$compoundName) | is.na(infile$resistanceLevel), c(1) , c(infile$hasError))
    infile$errorCode <- ifelse(is.na(infile$bacteriaName) | is.na(infile$id) | is.na(infile$sampleYear) | is.na(infile$compoundName) | is.na(infile$resistanceLevel), c("Vital data missing") , c(infile$errorCode))



    #subsetting erraneous observations
    infile <- infile[infile$hasError == 1, ]


    # export to csv
    write.csv(infile, outFilePath)
}




validateData()
