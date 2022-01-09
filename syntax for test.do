*Syntax for test data*
use "C:\Users\tiked\OneDrive\ドキュメント\論文\low back pain mortality\stata\stata13_se\elsa_w78.dta",clear
gen A0_lbp = .
replace A0_lbp = 0 if hebck0 >= 0 & hebck0 <= 4
replace A0_lbp = 1 if hebck0 >= 5 & hebck0 <= 10
gen A1_lbp = .
replace A1_lbp = 0 if hebck1 >= 0 & hebck1 <= 4
replace A1_lbp = 1 if hebck1 >= 5 & hebck1 <= 10

*Set c2 = c1*
gen c2 = c1

* drop participants with missing baseline info
foreach var of varlist W* L0* A0*{
drop if `var' == .
}

* if c1==0 c2 definitely has to be 0
replace c2 = 0 if c1==0 

* if any of c1 or c2 is 0 then the final outcome has to be missing
replace Y2_mortality = . if c1==0 | c2 == 0

* if c1==0 all variables after that should be missing
foreach var of varlist L1* A1* Y* {
replace `var' = . if c1==0 
}

label drop _all
order W* L0* A0* L1* A1* c* Y*