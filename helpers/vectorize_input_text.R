vectorize_input_text = function(textInput_id, separator = ";"){
  return(textInput_id %>%
           stringr::str_split(pattern = separator) %>%
           base::unlist() %>%
           OpenDataEnterprises::trim_remove_whitespaces_and_empty_values_from_character_vector()
         )
}
