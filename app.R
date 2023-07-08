#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source(file = "./global.R", local = TRUE)

# Define UI for application that draws a histogram
ui <- fluidPage(
  add_busy_bar(color = "#FF0000"),

  # Application title
  titlePanel("OpenData Enterprises"),
  navlistPanel(
    "Register of Enterprises",
    widths = c(3, 4), selected = "about_project",
    tabPanel(
      title = "Insolvency legal person proceedings", value = "InsolvencyLegalPersonProceedings",
      tabsetPanel(
        type = "tabs",
        filterDataframeTabPanelUI(id = "enterprise_insolvency_filter", mainTabPanelValue = "InsolvencyLegalPersonProceedings"),
        tabPanel(
          "Data",
          DTOutput("dt_InsolvencyLegalPersonProceedings")
        )
      )
    ),
    tabPanel(
      title = "Enterprises owners", value = "EnterprisesOwners",
      tabsetPanel(
        type = "tabs",
        filterDataframeTabPanelUI(id = "enterprises_owners_filter", mainTabPanelValue = "EnterprisesOwners"),
        tabPanel(
          "Data",
          h2("Enterprises shareholders"),
          br(),
          p("Data includes full and joint sharholders of enterprises. "),
          p("If entity_type column is JOINT_OWNERS, means that under one record could be two o more owners of share."),
          p("JOINT OWNERS could be matched by using id column with member_id column of next table."),
          DTOutput("dt_LlcShareholders"),
          p(),
          h2("Enterprises only joint owners"),
          p(),
          DTOutput("dt_LlcShareholderJointOwners")
        )
      )
    ),
    "Admin",
    tabPanel(
      title = "Logs", value = "read_log",
      h2("Files read log"),
      DTOutput("dt_read_log")
    ),
    tabPanel(
      title = "Update files", value = "update_files",
      h2("Update files"),
      p("Press button update in order to download newest files."),
      actionButton(inputId = "update_files", label = "Update files"),
      textOutput(outputId = "files_update_status"),
      h2("Files download log"),
      DTOutput("dt_download_log")
    ),
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
    tabPanel(
      title = "Version", value = "project_version",
      h3("03.07.2023 - version - 0.1.0."),
      p("App works ony with 3 files: enterprises under insolvency proceedings, and enterprises shareholders and enterprises joint shareholders.")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  session$onSessionEnded(function() {
    stopApp()
  })

  register <- RegisterOfEnterprisesOfLatvia$new(download_folder = "./data")
  register$read_files()

  output$dt_InsolvencyLegalPersonProceedings <- DT::renderDT(register$InsolvencyProceedings$dataframe)

  output$dt_LlcShareholders <- DT::renderDataTable(register$LlcShareholders$dataframe)
  output$dt_LlcShareholderJointOwners <- DT::renderDT(register$LlcShareholderJointOwners$dataframe)

  output$dt_read_log <- DT::renderDT(register$get_read_log_summary())

  output$dt_download_log <- DT::renderDT(register$get_download_log_summary())

  filterDataframeTabPanelServer(
    id = "enterprise_insolvency_filter",
    object_data_frame = EnterprisesUnderInsolvencyProceeding$new(register$InsolvencyProceedings$dataframe)
  )

  filterDataframeTabPanelServer(
    id = "enterprises_owners_filter",
    object_data_frame = EnterprisesOwners$new(
      df_llc_shareholders = register$LlcShareholders$dataframe,
      df_llc_joint_shareholders = register$LlcShareholderJointOwners$dataframe
    )
  )


  observeEvent(input$update_files, {
    # TODO Disable button ----
    # implement shinyjs enable disable button if files are up to date instead of validate.
    files_creation_dates <- register$get_read_log_summary() %>%
      dplyr::select(file_created) %>%
      unique() %>%
      dplyr::filter(!is.na(file_created))

    FileOrFilesAreNotUpToDate <- TRUE

    if (length(files_creation_dates$file_created) != 0) {
      for (date in files_creation_dates$file_created) {
        if (date == Sys.Date()) {
          FileOrFilesAreNotUpToDate <- FALSE
          break
        }
      }
    }

    output$files_update_status <- renderText({
      validate(need(FileOrFilesAreNotUpToDate, message = "Files are up to date!!!"))
    })
    validate(need(FileOrFilesAreNotUpToDate, message = "Files are up to date!!!"))
    # TODO END ----
    #----
    register$processed_files <- NULL
    register$download_files()
    register$read_files()

    output$dt_InsolvencyLegalPersonProceedings <- DT::renderDT(register$InsolvencyProceedings$dataframe)

    output$dt_LlcShareholders <- DT::renderDataTable(register$LlcShareholders$dataframe)
    output$dt_LlcShareholderJointOwners <- DT::renderDT(register$LlcShareholderJointOwners$dataframe)

    output$dt_read_log <- DT::renderDT(register$get_read_log_summary())

    output$dt_download_log <- DT::renderDT(register$get_download_log_summary())
  })
}

# Run the application
shinyApp(ui = ui, server = server)
