# docker build -t test .
# docker run -p 8080:8080 --rm -d test
library(shiny)
library(readr)
library(dplyr)
library(DT)
library(DBI)

# load pre-processed values for select inputs
var_lib_values <- readRDS("db/var_lib_values.RData")
var_data_holding_values <- readRDS("db/var_data_holding_values.RData")
var_ds_values <- readRDS("db/var_ds_values.RData")


 # metadata_import <- readr::read_delim("../../data/var_all_consolidated.csv", delim = "|", escape_double = FALSE, trim_ws = TRUE, n_max = 5000)

mydb <- DBI::dbConnect(RSQLite::SQLite(), "db/closm-db.sqlite")
# 
metadata_import <- dplyr::tbl(mydb, "metadata_trim") |> dplyr::collect()
# 
# metadata_import |> dplyr::select(var_data_holding) |> dplyr::distinct() |> dplyr::show_query()

# Define UI for application 
ui <- fluidPage(
  
  titlePanel("CLOSM - Data Catalogue"),
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           shiny::selectizeInput(inputId = "data_holding",
                                 label = "Data Holding",
                                 choices = c("All", var_data_holding_values))
    ),
    column(4,
           selectInput(inputId = "lib",
                       label = "Library",
                       choices = c("All", var_lib_values))
    ),
    column(4,
           selectInput(inputId = "dataset",
                       label = "Dataset",
                       choices = c("All", var_ds_values))
    )
    # ,
    # column(4,
    #        selectInput(inputId = "lang_var",
    #                    label = "Language variable",
    #                    choices = )
    # ),
    # column(4,
    #        selectInput(inputId = "lang_off",
    #                    label = "Official Language",
    #                    choices = "Loading...")
    # )
    ),
  # Create a new row for the table.
  DT::dataTableOutput("table")
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  

# 
#   shiny::updateSelectizeInput(
#     inputId = "lang_var",
#     choices = c("All",unique(as.character(metadata_import$lang_var_confirmed_VMS))),
#     server=TRUE)

  # shiny::updateSelectizeInput(
  #   inputId = "lang_off",
  #   choices =  c("All",unique(as.character(metadata_import$lang_var_confirmed_VMS))),
  #   server=TRUE)
  # 

  # Filter data based on selections
  # output$table <- DT::renderDataTable(DT::datatable(dplyr::collect(metadata_import)))
  output$table <- DT::renderDataTable(DT::datatable({
    data <- metadata_import

    if (!input$data_holding %in% c("All", "Loading...")) {
      #data <- data[data$var_data_holding == input$data_holding,]
      data <- dplyr::filter(data, var_data_holding == input$data_holding)
    }
    if (!input$lib %in% c("All", "Loading...")) {
      #data <- data[data$var_lib == input$lib,]
      data <- dplyr::filter(data, var_lib == input$lib)
    }
    if (!input$dataset %in% c("All", "Loading...")) {
      #data <- data[data$var_ds == input$dataset,]
      data <- dplyr::filter(data, var_ds == input$dataset)
    }
    # if (input$lang_var != "All") {
    #   # data <- data[data$lang_var_confirmed_VMS == input$lang_var,]
    #   data <- dplyr::filter(data, lang_var_confirmed_VMS == input$lang_var)
    # }
    # if (input$lang_off != "All") {
    #   # data <- data[data$official_lang_var_VMS == input$lang_off,]
    #   data <- dplyr::filter(data, official_lang_var_VMS == input$lang_off)
    # }
    data |> dplyr::collect()
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
