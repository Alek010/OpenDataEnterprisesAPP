processDataLogsTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Logs", value = "DataProcessLogs",
    h3("Data processing logs"),
    br(),
    DTOutput(ns("dt"), width = "1200px")
  )
}

processDataLogsTabPanelServer <- function(id, datasource_processor) {
  moduleServer(id, function(input, output, session) {

    processor <- datasource_processor
    processor$process_data()

    df_log <- processor$log_data %>% as.data.frame()

    output$dt <- DT::renderDT(
      DT::datatable(df_log,
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                      dom = "lp",
                      pageLength = 15,
                      lengthMenu = c(15, 30, 50, 100),
                      order = list(list(1, "desc"))
                    )
      )
    )
  })
}
