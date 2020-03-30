# Gets COVID-19 data by city
# Ben Malburg
# Last updated 2020-03-28

# Installs and/or loads required packages
packages = c("lubridate", "dplyr", "wbstats", "data.table")
tmp = sapply(packages, function(pkg){
  if (!require(pkg, character.only = T)){
    install.packages(pkg)
    library(pkg, character.only = T)
  }
})

#### Data Loading ####
baseDir = normalizePath("~/Documents/Github/")

# data directory
dataDir = normalizePath(paste0(baseDir, "COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/"))

# data files
files = list.files(dataDir, pattern = ".csv")

# most recent data file
dataFile = max(files)

# path to most recent data file
dataFilePath = paste0(dataDir, "/", dataFile)

# load COVID-19 data
if (file.exists(dataFilePath)){
  data = read.csv(dataFilePath)
} else {
  print("Data file not loaded. Investigate why.")
}

# load World Bank data to get population by country for the last 5 years
popDataLast5 <- wb(indicator = "SP.POP.TOTL", startdate = year(today())-5, enddate = year(today()))

# load mapping file
map_country = read.csv(paste0(baseDir, "/air-routes/Reference/map_country.csv"), stringsAsFactors = F)

## Thoughts on the data, after exploring it a bit. 

# Doesn't include cities. Would need to...get another dataset to join, to get cities within these counties?
# But then the best I could do would be come up with a list of cities that are part of counties which
# have a lot of cases. And then feed that list of cities into Gremlin, and say "don't fly through any of these 
# cities". A bit of a blunt tool, but not horrible. Or, could map county to region in graph (harder, probably). 

# Doesn't include a lot of other country data? Because not much in UK. Might need to get more data? 
# Same source or different? Could get messy joining lots of different datasets. 

# Could try to find the perfect dataset with everything I need. Might be worth searching for an hour or two for that.
# For now, however, I'm going to take the quicker route, and just say "don't fly through countries with a high
# % of infection".

#### Data Cleaning ####
# For each country, only select the most recent year of population data
# Doing it this way in case there are some countries whose most recent 
# data is a bit behind other countries' most recent data. 
popData = popDataLast5 %>%
  group_by(country) %>%
  arrange(desc(date)) %>%
  slice(1) %>%
  ungroup()

# Check which countries from COVID-19 data are not in popData countries
missingCountries = data[!(data$Country_Region %in% popData$country),] %>%
  select(Country_Region) %>%
  unique()

# Few options at this point: 
# 1. String substitution
# 2. Mapping file

# Fill in this section with checkForMappingUpdates, recreating map_country if you find any, etc. 

# 3. Fuzzy string matching

# adist
test = adist(missingCountries$Country_Region[1], popData$country, ignore.case = T)
testMin = which.min(apply(test,MARGIN=2,min))
popData$country[testMin]

# agrep
vec1 <- c("Dog", "Cat", "Pony")
vec2 <- c("catty", "doggy", "fish", "ponyt")
hmm = sapply(vec1, agrep, vec2)

vec1 = missingCountries$Country_Region
vec2 = popData$country
hmm = sapply(vec1, agrep, vec2)

# 4. Other options?

# None of these are quick, accurate, dynamic, and free from manual work. 
# For now, I am going to use mapping file. 
# In the future, potentially go back and use one of the other options. 

# Join population data to COVID-19 data
# Have to modify the order of this a bit to use map_country. 
testdata = data %>%
  left_join(popData[,c("country", "value")], by = c("Country_Region" = "country")) %>%


  