aboutProjectTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Project", value = "about_project",
    h2("Open Data Enterprises"),
    br(),
    h4("Under construction!!!"),
    br(),
    h4("The project is using official open data files from Register of Enterprises."),
    h4("Now project is focused only on Register of Enterprises of the Republc of Latvia (https://data.gov.lv/dati/lv/organization/ur)."),
    br(),
    h4("Found bugs, need new features or enhancements"),
    p(" - open issue on GitHub: https://github.com/Alek010/OpenDataEnterprisesAPP/issues"),
    p("- write via email: opendataenterprisesapp@gmail.com .")
  )
}
