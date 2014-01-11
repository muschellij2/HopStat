clear 
log using "test.log", replace
set obs 1
gen x = ""
count if mi(x)
count if x == ""
log close
exit, clear STATA 
