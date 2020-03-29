# Gets COVID-19 data by city
# Ben Malburg
# Last updated 2020-03-28

# Installs and/or loads required packages
packages = c("lubridate", "dplyr")
tmp = sapply(packages, function(pkg){
  if (!require(pkg, character.only = T)){
    install.packages(pkg)
    library(pkg, character.only = T)
  }
})

#### Data ####

# data directory
dataDir = normalizePath("~/Documents/Github/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/")

# data files
files = list.files(dataDir, pattern = ".csv")

# most recent data file
dataFile = max(files)

# path to most recent data file
dataFilePath = paste0(dataDir, "/", dataFile)

# load data
if (file.exists(dataFilePath)){
  data = read.csv(dataFilePath)
} else {
  print("Data file not loaded. Investigate why.")
}

## Thoughts on the data, after exploring it a bit. 

# Doesn't include cities. Would need to...get another dataset to join, to get cities within these counties?
# But then the best I could do would be come up with a list of cities that are part of counties which
# have a lot of case. And then feed that list of cities into Gremlin, and say "don't fly through any of these 
# cities". A bit blunt, but not horrible. Or, could map county to region in graph (harder, probably). 

# Doesn't include a lot of other country data? Because not much in UK. Might need to get more data? 
# Same source or different? Could get messy joining lots of different datasets. 


  