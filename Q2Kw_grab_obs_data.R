# March 15, 2018

# Compilation of observed grab samples for use in PEST calibration of QUAL2Kw

# Dan Sobota, ODEQ

# Database query----
channel <- RODBC::odbcConnect("ELEMENT-Repository")

# Set query to access data from appropriate sites (will need to manually adjust)
qry <- "SELECT * FROM dbo.Repo_Result WHERE Project = 'Yaquina River TMDL' AND (Sampled >= '2016-07-19 00:00:00') AND (Sampled <= '2016-07-28 00:00:00')"
data <- RODBC::sqlQuery(channel, qry, stringsAsFactors = FALSE, na.strings = "NA")
close(channel)

# Process retrieved data----

# Convert result to numeric
data$Result <- as.numeric(data$Result)

# Pull out data relevant for QUAL2Kw
require(magrittr) # Needed for piping
data %>% subset(Analyte == "Ammonia as N" | Analyte == "Nitrate/Nitrite as N" | Analyte == "Biochemical Oxygen Demand, Stream" | 
                Analyte == "Nitrogen, Total" | Analyte == "Orthophosphate as P" | Analyte == "Phosphate, Total as P",
                select = c(Sampled, Station_ID, SampleType, Analyte, Result)) %>%
        tidyr::spread(Analyte, Result) -> Q2K.spread.data

# Calculate Organic nutrients
Q2K.spread.data$orgn <- ifelse(is.na(Q2K.spread.data$`Ammonia as N`) == T,  Q2K.spread.data$`Nitrogen, Total` - Q2K.spread.data$`Nitrate/Nitrite as N`,
                              Q2K.spread.data$`Nitrogen, Total` - Q2K.spread.data$`Nitrate/Nitrite as N` - Q2K.spread.data$`Ammonia as N`)

Q2K.spread.data$orgp <- Q2K.spread.data$`Phosphate, Total as P` - Q2K.spread.data$`Orthophosphate as P`
  
# Organic nutrients cannot be less than zero  
Q2K.spread.data$orgn <- ifelse(Q2K.spread.data$orgn < 0, 0, Q2K.spread.data$orgn)
Q2K.spread.data$orgp <- ifelse(Q2K.spread.data$orgn < 0, 0, Q2K.spread.data$orgp)

# Get data into correct form for PEST----
# First need to exlcude specific stations and include only grab samples
Q2K.spread.data.GS <- subset(Q2K.spread.data, Station_ID != 1000 & Station_ID != 34454 & Station_ID != 34456 &
                               SampleType == "Grab Sample::GS")

# Aggrating for mean values (only ones used from fit assessment thus far)
mean.nh4.obs <- aggregate(Q2K.spread.data.GS$`Ammonia as N`, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T)
mean.nh4.obs$Parameter <- "nh4"
mean.nh4.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

mean.fcob.obs <- aggregate(Q2K.spread.data.GS$`Biochemical Oxygen Demand, Stream` * 1.46, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T) # constant to calculate fast CBOD
mean.fcob.obs$Parameter <- "fcob"
mean.fcob.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

mean.no3.obs <- aggregate(Q2K.spread.data.GS$`Nitrate/Nitrite as N`, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T)
mean.no3.obs$Parameter <- "no3"
mean.no3.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

mean.orgn.obs <- aggregate(Q2K.spread.data.GS$orgn, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T)
mean.orgn.obs$Parameter <- "orgn"
mean.orgn.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

mean.orgp.obs <- aggregate(Q2K.spread.data.GS$orgp, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T)
mean.orgp.obs$Parameter <- "orgp"
mean.orgp.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

mean.inorgp.obs <- aggregate(Q2K.spread.data.GS$`Orthophosphate as P`, list(Q2K.spread.data.GS$Station_ID), mean, na.rm = T)
mean.inorgp.obs$Parameter <- "inorgp"
mean.inorgp.obs$Reach <- c(8, 6, 5) # Need to manually assign reaches

# bind all data frames together
grab.obs <- rbind(mean.fcob.obs, mean.nh4.obs, mean.no3.obs, mean.orgn.obs, mean.orgp.obs, mean.inorgp.obs)
names(grab.obs) <- c("Station_ID", "Value", "Parameter", "Reach")

# Make a combined parameter name
grab.obs$Combined.nm <- paste0(grab.obs$Parameter, grab.obs$Reach)

# Make Combined.nm 14 spaces wide
grab.obs$Combined.nm <- sprintf("%-14s", grab.obs$Combined.nm)

# Make Value field display scientific notation
grab.obs$Value <- formatC(as.numeric(grab.obs$Value), format = "e", digits = 8)

# Make Value 14 spaces wide
grab.obs$Value <- sprintf("%-14s", grab.obs$Value)

# Write out continuous data
write.table(subset(grab.obs, select = c("Combined.nm", "Value")), "\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\PEST-Synthetic-data\\Dan-edits\\Q2Kw_grab_obs.txt", 
            row.names = F, col.names = F, quote = F, sep = "") # Change path as needed
