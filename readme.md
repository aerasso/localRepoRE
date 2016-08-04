Would you rent or buy a home in the USA?
================

Description:
------------

These applications compute multiple parameters to determine the present value of purchasing a residential property and the present value of renting the same property. On the UI side the application gathers multiple parameters to determine the present value of purchasing a residential property and the present value of renting the same property. This same application makes a recommendation. Calculations are stored on the server side.

Dependencies:
-------------

Libraries:

-   shiny - required for the shiny application

Developer usage:

-   Download the server.R and ui.R files from this repository and use runApp() to execute.
-   To see the code in action, you can use *runApp(displayMode = 'showcase')*

Default Values:
---------------

-   Parameters take common values for interest rates, inflation rates, and costs of ownership and rental as of April 2016 in the USA

Use:
----

Step 1 - In tab "Input Parameters" review the "Input and Calculated Values" . If correct then go to step 3, otherwise go to step 2.

Step 2 - On sidebar use the sliders to adjust the input values and press the "Update"" button. Go to step 1.

Step 3 - In tab "rent Buy Estimates" review tables with "Estimates of Periodic Values" and "Estimates of Present Value". Read the recommendations at the bottom.
