dataSourceTabPanelUI <- function(id, mainTabPanelValue) {

  getDataSourceTabPanelUIoutputs(NS(id), mainTabPanelValue)
}

dataSourceTabPanelServer <- function(id, dataframes) {

  moduleServer(id, function(input, output, session) {

    for (i in 1:length(dataframes)) {
      output[[paste0("dt", i)]] <- DT::renderDT(dataframes[[i]])
    }
  })
}

getDataSourceTabPanelUIoutputs <- function(namespace, mainTabPanelValue) {
  ns <- namespace
  outputs <- switch(mainTabPanelValue,
    "InsolvencyLegalPersonProceedings" = tabPanel(
      "Data",
      br(),
      DTOutput(ns("dt1"))
    ),
    "EnterprisesOwners" = tabPanel(
      "Data",
      br(),
      p("Data includes full and joint sharholders of enterprises.
            If entity_type column is JOINT_OWNERS, means that under one record could be two o more owners of share.
            JOINT OWNERS could be matched by using id column of 'Enterprises shareholders' with member_id column of table 'Enterprises only joint owners'."),
      br(),
      h2("Enterprises shareholders"),
      DTOutput(ns("dt1")),
      p(),
      h2("Enterprises only joint owners"),
      p(),
      DTOutput(ns("dt2"))
    )
  )
}
