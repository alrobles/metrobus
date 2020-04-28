#!/usr/bin/env Rscript
library(jsonlite)
library(RSQLite)
library(dplyr) 
library(DBI)
library(purrr)

library(jsonlite)
library(RSQLite)
library(dplyr) 
library(DBI)
library(purrr)

get_metrobus_data <- function(url = "https://datos.cdmx.gob.mx/api/records/1.0/search/?dataset=prueba_fetchdata_metrobus&rows=100")
{
  dataraw <- jsonlite::read_json(url, simplifyVector = TRUE)$records
  data <- dataraw$fields %>% tibble::tibble() %>% dplyr::mutate_all(as.character)
  
  return(data)
}

initial_SQL_createTable <- function(data){
  fieldchar <- paste(
    
    paste(names(data), "TEXT", collapse = ", ")
  )
  
  SQL_createTable <- paste("CREATE TABLE metrobus_data(", fieldchar, ")")
  return(SQL_createTable)
}

print("Initialize database") 
SQL_createTable <- initial_SQL_createTable(get_metrobus_data ())

conn <- dbConnect(RSQLite::SQLite(), "metrobus")
if(!grepl("metrobus_data",  DBI::dbListTables(conn) ) ){
  dbExecute(conn, SQL_createTable)
}
dbDisconnect(conn)


add_metrobus_data <- function(dbName = "metrobus", tableName = "metrobus_data"){
  
  metrobusdataLast <- dplyr::src_sqlite(dbName) %>% 
    dplyr::tbl(tableName) %>% 
    dplyr::arrange(dplyr::desc(date_updated)) %>% 
    head(100) %>% 
    dplyr::collect()
  
  metrobusdataNew <- get_metrobus_data()
  metrobusData <- dplyr::anti_join(metrobusdataNew, metrobusdataLast)
  
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbName)
  DBI::dbWriteTable(conn, tableName, metrobusData, append = TRUE)
  DBI::dbDisconnect(conn)
}
add_metrobus_data_safely <- purrr::safely(add_metrobus_data, otherwise = print("fail ingest"))

while(TRUE){
  #Initialize data ingest
  print("Initialize data ingest")
  add_metrobus_data_safely()
  print(1)
  Sys.sleep(time = 10)
  
  
}
