# docker build -t vincent-shiny-test .
#fly deploy --local-only --image vincent-shiny-test
library(shiny)
library(DT)
library(readr)
library(dplyr)


ui <- fluidPage(
  titlePanel("CLOSM - Data Catalogue"),
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           selectInput("data_holding",
                       "Data Holding",
                       choices = "Loading...")
    ),
    column(4,
           selectInput("lib",
                       "Library",
                       choices = "Loading...")
    ),
    column(4,
           selectInput("dataset",
                       "Dataset",
                       choices = "Loading...")
    ),
    column(4,
           selectInput("lang_var",
                       "Language variable",
                       choices = "Loading...")
    ),
    column(4,
           selectInput("lang_off",
                       "Official Language",
                       choices = "Loading...")
    ),
    # Create a new row for the table.
    DT::dataTableOutput("table")
  )
)





server <- function(input, output, session) {

  metadata_raw <- readr::read_csv("data/var-trimmed-2024-03-22.csv"
                                  #, n_max = 1000000
                                  )
  
  
  shiny::updateSelectInput(inputId = "data_holding",
                           label = "Data Holding",
                           choices = c("All",
                                       unique(as.character(metadata_raw$var_data_holding))))

  shiny::updateSelectInput(inputId = "lib",
                           label = "Library",
                           choices = c("All",
                             unique(as.character(metadata_raw$var_lib))))
  
  
  shiny::updateSelectInput(inputId = "dataset",
                           label = "Dataset",
                           choices = c("All",
                             unique(as.character(metadata_raw$var_ds))))
  
  
  shiny::updateSelectInput(inputId = "lang_var",
                           label = "Language variable",
                           choices = c("All",
                             unique(as.character(metadata_raw$lang_var_confirmed_VMS))))
  
  
  shiny::updateSelectInput(inputId = "lang_off",
                           label = "Official Language",
                           choices = c("All",
                             unique(as.character(metadata_raw$lang_var_confirmed_VMS))))
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- metadata_raw

    if (input$data_holding != "All") {
      data <- data[data$var_data_holding == input$data_holding,]
    }
    if (input$lib != "All") {
      data <- dplyr::filter(data, var_lib == input$lib)# data[data$var_lib == input$lib,]
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




# Run the application 
shinyApp(ui = ui, server = server, options = list(port=8080, host='0.0.0.0'))