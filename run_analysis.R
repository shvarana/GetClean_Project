# The file runscript.R with following steps:
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

library("data.table")
library("reshape2")

# Load the activity labels from the activity_labels.txt file by using read.table function
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]

# Load the data column names from the features.txt file by using read.table function
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement from the features list using grepl function
mean_std_features <- grepl("mean|std", features)

# Load and process X_test & y_test data from the test set
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Assign Column Labels to the X_test data set
names(X_test) = features

# Extract only the measurements on the mean and standard deviation for each measurement in the X_test set.
X_test = X_test[,mean_std_features]

# Assign activity labels to the numeric values and store as second column in y_test (e.g. 5 STANDING, 6 LAYING)
y_test[,2] = activity_labels[y_test[,1]]

# Assign column heading to the activity_labels in the y_test
names(y_test) = c("Activity_ID", "Activity_Label")
# Assign column heading to subject_test
names(subject_test) = "subject"

# Bind all the 3 datasets  i.e. Subject , y_test and X_test datasets
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Similarly load the training data both X_train and y_train respectively
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

# Similarly load the subject from the subject_train data.
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# Assign Column Labels to the X_train data set
names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement in the X_train set.
X_train = X_train[,mean_std_features]

# Assign activity labels to the numeric values and store as second column in y_test (e.g. 5 STANDING, 6 LAYING)
y_train[,2] = activity_labels[y_train[,1]]
# Assign column heading to the activity_labels in the y_train dataset
names(y_train) = c("Activity_ID", "Activity_Label")
# Assign column heading to subject_train dataset
names(subject_train) = "subject"

# Bind all the 3 datasets  i.e. Subject , y_train and X_train datasets
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data into one dataset by using rbind function (Row Bind)
merged_data = rbind(test_data, train_data)

# Set the ID Labels vector as id_labels
id_labels   = c("subject", "Activity_ID", "Activity_Label")
# Select only labels which measure the activity by removing the id_labels 
data_labels = setdiff(colnames(merged_data), id_labels)
# melt the data and stack the values in column variables and values. For e.g. "Subject, Activity_ID, Activity_Label, variable, value"
melt_data      = melt(merged_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function. Create tidy data set with the average of each variable for each activity and each subject
mean_tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Store the data into a file called mean_tidy_data.txt
write.table(mean_tidy_data, file = "./data/mean_tidy_data.txt",row.names = FALSE)