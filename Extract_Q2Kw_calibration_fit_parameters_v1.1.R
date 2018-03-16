# March 9, 2018

# Script to extract fit parameters from QUAL2Kw output
# Modified to fit hourly summaries of average min and max of dissolved oxygen, temperature, and pH

# Dan Sobota, ODEQ

# Set working directory (modify as needed)----
setwd("\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\Upper Yaquina River - 1710020401\\QUAL2Kw\\2016\\July")

Q2Kw.out <- list.files(pattern = "*.out")
Q2Kw.out <- Q2Kw.out[!grepl("oldph.out", Q2Kw.out)] # Un-needed file name

# scan in file and process----
Q2Kw.output <- scan(Q2Kw.out, what = "character", sep = "\n")

# Grab sample water quality parameters used to fit model during autocalibration process----
# Parameters are: average, min, and max pH (from continuous data)
#                 CBODfast
#                 Organic N
#                 Ammonium N
#                 Nitrate + nitrite
#                 Organic P
#                 Inorganic P
#                 Water Temperature
#                 Dissolved Oxygen

# Will need to manually adjust what sites are extracted

# Average values for parameters----

Avg.grab.loc <- grep("Daily average water quality summary for main channel", Q2Kw.output)[1] #First occurence is the target line
Avg.grab.nm.loc <- Avg.grab.loc + 1 
Avg.grab.sites <- c(Avg.grab.loc + 8, Avg.grab.loc + 9, Avg.grab.loc + 11) # Need to manually set based on site locations

Avg.grab.data <- Q2Kw.output[Avg.grab.sites]

Q2Kw.list <- list()

# Seperate data on at least two spaces then create data frame using rbind
for (y in 1:length(Avg.grab.data)) {
  Q2Kw.list[[y]] <- as.data.frame(strsplit(Avg.grab.data[y], split = "  "))
  names(Q2Kw.list[[y]]) <- y
  Q2Kw.list[[y]] <- t(Q2Kw.list[[y]])
}

# Get names of columns
Avg.grab.nm <- as.data.frame(strsplit(Q2Kw.output[Avg.grab.nm.loc], split = "  "))
names(Avg.grab.nm) <- "Parameter.nm"
Avg.grab.nm <- Avg.grab.nm[!apply(Avg.grab.nm == "", 1, all),]
grab.nm <- paste(Avg.grab.nm)
grab.nm <- sub(" ", "", grab.nm)

# Get rid of blanks
Avg.grab.nm <- Avg.grab.nm[!sapply(Avg.grab.nm, function(x) all(x == ""))]

# Set blank data frame
Q2Kw.df <- data.frame(stringsAsFactors = F)

# Build dataframe with rbind fill so that empty cells don't repeat
for (z in 1:length(Q2Kw.list)) {
  Q2Kw.df <- rbind(Q2Kw.df, as.data.frame(Q2Kw.list[[z]], 
                                          stringsAsFactors = F))
}

# Get rid of blanks
Q2Kw.df <- Q2Kw.df[!sapply(Q2Kw.df, function(x) all(x == ""))]

# Give columns the appropriate names
names(Q2Kw.df) <- grab.nm

# Extract average grab sample data for assessment of fit
Grab.fit.pm.avg <- subset(Q2Kw.df, select = c("Reach", "Fast CBOD", "Organic N", "NH4-N", "NO3+NO2-N", "Organic P", "Inorganic P"))

# Extracting temporal data for average, minimum, and maximum temperature, dissolved oxygen, and pH----
Cont.loc <- grep("Diel water quality in the main channel", Q2Kw.output)[1] #First occurence is the target line
Cont.nm.loc <- Cont.loc + 1
# Need to manually set based on site locations
Reach.5 <- seq(649, 777, 1) # Reach 5
Reach.6 <- seq(778, 906, 1) # Reach 6
Reach.8 <- seq(1036, 1164, 1) # Reach 8

Cont.sites <- c(Cont.loc + Reach.5, # Reach 5
                Cont.loc + Reach.6, # Reach 6
                Cont.loc + Reach.8) # Reach 8

Cont.data <- Q2Kw.output[Cont.sites]

Q2Kw.list <- list()

# Seperate data on at least two spaces then create data frame using rbind
for (y in 1:length(Cont.data)) {
  Q2Kw.list[[y]] <- as.data.frame(strsplit(Cont.data[y], split = "  "))
  names(Q2Kw.list[[y]]) <- y
  Q2Kw.list[[y]] <- t(Q2Kw.list[[y]])
}

# Get names of columns
Cont.nm <- as.data.frame(strsplit(Q2Kw.output[Cont.nm.loc], split = "  "))
names(Cont.nm) <- "Parameter.nm"
Cont.nm <- Cont.nm[!apply(Cont.nm == "", 1, all),]
Cont.nm <- paste(Cont.nm)
Cont.nm <- sub(" ", "", Cont.nm)

# Get rid of blanks
Cont.nm <- Cont.nm[!sapply(Cont.nm, function(x) all(x == ""))]

# Set blank data frame
Q2Kw.df <- data.frame(stringsAsFactors = F)

# Build dataframe with rbind fill so that empty cells don't repeat
for (z in 1:length(Q2Kw.list)) {
  Q2Kw.df <- rbind(Q2Kw.df, as.data.frame(Q2Kw.list[[z]], 
                                              stringsAsFactors = F))
}

# Get rid of blanks
Q2Kw.df <- Q2Kw.df[!sapply(Q2Kw.df, function(x) all(x == ""))]

# Give columns the appropriate names
names(Q2Kw.df) <- Cont.nm

# Extract temporal data for assessment of fit
Cont.fit.pm <- subset(Q2Kw.df, select = c("Reach", "Time", "Water temperature", "Dissolved Oygen", "pH"))
names(Cont.fit.pm) <- c("Reach", "Time", "Water temperature", "Dissolved Oxygen", "pH")

# Need to make average, min, and max calculations for each hour (averaging from 00-59)
# First need to make data the appropriate format
Cont.fit.pm$"Reach" <- as.factor(Cont.fit.pm$"Reach")
Cont.fit.pm$"Time" <- as.numeric(Cont.fit.pm$"Time")
Cont.fit.pm$"Water temperature" <- as.numeric(Cont.fit.pm$"Water temperature")
Cont.fit.pm$"Dissolved Oxygen" <- as.numeric(Cont.fit.pm$"Dissolved Oxygen")
Cont.fit.pm$"pH" <- as.numeric(Cont.fit.pm$"pH")

# Insert a factor for hour
Cont.fit.pm$hour <- trunc(Cont.fit.pm$"Time") # Truncates to hour for summary

# Make Hour a two digit integers
Cont.fit.pm$hour <- sprintf("%02d", as.integer(Cont.fit.pm$hour)) # 

# Summaries of statistics for hourly data
# DO first
Mean.DO <- aggregate(Cont.fit.pm$"Dissolved Oxygen", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), mean, na.rm = T) # Mean data
Mean.DO$pm <- "doave"
names(Mean.DO) <- c("Reach", "Hour", "Value", "Parameter")

Min.DO <- aggregate(Cont.fit.pm$"Dissolved Oxygen", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), min, na.rm = T) # Min data
Min.DO$pm <- "domin"
names(Min.DO) <- c("Reach", "Hour", "Value", "Parameter")

Max.DO <- aggregate(Cont.fit.pm$"Dissolved Oxygen", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), max, na.rm = T) # Max data
Max.DO$pm <- "domax"
names(Max.DO) <- c("Reach", "Hour", "Value", "Parameter")

DO.df <- rbind(Mean.DO, Min.DO, Max.DO)

# Temperature
Mean.temp <- aggregate(Cont.fit.pm$"Water temperature", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), mean, na.rm = T) # Mean data
Mean.temp$pm <- "tempave"
names(Mean.temp) <- c("Reach", "Hour", "Value", "Parameter")

Min.temp <- aggregate(Cont.fit.pm$"Water temperature", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), min, na.rm = T) # Min data
Min.temp$pm <- "tempmin"
names(Min.temp) <- c("Reach", "Hour", "Value", "Parameter")

Max.temp <- aggregate(Cont.fit.pm$"Water temperature", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), max, na.rm = T) # Max data
Max.temp$pm <- "tempmax"
names(Max.temp) <- c("Reach", "Hour", "Value", "Parameter")

temp.df <- rbind(Mean.temp, Min.temp, Max.temp)

# pH
Mean.pH <- aggregate(Cont.fit.pm$"pH", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), mean, na.rm = T) # Mean data
Mean.pH$pm <- "pHave"
names(Mean.pH) <- c("Reach", "Hour", "Value", "Parameter")

Min.pH <- aggregate(Cont.fit.pm$"pH", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), min, na.rm = T) # Min data
Min.pH$pm <- "pHmin"
names(Min.pH) <- c("Reach", "Hour", "Value", "Parameter")

Max.pH <- aggregate(Cont.fit.pm$"pH", list(Cont.fit.pm$Reach, Cont.fit.pm$hour), max, na.rm = T) # Max data
Max.pH$pm <- "pHmax"
names(Max.pH) <- c("Reach", "Hour", "Value", "Parameter")

pH.df <- rbind(Mean.pH, Min.pH, Max.pH)

# Compiled data frame
hourly.df <- rbind(DO.df, temp.df, pH.df)

# Get rid of extra space in Reach column
hourly.df$Reach <- gsub(" ", "", hourly.df$Reach)

# Make Reach a two digit integer
hourly.df$Reach <- sprintf("%02d", as.integer(hourly.df$Reach))

# Also need to make sure that 

# Combine parameters to make seperate result tag
hourly.df$Combined.nm <- paste0(hourly.df$Parameter, hourly.df$Reach, hourly.df$Hour)

# Make Combined.nm 14 spaces wide
hourly.df$Combined.nm <- sprintf("%-14s", hourly.df$Combined.nm)

# Make Value field display scientific notation
hourly.df$Value <- formatC(as.numeric(hourly.df$Value), format = "e", digits = 8)

# Make Value 14 spaces wide
hourly.df$Value <- sprintf("%-14s", hourly.df$Value)

# Compile grab data into one flat data frame----
# Make dataframe first
Q2Kw.flat.out <- tidyr::gather(Grab.fit.pm.avg, Parameter, Value, -Reach)

# Sub in requested names
Q2Kw.flat.out$Parameter <- gsub("Fast CBOD", "fcob", Q2Kw.flat.out$Parameter)
Q2Kw.flat.out$Parameter <- gsub("Organic N", "orgn", Q2Kw.flat.out$Parameter)
Q2Kw.flat.out$Parameter <- gsub("NH4-N", "nh4", Q2Kw.flat.out$Parameter)
Q2Kw.flat.out$Parameter <- gsub("NO3+NO2-N", "no3", Q2Kw.flat.out$Parameter, fixed = T) #Plus sign is a special character; fixed needs to be true
Q2Kw.flat.out$Parameter <- gsub("Organic P", "orgp", Q2Kw.flat.out$Parameter)
Q2Kw.flat.out$Parameter <- gsub("Inorganic P", "inorgp", Q2Kw.flat.out$Parameter)

# Get rid of extra space in Reach column
Q2Kw.flat.out$Reach <- gsub(" ", "", Q2Kw.flat.out$Reach)

# Make Reach two digit integers
Q2Kw.flat.out$Reach <- sprintf("%02d", as.integer(Q2Kw.flat.out$Reach))

# Combine parameters to make seperate result tag
Q2Kw.flat.out$Combined.nm <- paste0(Q2Kw.flat.out$Parameter, Q2Kw.flat.out$Reach)

# Make Combined.nm 14 spaces wide
Q2Kw.flat.out$Combined.nm <- sprintf("%-14s", Q2Kw.flat.out$Combined.nm)

# Make Value field display scientific notation
Q2Kw.flat.out$Value <- formatC(as.numeric(Q2Kw.flat.out$Value), format = "e", digits = 8)

# Make Value 14 spaces wide
Q2Kw.flat.out$Value <- sprintf("%-14s", Q2Kw.flat.out$Value)

# Make final data frames and write out to flat text file----
Q2Kw.flat <- subset(Q2Kw.flat.out, select = c("Combined.nm", "Value"))
hourly.flat <- subset(hourly.df, select =c("Combined.nm", "Value"))

# Write out flat text file
write.table(rbind(Q2Kw.flat, hourly.flat), "\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\PEST-Synthetic-data\\Dan-edits\\Q2Kw_output.txt", 
            row.names = F, col.names = F, quote = F, sep = "") # Change path as needed
