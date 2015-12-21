library(rCharts)
library(rMaps)
library(lubridate)
library(plyr)
library(dplyr)
library(reshape2)
library(shiny)

options(stringsAsFactors=FALSE)

#'
#' Gets the birth rate data from Quandl to be displayed in the data table
#' 
#' @return birth.rate data frame
#' 
getBirthRateDF <- function()
{
  ##Commenting out the Quandl download as the number of downloads per day using the function is restricted
  ####birth.rate <- Quandl("CDC/42512_40827_00")
  
  ##Download file the old-fashioned way
  if(!file.exists("birthRate.csv"))
  {
    download.file("https://www.quandl.com/api/v3/datasets/CDC/42512_40827_00.csv", destfile = "birthRate.csv")
  }
  birth.rate <- read.csv("birthRate.csv")
  birth.rate <- transform(birth.rate, Year = year(birth.rate$Year))
  birth.rate
}


#'
#' Transforms the birth.rate data frame in a format 
#' useful to display the choropleth
#' 
#' @return transformed birth.rate data frame
#' 
getTransformedBirthRateDF <- function()
{
  b <- melt(getBirthRateDF(), variable.name = 'State.Name', value.name = 'Birth.Rate', id = 'Year')
  b <- transform(b, State = state.abb[match(gsub("\\.", " ", State.Name), state.name)], 
                 State.Name = gsub("\\.", " ", State.Name), 
                 fillKey = cut(Birth.Rate, quantile(Birth.Rate, seq(0, 1, 1/4)), 
                               include.lowest=TRUE, labels = as.character(sort(unique(cut(b$Birth.Rate, quantile(b$Birth.Rate, seq(0, 1, 1/4))))))))
  b[is.na(b)] <- "DC"
  b
}


#'
#' Creates a choropleth using the data
#' 
#' @param formula - the formula to be used (eg: Birth.Rate ~ State)
#' @param data - a data frame (eg: b[b$Year=='2009'])
#' @param label.values - a list of labels (unique list of fill keys)
#' @return Environment object
#' 
createAnimatedMap <- function(formula, data, label.values)
{
  fillColors <- setNames(
    RColorBrewer::brewer.pal(4, 'Greens'),
    label.values)
  
  d <- Datamaps$new()
  fml = lattice::latticeParseFormula(formula, data = data)
  
  d$set(
    scope = 'usa', 
    data = dlply(data, fml$right.name),
    fills = fillColors,
    legend = TRUE,
    dom = 'map',
    labels = TRUE)
  d
}

#'
#' Creates a line chart using the data
#' 
#' @param data - a data frame (eg: b %>% filter(State.Name %in% 'New York'))
#' @return nPlot
#' 
createLineChart <- function(data)
{
  n1 <- nPlot(Birth.Rate ~ Year, group =  'State', data = data, type = 'lineChart', dom = 'chart')
  n1$chart(margin = list(left = 40))
  n1$yAxis(axisLabel = "Birth Rate", width = 40)
  n1$xAxis(axisLabel = "Year", width = 40)
  n1
}
