
get_tmle_df <- function(df, cat_vars, make_dbl){
  # to create dummies for categorical vars
  #to clean binary variables coded as 1 and 2
  base_vars <- df %>% dplyr::select(contains('0_'))  %>% names()
  follow_up_vars <- df %>% dplyr::select(contains('1_'))  %>% names()

  df %>%
    mutate(across(all_of(make_dbl), ~if_else(.==2,1,0))) %>%
    fastDummies::dummy_cols(all_of(cat_vars),
                            remove_first_dummy = T,
                            ignore_na = T ) %>%
    mutate_all(as.numeric) %>%
    dplyr::filter(
      across(
        all_of(
          starts_with(
            c("A0","W0", "L0"))), ~ !is.na(.))) %>%
    dplyr::mutate(
      across(
        -all_of(starts_with(
          c("A0","W0", "L0","c"))), ~ if_else(c1==0, -99, .))) %>%

    dplyr::filter(
      across(
        everything(), ~ !is.na(.))) %>%

    dplyr::mutate(
      across(
        everything(), ~ if_else(.==-99,NA_real_, .))) %>%

    dplyr::mutate(y0= 0,
                  y1= rbinom(n=nrow(.),size=1, prob = 0.10)
                  %>% as.numeric(),
                  y2= rbinom(n=nrow(.),size=1, prob = 0.20)
                  %>% as.numeric()) %>%
    dplyr::mutate(y1= if_else(c1==0, NA_real_, y1),
                  y2= if_else(c2==0, NA_real_, y2)) %>%
    lmtp::event_locf(paste0('y', 0:2)) %>%
    select(-any_of(cat_vars), -L1_age) %>%
    rename(W0_age= L0_age)

}




# ====================Function to run tmle estimator============================


run_lmtp <- function(data,
                     shift=NULL,
                     svy=FALSE,
                     wt_only=FALSE,
                     wt_var="",
                     ...){

  if (svy==TRUE){

    svy <- survey::svydesign(~psu, weights = data[[wt_var]], data = data)
    wt <- svy$prob
    psu <- svy$psu

    progressr::with_progress(
      m<-lmtp::lmtp_tmle(...,
                         data=data,
                         shift=shift,
                         weights = wt,
                         id = psu
      ))
  }

  else if (wt_only==TRUE){

    svy <- survey::svydesign(~1, weights = data[[wt_var]], data = data)
    wt <- svy$prob

    progressr::with_progress(
      m<-lmtp::lmtp_tmle(...,
                         data=data,
                         shift=shift,
                         weights = wt
      ))

  }


  else {

    progressr::with_progress(
      m<-lmtp::lmtp_tmle(...,
                         data=data,
                         shift=shift))

  }

  return(m)
}
