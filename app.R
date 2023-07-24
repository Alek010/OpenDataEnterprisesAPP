
source(file = "./global.R", local = TRUE)

ui <- fluidPage(
  add_busy_bar(color = "#FF0000"),

  titlePanel(paste("OpenData Enterprises", APP_VERSION)),
  navlistPanel(
    "Register of Enterprises",
    widths = c(3, 4), selected = "about_project",
    tabPanel(
      title = "Insolvency legal person proceedings", value = "InsolvencyLegalPersonProceedings",
      tabsetPanel(
        type = "tabs",
        filterDataframeTabPanelUI(id = "InsolvencyLegalPersonProceedingsFilter", mainTabPanelValue = "InsolvencyLegalPersonProceedings"),
        dataSourceTabPanelUI(id = "InsolvencyLegalPersonProceedingsData", mainTabPanelValue = "InsolvencyLegalPersonProceedings")
      )
    ),
    tabPanel(
      title = "Enterprises owners", value = "EnterprisesOwners",
      tabsetPanel(
        type = "tabs",
        filterDataframeTabPanelUI(id = "EnterprisesOwnersFilter", mainTabPanelValue = "EnterprisesOwners"),
        dataSourceTabPanelUI(id = "EnterprisesOwnersData", mainTabPanelValue = "EnterprisesOwners")
      )
    ),
    "Admin",
    adminFilesReadLogTabPanelUI(id = "filesReadLog"),
    adminFilesUpdateTabPanelUI(id = "filesUpdate"),

    "About",
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
    ),
    aboutVersioningTabPanelUI(id = "appVersions", latest_app_version = APP_VERSION)
  )
)


server <- function(input, output, session) {
  session$onSessionEnded(function() {
    stopApp()
  })

  register <- RegisterOfEnterprisesOfLatvia$new(download_folder = "./data")
  register$read_files()

  data <- reactiveValues(
    files_read_log = register$get_read_log_summary(),
    files_download_log = register$get_download_log_summary(),
    InsolvencyProceedings = register$InsolvencyProceedings$dataframe,
    LlcShareholders = register$LlcShareholders$dataframe,
    LlcShareholderJointOwners = register$LlcShareholderJointOwners$dataframe
  )

  observeEvent({data$InsolvencyProceedings},
    dataSourceTabPanelServer(
      id = "InsolvencyLegalPersonProceedingsData",
      dataframes = isolate(list(data$InsolvencyProceedings))
    )
  )

  observeEvent({data$LlcShareholders; data$LlcShareholderJointOwners},
    dataSourceTabPanelServer(
      id = "EnterprisesOwnersData",
      dataframes = isolate(list(data$LlcShareholders, data$LlcShareholderJointOwners))
    )
  )

  filterDataframeTabPanelServer(
    id = "InsolvencyLegalPersonProceedingsFilter",
    object_data_frame = isolate(EnterprisesUnderInsolvencyProceeding$new(data$InsolvencyProceedings))
  )

  filterDataframeTabPanelServer(
    id = "EnterprisesOwnersFilter",
    object_data_frame = isolate(EnterprisesOwners$new(df_llc_shareholders = data$LlcShareholders,
                                              df_llc_joint_shareholders = data$LlcShareholderJointOwners))
  )

  observeEvent({data$files_read_log},
    adminFilesReadLogTabPanelServer(id = "filesReadLog", df_read_log_summary = isolate(data$files_read_log))
  )

  adminFilesUpdateTabPanelServer(id = "filesUpdate", register = register, data = data)

  aboutVersioningTabPanelServer(id = "appVersions")

}

# Run the application
shinyApp(ui = ui, server = server)
