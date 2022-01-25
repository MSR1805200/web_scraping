library(tibble)
library(dplyr)
library(rvest)

link = 'https://www.patriotsoftware.com/blog/accounting/average-cost-living-by-state/'

pagina = read_html(link)

tabela = pagina %>% html_nodes("table") %>% html_table() %>% .[[1]]

View(tabela)
