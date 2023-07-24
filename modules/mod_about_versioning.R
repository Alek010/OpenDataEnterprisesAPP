aboutVersioningTabPanelUI <- function(id, latest_app_version) {
  ns <- NS(id)

  tabPanel(
    title = "Version", value = "project_version",
    h3(paste("Latest version is", latest_app_version)),
    br(),
    DTOutput(ns("dt"))
  )
}

aboutVersioningTabPanelServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$dt <- DT::renderDT(datatable(data.frame(Date = as.Date("2023-07-03"),
                                                            Version = "0.1.0",
                                                            Description = "<ol>App works ony with 3 files:<br/>
                                                   <li>enterprises under insolvency proceedings;</li>
                                                   <li>enterprises shareholders;</li>
                                                   <li>enterprises joint shareholders.</li>
                                                   </ol>"),
                                        rownames = FALSE,
                                        escape = FALSE))
  })
}
