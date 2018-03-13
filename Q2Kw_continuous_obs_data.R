# March 13, 2018

# R script to read in, process, and write out continous observed data for PEST optimization of QUAL2Kw

# Dan Sobota (sobota.daniel@deq.state.or.us; 503-229-5138)

# set working directory----
# Change as needed
setwd("\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\Upper Yaquina River - 1710020401\\QUAL2Kw\\2016\\Input data\\Water quality\\July\\PEST_data")

# Read files----
# Change as needed
options(stringsAsFactors = F)

Yaq.34454 <- read.csv("st34454_July2016.csv")

Yaq.33112 <- read.csv("st33112_July2016.csv")

Yaq.12301 <- read.csv("st12301_July2016.csv")

Yaq.11476 <- read.csv("st11476_July2016.csv")

# Clean up dates and times----
Yaq.34454$Date_time <- as.POSIXct(paste(Yaq.34454$Date..MM.DD.YYYY.,
                                Yaq.34454$Time..HH.MM.SS.), format = "%m/%d/%Y %H:%M:%S", tz="America/Los_Angeles")

Yaq.33112$Date_time <- as.POSIXct(paste(Yaq.33112$Date..MM.DD.YYYY.,
                                        Yaq.33112$Time..HH.MM.SS.), format = "%m/%d/%Y %H:%M:%S", tz="America/Los_Angeles")

Yaq.12301$Date_time <- as.POSIXct(paste(Yaq.12301$Date,
                                        Yaq.12301$Time), format = "%m/%d/%Y %H:%M:%S", tz="America/Los_Angeles")

Yaq.11476$Date_time <- as.POSIXct(paste(Yaq.11476$Date..MM.DD.YYYY.,
                                        Yaq.11476$Time..HH.MM.SS.), format = "%m/%d/%Y %H:%M:%S", tz="America/Los_Angeles")

# Clean up header names because of inconsistent file format and syntax stuff----
names(Yaq.34454) <- c("Date", "Time", "Time_Fract.Sec", "Site_Name", "Batt_volts",
                        "Temp", "SpCond_5S_cm", "Sal_psu", "ODO_sat", "ODO_mg_L", "pH",
                        "Turbidity_FNU", "Depth", "Date_time")

names(Yaq.33112) <- c("Date", "Time", "Time_Fract.Sec", "Site_Name", "Batt_volts",
                        "Temp", "SpCond_5S_cm", "ODO_sat", "ODO_mg_L", "pH", "Turbidity_FNU",
                        "Depth", "Date_time")

names(Yaq.12301) <- c("Date", "Time", "Temp", "SpCond_5S_cm",
                        "Depth", "pH", "ODO_mg_L", "ODO_sat", "Date_time")

names(Yaq.11476) <- c("Date", "Time", "Time_Fract.Sec", "Site_Name", "Batt_volts",
                        "Temp", "SpCond_5S_cm", "Sal_psu", "ODO_sat", "ODO_mg_L", "pH",
                        "Depth", "Date_time")

# Pull out data from specified range----
# Range is midnight - 11:59 PM of July 26, 2016




# Create data list----
Yaq.station.list <- list(Yaq.34454, Yaq.33112, Yaq.12301, Yaq.11476, Yaq.34456)
names(Yaq.station.list) <- c("34454", "33112", "12301", "11476", "34456")