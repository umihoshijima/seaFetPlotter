# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# library(rsconnect)
# run this next line without uncommennting it
 # rsconnect::deployApp('~/Dropbox/SeaFET files/seaFetPlotter/')

library(shiny)
library(dplyr)
library(lubridate)
library(tools)
library(lubridate)

shinyServer(function(input, output) {
  
  dat = reactive({
    
    inFile = input$file1
    if (is.null(inFile)) return (NULL)
    dat = read.csv(inFile$datapath, header=input$header, skip=input$skip, 
                    sep = input$sep)
    #get rid of NA columns
    
    dat = dat[, !apply(is.na(dat), 2, all)]
    if(ncol(dat) == 12){

      #Some SeaFET models:
      colnames(dat) = c('time', 'V.batt', 'V.therm', 'V.FET.int', 'V.FET.ext',
                        'V.power.iso', 'T.controller', 'T.Durafet', 'pn', 'sn',
                        'pH.int', 'pH.ext')
    } else if(ncol(dat) == 11){

      #Older seafet models:
      colnames(dat) = c('time', 'V.batt', 'V.therm', 'V.FET.int', 'V.FET.ext',
                        'V.power.iso','T.controller', 'T.Durafet', 'pn',
                        'pH.int', 'pH.ext')
    }  
    else if(ncol(dat) == 10){

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
    dat$time = lubridate::ymd_hms(dat$time, tz = 'UTC')
    return(dat)
    
  })
  
  #shows the table on the first pane
  output$contents <- renderTable(dat())
  
  # Second pane: plot based on Skip. 
  output$batteryPlot = renderPlot({
    dat2 = dat()[input$skipBattery+1:nrow(dat()),]
    plot(lubridate::ymd_hms(dat2$time),dat2$V.batt, type = 'l',
         main = input$plot_title_diff)
    
  })
  # Second pane: range based on Skip. 
  output$battery_Range <- renderText({
    dat2 = dat()[input$skipBattery+1:nrow(dat()),]$V.batt
    dat2 = dat2[complete.cases(dat2)]
    range(dat2)
  })
  
  #Third pane: plot. 
  output$voltagePlot = renderPlot({
    par(mar=c(5.1,4.1,4.1,4.1))
    
    plot(V.FET.int ~ ymd_hms(time), data = dat(), type = 'l', ylim = c(input$v_in_min, input$v_in_max),
         main = input$plot_title_diff)

    par(new = TRUE)
    
    plot(V.FET.ext ~ ymd_hms(time), data = dat(), xaxt = 'n', yaxt = 'n', ylab = '', 
         xlab = '', col = 'red', type = 'l', ylim = c(input$v_out_min, input$v_out_max))
    axis(4, col = 'red')
    mtext('V.FET.ext', side = 4, line = 2)
  })
  # DiffPlot
  output$diffPlot = renderPlot({
    par(mar=c(5.1,4.1,4.1,4.1))
    a = dat()
    dat_diff = (a$pH.int - a$pH.ext)
    dat_diff = dat_diff - mean(dat_diff)
    plot(dat_diff ~ ymd_hms(dat()$time), type = 'l', ylim = c(input$pH_diff_min, input$pH_diff_max),
         main = input$plot_title_diff)
  })
  
  output$Vint_Range <- renderText({
    dat2 = dat()[input$skipBattery+1:nrow(dat()),]$V.FET.int
    dat2 = dat2[complete.cases(dat2)]
    range(dat2)
  })
  
  output$Vout_Range <- renderText({
    dat3 = dat()[input$skipBattery+1:nrow(dat()),]$V.FET.ext
    dat3 = dat3[complete.cases(dat3)]
    range(dat3)
  })
  
  output$pH_diff_range <- renderText({
    a = dat()
    dat_diff = (a$pH.int - a$pH.ext)
    dat_diff = dat_diff - mean(dat_diff)
    range(dat_diff)
  })
  
  output$title = renderText({
    inFile = input$file1
    basename(inFile$datapath)
    
  })
  
})
  

