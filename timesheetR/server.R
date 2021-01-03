library(shiny)

# Define server logic required to summarise a timesheet
shinyServer(function(input, output, session) {

    fileInput <- reactive({
        file <- input$file
        req(file)

        # load and preprocess data
        ts <- load_timesheet(file$datapath)

        # update month/year/project group inputs
        shiny::updateSelectInput(session, "month", choices = get_months(ts))
        shiny::updateSelectInput(session, "year", choices = get_years(ts))
    
        file
    })

    output$summaryTable <- renderTable({
        file <- fileInput()
        req(file)
        get_summary(file$datapath, input$month, input$year)
    })

})
