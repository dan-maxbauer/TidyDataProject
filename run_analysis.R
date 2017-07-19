
# script to create tidy data 
#
require(dplyr)
require(tibble)

setwd("~/Documents/GitHub/datasciencecoursera/GettingandCleaningData_finalproject")

features <- read.table("UCI HAR Dataset/features.txt")
names <- as.character(unlist(features[,2]))

testdataX <- read.table("UCI HAR Dataset/test/X_test.txt") # data 
colnames(testdataX) <- names
testdataY <- read.table("UCI HAR Dataset/test/Y_test.txt") # labels for activity 
colnames(testdataY) <- ("activity")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt") #subject identifiers
colnames(subject_test) <- ("subject")

traindataX <- read.table("UCI HAR Dataset/train/X_train.txt") # data 
colnames(traindataX) <- names
traindataY <- read.table("UCI HAR Dataset/train/Y_train.txt") # labels for activity 
colnames(traindataY) <- ("activity")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt") #subject identifiers
colnames(subject_train) <- ("subject")

test_merged <- cbind(subject_test,testdataY,testdataX)
test_merged$testortrain <- rep("test",nrow(test_merged))
train_merged <- cbind(subject_train,traindataY,traindataX)
train_merged$testortrain <- rep("train",nrow(train_merged))

fulldata <- rbind(test_merged,train_merged)

# get all columns with mean or std in column names
measurements_wanted <- grep(".*mean.*|.*std.*",colnames(fulldata)) 

#select data using logical vector
data <- fulldata[,c(1:2,measurements_wanted)]
data <- as.tibble(data) #convert to tibble
measurement_names <- colnames(data)
measurement_names <- gsub('-mean', 'Mean', measurement_names)
measurement_names <- gsub('-std', 'Std', measurement_names)
measurement_names <- gsub('[-()]', '', measurement_names)

colnames(data) <- measurement_names

measurement_drop <- grep("MeanFreq",measurement_names)
data <- data[,-measurement_drop]

activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities[,2] <- gsub("_","",as.character(activities[,2]))

data$activity <- factor(data$activity, levels = activities[,1], labels = activities[,2])

#final output
outputdata <- data %>% group_by(subject, activity) %>%
               summarise_all(funs(mean))

#write to file 
write.table(outputdata, "tidyoutput.txt", row.names = FALSE, quote = FALSE)



