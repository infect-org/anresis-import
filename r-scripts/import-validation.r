#!/usr/bin/env Rscript
demoCheck <- function() {
    infile <- commandArgs(TRUE)[1]
    outfile <- commandArgs(TRUE)[2]


    data <- read.csv(infile, head = TRUE, spe=",")

    for (line in data) {
        trueCounter <- 0

        if (line$susbspecitble == "1") trueCounter <- trueCounter+1
        if (line$resistant == "1") trueCounter <- trueCounter+1
        if (line$intermediate == "1") trueCounter <- trueCounter+1

        if (trueCounter > 1) line.err <- "inconcistent resistancy data!"
    }


    write.csv(data, file = outfile)
}

demoCheck()