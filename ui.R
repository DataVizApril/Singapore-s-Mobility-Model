#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(rgdal)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  # Application title
  titlePanel("Singapore's Mobility Model"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h3("Filter"),
      selectInput('disType',h4("Distance Type:"),
                  choices = c("Euclidean Distance","Bus route Distance")),
      dateRangeInput('dateRange',
                     h4('Date range input: yyyy-mm-dd'),
                     start = Sys.Date() - 2, end = Sys.Date() + 2
      ),
      # Specification of range within an interval
      sliderInput("timeRange", h4("Time Range:"),
                  min = 0, max = 24, value = c(5,9)
      ),
      hr(),
      radioButtons("radio", label = h3("Flow type"),
                   choices = list("Origin(Outflow)" = 1, "Destination(Inflow)" = 2), 
                   selected = 1)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h3("Estimate Result"),
      leafletOutput("map_1"),
      h3("Std.Error"),
      leafletOutput("map_2")
    )
  )
))
