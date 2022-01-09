library(targets)

# Define custom functions and other global objects.
source("R/functions.R")

# Set target-specific options such as packages.
targets::tar_option_set(packages =
                          c("tidyverse",
                            "lmtp" ))


list(
  tar_target(data_file,
             'data/test_data.dta',
             format = 'file')
  ,

  tar_target(r_data,
             haven::read_dta(data_file),
             format = 'rds')

  ,

  tar_target(working_df,
             r_data %>% mutate(y= rbinom(n=nrow(.),size=1, prob = 0.30)))








)
