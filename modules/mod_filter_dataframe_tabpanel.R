filterDataframeTabPanelUI <- function(id, mainTabPanelValue) {
  ns <- NS(id)
  tabPanel(
    "Filters",
    radioButtons(ns("filter_radio"),
      label = h3(getFilterDataFrameRadioButtonLabel(mainTabPanelValue)),
      choices = getFilterDataFrameRadioButtonChoises(mainTabPanelValue),
      selected = 1,
      width = "150%"
    ),
    textInput(ns("filter_input_text"),
      label = "",
      width = "150%",
      placeholder = "For example 40003608302 or multiple values 40003608302;4000360800"
    ),
    actionButton(inputId = ns("action_button"), label = "Filter"),
    p(),
    h3("Result"),
    tabsetPanel(
      type = "tabs",
      id = ns("result"),
      tabPanel(
        "All in One",
        p(),
        DTOutput(ns("dt"))
      )
    )
  )
}

filterDataframeTabPanelServer <- function(id, object_data_frame) {
  moduleServer(id, function(input, output, session) {
    filter_input_values <- reactiveVal(character(0))

    observeEvent(input$action_button, {
      object_instance <- object_data_frame
      object_instance$process_data()

      filter_values <- vectorize_input_text(input$filter_input_text)

      filtered_df <- filter_df_based_on_classname(
        r6_object_instance = object_instance,
        input_id = input$filter_radio,
        filter_values = filter_values
      )

      output$dt <- DT::renderDataTable(filtered_df)

      if (length(filter_input_values()) > 1) {
        values <- filter_input_values()

        for (value in values) {
          removeTab(inputId = "result", target = value)
        }
      }

      filter_input_values(filter_values)

      if (length(filter_values) > 1) {
        filtered_df_per_value <- NULL

        for (i in 1:length(filter_values)) {
          insertTab(
            inputId = "result",
            tabPanel(
              filter_values[i],
              DTOutput(NS(id, filter_values[[i]]))
            ),
            target = "All in One"
          )

          filtered_df_per_value[[i]] <- filter_df_per_value_based_on_classname(
            r6_object_instance = object_instance,
            input_id = input$filter_radio,
            filtered_df = filtered_df,
            filter_value = filter_values[i]
          )

          local({
            local_df <- filtered_df_per_value[[i]]

            output[[filter_values[i]]] <- DT::renderDataTable(local_df)
          })
        }
      }
    })
  })
}

getFilterDataFrameRadioButtonLabel = function(mainTabPanelValue){
  label <- switch (mainTabPanelValue,
                   "InsolvencyLegalPersonProceedings" = "Filter enterprise under insolvency proceeding",
                   "EnterprisesOwners" = "Filter enterprise owners"
  )
  return(label)
}

getFilterDataFrameRadioButtonChoises = function(mainTabPanelValue){
  choises_list <- switch (mainTabPanelValue,
                          "InsolvencyLegalPersonProceedings" = list(
                            "by enterprise registration number" = 1,
                            "by enterprise name" = 2
                          ),
                          "EnterprisesOwners" = list(
                            "by enterprise registration number" = 1,
                            "by enterprise owner name" = 2
                          )

  )
  return(choises_list)
}

filter_df_based_on_classname <- function(r6_object_instance, input_id, filter_values) {
  filtered_df <- switch(class(r6_object_instance)[1],
    "EnterprisesUnderInsolvencyProceeding" = switch(input_id,
      "1" = r6_object_instance$filter_by_enterprise_registration_number(filter_values),
      "2" = r6_object_instance$filter_by_enterprise_name(filter_values)
    ),
    "EnterprisesOwners" = switch(input_id,
      "1" = r6_object_instance$filter_dataframes_by_enterprise_registration_number(filter_values),
      "2" = r6_object_instance$filter_dataframes_by_name(filter_values)
    )
  )
  return(filtered_df)
}

filter_df_per_value_based_on_classname <- function(r6_object_instance, input_id, filtered_df, filter_value) {
  filtered_df_per_value <- switch(class(r6_object_instance)[1],
    "EnterprisesUnderInsolvencyProceeding" = switch(input_id,
      "1" = filtered_df %>% dplyr::filter(debtor_registration_number == filter_value),
      "2" = filtered_df %>% dplyr::filter((debtor_name %>% toupper()) %like% (filter_value %>% toupper()))
    ),
    "EnterprisesOwners" = switch(input_id,
      "1" = filtered_df %>% dplyr::filter(at_legal_entity_registration_number == filter_value),
      "2" = filtered_df %>% dplyr::filter((name %>% toupper()) %like% (filter_value %>% toupper()))
    )
  )
  return(filtered_df_per_value)
}
