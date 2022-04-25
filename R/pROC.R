library(pROC)
library(dplyr)
library(ggplot2)

##Data for our Study
dfroc<-read.csv("inst/data/ROC.csv")


## ROC curves for wvELISA
rocs1<-roc(Exposed~wvELISA+IFA+VNResult,data=dfroc)
p1<-ggroc(rocs1)
p1



r1<-roc(Exposed~wvELISA,data=dfroc)
r2<-roc(Exposed~IFA,data=dfroc)
r3<-roc(Exposed~VNResult,data=dfroc)

##get the threshold and corresponding TPR and TNR of wvELISA

dfroc%>%roc(Exposed, wvELISA)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.8,specificity>0.75)


##get the threshold and corresponding TPR and TNR of IFA

dfroc%>%roc(Exposed,IFA)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.65,specificity>0.9)


##get the threshold and corresponding TPR and TNR of SVN

dfroc%>%roc(Exposed,VNResult)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.65,specificity>0.9)




var(r1)
var(r2)
var(r3)

plot(r1)

coords(r1)
ci(r1)
ci(r2)
ci(r3)


















