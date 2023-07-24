aboutVersioningTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Version", value = "project_version",
    h3("03.07.2023 - version - 0.1.0."),
    p("App works ony with 3 files: enterprises under insolvency proceedings, and enterprises shareholders and enterprises joint shareholders.")
  )
}
