dataSourceTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    "Data",
    DTOutput(ns("dt"))
  )
}

dataSourceTabPanelServer <- function(id, dataframe) {
  moduleServer(id, function(input, output, session) {
    output$dt <- DT::renderDT(dataframe)
  })
}
