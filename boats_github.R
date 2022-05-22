library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(writexl)

rawdata <- read.csv("C:/Users/zuzan/Desktop/Data_analysis/GitHub/Portfolio_projects/Boats_DataCamp/Boats_github/Github_boat_data.csv", na.string ="")
#write_xlsx(rawdata, "C:/Users/zuzan/Desktop/Data_analysis/GitHub/Portfolio_projects/Boats_DataCamp//Preview.xlsx")

# head(rawdata)
#str(rawdata)
#View(rawdata)



#### CLEANING ####

data <- rawdata

### Price #####
# in the 'Price' column - British pound is written as Ã‚Â£ - replace by GBP
data$Price <- str_replace(data$Price,  "Ã‚Â£", "GBP")
# column price is in format: 'EUR 12500' -> split it into two columns called Currency and Price_home_curr
data <- data %>% separate(Price, c('Currency', 'Price_home_curr'))
# add column where all the prices are in EUR
unique(data$Currency) # we have 4 different currencies: CHF, DKK, EUR, GBP
data$Currency <- as.factor(data$Currency)
data$Price_home_curr <- as.numeric(data$Price_home_curr)
data$Price_Eur <- as.numeric(data$Price_home_curr)

# calculate all the prices in Eur
for (i in 1:nrow(data)){
  if (data$Currency[i] %in% ("CHF")){data$Price_Eur[i] <- (data$Price_Eur[i] * 0.975)}
  if (data$Currency[i] %in% ("DKK")){data$Price_Eur[i] <- (data$Price_Eur[i] * 0.134)}
  if (data$Currency[i] %in% ("GBP")){data$Price_Eur[i] <- (data$Price_Eur[i] * 1.18)}
  if (data$Currency[i] %in% ("EUR")){data$Price_Eur[i] <- (data$Price_Eur[i])} 
}


### Type and Producer ####
data$Type <- as.factor(data$Type)
data$Producer <- as.factor(data$Producer)

####   Characteristics   ####
    # 'Characteristics' variable contains messy information which can be split into multiple categories:
    #Used vs New, Fuel, Model

## USed vs New  ##
data2 <- data
data2$Characteristics2 <- data2$Charactersitics #duplicate the column
data2 <- data2 %>% separate(Characteristics2, 'Used_New') # extracts first word and rename column
data2$Used_New <- tolower(data2$Used_New)

# not all the variables had information on used/new -> anything else then used / new is set to NA
for (i in 1:nrow(data2)){
  if (data2$Used_New[i] %in% c("used", "new")){data2$Used_New[i]}
  else {data2$Used_New[i] <- NA}
}

data2$Used_New <- as.factor(data2$Used_New)
# unique(data2$Used_New)

## Fuel ##
# in the Characteristics  there is also information on fuel
# there are several types of boats: Unleaded, Electric, Hybrid, Propane, propane(which belongs under Gas), Diesel, 
# Those words where always at the end starting with comma example: new boat from stock,Unleaded
unique(data2$Type)
data2$Fuel <- paste(data2$Charactersitics, ",") # I had to add the comma at the end of each variable for the step 2
data2$Fuel <- sub("^(.+?),", "",  data2$Fuel) # deletes everything before the first comma but since not all the rows have comma it was not working so I added commas in previous step
data2$Fuel <- gsub(",", " ",  data2$Fuel) # delete the comma at the end
data2$Fuel <- as.factor(data2$Fuel)
data2$Fuel <- str_replace(data2$Fuel, "Propane", "Gas") # Putting propane as gas

## Displayed as Model or not ##
# under characteristics - some boats are displayed as models
data2$Display_model <- str_replace(data2$Charactersitics, ",", " ") 
data2$Display_model <-  as.factor(str_extract(data2$Display_model, "Display Model")) 
data2$Display_model <- str_replace(data2$Display_model, "Display Model", "Yes") 
data2$Display_model <- data2$Display_model %>% replace_na("No") #if wasn't displayed it would have had NAs, I replaced Na for 'No'
data2$Display_model <- as.factor(data2$Display_model)
 
#### Age ####
# Age represents the Year when the boat was built. As it is misleading I renamed variable to Year
data2 <- rename(data2, c(Year = Age))

# replace 0 with NA
for (i in 1:nrow(data2)){
  if (data2$Year[i] %in% ('0')) {data2$Year[i] <- 'NA'}
  else {data2$Year[i] <- data2$Year[i]}
}
data2$Year <- as.numeric(data2$Year)





#### Place ####
# Variable Place starts with country: Switzerland Ã‚Â» Lake Geneva Ã‚Â» VÃƒÂ©senaz
# However sometimes country is missing or is written in wrong format
data3 <- data2
data3$Place <- str_extract(data2$Place, "^(.+?) ") #extract first word of location which stands for country
# fix names of the countries that are written incorrectly
#unique(data3$Location)
data3$Place <- str_replace(data3$Place, "Russian" , "Russian Federation") 
data3$Place <- str_replace(data3$Place, "United" , "USA")
data3$Place <- str_replace(data3$Place, "Slovak" , "Slovakia")
data3$Place <- str_replace(data3$Place, "Czech" , "Czechia")
data3$Place <- str_replace(data3$Place, "Kroatien" , "Croatia")
# omit words that do not stand for countires
list1 <- c("baden ", "TravemÃƒÂ¼nde ", "Lake " , "lago ", "BelgiÃƒÂ« ", "Donau ", "Oder " , "Marina ", "Italien ", "Italia ", "waren ", "Martinique ",
           "Ostsee ", "Mallorca ", "Greetsile/ ", "83278 " , "Novi ", "Lago ", "Isle " , "24782 ", "Neusiedl", "PT " , "Calanova " , "ZÃƒÂ¼richse, " , 
           "espa?a ", "Katwijk ", "Porto ", "Tenero, ", "VierwaldstÃƒÂ¤ttersee ", "Angera" , " Juelsminde ", "Rostock ", "Stralsund ", 
           "Brandenburg " , "Beilngries ", "Neustadt ", "Angera ", "Juelsminde ", "Neusiedl ", "BelgiÃƒÂ«, " , "Vierwaldst?f¤ttersee ", 
           "Z?f¼richse, ", "Vierwaldst?f¤ttersee ", "Travem?f¼nde ", "Belgi?f«, " , "French "   ) 
data3$Location[data3$Location %in% list1] <- 'NA'


# subset only relevant columns
DataC <- data3 %>% select(c(Views, Currency, Price_Eur,Price_home_curr, Type,
                            Producer, Year, Length, Width, MadeOf, Place,
                            Used_New, Fuel, Display_model))


write_xlsx(DataC, "C:/Users/zuzan/Desktop/Data_analysis/GitHub/Portfolio_projects/Boats_DataCamp//Preview_Clean.xlsx")


### Exploration #### 
#below is only sample of exploratory analysis
# cheaper boats and very expensive yachts have the most views
DataC %>% ggplot() + aes(Price_Eur, Views) + geom_point() 
DataC %>% filter(Price_Eur <= 2000000) %>% ggplot() + aes(Price_Eur, Views) + geom_point() 
DataC %>% ggplot() + aes(Year, Views) + geom_point(aes(), color = "darkcyan") 

#Average number of Views for each category was calculated using SQL
# Data Visualization was done using PowerBI
