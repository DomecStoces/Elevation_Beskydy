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

dataset_kula<-read_excel("Hamřík_long.xlsx")
table(dataset_kula$year,dataset_kula$site,dataset_kula$taxon_group)

# Adding traits info to taxon_groups
traits_path <- "traits.xlsx"

# INFO: spiders are not yet done
trait_sheets <- excel_sheets(traits_path)
trait_sheets <- trait_sheets[!trait_sheets %in% c("Pavouci")]
all_traits <- trait_sheets %>%
  set_names() %>% 
  map_df(~{
    sheet_data <- read_excel(traits_path, sheet = .x) %>%
      clean_names() 
    
    sheet_data %>%
      rename(species = 1) %>% 
      mutate(taxon_group = .x) %>%
      mutate(species = as.character(species)) %>%
      mutate(species = tolower(species)) %>% 
      mutate(species = str_replace_all(species, " ", "_"))
  })
final_data <- all_data_long %>%
  left_join(
    all_traits, 
    by = c("Species" = "species", "taxon_group" = "taxon_group") 
  )

glimpse(final_data)
View(final_data)
write_xlsx(final_data, "Hamřík_long_traits.xlsx")