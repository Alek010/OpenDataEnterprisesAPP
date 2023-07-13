adminFilesReadLogTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Logs", value = "read_log",
    h2("Files read log"),
    DTOutput(ns("dt"))
  )
}

adminFilesReadLogTabPanelServer <- function(id, df_read_log_summary) {
  moduleServer(id, function(input, output, session) {
    output$dt <- DT::renderDT(df_read_log_summary)
  })
}
