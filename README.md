Creating Tidy Data Set from the Human Activity Recognition Using Smartphones Data Set

This markdown documents the process of converting data from the "Human Activity Recognition using Smartphones Data Set" into a tidy data set with the average means and standard deviations of each measured variable for each subject/activity pair. The end result is a 180x68 data.frame that will be written to "mean-std-by-subject-activity.txt".

Data Processing

Download data file and read in data

First, the code sets the working directory (will be have to be changed for each user)
    setwd("~/datascispec/getdata/project")
The code identifies whether or not the file existed in the current directory. If not, the code download the zip file as "Samsung.zip", and unzips it.
    samsungurl <- "https://d396qusza40orc.cloudfront.net/
        getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
    if (!file.exists("samsung.zip")){
        download.file(samsungurl, destfile="samsung.zip", method="curl")
        unzip("samsung.zip")
}
Read the data from the activity labels and features files
    activitylbls <- read.table("UCI\ HAR\ Dataset/activity_labels.txt")
    features <- read.table("UCI\ HAR\ Dataset/features.txt")
Read the test and train data. We're only interested in the subject data and the x and y data, not the inertial data (which contains the very raw data and is not used in the data processing done here)
    x.test <- read.table("UCI\ HAR\ Dataset//test/X_test.txt")
    y.test <- read.table("UCI\ HAR\ Dataset//test/Y_test.txt")
    x.train <- read.table("UCI\ HAR\ Dataset//train/X_train.txt")
    y.train <- read.table("UCI\ HAR\ Dataset//train/Y_train.txt")
Calculate average means and standard deviations of each variable

Next select the features that are means or standard deviation variables. Note that this code does not use variables with "meanFreq" or that are angles. These variables are not means of recorded data, and are therefore left out.
    meanstd <- grep("std\\()|mean\\()", features[,2], ignore.case=TRUE)
Merge test and train data using "rbind" function, but only for the variables that are means or standard deviations
    x.tot <- rbind(x.test[,meanstd], x.train[,meanstd])
    y.tot <- rbind(y.test, y.train)
    subj.tot <- rbind(subj.test, subj.train)
Create new vectors for subjects and activities and store their lengths for future use
    subjects <- unique(subj.tot)$V1
    activities <- activitylbls$V1
    actlen <- length(activities)
    subjlen <- length(subjects)
Calculate average mean and standard variation for each variable for each subject and activity level and store these values in an array named "results". The array is 180x66, with 180 rows for 30*6 subject*activity pairs and 66 columns for 33 variable names with both means and standard deviations stored. Note that I chose not to use merge to combine the "y" data and activity labels because it isn't necessary - using the y values as indices and applying activity labels later on works just as well.
    results <- array(0, dim=c(subjlen*actlen, length(meanstd)))
    for (k in 1:length(meanstd)){
        for (i in 1:subjlen) {
            for (j in 1:actlen){
                ind <- which( (subj.tot==i) & (y.tot==j))
                results[(i-1)*actlen+j,k] <- mean(x.tot[ind, k])
            }
        }
    }
Store results in data.frame and write to output file

Create columns for subject and activity levels
    subjfin <- rep(1:30, each=6)
    actfin <- rep(1:6, 30)
Create new labels that conform with google R style guidelines
    lblfin <- c("walk", "walkup", "walkdown", "sitting", "standing", "laying")
Remove parantheses and hyphens from variable names. Upper case letters are left in (as allowed in google R style guide) to help with readability of variable names. Additionally, there are some misnamed variables in which "BodyBody" should just be "Body" (see codebook for details on names).
    varnames <- gsub("[\\(\\)-]", "", features$V2[meanstd])
    varnames <- gsub("BodyBody", "Body", varnames)
Store subject, activity levels and results in data.frame and write to file
    df <- data.frame(subjfin, lblfin[actfin], results)
    names(df) <- c("Subject", "Activity", varnames)
    write.table(df, "mean-std-by-subject-activity.txt")
Codebook (description of variables names)

Output variables

Subject: Subject number (1-30)
Acitivity: Activity undertaken by subject. walk=Walking, walkup=Walking Upstairs, walkdown=Walking Downstairs, others are as is.
Other variables names have multiple components and each component in the names can be interpreted as follows:
BodyAcc: body acceleration
GravityAcc: gravitational acceleration
Jerk: the jerk on the respective acceleration
Gyro: gyroscope signal
Mag: magnitude of 3d signal
XYZ: the direction of the acceleration
t: time-domain signal
f: frequency domain, calculate from a Fast Fourier Transform (FFT) of time domain data
mean, std: whether or not the value is the average mean or standard deviation
For example, the variable name "fBodyAccJerkX" is the jerk of the body acceleration measured by accelerometer in the X direction in the frequency domain ### Variables used in data processing script
samsungurl: url to download raw data from (string)
activitylbls: raw data activity labels (6x2)
features: raw data features list (561x2)
subj.test: subject numbers for test data (29741x1)
subj.train: subject numbers for training data (7352x1)
x.test: values for each features for test data (2947x561)
y.test: activities for each measurement in x.test (2947x1)
x.train: values for each features for train data (7352x561)
y.train: activities for each measurement in x.train (7352x1)
meanstd: index for features that are either a mean or standard deviation of one of the measurements
x.tot: values for combined test and training data set (10299x66)
y.tot: activities for combined test and training data set (10299x1)
subj.tot: subjects for combined test and training data set (10299x1)
subjects: unique list of subjects, numbered 1-30 (30x1)
activities: the indicies for the activities used in "y" variables (6x1)
actlen: length of "activities"" (6x1)
subjlen: length of "subjects" (30x1)
results: array to store average mean and std for each subject and activity (180x66)
ind: temporary index used to identify rows of X.tot with a certain subject and activity level
subjfin: final subject column (180x1)
actfin: final activity indices (180x1)
lblfin: final labels for activities for tidy data set (180x1)
varnames: tidy variable names
df: data frame containing final table to be written to tidy data file
