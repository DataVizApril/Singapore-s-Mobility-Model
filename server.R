#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(rgdal)

#Set Spark Evironment
Sys.setenv(SPARK_HOME="/Applications/spark-2.0.0-preview-bin-hadoop2.7")

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
#load R library
library(SparkR)

#load spark-csv_2.10:1.4.0 package
Sys.setenv('SPARKR_SUBMIT_ARGS'='"--packages" "com.databricks:spark-csv_2.11:1.4.0" "sparkr-shell"')

sc <- sparkR.init(master="local")

sqlContext <- sparkRSQL.init(sc)

#Read raw ride dataset from outter file 
#This is the same for all user
#city_ride_full_df <- read.df(sqlContext, "/Volumes/External 2/Mobility&City/ExperimentData/CITY_NATION_RIDE_DATA_FULL.csv", source = "com.databricks.spark.csv", inferSchema = "true",header = "true")
#registerTempTable(city_ride_full_df,"flow")
clean_city_ride_data <- read.df(sqlContext, "/Users/April/Desktop/City_ride_fitted.csv", source = "com.databricks.spark.csv", inferSchema = "true",header = "true")
Oi_temp <- agg(groupBy(clean_city_ride_data,clean_city_ride_data$Origin),fitted = "sum")
Oi_temp <- rename(Oi_temp,outflow = Oi_temp$`sum(fitted)`)
Oi_fitted <- as.data.frame(Oi_temp)
SG_WGS84 <- readOGR("/Users/April/Desktop/CP2/Shiny/MobilityModel_GLM_SparkR/data/Subzone_Area_WGS84.shp",
                    layer = "Subzone_Area_WGS84", verbose = FALSE)
Oi_joined_shp <- merge(SG_WGS84,Oi_fitted,by.x = "SUBZONE_N",by.y = "Origin")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  pal <- colorNumeric(
    palette = "YlOrRd",domain = Oi_joined_shp$outflow
  )
  output$map_1 <- renderLeaflet({
    leaflet(Oi_joined_shp) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 103.851959, lat = 1.35, zoom = 11)%>%
      addPolygons(
        stroke = FALSE,fillOpacity = 0.8,smoothFactor = 0.5,
        color = ~colorQuantile("YlOrRd",Oi_joined_shp$outflow)(outflow)
      )%>%
      addLegend("bottomright", values = ~outflow,
                title = "Subzone estimated outflow",
                pal = pal,
                opacity = 1
      )
  })
  output$map_2 <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 103.851959, lat = 1.35, zoom = 11) 
  })
  
})
