library(DBI)
library(RSQLite)
library(readr)

# load first big metadata file 
metadata_import <- readr::read_delim("../../data/var_all_consolidated.csv", 
                              delim = "|", escape_double = FALSE, trim_ws = TRUE)


# load manual data check file
metadata_lang_manual_check <- readr::read_csv(
  "../../data/data_concordance_output_20240116.csv", 
  col_types = cols(`300339` = col_skip(), 
                   ds_ref = col_character(), tbl_name = col_character(), 
                   lang_var_confirmed_VMS = col_logical(), 
                   official_lang_var_VMS = col_logical(), 
                   lang_var_confirmed_CP = col_logical(), 
                   official_lang_var_CP = col_logical(), 
                   lang_var_concordance = col_logical(), 
                   lang_off_concordance = col_logical(), 
                   `0.980929394012633` = col_skip()))

# combine the big metadata file with the manual check data
metadata_raw <- dplyr::left_join(
  x = metadata_import,
  y = metadata_lang_manual_check,
  by = c("key",
         "var_name",
         "var_descr",
         "var_data_holding",
         "var_ds",
         "var_lib",
         "ds_ref",
         "tbl_name")
)

# create/load a sqlite database
mydb <- DBI::dbConnect(RSQLite::SQLite(), "db/closm-db.sqlite")

# save our big consolidated data
DBI::dbWriteTable(mydb, "var_all_consolidated", metadata_import)

# create a smaller version
metadata_trim <-metadata_raw |>
  dplyr::select(var_name, var_descr, Type, var_data_holding, var_ds, var_data_holding, var_lib, var_ds, lang_var_confirmed, official_lang_var_VMS)

# confirm size reduction
object.size(metadata_raw) # 1039736776 bytes
object.size(metadata_trim) # 296494680 bytes ( ~70% file size reduction)

# write trimmed data to file
DBI::dbWriteTable(mydb, "metadata_trim", metadata_trim)

DBI::dbListTables(mydb)


# now pre-process variable values for faster loading
var_lib_values <- metadata_trim$var_lib |> unique() |> sort()
saveRDS(var_lib_values,"db/var_lib_values.RData" )

var_data_holding_values <- metadata_trim$var_data_holding |> unique() |> sort()
saveRDS(var_data_holding_values,"db/var_data_holding_values.RData" )

var_ds_values <-  metadata_trim$var_ds |> unique() |> sort()
saveRDS(var_ds_values,"db/var_ds_values.RData" )

lang_var_confirmed_VMS_values <- metadata_trim$lang_var_confirmed |> unique() |> sort()
