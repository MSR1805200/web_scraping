library(dplyr)
library(rvest)
library(tidyr)
library(tibble)

base_de_dados_completa = data.frame()
cont = 0

for(i in seq(1,2000,48)){
  lista_media_nota = c()
  lista_notas = c()
  lista_valor = c()
  livros = data.frame()
    
  link = paste0('https://livros.mercadolivre.com.br/livros-fisicos/livros_Desde_',i,'_NoIndex_True')
  pagina = read_html(link)
  
  links_desc = pagina %>% html_elements('.ui-search-result__content.ui-search-link') %>% html_attr("href") 
  
  for(j in 1:length(links_desc)){
    cont = cont + 1
    
    pagina_2 = read_html(links_desc[j])
    
    tabela = pagina_2 %>% html_nodes('.andes-table') %>% html_table()
    
    tryCatch(
      expr = {
        tabela[[1]]$id = cont
        livros = rbind(livros,data.frame(tabela))   
      },
      error = function(e){ 
        next
      }
    )
    
    media_nota = pagina_2 %>% html_nodes('.ui-pdp-reviews__rating__summary__average') %>% html_text()
    
    notas = pagina_2 %>% html_nodes('.ui-vpp-rating__level__value') %>% html_text() %>% paste(., collapse = ',')
    
    valor = pagina_2 %>% html_nodes('.ui-pdp-price__second-line .price-tag-fraction') %>% html_text()
    
    if(identical(media_nota,character(0))){
      media_nota = ''
    }
    
    if(identical(notas, character(0))){
      notas = ''
    }
    
    lista_media_nota = c(lista_media_nota,media_nota)
    lista_notas = c(lista_notas,notas)
    lista_valor = c(lista_valor,valor)
    
  }
  
  df = livros %>% distinct()  %>% pivot_wider(names_from=X1, values_from = X2)
  df = df %>% mutate(media_nota = lista_media_nota) 
  df = df %>% mutate(notas = lista_notas)
  df = df %>% mutate(valor = lista_valor)
  base_de_dados_completa =bind_rows(base_de_dados_completa,data.frame(df))
  
}

View(base_de_dados_completa)

write.csv(base_de_dados_completa, 'Documentos/estudos_em_R/web scrapping/livros_mercado_livre.csv')