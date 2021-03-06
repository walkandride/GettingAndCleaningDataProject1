# ------------------------------------------------------------
# Merge the training and the test sets to create one data set.
# ------------------------------------------------------------

ptm <- proc.time() # benchmark

# define location of data files
base_dir <- "./" #"./data/UCI HAR Dataset/test/"

# define column widths for measurement data (defined in "X" files)
w <- rep(c(16), times=561)		

# read test subject data
test_subj <- read.fwf(file = paste(base_dir, "subject_test.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = c(1)
		, col.names = c("subject_id")
		)
test_x <- read.fwf(file = paste(base_dir, "X_test.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = w
		)
test_y <- read.fwf(file = paste(base_dir, "Y_test.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = c(1)
		, col.names = c("activity_id")
		)
# combine three datafiles into a single dataset		
test_merge <- cbind(cbind(test_x, test_y), test_subj)

# read training data		
train_subj <- read.fwf(file = paste(base_dir, "subject_train.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = c(1)
		, col.names = c("subject_id")
		)
train_x <- read.fwf(file = paste(base_dir, "X_train.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = w
		)
train_y <- read.fwf(file = paste(base_dir, "Y_train.txt", sep = "")
		, flush = TRUE
		, header = FALSE
		, widths = c(1)
		, col.names = c("activity_id")
		)
# combine three datafiles into a single dataset		
train_merge <- cbind(cbind(train_x, train_y), train_subj)

# combine test and train data into a single dataset
results <- rbind(test_merge, train_merge)


# ---------------------------------------------------------------------------------------
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# ---------------------------------------------------------------------------------------

# Looking at the features.txt file, pull out those column names ending with
# mean() and std().  Append the "activity_id" and "subject_id" columns.
# identify indices for mean() and std() columns plus activity_id and subject_id
# mean() and std() to represent the columns to calculate.
mean_std_indices <- c(1:6, 41:46, 81:86, 121:126, 161:166, 201:202
		, 214:215, 227:228, 240:241, 253:254, 266:271, 345:350
		, 424:429, 503:504, 516:517, 529:530, 542:543, 562:563)

# Define a dataset based upon the above columns.		
results_mean_std <- results[, mean_std_indices]


# -----------------------------------------------------------------
# Appropriately label the data set with descriptive variable names. 
# -----------------------------------------------------------------

# Identify the mean snd standard deviation columns defined by the variable, mean_std_indices.
labels <- c("tBodyAcc-mean()-X", "tBodyAcc-mean()-Y", "tBodyAcc-mean()-Z", "tBodyAcc-std()-X"
	, "tBodyAcc-std()-Y", "tBodyAcc-std()-Z", "tGravityAcc-mean()-X", "tGravityAcc-mean()-Y"
	, "tGravityAcc-mean()-Z", "tGravityAcc-std()-X", "tGravityAcc-std()-Y", "tGravityAcc-std()-Z"
	, "tBodyAccJerk-mean()-X", "tBodyAccJerk-mean()-Y", "tBodyAccJerk-mean()-Z"
	, "tBodyAccJerk-std()-X", "tBodyAccJerk-std()-Y", "tBodyAccJerk-std()-Z", "tBodyGyro-mean()-X"
	, "tBodyGyro-mean()-Y", "tBodyGyro-mean()-Z", "tBodyGyro-std()-X", "tBodyGyro-std()-Y"
	, "tBodyGyro-std()-Z", "tBodyGyroJerk-mean()-X", "tBodyGyroJerk-mean()-Y"
	, "tBodyGyroJerk-mean()-Z", "tBodyGyroJerk-std()-X", "tBodyGyroJerk-std()-Y"
	, "tBodyGyroJerk-std()-Z", "tBodyAccMag-mean()", "tBodyAccMag-std()", "tGravityAccMag-mean()"
	, "tGravityAccMag-std()", "tBodyAccJerkMag-mean()", "tBodyAccJerkMag-std()"
	, "tBodyGyroMag-mean()", "tBodyGyroMag-std()", "tBodyGyroJerkMag-mean()"
	, "tBodyGyroJerkMag-std()", "fBodyAcc-mean()-X", "fBodyAcc-mean()-Y", "fBodyAcc-mean()-Z"
	, "fBodyAcc-std()-X", "fBodyAcc-std()-Y", "fBodyAcc-std()-Z", "fBodyAccJerk-mean()-X"
	, "fBodyAccJerk-mean()-Y", "fBodyAccJerk-mean()-Z", "fBodyAccJerk-std()-X"
	, "fBodyAccJerk-std()-Y", "fBodyAccJerk-std()-Z", "fBodyGyro-mean()-X", "fBodyGyro-mean()-Y"
	, "fBodyGyro-mean()-Z", "fBodyGyro-std()-X", "fBodyGyro-std()-Y", "fBodyGyro-std()-Z"
	, "fBodyAccMag-mean()", "fBodyAccMag-std()", "fBodyBodyAccJerkMag-mean()"
	, "fBodyBodyAccJerkMag-std()", "fBodyBodyGyroMag-mean()", "fBodyBodyGyroMag-std()"
	, "fBodyBodyGyroJerkMag-mean()", "fBodyBodyGyroJerkMag-std()", "activity_id", "subject_id")

# Re-label the results_mean_std dataset.
colnames(results_mean_std) <- labels

# ----------------------------------------------------------------------
# Uses descriptive activity names to name the activities in the data set
# ----------------------------------------------------------------------

# Add a new column, activity_type, based upon the activity id whose values are defined in
# the activity_labels.txt file.
attach(results_mean_std)
results_mean_std$activity_type[activity_id == 1] <- "walking"
results_mean_std$activity_type[activity_id == 2] <- "walking upstairs"
results_mean_std$activity_type[activity_id == 3] <- "walking downstairs"
results_mean_std$activity_type[activity_id == 4] <- "sitting"
results_mean_std$activity_type[activity_id == 5] <- "standing"
results_mean_std$activity_type[activity_id == 6] <- "laying"
detach(results_mean_std)

# prep dataset minus activity_id (don't want activity_id column included in molten dataset)
results2melt <- results_mean_std[, c(1:66, 68:69)]

# install reshape2 package if not currently installed
# install.packages("reshape2")
library(reshape2)

# Melt the dataset based upon subject_id and activity_type which are the id variables
mdata <- melt(results2melt, id=c("subject_id", "activity_type"))

# -------------------------------------------------------------------------------------
# Create a second, independent tidy data set with the average of each variable for each 
# activity and each subject. 
# -------------------------------------------------------------------------------------

# Create tidy dataset calculating the mean for each measurement and group by 
# subject_id and activity_type 
tidy_data <- dcast(mdata, formula = subject_id + activity_type ~ variable, mean)

# Export results to file.
write.table(tidy_data, file="tidy_data.txt", sep="\t")


proc.time() - ptm # End benchmark
# End of program.
