library(tidyverse)
library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(janitor)
library(writexl)

path <- "Hamřík.xlsx"
sheet_names <- excel_sheets(path)
all_data_long <- sheet_names %>%
  set_names() %>% 
  map_df(~{
    data <- read_excel(path, sheet = .x)
    data <- data %>% clean_names()
    data %>%
      mutate(across(1:16, as.character)) %>% 
      pivot_longer(
        cols = 17:last_col(), 
        names_to = "Species", 
        values_to = "Count"
      ) %>%
      mutate(taxon_group = .x)
  })
all_data_long <- all_data_long %>%
  mutate(Count = as.numeric(Count)) %>% 
  filter(Count > 0)
View(all_data_long)
glimpse(all_data_long)

write_xlsx(all_data_long, "Hamřík_long.xlsx")
