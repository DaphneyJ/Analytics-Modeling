###### Q3.1A ######
#Clear environment 
rm(list=ls())

#Load package 
library(kknn)

#Set working directory
setwd("C:/Users/jacqu/OneDrive/Desktop/RYouWithMe/hw1")

#Read data
data <- read.table("credit_card_data-headers.txt", header = TRUE)

#check data 
head(data)
tail(data)

#Set seeds
set.seed(1) 

#Set kmax
kmax <- 25

#Run the model and use train.kknn for leave-one-out cross validation
model <- train.kknn(R1~A1+A2+A3+A8+A9+A10+A11+A12+A14+A15, data, kmax = kmax, scale = TRUE)

accuracy_percent <- rep(0, kmax)

for (k in 1: kmax){
  predicted <- as.integer(fitted(model)[[k]][1: nrow(data)] + 0.5) 
  accuracy_percent[k] <- sum(predicted == data$R1)/ nrow(data) * 100
}
accuracy_percent
max(accuracy_percent)
#Found that the lowest values of k (k<5) had the lowest percentage, therefore the worst choice. 
#12, 15, 16, and 17 had the highest accuracy percentage at 85.3211%.


##### Q3.1B ######
#Clear environment 
rm(list=ls())

#Load package 
library(kknn)

#Read data
data <- read.table("credit_card_data-headers.txt", header = TRUE)

#Set seeds, random number generator so results are reproducible
set.seed(1)

#split the data using 70% for training
#sample function randomly selects 70% of the data points 
random_1 = sample(1:nrow(data), as.integer(0.7*nrow(data)))

#Assign the training data set to 70% of the data
train_set = data[random_1,]

#Assign the remaining 30% of the data to random set 
remaining_data = data[-random_1,]

#split in half the remaining data and generate a randomized sample
random_2 = sample(1:nrow(remaining_data), as.integer(0.5*nrow(remaining_data)))

#Assign half of the remaining data to validation set
validation_set = remaining_data[random_2,]

#Assign the other half to the test set
test_set = remaining_data[-random_2,]

#Check the data 
head(train_set)
head(validation_set)
head(test_set)

#Check # of rows in each data set to confirm split amount
nrow(train_set)
nrow(validation_set)
nrow(test_set)

#test & build kknn models on training set
predicted_train = rep(0,(nrow(train_set)))
train_accuracy = 0
X = 0

accuracy = data.frame(matrix(nrow = 25, ncol = 2))

for (X in 1:25){
  for (i in 1: nrow(train_set)){
    model = kknn(R1~A1+A2+A3+A8+A9+A10+A11+A12+A14+A15, train_set[-i,], train_set[i,], k = X, scale = TRUE)
    predicted_train[i] = as.integer(fitted(model)+0.5)
  }
#calculate fraction of correct predictions 
  train_accuracy = sum(predicted_train == train_set[,11]) / nrow(train_set)
  accuracy[X, 1] = X
  accuracy[X, 2] = train_accuracy
  }

#add titles to the accuracy table
colnames(accuracy) = c("k","accuracy")
accuracy 

#plot accuracy table and adjust margin to fit
par(mar= c(2,2,2,2))
plot(accuracy[,1],accuracy[,2])
#12 is the best fit for the training data. K values of 13-15 also performed well.

#Testing different models 
predicted_validate = rep(0,(nrow(validation_set)))
validate_accuracy = 0
X = 0

#Accuracy 
accuracy_validate_table = data.frame(matrix(nrow =4, ncol = 2))
counter = 0

for (X in 12:15){
  counter = counter +1 
  for (i in 1: nrow(validation_set)){
    model = kknn(R1~A1+A2+A3+A8+A9+A10+A11+A12+A14+A15, validation_set[-i,], validation_set[i,], k = X, scale = TRUE)
    predicted_validate[i] = as.integer(fitted(model)+0.5)
  }
  #calculate fraction of correct predictions 
  validate_accuracy = sum(predicted_validate == validation_set[,11]) / nrow(validation_set)
  accuracy_validate_table[counter, 1] = X
  accuracy_validate_table[counter, 2] = train_accuracy
}

#Create table for k values and corresponding accuracy
colnames(accuracy_validate_table) = c('k', 'validate_accuracy')
accuracy_validate_table
##the output shows the 4 models perform the same at 83.8%

#Testing accuracy on test data 
predicted_test = rep(0,(nrow(test_set)))
test_accuracy = 0

for (i in 1: nrow(test_set)){
  model = kknn(R1~A1+A2+A3+A8+A9+A10+A11+A12+A14+A15, test_set[-i,], test_set[i,], k = 12, scale = TRUE)
  predicted_test[i] = as.integer(fitted(model)+0.5)
}
#calculate fraction of correct predictions 
test_accuracy = sum(predicted_test == test_set[,11]) / nrow(test_set)
test_accuracy
#The actual accuracy turned out to be 77% which is lower than the accuracy tested on the training data set
#This is likely due to random effects in the training data.


##### Q4.2 #####
#Clear environment 
rm(list=ls())

#Read in the data
data <- read.table("iris.data", header = FALSE, sep = ",")

#name the columns according to the isris.names data file
v1 <- c("sepal.length", "sepal.width", "petal.length", "petal.width", "class")
colnames(data) <- v1

#check features to make sure they return the same values in the iris.names summary 
min(data$"sepal.length")
max(data$"petal.width")
head(data)

#check how many of each species there are  
table(data$class)

#Find number of unique results which form a cluster
numClusters <- length(unique(data$class))
numClusters

library(ggplot2)
ggplot(data, aes(petal.length, petal.width, color = class)) + geom_point()
ggplot(data, aes(sepal.length, sepal.width, color = class)) + geom_point()

#load package
library(factoextra)

#Remove column 5 which contains the class
data2 <- data[,1:4]

#use this function to evaluate and find the best number of clusters to test
plot <- fviz_nbclust(data2, kmeans, method ="wss")
plot

#test the k values that performed the best k = 2,3,4,5
#nstart=20 to ensure at least 20 random sets are chosen
cluster2 <- kmeans(data2, centers = 2, nstart=20)
cluster3 <- kmeans(data2, centers = 3, nstart=20)
cluster4 <- kmeans(data2, centers = 4, nstart=20)
cluster5 <- kmeans(data2, centers = 5, nstart=20)

#compare the clusters with the different classes 
chart2 <- table(cluster2$cluster, data$class)
chart3 <- table(cluster3$cluster, data$class)
chart4 <- table(cluster4$cluster, data$class)
chart5 <- table(cluster5$cluster, data$class)
chart2
chart3 #this model performed the best, all of species setosa was classified in one cluster. There were some overlapping for the species versicolor and virginica.
chart4
chart5

#plot each k value
ggplot(data, aes(petal.length, petal.width, color = cluster2$cluster)) + geom_point()
ggplot(data, aes(petal.length, petal.width, color = cluster3$cluster)) + geom_point()
ggplot(data, aes(petal.length, petal.width, color = cluster4$cluster)) + geom_point()
ggplot(data, aes(petal.length, petal.width, color = cluster5$cluster)) + geom_point()
#the graph shows that k=3 is the ideal number of clusters. Model 3 performed the best and we know that the actual number of classes, which is 3.

#scale data on sepal length and width
data_scaled <- scale(data2)
data_scaled <- data.frame(data_scaled, class = data$class)
ggplot(data, aes(sepal.length, sepal.width, color = class)) + geom_point()

