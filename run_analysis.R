library(plyr)
library(dplyr)

#1 - Merges the training and the test sets to create one data set.
mergedSet <- rbind(read.table("UCI HAR Dataset/train/X_train.txt"),
                   read.table("UCI HAR Dataset/test/X_test.txt"))

#2 - Extracts only the measurements on the mean and standard
#    deviation for each measurement.
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
features <- features$V2
validFeatures <- grepl(".*(mean|std).*", features)
mergedSet <- mergedSet[, validFeatures]

#3 - Uses descriptive activity names to name the activities in the data set.
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- rbind(read.table("UCI HAR Dataset/train/y_train.txt"),
                    read.table("UCI HAR Dataset/test/y_test.txt"))
activities <- join(activities, activityLabels)
mergedSet <- cbind(activities$V2, mergedSet)

#4 - Appropriately labels the data set with descriptive variable names.
names(mergedSet) <- c("activity", features[validFeatures])
names(mergedSet) <- gsub("\\(|)|-", "", names(mergedSet))

#5 - From the data set in step 4, creates a second, independent tidy
#    data set with the average of each variable for each activity 
#    and each subject.
subjects <- rbind(read.table("UCI HAR Dataset/train/subject_train.txt"),
                    read.table("UCI HAR Dataset/test/subject_test.txt"))
mergedSet2 <- cbind(subjects, mergedSet)
mergedSet2 <- rename(mergedSet2, subject=V1)
mergedSet2 <- mergedSet2 %>% group_by(activity, subject)
                %>% summarise_each(funs(mean))
write.table(mergedSet2, file = "dataSet.txt", row.names = FALSE)