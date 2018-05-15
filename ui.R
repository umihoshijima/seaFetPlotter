
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

navbarPage('SeaFET QC',
           tabPanel('1. Instructions',
                    helpText('This program will take in a SeaFET file and output graphs and diagnostics. Follow the above tabs in order - each one has its own set of directions.')),
           tabPanel('2. Import Data',
                    sidebarLayout(
                      sidebarPanel(
                        helpText('Upload SeaFET file using dialog below. '),
                        fileInput('file1', 'Choose SeaFET File' ),
                        helpText('Are there column names (no for Martz)?'),
                        checkboxInput('header', 'Header', FALSE),
                        helpText('Comma separated is for .csv (Satlantic), tab separated for Martz.'),
                        radioButtons('sep', 'Separator',
                                     c(
                                       Tab='\t', Comma=','),
                                     '\t'),
                        helpText('You should see the data on the right  of this page. Decrease this number until it breaks, then go back. generally 8 or 21 for Martz SeaFETs. '),
                        numericInput('skip', 'Skip', 21,
                                     min = 0, max = 21),
                      textInput('plot_title_diff', 'Plot Titles', value = '')
                      ),
                      mainPanel(
                        tableOutput('contents')
                      )
                    )
           ),
           
           tabPanel('3. Battery Plot',
                    sidebarLayout(
                      sidebarPanel(
                        helpText('This is the number of lines skipped at the beginning. Use only if there are weird datea at the beginning'),
                        numericInput('skipBattery', 'Skip',0,min = 0, max = 100), 
                        helpText('Battery Range:'),
                        verbatimTextOutput('battery_Range')
                      ),
                      mainPanel(
                        plotOutput('batteryPlot')
                      )
                    )
           ),
           
           tabPanel('4. Voltages (in/out)',
                    sidebarLayout(
                      sidebarPanel(
                        helpText('This is the voltages of the in/out electrodes.'),
                        numericInput("v_in_min", "V_in min", value = .03, step = .01),
                        numericInput("v_in_max", "V_in max", value = .1, step = .01),
                        numericInput("v_out_min", "V_out min", value = -.95, step = .01),
                        numericInput("v_out_max", "V_out max", value = -.8, step = .01), 
                        helpText('V_int range (norm is .03 ~ .1):'),
                        verbatimTextOutput('Vint_Range'), 
                        helpText('V_out range (norm is -.95 ~ -.8):'),
                        verbatimTextOutput('Vout_Range')
                        
                        
                      ),
                      mainPanel(
                        plotOutput('voltagePlot')
                        
                      )
                    )
           ), 
           tabPanel('5. pH difference',
                    sidebarLayout(
                      sidebarPanel(
                        helpText('This is the difference in pH between the electrodes.'),
                        numericInput("pH_diff_min", "pH diff min", value = -.02, step = .001),
                        numericInput("pH_diff_max", "pH diff max", value = .02, step = .001),
                        helpText('pH_diff range'),
                        verbatimTextOutput('pH_diff_range')


                      ),
                      mainPanel(
                        plotOutput('diffPlot')

                      )
                    )
           )
           
)

