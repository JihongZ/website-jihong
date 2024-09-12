library(rnoaa)
temp_min <- ncdc(
  datasetid = 'GHCND',
  stationid = 'GHCND:USW00093993',
  datatypeid = "TMIN",
  startdate = '2023-09-01',
  enddate = '2023-09-30',
  limit = 25,
  add_units = TRUE,
  token = "XXXXXXXXXXXXX"
)$data
temp_max <- ncdc(
  datasetid = 'GHCND',
  stationid = 'GHCND:USW00093993',
  datatypeid = "TMAX",
  startdate = '2023-09-01',
  enddate = '2023-09-30',
  limit = 25,
  add_units = TRUE,
  token = "ikTGSZhEsHJpjpBHcpQpyCgAcJimbzqU"
)$data
temp <- rbind(temp_min, temp_max)
# write.csv(temp, "data/temp_fayetteville.csv")