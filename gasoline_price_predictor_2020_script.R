### Gasoline Price Predictor 2020
### Christopher Page
### 7 September 2020

### GitHub repository: https://github.com/cjpage/gasoline_price_predictor_2020

### This part of the script loads the necessary libraries from the repository http://cran.us.r-project.org

if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(caTools)) install.packages("caTools", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(dslabs)) install.packages("dslabs", repos = "http://cran.us.r-project.org")
if(!require(forcats)) install.packages("forcats", repos = "http://cran.us.r-project.org")
if(!require(foreach)) install.packages("foreach", repos = "http://cran.us.r-project.org")
if(!require(gam)) install.packages("gam", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(ggrepel)) install.packages("ggrepel", repos = "http://cran.us.r-project.org")
if(!require(ggthemes)) install.packages("ggthemes", repos = "http://cran.us.r-project.org")
if(!require(knitr)) install.packages("knitr", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")
if(!require(purrr)) install.packages("purrr", repos = "http://cran.us.r-project.org")
if(!require(randomForest)) install.packages("randomForest", repos = "http://cran.us.r-project.org")
if(!require(ranger)) install.packages("ranger", repos = "http://cran.us.r-project.org")
if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")

### This part of the script reads "data/commodity_closing_prices_2010_2020.csv" into a new data frame named "commodities"
### Then, it mutates the resulting data set in way that will enable the envisioned analysis
### Next, it saves that data frame into a .RDATA data set under the RDA subdirectory

commodities <- read_csv("data/commodity_closing_prices_2010_2020.csv")

commodities <- commodities %>%
  rename(date = Date) %>%
  mutate(date = as.Date(mdy(date))) %>%
  mutate(date_year = year(date)) %>%
  mutate(date_quarter_of_the_year = quarter(date)) %>%
  mutate(date_month = round_date(date, unit = "months")) %>%
  mutate(date_month_of_the_year = month(date)) %>%
  mutate(date_day = day(date)) %>%
  mutate(date_weekday = weekdays(date)) %>%
  rename(commodity = Commodity) %>%
  rename(sector = Sector) %>%
  rename(closing_price = `Closing Price`)

save(commodities, file = "rda/commodities.rdata")

### This part generates and saves data sets focused on the energy, precious metals, and agricultural sectors

energy <- commodities %>%
  filter(sector == 'Energy')
save(energy, file = "rda/energy.rdata")

precious_metals <- commodities %>%
  filter(sector == 'Precious Metals')
save(precious_metals, file = "rda/precious_metals.rdata")

agriculture <- commodities %>%
  filter(sector == 'Agriculture')
save(agriculture, file = "rda/agriculture.rdata")

### This part generates and saves a data set focused on gasoline

gasoline <- energy %>%
  filter(commodity == 'Gasoline')
save(gasoline, file = "rda/gasoline.rdata")

### This part generates and saves data sets focused on the commodities (other than gasoline) in the energy sector

natural_gas <- energy %>%
  filter(commodity == 'Natural Gas') %>%
  rename(natural_gas_closing_price = closing_price)
save(natural_gas, file = "rda/natural_gas.rdata")

heating_oil <- energy %>%
  filter(commodity == 'Heating Oil') %>%
  rename(heating_oil_closing_price = closing_price)
save(natural_gas, file = "rda/heating_oil.rdata")

crude_oil <- energy %>%
  filter(commodity == 'Crude Oil') %>%
  rename(crude_oil_closing_price = closing_price)
save(gasoline, file = "rda/crude_oil.rdata")

### This part generates and saves data sets focused on the commodities in the precious metals sector

gold <- precious_metals %>%
  filter(commodity == 'Gold') %>%
  rename(gold_closing_price = closing_price)
save(natural_gas, file = "rda/gold.rdata")

silver <- precious_metals %>%
  filter(commodity == 'Silver') %>%
  rename(silver_closing_price = closing_price)
save(natural_gas, file = "rda/silver.rdata")

platinum <- precious_metals %>%
  filter(commodity == 'Platinum') %>%
  rename(platinum_closing_price = closing_price)
save(gasoline, file = "rda/platinum.rdata")

### This part generates and saves data sets focused on the commodities in the agriculture sector

wheat <- agriculture %>%
  filter(commodity == 'Wheat') %>%
  rename(wheat_closing_price = closing_price)
save(wheat, file = "rda/wheat.rdata")

rice <- agriculture %>%
  filter(commodity == 'Rice') %>%
  rename(rice_closing_price = closing_price)
save(rice, file = "rda/rice.rdata")

soybeans <- agriculture %>%
  filter(commodity == 'Soybeans') %>%
  rename(soybeans_closing_price = closing_price)
save(soybeans, file = "rda/soybeans.rdata")

### This part generates a table that compares gasoline's closing price to the closing prices of all other commodities

natural_gas_price_table <- natural_gas %>% select(date, natural_gas_closing_price)
heating_oil_price_table <- heating_oil %>% select(date, heating_oil_closing_price)
crude_oil_price_table <- crude_oil %>% select(date, crude_oil_closing_price)

gold_price_table <- gold %>% select(date, gold_closing_price)
silver_price_table <- silver %>% select(date, silver_closing_price)
platinum_price_table <- platinum %>% select(date, platinum_closing_price)

wheat_price_table <- wheat %>% select(date, wheat_closing_price)
rice_price_table <- rice %>% select(date, rice_closing_price)
soybeans_price_table <- soybeans %>% select(date, soybeans_closing_price)

gasoline_in_commodities_market <- gasoline %>%
  left_join(natural_gas_price_table) %>%
  left_join(heating_oil_price_table) %>%
  left_join(crude_oil_price_table) %>%
  left_join(gold_price_table) %>%
  left_join(silver_price_table) %>%
  left_join(platinum_price_table) %>%
  left_join(wheat_price_table) %>%
  left_join(rice_price_table) %>%
  left_join(soybeans_price_table)

### This part of the script generate a 31% hold-out TEST set

set.seed(1)

test_index <- createDataPartition(y = gasoline_in_commodities_market$commodity, 
                                  times = 1, p = 0.31, list = FALSE)

gasoline_in_commodities_market_train <- gasoline_in_commodities_market[-test_index,]

gasoline_test <- gasoline_in_commodities_market[test_index,]

### This part splits remaining 69% into TRAIN and VALIDATE sets

set.seed(755)

test_index <- createDataPartition(y = gasoline_in_commodities_market_train$commodity, 
                                  times = 1, p = 0.43, list = FALSE)

gasoline_train <- gasoline_in_commodities_market_train[-test_index,]

gasoline_validate <- gasoline_in_commodities_market_train[test_index,]

### This part defines RMSE

RMSE <- function(true_ratings, predicted_ratings){
  sqrt(mean((true_ratings - predicted_ratings)^2))
}

### This part defines and validates the prediction algorithm

ranger_time_energy_precious_metals_agriculture <- 
  train(closing_price ~
          date_year + 
          date_month + 
          heating_oil_closing_price +
          crude_oil_closing_price +
          platinum_closing_price +
          silver_closing_price +
          wheat_closing_price +
          soybeans_closing_price,
        method = "ranger",
        data = gasoline_train)

pred <- predict(ranger_time_energy_precious_metals_agriculture, 
                newdata = gasoline_train)

predicted_price_algorithm_10 <- 
  predict(ranger_time_energy_precious_metals_agriculture, 
          newdata = gasoline_validate)

RMSE10 <- RMSE(predicted_price_algorithm_10, 
               gasoline_validate$closing_price)

### This part defines runs the prediction algorithm against the TEST set

predicted_price_algorithm_10 <- 
  predict(ranger_time_energy_precious_metals_agriculture, 
          newdata = gasoline_test)

RMSE_final <- RMSE(predicted_price_algorithm_10, 
                   gasoline_test$closing_price)

RMSE_final

