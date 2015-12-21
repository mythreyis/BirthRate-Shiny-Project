library(shiny)

source('global.R')
birth.rate.df <- getTransformedBirthRateDF()
states <- unique(birth.rate.df$State.Name)
label.value <- as.character(sort(unique(birth.rate.df$fillKey)))

shinyServer(function(input, output) {
  
  ##Check boxes for states
  output$states <- renderUI({
    checkboxGroupInput('states', 'States', states, selected=c('Alaska', 'Vermont'))
  })
  
  ##HTML Texts
  output$mapText=renderText({paste("Birth Rate for Year ", input$Year)})
  output$chartText=renderText({"Birth Rate changes in individual states"})
  output$tableText=renderText({"Source Data"})
  
  ##Data Table 
  output$birth.rate.table <- renderDataTable(getBirthRateDF())
  
  ##NVD3 Line Chart
  output$chart <- renderChart({
    createLineChart(birth.rate.df %>% filter(State.Name %in% input$states))
  })
  
  ##Choropleth using rMaps
  output$map = renderChart({
    createAnimatedMap(
      Birth.Rate~State,
      data = birth.rate.df[birth.rate.df$Year==input$Year,],
      label.value
    )
  })
})
