# plumber.R

#' Get data from metrobus dataset
#' @get /avaliableUnits
function(){
  
  
  get_avaliable_units <- function(){
  dplyr::src_sqlite("metrobus") %>% 
    dplyr::tbl("metrobus_data") %>% 
    dplyr::filter(vehicle_current_status == "1") %>% 
    dplyr::arrange(dplyr::desc(date_updated)) %>% 
    dplyr::select(vehicle_label, vehicle_id) %>% 
    dplyr::distinct() %>% 
    head(100) %>%   
    dplyr::collect()
  }
  
  
  get_avaliable_units_safely <- purrr::possibly(get_avaliable_units, NULL)
  
  return( get_avaliable_units_safely() )
}


#' Get data from metrobus dataset
#' @param vehicleID If provided return date and position of vehicle
#' @get /historyVehicleID
function(vehicleID){
  get_history_vehicleID <- function(vehicleID){
    vehicleID <- as.character(vehicleID)
    
    dplyr::src_sqlite("metrobus") %>% 
      dplyr::tbl("metrobus_data") %>%
      filter(vehicle_id == vehicleID) %>%
      select(vehicle_id, date_updated, position_longitude, position_latitude) %>% 
      collect() 
  }  
  get_history_vehicleID_safely <- purrr::possibly(get_history_vehicleID, NULL)
  get_avaliable_units_safely <- purrr::possibly(get_avaliable_units, NULL)
  get_history_vehicleID_safely(vehicleID)
  
  
}