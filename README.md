##run_Analysis.R instructions
To process the data with the run_Analysis.R function, merely source the function and then pass the outputs of the function without any inputs to a new list. For example:

> source(“run_Analysis.R”)
> results <- run_Analysis()

All necessary files are downloaded when the function is run.  The downloaded zip files will be saved to whatever working directory you have selected.  The files will be unzipped in the same directory.  The output (“results” in the example above) will be a list consisting of 2 data tables.  The first is titled “allData” and the second is titled “summaryData”.  “allData” consists of the merged test and training data sets with columns corresponding to subject ID, activity descriptions, and mean or standard deviations of various measurements.  “summaryData” condenses this data set and shows only the mean of each column shown in full data set where the mean is calculated across each subject and each activity.  These tables can be accessed and viewed via the R command (as in the example above):

>View(results$allData)
>View(results$summaryData”).