library(shiny)

library(ggplot2)

fluidPage(
  titlePanel("CLOSM - Data Catalogue"),
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           shiny::selectizeInput(inputId = "data_holding",
                       label = "Data Holding",
                       choices = NULL)
    ),
    column(4,
           selectInput("lib",
                       "Library",
                       c("All",
                         unique(as.character(metadata_import$var_lib))))
    ),
    column(4,
           selectInput("dataset",
                       "Dataset",
                       c("All",
                         unique(as.character(metadata_import$var_ds))), selectize = )
    ),
    column(4,
           selectInput("lang_var",
                       "Language variable",
                       c("All",
                         unique(as.character(metadata_import$lang_var_confirmed_VMS))))
    ),
    column(4,
           selectInput("lang_off",
                       "Official Language",
                      c("All",
                         unique(as.character(metadata_import$lang_var_confirmed_VMS))))
    )),
  # Create a new row for the table.
    DT::dataTableOutput("table")
  )
