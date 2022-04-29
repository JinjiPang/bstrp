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

p2<-ggroc(r1)

p2
##get the threshold and corresponding TPR and TNR of wvELISA

dfroc%>%roc(Exposed, wvELISA)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.8,specificity>0.75)


##get the threshold and corresponding TPR and TNR of IFA

dfroc%>%roc(Exposed,IFA)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.65,specificity>0.9)


##get the threshold and corresponding TPR and TNR of SVN

dfroc%>%roc(Exposed,VNResult)%>%coords(transpose=FALSE)%>%
  filter(sensitivity>0.65,specificity>0.9)

coords(r1)
coords(roc1)
ci(r1)
ci(r2)
ci(r3)

ci.auc(r1)
ci.auc(r2)
ci.auc(r3)

sens.ci <- ci.se(r1, specificities=seq(0, 1, 0.1))
plot(sens.ci, type="shape", col="lightblue")
plot(sens.ci, type="bars")


# Diference in AUC between assay results and confdence intervals for sensitivities and
# specifcities for selected cutof values were evaluated using bootstrap methods which considers
# the repeated measures data structure.

##

# Increase boot.n for a more precise p-value:
roc.test(r1, r2, method="bootstrap", boot.n=10000)

# wvELISA was significantly different with IFA, in the paper p-value=0.0318,here it it 0.005662

# Bootstrap test for two correlated ROC curves
#
# data:  r1 and r2
# D = 2.7668, boot.n = 10000, boot.stratified = 1, p-value = 0.005662
# alternative hypothesis: true difference in AUC is not equal to 0
# sample estimates:
#   AUC of roc1 AUC of roc2
# 0.9580145   0.9283437


# wvELISA vs SVN
roc.test(r1, r3, method="bootstrap", boot.n=10000)

# no significant difference
# data:  r1 and r3
# D = 0.91209, boot.n = 10000, boot.stratified = 1, p-value = 0.3617
# alternative hypothesis: true difference in AUC is not equal to 0
# sample estimates:
#   AUC of roc1 AUC of roc2
# 0.9577991   0.9487179


# IFA vs SVN

roc.test(r2, r3, method="bootstrap", boot.n=10000)

## this in the paper is not significant, but here is significant
# data:  r2 and r3
# D = -2.0605, boot.n = 10000, boot.stratified = 1, p-value = 0.03935
# alternative hypothesis: true difference in AUC is not equal to 0
# sample estimates:
#   AUC of roc1 AUC of roc2
# 0.9282197   0.9487179


dfnew<-dfroc%>%
  mutate(
    y=ifelse(Exposed=="NEG", "0","1")
  )



m1<-lm(y~wvELISA,data=dfnew)
summary(m1)


m2<-lm(y~IFA,data=dfnew)
summary(m2)



m3<-lm(y~VNResult,data=dfnew)
summary(m3)

##SVN and IFA highest correlated, IFA and wv-ELISA strong correlated,
#SVN and wv-ELISA moderate correlated


lm1 <- lm(VNResult~IFA, data = df)
lm2 <- lm(IFA~VNResult, data = subset(dfnew, dfnew$Exposed == "POS"))

with(subset(dfnew, dfnew$Exposed == "POS"), { cor(IFA,VNResult, use="pairwise") })

df<-dfnew %>% filter(IFA > log(40, 2), Exposed == "POS")
  # { cor(.$IFA, .$VNResult, use = "pairwise")}
  {  }

 dfnew %>% filter(wvELISA>0.1,Exposed == "POS") %>%
  { cor(.$VNResult, .$wvELISA, use = "pairwise")}


summary(lm1)


sqrt(0.8325)












