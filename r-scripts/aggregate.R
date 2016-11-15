
####################################################

# INFECT automated data aggregation file

# uses package "foreign" and "data.table" to work!

####################################################

# Date: 5th November

# Author: Anon Y. Mous

# if packages foreign and data.table are not installed yet, use below code to install:
# install.packages("foreign")



# load needed packages (foreign for reading data, data.table to aggregate)
library(foreign)
library(data.table)


aggregateData <- function() {
  inFilePath <- commandArgs(TRUE)[1]
  outFilePath <- commandArgs(TRUE)[2]

  ### importing csv file (foreign package must be installed)
  infile <- read.csv(inFilePath, header = TRUE , sep="," , na.strings=c(""))


  # Drop all columns that are not needed for FrontEnd (at the moment)
  infile$sex <- NULL
  infile$age <- NULL
  infile$dataSource <- NULL
  infile$region <- NULL
  infile$city <- NULL
  infile$organ <- NULL
  infile$organGroup <- NULL
  infile$sampleDate <- NULL
  infile$resistanceValue <- NULL
  infile$causedInfection <- NULL
  infile$isHospitalized <- NULL
  infile$isNosocomial <- NULL
  infile$id <- NULL
  infile$year <- NULL
  infile$hasError <- NULL
  infile$errorCode <- NULL

  
  # generate a column for binary non-susceptible values (called "resistance" for simplicity):
  # with susceptible = 0 and resistant = 1
  infile$resistance = ifelse(infile$resistanceLevel == "susceptible" , c(0) , c(1))

  # drop resistanceLevel (that has 3 resistance categories and is string)
  infile$resistanceLevel = NULL

  
  # create a counter column, that gives the total number of bacteria/compound samples per combination
  # which is needed as denominator to calculate resistance percentages
  infile$counter = (1)

  # change infile to data table and aggregate by bacteria and compound; columns V1 and V2 are created
  infile = data.table(infile)
print(infile)
  aggregated = infile[,list(sum(resistance), sum(counter)), by = c("bacteria","compound")]


print(aggregated)
  # the number of resistant values per bacteria/compound combo (V1) is renamed to nrResistant
  aggregated$nrResistant = aggregated$V1
  aggregated$V1 = NULL

  # the number of total values per bacteria/compound combo (V2) is renamed to nrTotal
  aggregated$nrTotal = aggregated$V2
  aggregated$V2 = NULL

  # calculate percentage of non-susceptible bacteria  
  aggregated$percentResistant = round(aggregated$nrResistant / aggregated$nrTotal * 100, digits = 1)


  # export to csv using outFilePath as the files designated path
  write.csv(aggregated, outFilePath)

}



aggregateData()






