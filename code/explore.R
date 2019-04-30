
source('lib/functions.R')

library(devtools)
remove.packages('EHRtemporalVariability')
install_git('/store/src/EHRtemporalVariability')
library(EHRtemporalVariability)

library(EHRtemporalVariability)
library(janitor)

read_csv('/home/dewoller/mydoc/teaching/hdi/generate_data/data/diagnosis_desc.csv') %>% 
  { . } -> df_diag

skim(df_diag)

source('lib/get_all_data.R')


df_all %>%  # df_diag is missing 141 / 14472 codes
  select(starts_with('diag')) %>%
  gather( position, diag_code ) %>% 
  distinct(diag_code ) %>%
  anti_join( df_diag )

read_csv('data/Phecode_map_v1_2_icd10cm_beta.csv')  %>%
  clean_names () %>%
  mutate( code = str_replace( icd10cm, '\\.', '' )) %>% 
  { . } -> df_codes

df_all %>% 
  count( encrypted_campus_code ) %>% 
  { . } -> df_campus


df_all %>% 
  filter( encrypted_campus_code == 580916 ) %>%
  { . } -> df_1

df_1 %>% 
  select(date, starts_with('diag')) %>%
  gather( position, code, -date ) %>% 
  select( -position ) %>%
  estimateDataTemporalMap( dateColumnName='date' ) %>% 
  { . } -> probMaps

df_1 %>% 
  select(date, starts_with('diag')) %>%
  gather( position, code, -date ) %>% 
  inner_join( df_codes, by='code') %>%
  select( phecode_description, date ) %>%
  estimateDataTemporalMap( dateColumnName='date' ) %>% 
  { . } -> probMaps

df_1 %>% 
  select(date, 'diag1') %>%
  inner_join( df_codes, by=c('diag1'='code')) %>%
  select( phecode_description, date ) %>%
  estimateDataTemporalMap( dateColumnName='date' ) %>% 
  { . } -> probMaps

#PD only
df_all %>% 
  select( diag1, date ) %>%
  inner_join( df_codes, by=c('diag1'='code')) %>%
  select( phecode_description, date ) %>%
  estimateDataTemporalMap( dateColumnName='date' ) %>% 
  { . } -> probMaps

#all codes
df_all %>% 
  select( starts_with('diag'), date ) %>%
  gather( junk, code, -date ) %>%
  inner_join( df_codes, by='code') %>%
  select( phecode_description, date ) %>%
  estimateDataTemporalMap( dateColumnName='date' ) %>% 
  { . } -> probMaps



igtProj <- estimateIGTProjection( dataTemporalMap = probMaps, dimensions      = 2 )
#
plotDataTemporalMap(
                    dataTemporalMap =  probMaps,
                    startValue = 1,
                    endValue = 99,
                    colorPalette    = "Spectral")
#
#
plotIGTProjection( 
                  igtProjection   =  igtProj,
                  colorPalette    = "Spectral", 
                  dimensions      = 2)
