
rm(list=ls())
library(INLA)
inputData <- read.csv('Immunity_Type1.csv', stringsAsFactors=FALSE)

inputData$NObserved = ifelse(inputData$NObserved<1,1,inputData$NObserved)




######################
# INLA Model
######################


# - takes about 2min - unstructured space time interaction (iid) - #
smoothing.model1 <- ExpectedImmunity ~ f(L1Index, model="iid") + f(TimeIndex, model="rw1", replicate=L1Index) + 
  f(L2Index, model="iid") + f(TimeIndex2, model="iid", replicate=L2Index)


############
# RUN MODEL
############

print(temp <- Sys.time())
output1 <- inla(smoothing.model1, data=inputData, family="gaussian", scale=sqrt(NObserved),
               control.predictor = list(compute = T, link = 1),# verbose = T, 
               control.inla = list(int.strategy = "eb"))
print(diff <- Sys.time() - temp)

print(temp <- Sys.time())
output2 <- inla(smoothing.model1, data=inputData, family="gaussian", scale=NObserved,
               control.predictor = list(compute = T, link = 1),# verbose = T, 
               control.inla = list(int.strategy = "eb"))
print(diff <- Sys.time() - temp)


# -- smoothed immunity -- #
outputData <- inputData

outputData$SmoothedImmunity1<-output1$summary.fitted.values$mean
outputData$SmoothedImmunity2<-output2$summary.fitted.values$mean

#with(outputData,plot(ExpectedImmunity,SmoothedImmunity1,
#                xlab="Observed",ylab="Smoothed"))
#abline(0,1,lty=3)

write.csv(outputData, file='Immunity_Type1_smoothed.csv', row.names=FALSE)
