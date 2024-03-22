library(tidyverse)
library(ggplot2)


# import data
library(readr)

metadata_import <- readr::read_delim("../../data/var_all_consolidated.csv", 
                                     delim = "|", escape_double = FALSE, trim_ws = TRUE)



metadata_lang_manual_check <- read_csv(
  "~/Nextcloud/Documents-Starbook/Projects/A11-CLOSM/data/data_concordance_output_20240109.csv", 
  col_types = cols(`300339` = col_skip(), 
                   ds_ref = col_character(), tbl_name = col_character(), 
                   lang_var_confirmed_VMS = col_logical(), 
                   official_lang_var_VMS = col_logical(), 
                   lang_var_confirmed_CP = col_logical(), 
                   official_lang_var_CP = col_logical(), 
                   lang_var_concordance = col_logical(), 
                   lang_off_concordance = col_logical(), 
                   `0.980929394012633` = col_skip()))


metadata_raw <- dplyr::left_join(
  x = metadata_import,
  y = metadata_lang_manual_check,
  by = c("key",
         "var_name",
         "var_descr",
         "var_data_holding",
         "var_ds",
         "var_lib",
         "ds_ref",
         "tbl_name")
)



function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- metadata_import
    
    if (input$data_holding != "All") {
      data <- data[data$var_data_holding == input$data_holding,]
    }
    if (input$lib != "All") {
      data <- data[data$var_lib == input$lib,]
    }
    if (input$dataset != "All") {
      data <- data[data$var_ds == input$dataset,]
    }
    if (input$lang_var != "All") {
      data <- data[data$lang_var_confirmed_VMS == input$lang_var,]
    }
    if (input$lang_off != "All") {
      data <- data[data$official_lang_var_VMS == input$lang_off,]
    }
    data
  }))
  
}

