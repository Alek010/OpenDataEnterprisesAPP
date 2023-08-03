adminFilesUpdateTabPanelUI <- function(id) {
  ns <- NS(id)

  tabPanel(
    title = "Update files", value = "update_files",
    h2("Update files"),
    p("Press button update in order to download newest files."),
    actionButton(inputId = ns("update_files"), label = "Update files"),
    textOutput(outputId = ns("files_update_status")),
    h2("Files download log"),
    DTOutput(ns("dt_download_log"))
  )
}

adminFilesUpdateTabPanelServer <- function(id, register, data) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$update_files, {

      # TODO Disable button ----
      # implement shinyjs enable disable button if files are up to date instead of validate.
      files_creation_dates <- data$files_read_log %>%
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

      data$InsolvencyProceedings <- register$InsolvencyProceedings$dataframe
      data$LlcShareholders <- register$LlcShareholders$dataframe
      data$LlcShareholderJointOwners <- register$LlcShareholderJointOwners$dataframe
      data$files_read_log <- register$get_read_log_summary()
      data$files_download_log <- register$get_download_log_summary()

      output$dt_download_log <- DT::renderDT(
        DT::datatable(isolate(data$files_download_log),
                      rownames = FALSE,
                      escape = FALSE,
                      options = list(
                        dom = "lp",
                        pageLength = 15,
                        lengthMenu = c(15, 30, 50, 100),
                        order = list(list(1, "desc"))
                      )
                      )
      )

      return(data)

    })
  })
}
