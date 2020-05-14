# Load Packages
library(data.table)
library(reshape2)

#Get Data
path <- getwd()
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#Activities and Features
activityLabels <- fread(file.path(paste0(path, "/UCI HAR Dataset/activity_labels.txt"))
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(paste0(path, "/UCI HAR Dataset/features.txt"))
                  , col.names = c("index", "featureNames"))
featuresMeanStd <- grep("(mean|std)\\()", features[, featureNames])
measurements <- features[featuresMeanStd, featureNames]
measurements <- gsub('[()]', '', measurements)

#Training Data
train <- fread(file.path(paste0(path, "/UCI HAR Dataset/train/X_train.txt")))[, featuresMeanStd, with = FALSE]
setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(paste0(path, "/UCI HAR Dataset/train/Y_train.txt"))
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(paste0(path, "/UCI HAR Dataset/train/subject_train.txt"))
                       , col.names = c("SubjectNo"))
train <- cbind(trainSubjects, trainActivities, train)

#Test Data
test <- fread(file.path(paste0(path, "/UCI HAR Dataset/test/X_test.txt")))[, featuresMeanStd, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(paste0(path, "/UCI HAR Dataset/test/Y_test.txt"))
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(paste0(path, "/UCI HAR Dataset/test/subject_test.txt"))
                      , col.names = c("SubjectNo"))
test <- cbind(testSubjects, testActivities, test)

#Combining Datasets
combined <- rbind(train,test)

#Formatting properly
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabels"]],labels = activityLabels[["activityName"]])
combined[["SubjectNo"]] <- as.factor(combined[, SubjectNo])
combined <- melt(data = combined, id = c("SubjectNo", "Activity"))
combined <- dcast(data = combined, SubjectNo + Activity ~ variable, fun.aggregate = mean)

#Exporting the data 
fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
