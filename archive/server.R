library(tidyverse)
library(ggplot2)


# import data
library(readr)
metadata_import <- readr::read_delim("../../data/var_all_consolidated.csv", 
                                     delim = "|", escape_double = FALSE, trim_ws = TRUE, n_max = 500)

shiny::updateSelectizeInput(session, 
                            inputId = "data_holding",
                            choices = c("All", unique(as.character(metadata_import$var_data_holding))),
                            server=TRUE
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
  }, 
  options = list(
  pageLength = 10,      # Set number of rows per page
    autoWidth = TRUE,     # Adjust column width automatically
    searchHighlight = TRUE,  # Highlight search results
    search = list(regex = TRUE, caseInsensitive = TRUE),  # Enable regex, case-insensitive search
    scrollX = TRUE        # Enable horizontal scrolling
  ),
  filter = 'top' ))
  
}

