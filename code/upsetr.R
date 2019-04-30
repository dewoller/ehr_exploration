

source('lib/functions.R')

library(UpSetR)
library(janitor)

read_csv('/home/dewoller/mydoc/teaching/hdi/generate_data/data/diagnosis_desc.csv') %>% 
  { . } -> df_diag


source('lib/get_all_data.R')


df_all %>% 
  filter( encrypted_campus_code == 580916 ) %>%
  { . } -> df_1

movies <- read.csv(system.file("extdata", "movies.csv", package = "UpSetR"), 
                   header = T, sep = ";")


df_all %>% 
  select(starts_with('diag')) %>%
  gather( position, code ) %>% 
  count( code, sort=TRUE ) %>%
  head(100) %>% 
  { . } -> df_frequent




  select( -position ) %>%
 
