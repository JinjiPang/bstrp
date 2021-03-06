STAT-Creative Component
================
Jinji(Kimki) Pang
2022-04-29

## 1.Explore the data using pROC package

### 1.1 read in data

``` r
dfroc<-read.csv("../data/ROC.csv")

dfnew<-dfroc%>%
  mutate(
    y=ifelse(Exposed=="NEG", "0","1")
  )
```

### 1.2 calculate roc and visualization for all three assays

``` r
## ROC curves for wvELISA, IFA and SVN
rocall<-roc(Exposed~wvELISA+IFA+VNResult,data=dfroc)
plot1<-ggroc(rocall)
plot1
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="80%" />

### 1.3 calculate AUC seperately using pROC package

``` r
## ROC curves for wvELISA
roc1<-roc(Exposed~wvELISA,data=dfnew)
## ROC curves for IFA 
roc2<-roc(Exposed~IFA,data=dfnew)
## ROC curves forSVN
roc3<-roc(Exposed~VNResult,data=dfnew)

##calculate AUC and 95% CI
CI<-c(ci.auc(roc1),ci.auc(roc2),ci.auc(roc3))
CI<-matrix(CI, nrow = 3, byrow=T)

AUC<-data.frame(CI[,2],CI[,1],CI[,3])
rownames(AUC)<-c("wvELISA","IFA","SVN")

AUC<-AUC%>%knitr::kable(caption="95% CI of AUC ", col.names = c("AUC","Lowwer","Upper"))
print(AUC)
#> 
#> 
#> Table: 95% CI of AUC 
#> 
#> |        |       AUC|    Lowwer|     Upper|
#> |:-------|---------:|---------:|---------:|
#> |wvELISA | 0.9580145| 0.9366256| 0.9794033|
#> |IFA     | 0.9285859| 0.9031649| 0.9540069|
#> |SVN     | 0.9487179| 0.9273719| 0.9700640|
```

### 1.4 pair-wise ROC test (test difference in AUC) using pROC package

``` r
## wv_ELISA vs IFA
roc.test(roc1, roc2, method="bootstrap", boot.n=10000)
#> 
#>  Bootstrap test for two correlated ROC curves
#> 
#> data:  roc1 and roc2
#> D = 2.7175, boot.n = 10000, boot.stratified = 1, p-value = 0.006578
#> alternative hypothesis: true difference in AUC is not equal to 0
#> sample estimates:
#> AUC of roc1 AUC of roc2 
#>   0.9580145   0.9283437
## wv_ELISA vs SVN
roc.test(roc1, roc3, method="bootstrap", boot.n=10000)
#> 
#>  Bootstrap test for two correlated ROC curves
#> 
#> data:  roc1 and roc3
#> D = 0.92538, boot.n = 10000, boot.stratified = 1, p-value = 0.3548
#> alternative hypothesis: true difference in AUC is not equal to 0
#> sample estimates:
#> AUC of roc1 AUC of roc2 
#>   0.9577991   0.9487179
## IFA vs SVN
roc.test(roc2, roc3, method="bootstrap", boot.n=10000)
#> 
#>  Bootstrap test for two correlated ROC curves
#> 
#> data:  roc2 and roc3
#> D = -2.0365, boot.n = 10000, boot.stratified = 1, p-value = 0.0417
#> alternative hypothesis: true difference in AUC is not equal to 0
#> sample estimates:
#> AUC of roc1 AUC of roc2 
#>   0.9282197   0.9487179
```

## 2.Explore the data while considering the repeated measures data structure

### 2.1 calculate AUC seperatly using bootstrap methods (boot and pROC packages)

``` r
set.seed(0702)
## get the unique Pig ID
pig_id <- unique(dfnew$Pig.ID)

## function for compute the bootstrap statistics AUC
compute_auc <- function(data, indices, formula, data_all) {
  # id from bootstrap sampling
  selected_id <- data[indices]
  # 
  boot_data_list <- lapply(selected_id, function(id) {
    data_all[data_all$Pig.ID == id , ]
  })

  # get all data with selected id
  boot_data <- do.call(rbind, boot_data_list)

  return(roc(formula, data=boot_data)$auc)
}


#### compute AUC for wvELISA
result_elisa <- boot(data=pig_id, statistic=compute_auc,
                   R=2000, formula=y~wvELISA, data_all=dfnew)
#### compute AUC for  IFA
result_ifa <- boot(data=pig_id, statistic=compute_auc,
                       R=2000, formula=y~IFA, data_all=dfnew)
#### compute AUC for SVN
result_svn <- boot(data=pig_id, statistic=compute_auc,
                       R=2000, formula=y~VNResult, data_all=dfnew)



wvELISA<-quantile(result_elisa$t[,1], c(0.5,0.025, 0.975))
IFA<-quantile(result_ifa$t[,1], c(0.5, 0.025, 0.975))
SVN<-quantile(result_svn$t[,1], c(0.5, 0.025, 0.975))

df<-data.frame(wvELISA,IFA,SVN)
rownames(df)<-c("AUC","Lower","Upper")
print(df)
#>         wvELISA       IFA       SVN
#> AUC   0.9580586 0.9288856 0.9485294
#> Lower 0.9352018 0.8980231 0.9252513
#> Upper 0.9764221 0.9537447 0.9695431
```

#### 2.2. pair-wise test (test difference in AUC) using boot and pROC packages

``` r
## function for compute the bootstrap statistics AUC difference
compare_auc <- function(data, indices, data_all, formula1, formula2) {
  # id from bootstrap sampling
  selected_id <- data[indices]

  boot_data_list <- lapply(selected_id, function(id) {
    data_all[data_all$Pig.ID == id , ]
  })

  # get all data with selected id
  boot_data <- do.call(rbind, boot_data_list)

  auc1 <- roc(formula1, data=boot_data)$auc
  auc2 <- roc(formula2, data=boot_data)$auc

  return(auc1 - auc2)
}

#### compute AUC difference for wvELISA and IFA
auc_compare_elisa_ifa <- boot(data=pig_id, statistic=compare_auc,
                              R=2000, data_all= dfnew,
                              formula1=y~wvELISA, formula2 = y~IFA)

quantile(auc_compare_elisa_ifa$t[,1], c(0.025, 0.975))
#>        2.5%       97.5% 
#> 0.004511347 0.057554813

diff1 <- auc_compare_elisa_ifa$t[,1]

ELISA_IFA_pvalue= (1 - pt( (mean(diff1) - 0)/sd(diff1), df = 1999)) * 2


#### compute AUC difference for wvELISA and SVN
auc_compare_elisa_svn <- boot(data=pig_id, statistic=compare_auc,
                              R=2000, data_all= dfnew,
                              formula1=y~wvELISA, formula2 = y~VNResult)

quantile(auc_compare_elisa_svn$t[,1], c(0.025, 0.975))
#>        2.5%       97.5% 
#> -0.01079228  0.03098910

diff2 <- auc_compare_elisa_svn$t[,1]

ELISA_SVN_pvalue = (1 - pt( (mean(diff2) - 0)/ sd(diff2), df = 1999)) * 2


#### compute AUC difference for IFA and SVN
auc_compare_ifa_svn <- boot(data=pig_id, statistic=compare_auc,
                              R=2000, data_all= dfnew,
                              formula1=y~IFA, formula2 = y~VNResult)

quantile(auc_compare_ifa_svn$t[,1], c(0.025, 0.975))
#>         2.5%        97.5% 
#> -0.043256609  0.001338373

diff3 <- auc_compare_ifa_svn$t[,1]

##note that on average, IFA's AUC < SVN's AUC
IFA_SVN_pvalue = (pt((mean(diff3) - 0)/ sd(diff3), df = 1999)) * 2

df<-data.frame(ELISA_IFA_pvalue, ELISA_SVN_pvalue,IFA_SVN_pvalue)

print(df)
#>   ELISA_IFA_pvalue ELISA_SVN_pvalue IFA_SVN_pvalue
#> 1        0.0335318         0.379269     0.06916851
```
