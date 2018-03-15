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

# Pull out data from specified range for model fit assessment----
# Range is midnight - 11:59 PM of July 26, 2016

Yaq.33112.26Jul <- subset(Yaq.33112, Date_time >= as.POSIXct("2016-07-26 00:00:00", tz = "America/Los_Angeles") & Date_time < as.POSIXct("2016-07-27 12:00:00", tz = "America/Los_Angeles"),
                          select = c("Date_time", "ODO_mg_L", "Temp", "pH"))
Yaq.33112.26Jul$Reach <- sprintf("%02d", 5)

Yaq.12301.26Jul <- subset(Yaq.12301, Date_time >= as.POSIXct("2016-07-26 00:00:00", tz = "America/Los_Angeles") & Date_time < as.POSIXct("2016-07-27 12:00:00", tz = "America/Los_Angeles"),
                          select = c("Date_time", "ODO_mg_L", "Temp", "pH"))
Yaq.12301.26Jul$Reach <- sprintf("%02d", 6)

Yaq.11476.26Jul <- subset(Yaq.11476, Date_time >= as.POSIXct("2016-07-26 00:00:00", tz = "America/Los_Angeles") & Date_time < as.POSIXct("2016-07-27 12:00:00", tz = "America/Los_Angeles"),
                          select = c("Date_time", "ODO_mg_L", "Temp", "pH"))
Yaq.11476.26Jul$Reach <- sprintf("%02d", 8)

# Build combined data frame
Yaq.26Jul <- rbind(Yaq.33112.26Jul, Yaq.12301.26Jul, Yaq.11476.26Jul)
Yaq.26Jul$Hour <- format(lubridate::floor_date(Yaq.26Jul$Date_time, "1 hour"), "%H") #Displays the hour

# Build text file for PEST format----
# Dissolved oxygen
Mean.DO.obs <- aggregate(Yaq.26Jul$ODO_mg_L, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), mean, na.rm = T) # Mean data
Mean.DO.obs$pm <- "doave"
names(Mean.DO.obs) <- c("Reach", "Hour", "Value", "Parameter")

min.DO.obs <- aggregate(Yaq.26Jul$ODO_mg_L, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), min, na.rm = T) # min data
min.DO.obs$pm <- "domin"
names(min.DO.obs) <- c("Reach", "Hour", "Value", "Parameter")

max.DO.obs <- aggregate(Yaq.26Jul$ODO_mg_L, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), max, na.rm = T) # max data
max.DO.obs$pm <- "domax"
names(max.DO.obs) <- c("Reach", "Hour", "Value", "Parameter")

# Temperature
Mean.Temp.obs <- aggregate(Yaq.26Jul$Temp, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), mean, na.rm = T) # Mean data
Mean.Temp.obs$pm <- "tempave"
names(Mean.Temp.obs) <- c("Reach", "Hour", "Value", "Parameter")

min.Temp.obs <- aggregate(Yaq.26Jul$Temp, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), min, na.rm = T) # min data
min.Temp.obs$pm <- "tempmin"
names(min.Temp.obs) <- c("Reach", "Hour", "Value", "Parameter")

max.Temp.obs <- aggregate(Yaq.26Jul$Temp, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), max, na.rm = T) # max data
max.Temp.obs$pm <- "tempmax"
names(max.Temp.obs) <- c("Reach", "Hour", "Value", "Parameter")

# pH
Mean.pH.obs <- aggregate(Yaq.26Jul$pH, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), mean, na.rm = T) # Mean data
Mean.pH.obs$pm <- "pHave"
names(Mean.pH.obs) <- c("Reach", "Hour", "Value", "Parameter")

min.pH.obs <- aggregate(Yaq.26Jul$pH, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), min, na.rm = T) # min data
min.pH.obs$pm <- "pHmin"
names(min.pH.obs) <- c("Reach", "Hour", "Value", "Parameter")

max.pH.obs <- aggregate(Yaq.26Jul$pH, list(Yaq.26Jul$Reach, Yaq.26Jul$Hour), max, na.rm = T) # max data
max.pH.obs$pm <- "pHmax"
names(max.pH.obs) <- c("Reach", "Hour", "Value", "Parameter")

# Combine data frames
Yaq.Jul26sum <- rbind(Mean.DO.obs, min.DO.obs, max.DO.obs, Mean.Temp.obs, min.Temp.obs, max.Temp.obs, Mean.pH.obs, min.pH.obs, max.pH.obs)
Yaq.Jul26sum$Combined.nm <- paste0(Yaq.Jul26sum$Parameter, Yaq.Jul26sum$Reach, Yaq.Jul26sum$Hour)

# Make Combined.nm 14 spaces wide
Yaq.Jul26sum$Combined.nm <- sprintf("%-14s", Yaq.Jul26sum$Combined.nm)

# Make Value field display scientific notation
Yaq.Jul26sum$Value <- formatC(as.numeric(Yaq.Jul26sum$Value), format = "e", digits = 8)

# Make Value 14 spaces wide
Yaq.Jul26sum$Value <- sprintf("%-14s", Yaq.Jul26sum$Value)

# Write out continuous data
write.table(subset(Yaq.Jul26sum, select = c("Combined.nm", "Value")), "\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\PEST-Synthetic-data\\Dan-edits\\Q2Kw_cont_obs.txt", 
            row.names = F, col.names = F, quote = F, sep = "") # Change path as needed
