source(file = "./global.R", local = TRUE)

ui <- fluidPage(
  add_busy_bar(color = "#FF0000"),
  titlePanel(paste("OpenData Enterprises", APP_VERSION)),
  navlistPanel(
    "Register of Enterprises",
    widths = c(3, 4), selected = "aboutProject",
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
        dataSourceTabPanelUI(id = "EnterprisesOwnersData", mainTabPanelValue = "EnterprisesOwners"),
        processDataLogsTabPanelUI(id = "EnterpriseOwnersDataProcessingLogs")
      )
    ),
    "Admin",
    adminFilesReadLogTabPanelUI(id = "filesReadLog"),
    adminFilesUpdateTabPanelUI(id = "filesUpdate"),
    "About",
    aboutProjectTabPanelUI(id = "aboutProject"),
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

  observeEvent(
    {
      data$InsolvencyProceedings
    },
    dataSourceTabPanelServer(
      id = "InsolvencyLegalPersonProceedingsData",
      dataframes = isolate(list(data$InsolvencyProceedings)),
      columns_to_hide = list(c(
        "proceeding_id", "debtor_cleaned_name", "proceeding_subtype", "proceeding_resolution_type",
        "proceeding_resolution_name", "entry_created_on", "court_case_initial_number", "court_code",
        "court_name", "creditor_applications_deadline_date", "creditor_applications_deadline_in_days",
        "creditor_applications_deadline_in_weeks", "creditor_applications_deadline_in_months",
        "creditor_applications_deadline_in_years", "legislation_number", "legislation_version"
      ))
    )
  )

  observeEvent(
    {
      data$LlcShareholders
      data$LlcShareholderJointOwners
    },
    dataSourceTabPanelServer(
      id = "EnterprisesOwnersData",
      dataframes = isolate(list(data$LlcShareholders, data$LlcShareholderJointOwners)),
      columns_to_hide = list(
        c(
          "id", "uri", "share_nominal_value", "share_currency",
          "date_from", "registered_on", "last_modified_at"
        ),
        c("id", "member_id")
      )
    )
  )

  filterDataframeTabPanelServer(
    id = "InsolvencyLegalPersonProceedingsFilter",
    object_data_frame = isolate(EnterprisesUnderInsolvencyProceeding$new(data$InsolvencyProceedings)),
    columns_to_hide = list(c(
      "proceeding_id", "debtor_cleaned_name", "proceeding_subtype", "proceeding_resolution_type",
      "proceeding_resolution_name", "entry_created_on", "court_case_initial_number", "court_code",
      "court_name", "creditor_applications_deadline_date", "creditor_applications_deadline_in_days",
      "creditor_applications_deadline_in_weeks", "creditor_applications_deadline_in_months",
      "creditor_applications_deadline_in_years", "legislation_number", "legislation_version"
    ))
  )

  filterDataframeTabPanelServer(
    id = "EnterprisesOwnersFilter",
    object_data_frame = isolate(EnterprisesOwners$new(
      df_llc_shareholders = data$LlcShareholders,
      df_llc_joint_shareholders = data$LlcShareholderJointOwners
    )),
    columns_to_hide = c("uri", "date_from", "registered_on", "last_modified_at")
  )

  processDataLogsTabPanelServer(
    id = "EnterpriseOwnersDataProcessingLogs",
    datasource_processor = isolate(EnterprisesOwners$new(
      df_llc_shareholders = data$LlcShareholders,
      df_llc_joint_shareholders = data$LlcShareholderJointOwners
    ))
  )

  observeEvent(
    {
      data$files_read_log
    },
    adminFilesReadLogTabPanelServer(id = "filesReadLog", df_read_log_summary = isolate(data$files_read_log))
  )

  adminFilesUpdateTabPanelServer(id = "filesUpdate", register = register, data = data)

  appVersion <- AppVersionsDataFrame$new()
  aboutVersioningTabPanelServer(id = "appVersions", df_app_versions = appVersion$get_df())
}

# Run the application
shinyApp(ui = ui, server = server)
