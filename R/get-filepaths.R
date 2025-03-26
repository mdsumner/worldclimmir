
get_filepaths <- function() {
## we aren't downloading
my_directory <- tempdir()
cf <- bb_config(local_file_root = my_directory)

##https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_10m_tmin.zip
src <-
  bb_source(
    name = "worldclim",
    id = "worldclim-doi",
    description = "WorldClim",
    doc_url = "https://worldclim.org/",
    citation = " [access date]",
    source_url = "https://geodata.ucdavis.edu/climate/worldclim",
    license = "Please cite",
    method = list("bb_handler_rget", level = Inf, relative = TRUE),
    postprocess = NULL,
    access_function = c("terra::rast", "terra::vect")[1],
    collection_size = 1e10,
    data_group = "climate")

cf <- bb_add(cf, src)

status <- bb_sync(cf, verbose = TRUE, dry_run = TRUE)


## how big is it all

allurls <- do.call(rbind, status$files)
#size <- numeric(length(allurls))

options(parallelly.fork.enable = TRUE, future.rng.onMisuse = "ignore")
future::plan(multicore)

allurls$sizes <- future_map_dbl(allurls$url, \(.url) as.numeric(gdalraster::vsi_stat(sprintf("/vsicurl/%s", .url), "size")))
plan(sequential)
#sum(sizes)/1e9
#[1] 5479.997
allurls
}

writefile <- function(x) {
  nanoparquet::write_parquet(x, "geodata.parquet")
}
