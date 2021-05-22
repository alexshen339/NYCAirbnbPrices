library(curl)
library(shiny)
library(shinydashboard)
library(glue)
library(stringr)
library(jsonlite)

load(file = "R/selected_model.Rdata")


valid_neighborhoods = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island")

valid_room_types = c("Entire home/apt", "Private room", "Shared room")

ui <- dashboardPage(
    dashboardHeader(title = "NYC Airbnb Price Estimator"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Estimate Airbnb Price", tabName = "AirbnbPrice", icon = icon("dollar-sign")),
            menuItem("Report", tabName = "Report", icon = icon("sticky-note"))
        )
    ),
    
    dashboardBody(
        tabItems(
            tabItem(
                tabName = "AirbnbPrice",
                h2("NYC Airbnb Price Estimator"),
                p("Use this page to estimate the price of an Airbnb in NYC
          based on various factors."),
                fluidRow(
                    box(
                        width = 12,
                        selectInput(
                            inputId = "neighborhood",
                            label = "Neighborhood Group",
                            choices = valid_neighborhoods,
                            selected = "Manhattan"
                        ),
                        numericInput(
                            inputId = "minimumNights",
                            label = "Minimum Nights",
                            min = 1,
                            value= 1,
                        ),
                        selectInput(
                            inputId = "roomType",
                            label = "Room Type",
                            choices = valid_room_types,
                            selected = "Entire home/apt"
                        ),
                        numericInput(
                            inputId = "reviewsPerMonth",
                            label = "Reviews Per Month",
                            min = 1,
                            value= 1,
                        ),
                        numericInput(
                            inputId = "calculatedHostListingsCount",
                            label = "Number of Listings Per Host",
                            min = 1,
                            value= 1,
                        ),
                        numericInput(
                            inputId = "availability365",
                            label = "Number of Days Available for Booking when Listing",
                            min = 1,
                            value= 1,
                        ),
                    )
                ),
                fluidRow(
                    box(
                        width = 12,
                        htmlOutput("AirbnbOutput")
                    )
                )
            ),
            tabItem(tabName="Report", 
                    includeHTML("Project.html")
            )
        )
    )
)


server <- function(input, output, session) {
    output$AirbnbOutput = renderUI({
        neighborhood_group = input$neighborhood
        minimum_nights = input$minimumNights
        room_type = input$roomType
        reviews_per_month = input$reviewsPerMonth
        calculated_host_listings_count = input$calculatedHostListingsCount
        availability_365 = input$availability365
        
        new_dataframe = data.frame(
            neighborhood_group = neighborhood_group,
            room_type = room_type, 
            minimum_nights = minimum_nights,
            room_type = room_type,
            reviews_per_month = reviews_per_month, 
            calculated_host_listings_count = calculated_host_listings_count,
            availability_365 = availability_365
        )
        prices = round(exp(unname(predict(Selected_model, new_dataframe, interval = "prediction"))), 2)
        return(HTML(glue("<div><p>Estimated price: ${prices[1,1]}. Estimated range: between ${prices[1,2]} and ${prices[1,3]}</p></div>")))
    })
}

shinyApp(ui = ui, server = server)
