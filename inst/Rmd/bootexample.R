# Bootstrap 95% CI for R-Squared
library(boot)
# function to obtain R-Squared from the data
rsq <- function( data, indices,formula) {
  d <- data[indices,] # allows boot to select sample
  fit <- lm(formula, data=d)
  return(summary(fit)$r.square)
}



# bootstrapping with 1000 replications
result <- boot(data=mtcars, statistic=rsq,
               R=1000, formula=mpg~wt+disp)

indices_all <- 1:nrow(dfnew)
indices <- sample(indices_all, size = nrow(dfnew), replace = TRUE)
boot_sample <- dfnew[indices, ]



lapply(1:10, function(num, aa) {
  print(paste0(num, aa, '\n'))
}, aa = 'a')

# view results
result
plot(result)


ro <- function( data, indices,formula) {
  d <- data[indices,] # allows boot to select sample
  auv <- roc(formula, data=d)$auc
}

result1 <- boot(data=dfnew, statistic=ro,
                R=1000, formula=Exposed~wvELISA)

###################################
df_id <- unique(dfnew$Pig.ID)
compute_auc <- function(data, indices, formula, data_all) {
  # id from bootstrap sampling
  selected_id <- data[indices]

  boot_data_list <- lapply(selected_id, function(id) {
    data_all[data_all$Pig.ID == id , ]
  })

  # get all data with selected id
  boot_data <- do.call(rbind, boot_data_list)

  return(roc(formula, data=boot_data)$auc)
}




set.seed(0702)
result_new <- boot(data=df_id, statistic=compute_auc,
                   R=1000, formula=y~wvELISA, data_all=dfnew)
quantile(result_new$t[,1], c(0.025, 0.975))







result_new_ifa <- boot(data=df_id, statistic=compute_auc,
                       R=2000, formula=y~IFA, data_all=dfnew)
quantile(result_new_ifa$t[,1], c(0.025, 0.975))

result_new_svn <- boot(data=df_id, statistic=compute_auc,
                       R=2000, formula=y~VNResult, data_all=dfnew)
quantile(result_new_svn$t[,1], c(0.025, 0.975))
######################################

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

auc_compare_elisa_ifa <- boot(data=pig_id, statistic=compare_auc,
                              R=200, data_all= dfnew,
                              formula1=y~wvELISA, formula2 = y~IFA)
quantile(auc_compare_elisa_ifa$t[,1], c(0.025, 0.975))
xx <- auc_compare_elisa_ifa$t[,1]
t.test(xx)

(1 - pt( (mean(xx) - 0) / sd(xx), df = 199)) * 2


(1 - pnorm( (mean(xx) - 0) / sd(xx))) * 2
(1 - pnorm( (mean(xx) - 0) / sd(xx)))
##################################

auc_compare_elisa_svn <- boot(data=df_id, statistic=compare_auc,
                              R=200, data_all= dfnew,
                              formula1=y~wvELISA, formula2 = y~VNResult)
quantile(auc_compare_elisa_svn$t[,1], c(0.025, 0.975))
xx <- auc_compare_elisa_svn$t[,1]
t.test(xx)

(1 - pt( (mean(xx) - 0) / sd(xx), df = 199)) * 2
(1 - pnorm( (mean(xx) - 0) / sd(xx))) * 2
(1 - pnorm( (mean(xx) - 0) / sd(xx)))

#######

auc_compare_ifa_svn <- boot(data=pig_id, statistic=compare_auc,
                              R=200, data_all= dfnew,
                              formula1=y~IFA, formula2 = y~VNResult)
quantile(auc_compare_ifa_svn$t[,1], c(0.025, 0.975))
xx <- auc_compare_ifa_svn$t[,1]
t.test(xx)

(1 - pt( (mean(xx) - 0) / sd(xx), df = 199)) * 2
(1 - pnorm( (mean(xx) - 0) / sd(xx))) * 2
(1 - pnorm( (mean(xx) - 0) / sd(xx)))

pnorm( (mean(xx) - 0) / sd(xx))



