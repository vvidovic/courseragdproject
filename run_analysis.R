## Script which cleans and analize Samsung's wearable computing data.
#  Samsung data have to be available under current working directory in "data" subdirectory.

# Load required libraries
library(dplyr)

# Load data only if it is not allready loaded to save time
if(!exists("df_feature_names")) {
    # Load feature names
    df_feature_names <- read.table("data/features.txt")
    df_activity_names <- read.table("data/activity_labels.txt")

    # Load test data, labels and subjects
    df_test_data = read.table("data/test/X_test.txt")
    df_test_activities = read.table("data/test/y_test.txt")
    df_test_subjects = read.table("data/test/subject_test.txt")
    
    # Load training data, labels and subjects
    df_train_data = read.table("data/train/X_train.txt")
    df_train_activities = read.table("data/train/y_train.txt")
    df_train_subjects = read.table("data/train/subject_train.txt")
}

# Merges the training and the test sets to create one data set.
df_data <- rbind(df_test_data, df_train_data)
# Appropriately labels the data set with descriptive variable names.
feature_names <- gsub("\\(|\\)","",df_feature_names$V2)
feature_names <- sub("$", "-avg", feature_names)
colnames(df_data) <- feature_names
df_activity_ids <- rbind(df_test_activities, df_train_activities)
df_subjects <- rbind(df_test_subjects, df_train_subjects)

# Extracts only the measurements on the mean and standard deviation for each measurement.
df_stdmean <- df_data[,grep("std|mean", feature_names)]

# Add subject id-s to data frame.
colnames(df_subjects) <- c("subject_id")
df_stdmean <- cbind(df_stdmean, df_subjects)

# Uses descriptive activity names to name the activities in the data set
colnames(df_activity_ids) <- c("activity_id")
colnames(df_activity_names) <- c("activity_id", "activity_name")
df_stdmean <- cbind(df_stdmean, activity_id = df_activity_ids$activity_id)
# merge changes row ordering
df_stdmean <- merge(df_stdmean, df_activity_names)
df_stdmean <- df_stdmean[,2:82]


# Creates a second, independent tidy data set with the average of each variable
# for each activity and each subject.
df_avgdata <- summarise_each(group_by(df_stdmean, activity_name, subject_id), funs(mean))

# Writes result data to txt file
write.table(df_avgdata, "average_data.txt", row.names = FALSE)
