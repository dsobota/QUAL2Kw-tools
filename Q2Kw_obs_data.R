# March 15, 2018

# Merging together observed continuous and grab data

# Dan Sobota, ODEQ

# Set working directory----
setwd("\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\PEST-Synthetic-data\\Dan-edits")

# Load data----
Q2kw.cont <- read.table("Q2Kw_cont_obs.txt", header = F, stringsAsFactors = F)
Q2kw.grab <- read.table("Q2Kw_grab_obs.txt", header = F, stringsAsFactors = F)

# Make combined data frame and format correctly----
Q2kw.obs <- rbind(Q2kw.grab, Q2kw.cont)

# Make first column 14 spaces wide
Q2kw.obs[, 1] <- sprintf("%-14s", Q2kw.obs[, 1])

# Make Value field display scientific notation
Q2kw.obs[, 2] <- formatC(Q2kw.obs[, 2], format = "e", digits = 8)

# Make Value 14 spaces wide
Q2kw.obs[, 2] <- sprintf("%-14s", Q2kw.obs[, 2])

# Write out continuous data
write.table(Q2kw.obs, "\\\\deqhq1\\tmdl\\TMDL_WR\\MidCoast\\Models\\Dissolved Oxygen\\PEST-Synthetic-data\\Dan-edits\\Q2Kw_obs.txt", 
            row.names = F, col.names = F, quote = F, sep = "") # Change path as needed