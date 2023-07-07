filterResultUI <- function(id) {
  ns <- NS(id)
  tabPanel("Filters",
           radioButtons(ns("filter_radio"),
                        label = h3("Filter enterprise under insolvency proceeding"),
                        choices = list("by enterprise registration number" = 1,
                                       "by enterprise name" = 2),
                        selected = 1,
                        width = "150%"),
           textInput(ns("filter_input_text"),
                     label = "",
                     width = "150%",
                     placeholder = "For example 40003608302 or multiple values 40003608302;4000360800"),
           actionButton(inputId = ns("action_button"), label = "Filter"),
           p(),
           h3("Result"),
           tabsetPanel(type = "tabs",
                       id = ns("result"),
                       tabPanel("All in One",
                                p(),
                                DTOutput(ns("dt")))
                       )

  )

}

filterResultServer <- function(id, object_data_frame){
  moduleServer(
    id,
    function(input, output, session) {

      filter_input_values <- reactiveVal(character(0))

      observeEvent(input$action_button,
                   {
                     enterprises_under_insolvency <- object_data_frame
                     enterprises_under_insolvency$process_data()

                     filter_values <- vectorize_input_text(input$filter_input_text)

                     filtered_df <- switch (input$filter_radio,
                                            "1" = enterprises_under_insolvency$filter_by_enterprise_registration_number(filter_values),
                                            "2" = enterprises_under_insolvency$filter_by_enterprise_name(filter_values)
                     )

                     output$dt <- DT::renderDataTable(filtered_df)

                     if(length(filter_input_values()) > 1){

                       values <- filter_input_values()

                       for (value in values) {

                         removeTab(inputId = "result", target = value)
                       }
                     }

                     filter_input_values(filter_values)

                     if( length(filter_values) > 1){

                       filtered_df_per_value <- NULL


                           for (i in 1:length(filter_values)) {

                           insertTab(inputId = "result",
                                     tabPanel(filter_values[i],
                                              DTOutput(NS(id, filter_values[[i]]))),
                                     target = "All in One"
                           )

                             filtered_df_per_value[[i]] <-
                               switch (input$filter_radio,
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

    }
  )
  }
