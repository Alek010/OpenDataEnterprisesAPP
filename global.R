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

source(file = "./modules/mod_filter_dataframe_tabpanel.R")
source(file = "./modules/mod_data_source_tabpanel.R")
source(file = "./modules/mod_admin_files_read_log.R")
source(file = "./modules/mod_admin_files_update.R")
source(file = "./modules/mod_about_versioning.R")

APP_VERSION <- "0.1.0"
