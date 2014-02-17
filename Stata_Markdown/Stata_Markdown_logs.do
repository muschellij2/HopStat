clear 
log using print_hello.log, replace
disp "hello world!"
log close

log using run_summ.log, replace
set obs 100
gen x = rnormal(100)
summ x
log close 
exit, clear STATA