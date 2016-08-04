# --------------------------------------------------------------------------------------------------------
#
#   Would you rent or buy a home in the USA?
#
#   Description: 
#
#   This UI side application gathers multiple parameters to determine 
#   the present value of purchasing a residential property and the present
#   value of renting the same property. This same application provides the output 
#   and makes a recommendation.
#   
#   Dependencies:
#
#   Libraries:
#    
#   - shiny - required for the shiny application
#   
#   Developer usage:
#    
#   - Download the server.R and ui.R files from this repository and use runApp() to execute.
#   - To see the code in action, you can use 
#           runApp(displayMode = 'showcase')
#
#   Default Values:
#
#   - Parameters take common values for interest rates, inflation rates, and costs of
#   ownership and rental as of April 2016 in the USA
#
# --------------------------------------------------------------------------------------------------------

library(shiny)


# Define UI for fluid layout
fluidPage(
    
    # Application title
    titlePanel("Would you rent or buy a home in the USA?"),
    
    br(),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            
            helpText("Use the sliders to adjust the input values and press the Update button."),
            
            submitButton("Update"),
            
            br(),
            
            # Area of the property - Simple integer interval
            sliderInput("area", "Area [sf]:",
                        min=100, max=15000, value=2000),
            
            # Time horizon in months - Simple integer interval
            sliderInput("Months", "Months:",
                        min=12, max=360, value=180),
            
            # Inflation - Decimal interval with step value
            sliderInput("Inflation", "Inflation [%]:",
                        min = -2, max = 10, value = 1.0, step= 0.1),
            
            # Opportunity Cost (Delta over Mortgage Rate) - Decimal 
            sliderInput("Opportunity_Cost", "Opportunity Cost (delta over mortgage) [%]:",
                        min = 0, max = 4, value = 1.5, step= 0.1),

            # Monthly Rent per square foot - Custom currency format with  animation
            sliderInput("rentPerSf", "Monthly Rent per square foot [$/sf]:",
                        min = 0, max = 10, value = 2, step = 0.1,
                        pre = "$", sep = ",", animate=TRUE),
            
            # Rent Inflation - Decimal interval with step value
            sliderInput("Rent_Inflation", "Rent Inflation [%]:",
                        min = -2, max = 10, value = 1.0, step= 0.1),

            # Selling Price per square foot - Custom currency format with  animation
            sliderInput("sellingPricePerSf", "Selling Price per square foot [$/sf]:",
                        min = 0, max = 2000, value = 200, step = 10,
                        pre = "$", sep = ",", animate=TRUE),
            
            # Down_Payment - Simple integer interval
            sliderInput("Down_Payment", "Down Payment [%]:",
            min = 0, max = 100, value = 15),

            # Mortgage_Rate - Decimal interval with step value
            sliderInput("Mortgage_Rate", "Mortgage Rate [%]:",
                        min = 0, max = 10, value = 4.0, step= 0.1),

            # Closing_Costs - Decimal interval with step value
            sliderInput("Closing_Costs", "ClosingCosts [%]:",
                        min = 0, max = 2.5, value = 1.0, step= 0.1),

            # Effective_Tax_Rate - Simple integer interval
            sliderInput("Effective_Tax_Rate", "Effective Tax Rate [%]:",
                        min = 0, max = 40, value = 15),

            # Property_Tax - Decimal interval with step value
            sliderInput("Property_Tax", "Property Tax [%]:",
                        min = 0, max = 3, value = 1.25, step= 0.25),

            # Home_Owner_Insurance - Custom currency format with animation
            sliderInput("Home_Owner_Insurance", "Home Owners Insurance [$]:",
                        min = 0, max = 10000, value = 500, step = 50,
                        pre = "$", sep = ",", animate=TRUE),

            # Repair_Maintenance - Decimal interval with step value
            sliderInput("Repair_Maintenance", "Repair & Maintenance [%]:",
                        min = 0, max = 5, value = 1.5, step= 0.25)
            

        ),
        
        # Show different tabs in the main panel
        mainPanel(
            
           # h4("Summary"),
            tabsetPanel(type = "tabs", 
                        tabPanel("Input Parameters", 
                                p(h4("Input and Calculated Values")),
                                tableOutput("values")
                                 ),
                        tabPanel("Rent Buy Estimates",
                                 p(h4("Estimates of Periodic Values")),
                                 tableOutput("periodic"),
                                 p(h4("Estimates of Present Value")),
                                 tableOutput("totals"),     
                                 p(tags$strong(h5(textOutput("recommendation1")))),
                                 p(tags$strong(h5(textOutput("recommendation2")))),
                                 p(h5("Note: These calculations do not include the tax benefit of deducting interest expense"))
                                 )
                        
            )

        )
    )
)