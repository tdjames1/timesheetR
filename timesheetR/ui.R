library(shiny)

# Define UI for application that summarises a timesheet
shinyUI(fluidPage(

    titlePanel("Timesheet Summary"),

    # Sidebar with controls for file upload and date selection
    sidebarLayout(
        sidebarPanel(
            shiny::fileInput("file", "Choose file"),
            shiny::selectInput("month", "Month", choices = month.name),
            shiny::selectInput("year", "Year", choices = format(Sys.Date(), "%Y")),
            # TODO add select input for project groups
        ),

        # Show timesheet summary
        mainPanel(
            shiny::tableOutput("summaryTable")
        )
    )
))