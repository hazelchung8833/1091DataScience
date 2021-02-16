# read parameters
args = commandArgs(trailingOnly=TRUE)

# parse parameters
i<-1 
while(i < length(args))
{
  if(args[i] == "--fold"){
    k_fold<-args[i+1]
    i<-i+1
  }else if(args[i] == "--train"){
    train_file<-args[i+1]
    i<-i+1
  }else if(args[i] == "--report"){
    report_file<-args[i+1]
    i<-i+1
  }else{
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i<-i+1
}

require(e1071) # for svm
library(randomForest)

# Read train data
d <- read.csv(train_file, header = TRUE)

d <- d[,-c(1,3,4,5,6,7,8)]

set.seed(500)

library(caret)
folds <- createFolds(d$lab, k = strtoi(k_fold), list = T, returnTrain =F)

set <- c()
training_acc <- c()
test_acc <- c()
best_model_acc <- 0 # Test
for(i in 1:k_fold){
  print(paste("k_fold", i))
  test_set <- d[folds[[i]],]
  train_set <- d[-folds[[i]],]
  
  tmp_model = randomForest(
    formula = as.factor(lab) ~ .,
    data    = train_set
  )
  
  train_results <- confusionMatrix(table(pred=predict(tmp_model, train_set, type="class"), train_set$lab))
  
  test_results <- confusionMatrix(table(pred=predict(tmp_model, test_set, type="class"), test_set$lab))
  
  set <- c(set, paste("fold", i, sep=""))
  training_acc <- c(training_acc, round(train_results$overall[['Accuracy']] , digits = 2))
  test_acc <- c(test_acc, round(test_results$overall[['Accuracy']], digits = 2))
  
  if(train_results$overall[['Accuracy']] > best_model_acc){
    best_model_acc <- train_results$overall[['Accuracy']]
    model <- tmp_model
  }
}

set <- c(set, "ave.")
training_acc <- c(training_acc, round(mean(training_acc), digits = 2))
test_acc <- c(test_acc, round(mean(test_acc), digits = 2))

out_data<-data.frame(set = set, training = training_acc, test = test_acc, stringsAsFactors = F)
print(out_data)

write.csv(out_data, file=report_file, row.names = F, quote = F)

# Print best model f1 score
data_results <- confusionMatrix(table(pred=predict(model, d, type="class"), d$lab))
print("Confusion Matrix")
print(table(pred=predict(model, d, type="class"), d$lab))
print("Precision")
print(data_results[["byClass"]][ , "Precision"])
print("Recall")
print(data_results[["byClass"]][ , "Recall"])
print("F1 score")
print(data_results[["byClass"]][ , "F1"])