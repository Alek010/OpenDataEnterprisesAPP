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
    output$dt <- DT::renderDT(
      DT::datatable(df_read_log_summary,
                    rownames = FALSE,
                    options = list(
                      columnDefs = list(list(className = 'dt-left', targets = "_all")),
                      pageLength = 15,
                      lengthMenu = c(15, 30, 50, 100)
                    ))
    )
  })
}
