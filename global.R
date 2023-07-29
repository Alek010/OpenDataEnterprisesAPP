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

APP_VERSION <- "0.1.0"

source(file = "./helpers/vectorize_input_text.R")

source(file = "./modules/mod_filter_dataframe_tabpanel.R")
source(file = "./modules/mod_data_source_tabpanel.R")
source(file = "./modules/mod_admin_files_read_log.R")
source(file = "./modules/mod_admin_files_update.R")
source(file = "./modules/mod_about_versioning.R")

source(file = "./r6_classes/AppVersionsList.R", encoding = "UTF-8")
source(file = "./r6_classes/AppVersionsDataFrame.R")


