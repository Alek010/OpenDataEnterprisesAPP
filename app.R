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
      "Register of Enterprises", widths = c(3, 4), selected = "about_project",
      tabPanel(title = "Insolvency legal person proceedings", value = "InsolvencyLegalPersonProceedings",
               tabsetPanel(type = "tabs",
                           tabPanel("Filters",
                                    radioButtons("insolvency_filter_radio",
                                                 label = h3("Filter enterprise under insolvency proceeding"),
                                                 choices = list("by enterprise registration number" = 1,
                                                                "by enterprise name" = 2),
                                                 selected = 1,
                                                 width = "150%"),
                                    textInput("insolvency_filter_input_text",
                                              label = "",
                                              width = "150%",
                                              placeholder = "For example 40003608302 or multiple values 40003608302;4000360800"),
                                    actionButton(inputId = "insolvency_filter_button", label = "Filter"),
                                    p(),
                                    h3("Result"),
                                    tabsetPanel(type = "tabs",
                                                id = "enterprise_insolvency_filter_result",
                                                tabPanel("All in One",
                                                         p(),
                                                         DTOutput("dt_filtered_InsolvencyLegalPersonProceedings"))
                                                )

                                    ),
                           tabPanel("Data",
                                    DTOutput("dt_InsolvencyLegalPersonProceedings")
                                    )
                           )
               ),

      tabPanel(title = "Enterprises owners", value = "EnterprisesOwners",
               tabsetPanel(type = "tabs",
                           id = "EnterprisesOwners_tabset",
                           tabPanel("Filters",
                                    radioButtons("enterprises_owners_filter_radio",
                                                 label = h3("Filter enterprises owners"),
                                                 choices = list("by enterprise registration number" = 1,
                                                                "by owner name in order of Doe John or just enter last name" = 2),
                                                 selected = 1,
                                                 width = "150%"),
                                    textInput("enterprises_owners_filter_input_text",
                                              label = "",
                                              width = "150%",
                                              placeholder = "For example 40003608302 or multiple values 40003608302;4000360800"),
                                    actionButton(inputId = "enterprises_owners_filter_button", label = "Filter"),
                                    p(),
                                    h3("Result"),
                                    tabsetPanel(type = "tabs",
                                                id = "enterprises_owners_filter_result",
                                                tabPanel("All in One",
                                                         p(),
                                                         DTOutput("dt_filtered_enterprises_owners")))

                                    ),
                           tabPanel("Data",
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
      tabPanel(title = "Logs", value = "read_log",
               h2("Files read log"),
               DTOutput("dt_read_log")),
      tabPanel(title = "Update files", value = "update_files",
               h2("Update files"),
               p("Press button update in order to download newest files."),
               actionButton(inputId = "update_files",label = "Update files"),
               textOutput(outputId = "files_update_status"),
               h2("Files download log"),
               DTOutput("dt_download_log")),
      "About",
      tabPanel(title = "Project", value = "about_project",
              h2("Open Data Enterprises"),
              br(),
              h4("Under construction!!!"),
              br(),
              h4("The project is using official open data files from Register of Enterprises."),
              h4("Now project is focused only on Register of Enterprises of the Republc of Latvia (https://data.gov.lv/dati/lv/organization/ur)."),
              br(),
              h4("Found bugs, need new features or enhancements"),
              p(" - open issue on GitHub: https://github.com/Alek010/OpenDataEnterprisesAPP/issues"),
              p("- write via email: opendataenterprisesapp@gmail.com .")),
      tabPanel(title = "Version", value = "project_version",
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

  filter_input <- reactiveValues(insolvency = character(),
                                 enterprise_owners = character())

  observeEvent(input$insolvency_filter_button,
               {
                 enterprises_under_insolvency <- EnterprisesUnderInsolvencyProceeding$new(register$InsolvencyProceedings$dataframe)
                 enterprises_under_insolvency$process_data()

                 filter_values <- vectorize_input_text(input$insolvency_filter_input_text)

                 filtered_df <- switch (input$insolvency_filter_radio,
                                        "1" = enterprises_under_insolvency$filter_by_enterprise_registration_number(filter_values),
                                        "2" = enterprises_under_insolvency$filter_by_enterprise_name(filter_values)
                 )

                 output$dt_filtered_InsolvencyLegalPersonProceedings <- DT::renderDataTable(filtered_df)

                 if(length(filter_input$insolvency) > 1){

                   values <- filter_input$insolvency

                   for (value in values) {

                     removeTab(inputId = "enterprise_insolvency_filter_result", target = value)
                   }
                 }

                 filter_input$insolvency <- filter_values

                 if( length(filter_values) > 1){

                   filtered_df_per_value <- NULL


                       for (i in 1:length(filter_values)) {

                       insertTab(inputId = "enterprise_insolvency_filter_result",
                                 tabPanel(filter_values[i],
                                          DTOutput(filter_values[[i]])),
                                 target = "All in One"
                       )

                         filtered_df_per_value[[i]] <-
                           switch (input$insolvency_filter_radio,
                                   "1" = filtered_df %>%
                                     dplyr::filter(debtor_registration_number == filter_values[i]),
                                   "2" = filtered_df %>%
                                     dplyr::filter((debtor_name %>% toupper()) %like% (filter_values[i] %>% toupper()))
                                   )

                         local({
                           local_df <- filtered_df_per_value[[i]]

                           output[[filter_values[i]]] <- DT::renderDataTable(local_df)
                         })
                       }
                }
                 }
               )

  observeEvent(input$enterprises_owners_filter_button,
               {
                 enterprises_owners <- EnterprisesOwners$new(df_llc_shareholders = register$LlcShareholders$dataframe,
                                                             df_llc_joint_shareholders = register$LlcShareholderJointOwners$dataframe)

                 enterprises_owners$process_data()

                 filter_values <- vectorize_input_text(input$enterprises_owners_filter_input_text)

                 filtered_df <- switch (input$enterprises_owners_filter_radio,
                   "1" = enterprises_owners$filter_dataframes_by_enterprise_registration_number(filter_values),
                   "2" = enterprises_owners$filter_dataframes_by_name(filter_values)
                 )

                 output$dt_filtered_enterprises_owners <- DT::renderDataTable(filtered_df)


                 if(length(filter_input$enterprise_owners)>1){
                   values <- filter_input$enterprise_owners
                   for (value in values) {

                     removeTab(inputId = "enterprises_owners_filter_result", target = value)
                   }
                 }

                 filter_input$enterprise_owners <- filter_values

                 if( length(filter_values) > 1){

                   filtered_df_per_value <- NULL


                   for (i in 1:length(filter_values)) {

                     insertTab(inputId = "enterprises_owners_filter_result",
                               tabPanel(filter_values[i],
                                        DTOutput(filter_values[[i]])),
                               target = "All in One"
                     )

                     filtered_df_per_value[[i]] <-
                       switch (input$enterprises_owners_filter_radio,
                         "1" = filtered_df %>%
                           dplyr::filter(at_legal_entity_registration_number == filter_values[i]),
                         "2" = filtered_df %>%
                           dplyr::filter((name %>% toupper()) %like% (filter_values[i] %>% toupper()))
                       )

                     local({
                       local_df <- filtered_df_per_value[[i]]

                       output[[filter_values[i]]] <- DT::renderDataTable(local_df)
                     })
                   }

                 }


               })



  observeEvent(input$update_files, {
    # TODO Disable button ----
    # implement shinyjs enable disable button if files are up to date instead of validate.
    files_creation_dates <- register$get_read_log_summary() %>%
      dplyr::select(file_created) %>%
      unique() %>%
      dplyr::filter(!is.na(file_created))

    FileOrFilesAreNotUpToDate <- TRUE

    if(length(files_creation_dates$file_created) != 0){
      for (date in files_creation_dates$file_created) {

          if(date == Sys.Date()){
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
