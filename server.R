# --------------------------------------------------------------------------------------------------------
#
#   Would you rent or buy a home in the USA?
#
#   Description: 
#
#   This server side application computes multiple parameters to determine 
#   the present value of purchasing a residential property and the present
#   value of renting the same property.
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


# - Shiny Server function 
function(input, output) {
    
    # Reactive expression to compose a data frame containing all of
    # the input parameters and some derived values
    sliderValues <- reactive({
        
        # Compose data frame
        data.frame(
            Name = c("Area [sf]",
                     "Months",
                     "Inflation [%]",
                     "Opportunity Cost (delta) [%]",
                     "Monthly Rent per ft2 [$/sf]",
                     "Monthly Rent [$]",
                     "Rent Inflation [%]",
                     "Selling Price per ft2 [$/sf]",
                     "Selling Price [$]",
                     "Down Payment [%]",
                     "Down Payment [$]",
                     "Mortgage Rate [%]",
                     "Closing Costs [%]",
                     "Effective Tax_Rate [%]",
                     "Property Tax [%]",
                     "Home Owners Insurance [$]",
                     "Repair & Maintenance [%]"
                     ),
            Value = as.character(c(format(input$area, format="d", big.mark=','),
                                   input$Months,
                                   input$Inflation,
                                   input$Opportunity_Cost,
                                   input$rentPerSf,
                                   format(input$rentPerSf * input$area, format="d", big.mark=','),
                                   input$Rent_Inflation,
                                   input$sellingPricePerSf,
                                   format(input$sellingPricePerSf * input$area, format="d", 
                                          big.mark=','),
                                   input$Down_Payment,
                                   format(input$Down_Payment/100 * 
                                              input$sellingPricePerSf * input$area, format="d", 
                                          big.mark=','),
                                   input$Mortgage_Rate,
                                   input$Closing_Costs,
                                   input$Effective_Tax_Rate,
                                   input$Property_Tax,
                                   format(input$Home_Owner_Insurance, format="d", big.mark=','),
                                   input$Repair_Maintenance  
                                 )),
            stringsAsFactors=FALSE)
    }) 
    
    # Show the input parameters using an HTML table
    output$values <- renderTable({
        sliderValues()
    })
    
    
    # Prepare internal calculations NOT accounting for inflation
    # This is an observer to trigger recalculation if any dependency
    # changes (unlike a standard reactive object that uses lazy evaluation)
    calcValues <- reactiveValues()
         observe({    
             
             # Input values and derived items -----------------------------------------------------
             
             area <- input$area
             Months <- input$Months
             Inflation <- input$Inflation
             Mortgage_Rate <- input$Mortgage_Rate
             Opportunity_Cost <- input$Opportunity_Cost
             rentPerSf <- input$rentPerSf
             Monthly_Rent <- input$rentPerSf * input$area
             Rent_Inflation <- input$Rent_Inflation
             sellingPricePerSf <- input$sellingPricePerSf
             Selling_Price <- input$sellingPricePerSf * input$area
             Down_Payment <- input$Down_Payment
             Total_Down_Payment <- input$Down_Payment/100 * 
                                    input$area * input$Selling_Price
             Mortgage_Rate <- input$Mortgage_Rate
             Closing_Costs <- input$Closing_Costs
             Effective_Tax_Rate <- input$Effective_Tax_Rate
             Property_Tax <- input$Property_Tax
             Home_Owner_Insurance <-input$Home_Owner_Insurance
             Repair_Maintenance <- input$Repair_Maintenance
            
             # New calculations for cases WITHOUT inflation, rent inflation  -----------------------
             
             calcValues$month_mort_rate=(Mortgage_Rate/12)/100*
                                        (1-Effective_Tax_Rate/100)
             month_mort_rate=calcValues$month_mort_rate
             
             calcValues$month_opp_rate=((Opportunity_Cost+
                                        Mortgage_Rate)/12/100 )
             month_opp_rate=calcValues$month_opp_rate
             
             calcValues$month_inflation=(Inflation/12)/100
             month_inflation=calcValues$month_inflation
             
             calcValues$month_ren_inflation=(Rent_Inflation/12)/100
             month_ren_inflation=calcValues$month_ren_inflation
             
             calcValues$annual_opp_rate=((1+month_opp_rate)^12)-1
             annual_opp_rate=calcValues$annual_opp_rate
                 
             calcValues$mortgage_installment=month_mort_rate*
                            (Selling_Price-(Selling_Price*Down_Payment/100))/
                            (1-((1+month_mort_rate)^(-Months)))
             mortgage_installment=calcValues$mortgage_installment
             
             calcValues$Own1=Selling_Price*Down_Payment/100
             TOC_Down_Payment=calcValues$Own1
             
             calcValues$Own2=Selling_Price*Closing_Costs/100
             TOC_Closing_Costs=calcValues$Own2
             
             calcValues$Own3=mortgage_installment/month_opp_rate*
                            (1-(1/(1+month_opp_rate)^Months))
             TOC_Mortgage=calcValues$Own3
             
             calcValues$Own4=Home_Owner_Insurance/annual_opp_rate*
                            (1-(1/(1+annual_opp_rate)^(Months/12)))
             TOC_Property_Insurance=calcValues$Own4
             
             calcValues$Own5=Repair_Maintenance/100*Selling_Price/annual_opp_rate*
                            (1-(1/(1+annual_opp_rate)^(Months/12)))
             TOC_Repair_Maintenance=calcValues$Own5
             
             calcValues$Own6=Property_Tax*Selling_Price/100/annual_opp_rate*
                            (1-(1/(1+annual_opp_rate)^(Months/12)))
             TOC_Property_Tax=calcValues$Own6
             
             calcValues$OwnA=TOC_Property_Insurance*month_opp_rate/
                                (1-(1/(1+month_opp_rate)^Months))
             Monthly_Property_Insurance=calcValues$OwnA
             
             calcValues$OwnB=TOC_Repair_Maintenance*month_opp_rate/
                                (1-(1/(1+month_opp_rate)^Months))
             Monthly_Rapair_Maintenance=calcValues$OwnB
             
             calcValues$OwnC=TOC_Property_Tax*month_opp_rate/
                                (1-(1/(1+month_opp_rate)^Months))
             Monthly_Property_Tax=calcValues$OwnC
             
             calcValues$month_opp_cost=(mortgage_installment+Monthly_Property_Insurance+
                                        Monthly_Rapair_Maintenance+Monthly_Property_Tax)*
                                        annual_opp_rate
             month_opp_cost=calcValues$month_opp_cost
             
             calcValues$Own7=month_opp_cost/month_opp_rate*(1-(1/(1+month_opp_rate)^Months))
             TOC_Opportunity_Cost=calcValues$Own7
             
             calcValues$Total_Ownership_Cost=calcValues$Own1+calcValues$Own2+calcValues$Own3+
                                        calcValues$Own4+calcValues$Own5+calcValues$Own6+
                                        calcValues$Own7
             
             
             calcValues$Monthly_Rent=Monthly_Rent
             calcValues$Total_Rental_Cost=Monthly_Rent/month_opp_rate*
                                            (1-(1/(1+month_opp_rate)^Months))
             

             # New calculations for cases WITH inflation, rent inflation -----------------------
             
             calcValues$annual_mort_rate=((1+month_mort_rate)^12)-1
             
             # calcValues$annual_opp_rate=((1+month_opp_rate)^12)-1
             
             calcValues$annual_infl_rate=((1+month_inflation)^12)-1
             annual_infl_rate=calcValues$annual_infl_rate
             
             calcValues$annual_rent_infl_rate=((1+month_ren_inflation)^12)-1
             annual_rent_infl_rate=calcValues$annual_rent_infl_rate
             
             calcValues$annual_mortgage_installment=mortgage_installment*12
             
             calcValues$annual_infl_Own1 = TOC_Down_Payment
             
             calcValues$annual_infl_Own2 = TOC_Closing_Costs
             
             calcValues$annual_infl_Own3 = TOC_Mortgage
             
             calcValues$annual_infl_Own4=Home_Owner_Insurance/(annual_opp_rate-annual_infl_rate)*
                                        (1-((1+annual_infl_rate)/(1+annual_opp_rate))^(Months/12))

             calcValues$annual_infl_Own5=Repair_Maintenance/100*Selling_Price/
                                        (annual_opp_rate-annual_infl_rate)*
                                        (1-((1+annual_infl_rate)/(1+annual_opp_rate))^(Months/12))

             calcValues$annual_infl_Own6=Property_Tax*Selling_Price/100/
                                        (annual_opp_rate-annual_infl_rate)*
                                        (1-((1+annual_infl_rate)/(1+annual_opp_rate))^(Months/12))
             
             calcValues$annual_infl_OwnA=calcValues$annual_infl_Own4*annual_opp_rate/
                                            (1-(1/(1+annual_opp_rate)^(Months/12)))

             calcValues$annual_infl_OwnB=calcValues$annual_infl_Own5*annual_opp_rate/
                                            (1-(1/(1+annual_opp_rate)^(Months/12)))

             calcValues$annual_infl_OwnC=calcValues$annual_infl_Own6*annual_opp_rate/
                                            (1-(1/(1+annual_opp_rate)^(Months/12)))

             calcValues$annual_infl_Own7=month_opp_cost*12*annual_opp_rate/(month_opp_rate*12)/
                                            (annual_opp_rate-annual_infl_rate)*
                                            (1-((1+annual_infl_rate)/(1+annual_opp_rate))^(Months/12))
             
             calcValues$annual_infl_OwnD=calcValues$annual_infl_Own7*annual_opp_rate/
                                            (1-(1/(1+annual_opp_rate)^(Months/12)))             
             
             calcValues$Total_Infl_Ownership_Cost=calcValues$annual_infl_Own1+calcValues$annual_infl_Own2+
                                             calcValues$annual_infl_Own3+calcValues$annual_infl_Own4+
                                             calcValues$annual_infl_Own5+calcValues$annual_infl_Own6+
                                             calcValues$annual_infl_Own7
             
             
             calcValues$Total_Infl_Rental_Cost=Monthly_Rent*12*annual_opp_rate/(month_opp_rate*12)/
                                                (annual_opp_rate-annual_rent_infl_rate)*
                                                (1-((1+annual_rent_infl_rate)/
                                                (1+annual_opp_rate))^(Months/12))
             
             calcValues$annual_infl_Rent=calcValues$Total_Infl_Rental_Cost*annual_opp_rate/
                                            (1-(1/(1+annual_opp_rate)^(Months/12)))  
             
             
    })
    

    # Posting of estimated periodic values --------------------------------------------------------
         
    periodicEst <- reactive({
        
        # Define data frame using the calcValues object
        data.frame(
            
            Name = c("Mortgage Rate [%]",
                     "Opportunity Rate [%]",
                     "Inflation Rate [%]",
                     "Rent Inflation Rate [%]",
                     
                     "Mortgage Installment [$]",
                     "Property Insurance [$]",
                     "Repair Maintenance [$]",
                     "Property Tax [$]",
                     "Opportunity Cost [$]",
                     
                     "Rental Cost [$]" 

            ),

            # Output for monthly cases WITHOUT inflation and rent inflation  ----------------------
            
            Monthly_No_Infl = as.character(c(format(calcValues$month_mort_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$month_opp_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$month_inflation*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$month_ren_inflation*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   
                                   format(calcValues$mortgage_installment, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$OwnA, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$OwnB, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$OwnC, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$month_opp_cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   
                                   format(calcValues$Monthly_Rent, nsmall=0, digits = 0, scientific=FALSE, big.mark=',')

            )),
            
            # Output for annualized cases WITHOUT inflation and rent inflation  ----------------------
            
            Annual_No_Infl = as.character(c(format(12*calcValues$month_mort_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                                  format(12*calcValues$month_opp_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                                  format(12*calcValues$month_inflation*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                                  format(12*calcValues$month_ren_inflation*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                                  
                                                  format(12*calcValues$mortgage_installment, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                  format(12*calcValues$OwnA, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                  format(12*calcValues$OwnB, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                  format(12*calcValues$OwnC, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                  format(12*calcValues$month_opp_cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                  
                                                  format(12*calcValues$Monthly_Rent, nsmall=0, digits = 0, scientific=FALSE, big.mark=',')

            )),

            # Output for annualized cases WITH inflation and rent inflation  ----------------------
            

            Annual_Equiv_Infl = as.character(c(format(calcValues$annual_mort_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$annual_opp_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$annual_infl_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                   format(calcValues$annual_rent_infl_rate*100, nsmall=4, digits = 4, format="d", big.mark=','),
                                             
                                   format(calcValues$annual_mortgage_installment, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$annual_infl_OwnA, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$annual_infl_OwnB, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$annual_infl_OwnC, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                   format(calcValues$annual_infl_OwnD, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),

                                   format(calcValues$annual_infl_Rent, nsmall=0, digits = 0, scientific=FALSE, big.mark=',')

             )),

            stringsAsFactors=FALSE)
    })     
    
    output$periodic <- renderTable({
        periodicEst()
    })
    
    # Posting of estimated present values ---------------------------------------------------------
    totalsEst <- reactive({
        
        # Define data frame using the calcValues object
        data.frame(
            
            Name = c("Total Down Payment [$]",
                     "Total Closing Costs [$]",
                     "Total Mortgage [$]",
                     "Total Insurance [$]",
                     "Total Repair Maintenance [$]",
                     "Total Property Tax [$]",
                     "Total Opportunity Cost [$]",
                     "Present Value of Ownership Cost [$]", 
                     
                     "Present Value Rental Cost [$]"

            ),
            
            # Output for cases WITHOUT inflation and rent inflation  -----------------------
            
            Value_Without_Infl = as.character(c(format(calcValues$Own1, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own2, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own3, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own4, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own5, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own6, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Own7, digits = 0, scientific=FALSE, big.mark=','),
                                                format(calcValues$Total_Ownership_Cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                                
                                                format(calcValues$Total_Rental_Cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=',')
                                                
            )),
            
            # Output for cases WITH inflation, rent inflation  -----------------------
            
            
            Value_WIth_Infl = as.character(c(format(calcValues$annual_infl_Own1, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own2, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own3, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own4, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own5, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own6, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$annual_infl_Own7, digits = 0, scientific=FALSE, big.mark=','),
                                             format(calcValues$Total_Infl_Ownership_Cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=','),
                                             
                                             format(calcValues$Total_Infl_Rental_Cost, nsmall=0, digits = 0, scientific=FALSE, big.mark=',')
                                             
            )),
            
            stringsAsFactors=FALSE)
    })     
    
    output$totals <- renderTable({
        totalsEst()
    })
    
 
    recomm1 <- reactive({
        ifelse((calcValues$Total_Rental_Cost/calcValues$Total_Ownership_Cost) >1.0, 
               recomm1<- "Not considering inflation you should buy the property",
               recomm1<- "Not considering inflation you should rent the property"
        ) 
    })
    
    output$recommendation1 <- renderText({
        recomm1()
    })
    
    
    recomm2 <- reactive({
        ifelse((calcValues$Total_Infl_Rental_Cost/calcValues$Total_Infl_Ownership_Cost) >1.0, 
               recomm2<- "Considering the effects of inflation (rent, general) you should buy the property",
               recomm2<- "Considering the effects of inflation (rent, general) you should rent the property"
        ) 
    })
    
    output$recommendation2 <- renderText({
        recomm2()
    })

}