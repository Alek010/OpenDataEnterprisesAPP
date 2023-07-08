library(R6)
library(httr)
library(magrittr)
library(digest)
library(data.table)
library(tidyr)
library(OpenDataEnterprises)

library(shiny)
library(shinybusy)
library(DT)
library(dplyr)
library(stringr)

source(file = "./helpers/vectorize_input_text.R")

source(file = "./modules/mod_filter_result.R")
