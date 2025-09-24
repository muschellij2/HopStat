## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----------------------------
library(knitr)
library(dplyr)
library(arcgis)
opts_chunk$set(echo = TRUE, prompt = FALSE, message = FALSE, warning = FALSE, comment = "", results = "hide")


## ----results='markup', echo = FALSE--------------------------------------------------------------------
knitr::include_graphics("walking_index_definition.png")


## ----results='markup', echo = FALSE--------------------------------------------------------------------
knitr::include_graphics("walking_index_scoring.png")


## ----results='markup', echo = FALSE--------------------------------------------------------------------
knitr::include_graphics("walking_index_mapserver.png")


## ----results='markup', echo = FALSE--------------------------------------------------------------------
knitr::include_graphics("walking_index_fields.png")


## ----eval = FALSE--------------------------------------------------------------------------------------
# remotes::install_github("https://github.com/R-ArcGIS/arcgis")
# # Alternative
# install.packages("arcgis", repos = "https://r-arcgis.r-universe.dev")


## ----message=FALSE, results='markup'-------------------------------------------------------------------
library(arcgis)
url <- "https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer/0"
(walk_arc <- arc_open(url))


## ----eval = FALSE--------------------------------------------------------------------------------------
# res = arc_select(walk_arc)


## ----eval = FALSE--------------------------------------------------------------------------------------
# res = arc_select(walk_arc, geometry = FALSE)


## ----arc_select, results='markup'----------------------------------------------------------------------
(res = arc_select(walk_arc, where = "GEOID10 in ('481130078254', '481130078252')"))


## ----results='markup'----------------------------------------------------------------------------------
library(dplyr)
res %>% 
  select(GEOID10, NatWalkInd)


## ----results='markup'----------------------------------------------------------------------------------
res %>% 
  select(GEOID10, NatWalkInd) %>% 
  as_tibble() %>% 
  select(-any_of("geometry"))


## ----results='markup'----------------------------------------------------------------------------------
library(censusxy)
address = tibble(
  street = "1600 Pennsylvania Avenue NW",
  city = "Washington",
  state = "DC",
  zip = "20500"
)
cxy = address %>%
  cxy_geocode(street = "street", 
              city = "city",
              state = "state", 
              zip = "zip", 
              output = "full",
              return = "geographies",
              benchmark = "Public_AR_Current",
              vintage = "Census2010_Current")


## ----results='markup'----------------------------------------------------------------------------------
colnames(cxy)
cxy %>% select(starts_with("cxy"))


## ----results='markup'----------------------------------------------------------------------------------
make_fips15 = function(
    state,
    county,
    tract,
    block) {
  fips15 = sprintf("%02.0f%03.0f%06.0f%04.0f",
                   state,
                   county,
                   tract,
                   block)
}
make_fips12 = function(...) {
  fips15 = make_fips15(...)
  fips12 = substr(fips15, 1, 12)
}


## ----results='markup'----------------------------------------------------------------------------------
(cxy = cxy %>% 
  dplyr::mutate(
    GEOID10 = make_fips12(
      cxy_state_id,
      cxy_county_id,
      cxy_tract_id,
      cxy_block_id)
  ) %>% 
  select(GEOID10, starts_with("cxy")))


## ----results='markup'----------------------------------------------------------------------------------
(result = arc_select(walk_arc, where = paste0("GEOID10 = '110010062021'")))


## ----results='markup'----------------------------------------------------------------------------------
result %>% as_tibble() %>% select(NatWalkInd)


## ----results='markup'----------------------------------------------------------------------------------
ids = unique(cxy$GEOID10)
ids = paste0("'", ids, "'")
ids = paste(ids, collapse = ", ")
ids = paste0("(", ids, ")")
(where = paste0("GEOID10 in ", ids))


## ------------------------------------------------------------------------------------------------------
knitr::include_graphics("smart_location_database_layers.png")

