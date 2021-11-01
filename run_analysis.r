require(dplyr)
require(tidyr)

setwd('C:/Users/Steven/Documents/R/Data Science Class/UCI HAR Dataset')

# *** Load and modify variable names ***
  var_names <- read.table('features.txt', header = F)
  var_namesClean <- gsub('(-[a-z])', '\\U\\1', var_names[,2], perl = T)
  var_namesClean <- gsub(',', 'to', var_namesClean)
  var_namesClean <- gsub('[^[:alnum:]]', '', var_namesClean)

 
    activity <- read.table('activity_labels.txt', header = F)
    names(activity) <- c('labels', 'activity')
    
   

# *** Load Test Data Sets ***
  subjectTest <- read.table('./test/subject_test.txt', header = F)
  xTest <- read.table('./test/x_test.txt', header = F)
  #xTest <- as_tibble(xTest)
  yTest <- read.table('./test/y_test.txt', header = F)
  
  # *** Merge Test Data ***
    names(xTest) <- var_namesClean
    xTest$subject <- subjectTest[,1]
    xTest$labels <- yTest[,1]
    xTest$testOrTrain <- 'test'

  
# *** Load Training Data Sets ***
  subjectTrain <- read.table('./train/subject_train.txt', header = F)
  xTrain <- read.table('./train/x_train.txt', header = F)
  #xTrain <- as_tibble(xTrain)
  yTrain <- read.table('./train/y_train.txt', header = F)
  
  # *** Merge Train Data ***
    names(xTrain) <- var_namesClean
    xTrain$subject <- subjectTrain[,1]
    xTrain$labels <- yTrain[,1]
    xTrain$testOrTrain <- 'train'
    
    
# *** Merge Test and Train Data ***
  #  rownames(xTrain) <- rownames(xTest) <- NULL
  
  trainRow <- nrow(xTrain)
  testRow <- nrow(xTest)
  allData <- xTrain
  allData[(trainRow + 1):(trainRow + testRow), ] <- xTest
  
# *** rename activity labels ***
  allData <- merge(allData, activity, by = 'labels')
  #allData <- full_join(activity, allData, by = 'labels')
  
# *** Extract mean and std columns and summarize by subject and activity***
  meanStd <- allData %>% 
    select(subject, testOrTrain, activity, contains('mean'), contains('std')) %>%
    gather(measure, value, -subject, -testOrTrain, -activity) %>%
    group_by(subject, activity) %>%
    summarize(average = mean(value))
  
