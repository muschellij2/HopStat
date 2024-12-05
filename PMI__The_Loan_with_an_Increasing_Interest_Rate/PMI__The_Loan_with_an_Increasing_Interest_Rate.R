## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE-------------------------------------------------------------------
library(knitr)
library(dplyr)
library(ggplot2)
opts_chunk$set(echo = TRUE, prompt = FALSE, 
               message = FALSE, warning = FALSE, 
               comment = "")


## ---------------------------------------------------------------------------------------------------------------------------------------------
i = monthly_interest_rate = 0.05/12
p = c(80000, 90000, 100000)
# n = 1:(30*12)
n = 30*12
pmi_cutoff = 80000
get_monthly = function(p) {
  round(p * (i * (1+i)^n)/{(1+i)^n -1}, digits = 2)
}
a = get_monthly(p)
names(a) = sprintf("%4.0f", p)
a


## ---------------------------------------------------------------------------------------------------------------------------------------------
schedule = matrix(ncol = 3, nrow = n+1)
schedule[1,] = p
colnames(schedule) = paste0("base_", p/1000)
for (irow in 2:(n+1)) {
  schedule[irow,] = schedule[irow-1,] - a + 
    round(schedule[irow-1, ] * monthly_interest_rate, 2)
}
schedule = as.data.frame(schedule)
schedule = schedule %>% 
  mutate(month = 0:(nrow(schedule)-1)) %>% 
  select(month, everything())
gt::gt(schedule %>% filter(month > 30 & month <= 36))


## ---------------------------------------------------------------------------------------------------------------------------------------------
make_schedule = function(p, 
                         monthly_interest_rate = 0.05/12,
                         pmi_cutoff = 80000, 
                         pmi_value = 50) {
  schedule = as.data.frame(matrix(ncol = 3, nrow = n+1))
  colnames(schedule) = c("balance", "payment", "interest")
  schedule$balance[1] = p
  a = get_monthly(p)
  schedule = schedule %>% 
    dplyr::mutate(payment = a,
                  interest = 0L)
  # fill in the amortization schedule
  for (irow in 2:(n+1)) {
    schedule$interest[irow-1] = round(schedule$balance[irow-1] * monthly_interest_rate, 2)
    schedule$balance[irow] = schedule$balance[irow-1] - 
      a +
      schedule$interest[irow-1]
  }
  # add columns for the month, principal paid, indicator of PMI and PMI cost
  schedule = schedule %>% 
    dplyr::mutate(
      month = 0:(dplyr::n()-1),
      principal = payment - interest
    )
  schedule = schedule %>% 
    dplyr::mutate(
      has_pmi = balance > pmi_cutoff,
      pmi = ifelse(has_pmi, pmi_value, 0),
      total_cost = interest + pmi,
      effective_interest_rate = total_cost / balance, n = 1L)
  # schedule$effective_interest_rate[1] = schedule$effective_interest_rate[2]
  # We can see the effective APR (PMI + interest)
  schedule = schedule %>% 
    dplyr::mutate(
      effective_apr = scales::percent(effective_interest_rate * 12, 
                                      accuracy = 0.01),
      effective_interest_rate = scales::percent(effective_interest_rate,
                                                accuracy = 0.001),
    )
  # remove the last which happens due to rounding
  schedule = schedule %>% 
    filter(balance > 0)
  schedule = tibble::as_tibble(schedule)
  schedule
}


## ---------------------------------------------------------------------------------------------------------------------------------------------
m = make_schedule(90000, monthly_interest_rate = monthly_interest_rate)
gt::gt(head(m))


## ---------------------------------------------------------------------------------------------------------------------------------------------
m %>% 
  ggplot(aes(x = month, y = effective_apr)) + 
  geom_step() + 
  labs(x = "Month", y = "Effective APR (including PMI)")


## ---------------------------------------------------------------------------------------------------------------------------------------------
m = m %>% 
  mutate(pmi_balance = balance - pmi_cutoff,
         pmi_balance = ifelse(pmi_balance < 0, 0, pmi_balance),
         other_balance = balance - pmi_balance)
m = m %>% 
  mutate(pmi_balance_interest = round(pmi_balance / balance * interest,2),
         other_balance_interest = interest - pmi_balance_interest)
m = m %>% 
  mutate(
    pmi_balance_total_cost = pmi_balance_interest + pmi,
    effective_pmi_balance_apr = pmi_balance_total_cost/pmi_balance * 12,
    effective_other_apr = other_balance_interest/other_balance * 12,
    effective_pmi_balance_apr = scales::percent(effective_pmi_balance_apr),
    effective_other_apr = scales::percent(effective_other_apr))
data = m %>% 
  filter(has_pmi) %>% 
  select(balance, month, pmi_balance,
         effective_pmi_balance_apr, pmi_balance_interest, 
         pmi_balance_total_cost, effective_apr)
gt::gt(head(data))


## ----echo = FALSE-----------------------------------------------------------------------------------------------------------------------------
gt::gt(data %>% filter(month == 36))


## ---------------------------------------------------------------------------------------------------------------------------------------------
data %>% 
  filter(month <= 72) %>% 
  mutate(effective_pmi_balance_apr = 
           as.numeric(sub("%", "", effective_pmi_balance_apr))/100) %>% 
  ggplot(aes(x = month, y = effective_pmi_balance_apr)) + 
  scale_y_continuous(label =  scales::percent) +
  geom_step() + 
  labs(x = "Month", y = "PMI Balance Effective APR")


## ----echo = FALSE-----------------------------------------------------------------------------------------------------------------------------
gt::gt(tail(data))

