aboutProjectTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Project", value = id,
    includeHTML(path = "./html/AboutProject.html"),
    style='width: 1000px;'
  )
}
