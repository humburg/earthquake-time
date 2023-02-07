library(lutz)
library(purrr)
library(lubridate)
library(dplyr)
library(readr)
library(tidyr)

eq_df <- read_csv("data/earthquatedates.csv")

## Some entries are missing the minutes. I've replaced them with 0, i.e. start of the hour here
eq_df <- eq_df %>% mutate(Mn = replace_na(Mn, 0))

## Convert coordinates to time zones. Note that this uses current time zones, not historic ones
eq_df <- eq_df %>% mutate(UTC=paste0(Year,"-", Mo, "-", Dy, " ", sprintf("%02d", Hr), ":", sprintf("%02d", Mn)),
                          timezone=tz_lookup_coords(lat=eq_df$Latitude, lon=eq_df$Longitude, method="fast")) %>% 
  mutate(local_time = map2(.x=UTC, .y=timezone, .f = function(x, y){
    with_tz(time=as.POSIXct(x, format="%Y-%m-%d %H:%M", tz="UTC"), tzone=y)})) %>% 
  unnest(local_time) %>% mutate(local_time = as.character(local_time))

write_csv(eq_df, file="data/earthquakedates_conversion.csv")
