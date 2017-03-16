
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

navbarPage('SeaFET QC',
  tabPanel('Import Data',
    sidebarLayout(
      sidebarPanel(
        fileInput('file1', 'Choose SeaFET File' ),
        checkboxInput('header', 'Header', FALSE),
        radioButtons('sep', 'Separator',
          c(Comma=',',
            Tab='\t'),
          ','),
        numericInput('skip', 'Skip', 0,
          min = 0, max = 21)
      ),
      mainPanel(
        tableOutput('contents')
      )
    )
  ),
  tabPanel('Battery Plot',
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
  tabPanel('Voltages (in/out)',
      mainPanel(
        plotOutput('voltagePlot')
      )
  )
           
)
