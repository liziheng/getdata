#start by setting working directory
setwd("~/datascispec/getdata/project")
# check if Samsung zip file exists;
# if not, download the file and read in the data
samsungurl <- "https://d396qusza40orc.cloudfront.net/
getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
if (!file.exists("samsung.zip")){
  download.file(samsungurl, destfile="samsung.zip", method="curl")
  unzip("samsung.zip")
}
# read in activity labels, features, subject data, and x and y data
activitylbls <- read.table("UCI\ HAR\ Dataset/activity_labels.txt")
features <- read.table("UCI\ HAR\ Dataset/features.txt")
subj.test <- read.table("UCI\ HAR\ Dataset//test/subject_test.txt")
subj.train <- read.table("UCI\ HAR\ Dataset//train/subject_train.txt")
x.test <- read.table("UCI\ HAR\ Dataset//test/X_test.txt")
y.test <- read.table("UCI\ HAR\ Dataset//test/Y_test.txt")
x.train <- read.table("UCI\ HAR\ Dataset//train/X_train.txt")
y.train <- read.table("UCI\ HAR\ Dataset//train/Y_train.txt")
# only use the features that are the mean and standard deviation 
# of the variables measured
meanstd <- grep("std\\()|mean\\()", features[,2], ignore.case=TRUE)
# merge test and train data sets together using rbind
x.tot <- rbind(x.test[,meanstd], x.train[,meanstd])
y.tot <- rbind(y.test, y.train)
subj.tot <- rbind(subj.test, subj.train)
#
# assign new vectors for unique subjects and each activity level
subjects <- unique(subj.tot)$V1
activities <- activitylbls$V1
actlen <- length(activities)
subjlen <- length(subjects)
# initialize array for storing average mean and standard deviations 
#   for each subject and activity
results <- array(0, dim=c(subjlen*actlen, length(meanstd)))

# loop through variables to calculate mean and sd of, and number of subjects
# and activities
for (k in 1:length(meanstd)){
  for (i in 1:subjlen) {
    for (j in 1:actlen){
      ind <- which( (subj.tot==i) & (y.tot==j))
      results[(i-1)*actlen+j,k] <- mean(x.tot[ind, k])
    }
  }
}
# the final output will have 180 rows, one for each subject/activity pair, so I 
# need to use "rep" function to create the 180-length columns for the 
# subjects and acitivites
subjfin <- rep(1:30, each=6)
actfin <- rep(1:6, 30)
# create labels for tidy data set
lblfin <- c("walk", "walkup", "walkdown", "sitting", "standing", "laying")
# clean up the variable names: remove parantheses and hyphens
varnames <- gsub("[\\(\\)-]", "", features$V2[meanstd])
# there are some variable names with "BodyBody" which should just by "Body"
varnames <- gsub("BodyBody", "Body", varnames)
# create data frame with subjects, acitivity labels, means and std. deviations
df <- data.frame(subjfin, lblfin[actfin], results)
# change the names in the data frame to the tidy versions
names(df) <- c("Subject", "Activity", varnames)
# write output to a tab-delimited file
write.table(df, "Data Mean Std Avg.txt")
