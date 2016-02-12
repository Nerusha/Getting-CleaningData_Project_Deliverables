library(reshape2)

filename <- "C:/getdata_dataset.zip"

#Download files and unzip them

if (!file.exists(filename)){
fileURL <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00341/HAPT%20Data%20Set.zip"
download.file(fileURL, destfile = filename, method = "curl")
}
if(!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

# Load activity labels + features
activityLbl <- read.table("C:/UCI HAR Dataset/activity_labels.txt")
activityLbl[,2] <- as.character(activityLbl[,2])

features <- read.table("C:/UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2]) ##isolate the 2nd column


# Isolate and Extract only the data on mean and standard deviation
Requiredfeatures <- grep(".*mean.*|.*std.*", features[,2]) ##search for the string criteria mean or std in the subset of data
Requiredfeatures.names <- features[Requiredfeatures,2] ##isolate only the rows with the required feature names
Requiredfeatures.names = gsub('-mean', 'Mean', Requiredfeatures.names) ## substitute -mean for Mean
Requiredfeatures.names = gsub('-std', 'Std', Requiredfeatures.names) ## substitute -std for Std
Requiredfeatures.names <- gsub('[-()]', '', Requiredfeatures.names)

#Read datasets into R

#Tr = Train -> referenced dataset
Tr1 <- read.table("C:/UCI HAR Dataset/train/X_train.txt") [Requiredfeatures]
TrAct <- read.table("C:/UCI HAR Dataset/train/Y_train.txt")
TrSub <- read.table("C:/UCI HAR Dataset/train/subject_train.txt")

Tr = cbind(Tr1,TrAct,TrSub)

#Tt = Test -> referenced dataset
Tt1 <- read.table("C:/UCI HAR Dataset/test/X_test.txt") [Requiredfeatures]
TtAct <- read.table("C:/UCI HAR Dataset/test/Y_test.txt")
TtSub <- read.table("C:/UCI HAR Dataset/test/subject_test.txt")

Tt = cbind(Tt1,TtAct,TtSub)

# merge datasets and then add the labels to the dataset
dataset <- rbind(Tr, Tt)
colnames(dataset) <- c("Subject", "Activity", Requiredfeatures.names)

# Convert the activities & subjects data into factors
dataset$Activity <- factor(dataset$Activity, levels = activityLabels[,1], labels = activityLabels[,2])
dataset$Subject <- as.factor(dataset$Subject)

# Melt data to get the Mean variables by subject and activity
dataset.melted <- melt(dataset, id = c("Subject", "Activity"))
dataset.mean <- dcast(dataset.melted, Subject + Activity ~ variable, mean)

# Write tidy dataset to new flat file
write.table(dataset.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
