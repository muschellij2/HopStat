library(here)
library(dplyr)
setwd(here::here())
x = list.files(pattern = ".html", recursive = TRUE)
df = tibble::tibble(html = x,
                    bn = basename(x)) %>%
  filter(!bn %in% "index.html")
df = df %>%
  mutate(index = paste0(dirname(html), "/", "index.html"))

file.copy(df$html, df$index, overwrite = TRUE)
