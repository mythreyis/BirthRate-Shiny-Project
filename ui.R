library(shiny)
library(markdown)

shinyUI(
  navbarPage("", 
               tabPanel("Home", 
                 mainPanel(
                   includeMarkdown("home.md")
                 )),
               tabPanel("Map", 
                 sidebarPanel(
                   sliderInput("Year","Year:", min=1990, max=2009, value=1990, sep="")
                 ),
                 mainPanel(
                   h3(textOutput("mapText")),
                   showOutput("map", "datamaps", package="rMaps")  
                 )
               ),
               tabPanel("Plot", 
                  sidebarPanel(
                    uiOutput("states")
                  ),
                  mainPanel(
                    h3(textOutput("chartText")),
                    showOutput("chart", "nvd3")  
                  )
               ),
               tabPanel("Data",
                  h3(textOutput("tableText")),
                  dataTableOutput(outputId="birth.rate.table")
               )
             
  )
)
