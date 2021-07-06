library(shiny)

# Define server logic required to summarise a timesheet
shinyServer(function(input, output, session) {

    fileInput <- reactive({
        file <- input$file
        req(file)

        # load and preprocess data
        ts <- load_timesheet(file$datapath)

        # update month/year/project group inputs
        shiny::updateSelectInput(session, "month",
                                 choices = get_months(ts),
                                 selected = format(Sys.time(), "%B"))
        shiny::updateSelectInput(session, "year",
                                 choices = get_years(ts),
                                 selected = format(Sys.time(), "%Y"))
    
        file
    })

    output$summaryTable <- renderTable({
        file <- fileInput()
        req(file)
        get_summary(file$datapath, input$month, input$year)
    })

})
