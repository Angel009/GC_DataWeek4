library(data.table)
#--------------------------------------------------------
#It is asummed that the working directory was already set
#--------------------------------------------------------

#Download and unzip required data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file( url, destfile = "data.zip" )
unzip("data.zip")

#As the files have the words 'train' and 'test'. It is possible
#to use that as a type of 'filter' to divide the whole data in two parts.

f_train <- list.files( "train", full.names = TRUE )[-1]
f_test  <- list.files( "test" , full.names = TRUE )[-1]

#Read the files using the keywords defined before 
file <- c( f_train, f_test )
data <- lapply( file, read.table, stringsAsFactors = FALSE, header = FALSE )


#######################################################################
#STEP 1 : Merges the training and the test sets to create one data set
# rbind test and train data by variable
merged_data <- mapply ( rbind, data[ c(1:3) ], data[ c(4:6) ] )
# complete_data: the whole single dataset
complete_data <- do.call( cbind, merged_data )
#----------------------------------------------------------------------

#######################################################################
#STEP 2 : For the feature column, extracts only the measurements on the 
# mean and standard deviation for each measurement
# match it using features.txt(second file in list.file() )
# featurename is in the second column(V2)
featurenames <- fread( list.files()[2], header = FALSE, stringsAsFactors = FALSE )
#----------------------------------------------------------------------


# Extract only the column that have mean() or std() in the end
# Add 1 to it because the first column in complete_data is not a 'feature'
# Each backslash must be expressed as \\
measurements <- grep( "std|mean\\(\\)", featurenames$V2 ) + 1

# m_sd_data : contains only the mean and standard deviation for feature column 
m_sd_data <- complete_data[, c( 1, measurements, 563 ) ]
#----------------------------------------------------------------------

#######################################################################
#STEP 3 : Use descriptive activity names to name the activities in the data set
# match it using activity_labels.txt(first file in list.file() )
activitynames <- fread( list.files()[1], header = FALSE, stringsAsFactor = FALSE )
m_sd_data$activity <- activitynames$V2[ match( m_sd_data$activity, activitynames$V1 ) ]
#-----------------------------------------------------------------------------

#######################################################################
#STEP 4 : Appropriately labels the data set with descriptive variable names.
setnames( complete_data, c(1:563), c( "subject", featurenames$V2, "activity" ) )

#######################################################################
#STEP 5 : From the data set in step 4, creates a second, independent tidy data set, 
# with the average of each variable for each activity and each subject.
clean_data <- aggregate( . ~ subject + activity, data = m_sd_data, FUN = mean )
#-----------------------------------------------------------------------

#write out clean_data
write.table( clean_data, "tidy_data.txt", row.names = FALSE )
