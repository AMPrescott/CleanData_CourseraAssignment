run_Analysis <- function() {
  #This function takes no input and processes movement data compiled using smart phones
  
  #Load necessary R packages
  library(data.table)
  library(dplyr)
  
  dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"  #Url for data packet
  
  download.file(dataUrl, destfile = "smartPhoneMotionData.zip", method = "curl") #Download zip file
  
  unzip("smartPhoneMotionData.zip")  #Unzip the data file into current working directory
  
  #Read in applicable data
  X_test <- data.frame(read.table("./UCI HAR Dataset/test/X_test.txt", sep = ""))
  Y_test <- fread("./UCI HAR Dataset/test/y_test.txt")
  subject_test <- fread("./UCI HAR Dataset/test/subject_test.txt")
  
  X_train <- data.frame(read.table("./UCI HAR Dataset/train/X_train.txt", sep = ""))
  Y_train <- fread("./UCI HAR Dataset/train/y_train.txt")
  subject_train <- fread("./UCI HAR Dataset/train/subject_train.txt")
  
  activityLabels <- fread("./UCI HAR Dataset/activity_labels.txt")
  features <- fread("./UCI HAR Dataset/features.txt")
  
  #Add descriptive names to variables in X_test and X_train that are described in the data.table features
  setnames(X_test, colnames(X_test), features$V2)
  setnames(X_train, colnames(X_train), features$V2)
  
  #Give column names to Y_test, Y_train, subject_test, and subject_train
  setnames(Y_test, colnames(Y_test), c("ActivityID"))
  setnames(Y_train, colnames(Y_train), c("ActivityID"))
  setnames(subject_test, colnames(subject_test), c("SubjectID"))
  setnames(subject_train, colnames(subject_train), c("SubjectID"))
  
  #Extract columns from X_test and X_train that describe measurement standard deviations or means
  X_test <- X_test[,grep("(.*std.*|.*mean.*)", colnames(X_test))]
  X_train <- X_train[,grep("(.*std.*|.*mean.*)", colnames(X_train))]
  
  #Bind subject_*** and Y_*** to X_*** and merge the test and train data sets into a single table
  fullDataSet <- rbind(cbind(subject_test, Y_test, X_test), cbind(subject_train, Y_train, X_train))
  
  #Summarize the full data set into a data set that has the averages of each value for each subject and activity
  #Initialize a data.table to store summarized data for each subject and activity
  summarizedDataMeans <- data.table(matrix(0, ncol = ncol(fullDataSet), nrow = length(unique(fullDataSet$SubjectID))*length(unique(fullDataSet$ActivityID))))
  setnames(summarizedDataMeans, colnames(summarizedDataMeans), colnames(fullDataSet))
  #Calculate the mean for each column value only examining the full data for each subject for each activity
  for(subject in unique(fullDataSet$SubjectID)) {
    for(activity in unique(fullDataSet$ActivityID)) {
      sumRow <- (subject-1)*length(unique(fullDataSet$ActivityID))+activity
      summarizedDataMeans[sumRow, 1] <- subject
      summarizedDataMeans[sumRow, 2] <- activity
      testData <- fullDataSet[fullDataSet$SubjectID == subject & fullDataSet$ActivityID == activity,]
      for(measurement in 3:ncol(fullDataSet)) {
        summarizedDataMeans[sumRow,measurement] <- mean(testData[[measurement]],na.rm = T)
      }
    }
  }
  
  #Order the data table fullDataSet
  fullDataSet <- fullDataSet[order(fullDataSet$SubjectID, fullDataSet$ActivityID),]
  
  #Give descriptive name to activities in the ActivityID column of full data and summaraized mean data sets by referencing the activityLabes table
  activityDescription <- as.character(rep(0,nrow(fullDataSet)))  #Initialize a character vector with same number of rows as full data set
  #Determine what activity description goes with each activity ID in full data set and pass this to activityDescription vector
  for(obs in 1:nrow(fullDataSet)) {
    activityDescription[obs] <- activityLabels$V2[fullDataSet$ActivityID[obs]]
  }
  fullDataSet$ActivityID <- activityDescription  #Make ActivityID in full data set a factor vector with description of each activity
  fullDataSet$ActivityID <- as.factor(fullDataSet$ActivityID)
  
  activityDescription <- as.character(rep(0,nrow(summarizedDataMeans)))  #Initialize a character vector with same number of rows as summarized means data set
  #Determine what activity description goes with each activity ID in summarized means data set and pass this to activityDescription vector
  for(obs in 1:nrow(summarizedDataMeans)) {
    activityDescription[obs] <- activityLabels$V2[summarizedDataMeans$ActivityID[obs]]
  }
  summarizedDataMeans$ActivityID <- activityDescription  #Make ActivityID in summarized means set a factor vector with description of each activity
  summarizedDataMeans$ActivityID <- as.factor(summarizedDataMeans$ActivityID)
  
  #Order the data table fullDataSet
  fullDataSet <- fullDataSet[order(fullDataSet$SubjectID, fullDataSet$ActivityID),]
  
  results = list( "allData" = fullDataSet, "summaryData" = summarizedDataMeans)
}