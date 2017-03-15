# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(lubridate)
library(tools)
library(lubridate)

shinyServer(function(input, output) {
  
  
  
  
  
  output$contents <- renderTable({
    inFile <- input$file1
    if (is.null (inFile))
      return(NULL)
    
    dat = read.csv(inFile$datapath, header=input$header, skip=input$skip, 
      sep = input$sep)
    
    if(ncol(dat) == 12){
      
      #Some SeaFET models:
      colnames(dat) = c('time', 'V.batt', 'V.therm', 'V.FET.int', 'V.FET.ext',
        'V.power.iso', 'T.controller', 'T.Durafet', 'pn', 'sn',
        'pH.int', 'pH.ext')
    } else if(ncol(dat) == 11){
      
      #Older seafet models:
      colnames(dat) = c('time', 'V.batt', 'V.therm', 'V.FET.int', 'V.FET.ext',
        'V.power.iso', 'T.Durafet', 'pn',
        'pH.int', 'pH.ext')
    }  else if(ncol(dat) == 10){
      
      #Older seafet models:
      colnames(dat) = c('time', 'V.batt', 'V.therm', 'V.FET.int', 'V.FET.ext',
        'V.power.iso', 'T.controller', 'T.Durafet', 'pn',
        'pH.int', 'pH.ext')
      
    }else if (ncol(dat) == 25){
      years = floor(dat$V2/1000)
      # get the remainder of column 2 after dividing by 1000 - this is days of the year
      days = dat$V2%%1000
      # Take years and days, comine them to form date. Column 3 is fractional hours, multiply by 60 to get minutes, multiply again by 60 to get seconds. Add to POSIXct output and save as new column.
      dat$ymd = as.POSIXct(paste(years, days), format = '%Y %j', tz = 'UTC') + dat$V3*60*60
      #round to nearest minute, as sometimes they log a few seconds off of programmed time.
      dat$time = round(dat$ymd, 'mins')
      dat$pH.int = dat$V4
      dat$pH.ext = dat$V5
      dat$temp = dat$V6
      dat$V.FET.int = dat$V11
      dat$V.FET.ext = dat$V12
      dat$V.therm = dat$V13
      dat$V.batt = dat$V14
      #satlantics that spit out a single file natively:
    } else if (ncol(dat) == 16) {
      
      #Some satlantics have 16. whoooo!
      years = floor(dat$V2/1000)
      # get the remainder of column 2 after dividing by 1000 - this is days of the year
      days = dat$V2%%1000
      # Take years and days, comine them to form date. Column 3 is fractional hours, multiply by 60 to get minutes, multiply again by 60 to get seconds. Add to POSIXct output and save as new column.
      dat$ymd = as.POSIXct(paste(years, days), format = '%Y %j', tz = 'UTC') + dat$V3*60*60
      dat$time = round(dat$ymd, 'mins')
      
      dat$pH.int = dat$V4
      dat$pH.ext = dat$V5
      dat$temp = dat$V6
      dat$V.FET.int = dat$V7
      dat$V.FET.ext = dat$V8
      dat$V.therm = dat$V9
      dat$V.batt = dat$V10
      
      
    } else {
      #Satlantics should have 27.
      #let's just rename the ones we care about for now...
      
      dat$time = dat$ymd
      dat$pH.int = dat$V4
      dat$pH.ext = dat$V5
      dat$temp = dat$V6
      dat$V.FET.int = dat$V11
      dat$V.FET.ext = dat$V12
      dat$V.therm = dat$V13
      dat$V.batt = dat$V14
    }
    
    dat
    
  })
  
})
# 
#     plot(dat$pH.int)
#     # dat$time =  ymd_hms(dat$time, tz = 'UTC')
# 
#     # plot(dat$time, dat$pH.int)



