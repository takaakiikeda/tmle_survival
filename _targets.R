library(targets)

# Define custom functions and other global objects.
source("R/functions.R")

# Set target-specific options such as packages.
targets::tar_option_set(packages =
                          c("tidyverse",
                            "lmtp" ))

cat_vars <- c('L0_srh','L1_srh', 'W0_edu')
bi_vars <- c('W0_eth','W0_sex')

# check why income has - values??
# gen c2 = c1 ???

list(
  # prepare data----------------------------------------------------------------
  tar_target(data_file,
             'data/test_data.dta',
             format = 'file')
  ,

  tar_target(r_data,
             haven::read_dta(data_file),
             format = 'rds')

  ,

  tar_target(tmle_df,
             get_tmle_df(r_data,
                         cat_vars= c('L0_srh','L1_srh', 'W0_edu'),
                         make_dbl= c('W0_eth','W0_sex')),
             format = 'rds')
  ,

  # Set-up TMLE ----------------------------------------------------------------
  tar_target(a, c("A0_lbp", "A1_lbp"))
  ,
  tar_target(y, paste0("y", 1:2))
  ,
  tar_target(w, tmle_df %>% select(starts_with("W0")) %>% names())
  ,
  tar_target(l0, tmle_df %>% select(starts_with("L0")) %>% names())
  ,
  tar_target(l1, tmle_df %>% select(starts_with("L1")) %>% names())
  ,
  tar_target(tv, list(l0,l1))
  ,
  tar_target(cens, c("c1","c2"))
  ,
  tar_target(sl_lib, c("SL.glm","SL.xgboost", "SL.nnet"))
  ,

  tar_target(parms,
             list(trt = a,
                  outcome = y ,
                  baseline = w ,
                  time_vary=tv,
                  outcome_type = "survival",
                  cens = cens
                  # ,
                  # learners_outcome = sl_lib,
                  # learners_trt = sl_lib
             ))
  ,

  # Shift functions ------------------------------------------------------------

  # tar_target(d1,
  #            function(data, trt) {
  #              (data[[trt]]==1)*data[[trt]]+
  #                (data[[trt]]!=1)* 1})
  # ,
  # tar_target(d2,
  #            function(data, trt) {
  #              (data[[trt]]==2)*data[[trt]]+
  #                (data[[trt]]!=2)* 2})
  # ,
  # tar_target(d3,
  #            function(data, trt) {
  #              (data[[trt]]==3)*data[[trt]]+
  #                (data[[trt]]!=3)* 3})
  # ,
  # tar_target(d4,
  #            function(data, trt) {
  #              (data[[trt]]==4)*data[[trt]]+
  #                (data[[trt]]!=4)* 4})
  # ,

  # Run TMLE on nested mi_data--------------------------------------------------

  tar_target(tmle_observed,
            do.call( run_lmtp, c(parms, list(data= tmle_df))
                     ))
  # ,
  # tar_target(tmle_shift1,
  #            run_lmtp(parms, data= tmle_df, shift= d1))


)





