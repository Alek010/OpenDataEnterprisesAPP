aboutVersioningTabPanelUI <- function(id, latest_app_version) {
  ns <- NS(id)

  tabPanel(
    title = "Version", value = "project_version",
    h3(paste("Latest version is", latest_app_version)),
    br(),
    DTOutput(ns("dt"),width = "1200px")
  )
}

aboutVersioningTabPanelServer <- function(id, df_app_versions) {
  moduleServer(id, function(input, output, session) {

    output$dt <- DT::renderDT(DT::datatable(df_app_versions,
                                        rownames = FALSE,
                                        escape = FALSE,
                                        options = list(
                                          dom = 'lp',
                                          pageLength = 15,
                                          lengthMenu = c(15, 30, 50, 100),
                                          order = list(list(1, 'desc'))
                                        )
                                        ))
  })
}





