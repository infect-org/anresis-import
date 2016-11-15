#!/usr/bin/env Rscript

####################################################

# INFECT Data Import Script

# install foreign package: sudo apt install r-cran-foreign
# call using: Rscript import.R in.csv out.csv

# Function still needs some "on error return false" part,
# since the server has to know if there was an error running this script!

####################################################


# Load foreign package (needed for the read.csv function).
# If it is not installed yet, it is possibel to do so from R
# using:
# install.packages("foreign")
library(foreign)



validateData <- function() {
    inFilePath <- commandArgs(TRUE)[1]
    outFilePath <- commandArgs(TRUE)[2]


    # read csv file from disk
    infile <- read.csv(inFilePath, header = TRUE , sep="," , na.strings=c(""))


    # same as above for testing purposes with hardcoded file path
    ##infile <- read.csv("import.csv", header = TRUE , sep="," , na.strings=c(""))


    # drop a variable from dataset
    #infile$isnew <- NULL

    # check if all patients with nosocomial infections are hospitalised, if not, give error:
    infile$hasError <- ifelse(infile$isNosocomial == 1 & infile$isHospitalized == 0, c(1) , c(0))
    infile$errorCode <- ifelse(infile$isNosocomial == 1 & infile$isHospitalized == 0, c('Hospitalisation/Nosocomial: implausible value') , c(''))


    # check if there are any missings in important columns: bacteria, id, year, compound, or resistanceLevel
    # in case of missing, give error message in errorCode
    infile$hasError <- ifelse(is.na(infile$bacteria) | is.na(infile$id) | is.na(infile$year) | is.na(infile$compound) | is.na(infile$resistanceLevel), c(1) , c(infile$hasError))
    infile$errorCode <- ifelse(is.na(infile$bacteria) | is.na(infile$id) | is.na(infile$year) | is.na(infile$compound) | is.na(infile$resistanceLevel), c("Vital data missing") , c(infile$errorCode))



    #subsetting erraneous observations
    infile <- infile[infile$hasError == 1, ]


    # export to csv
    write.csv(infile, outFilePath)
}




validateData()