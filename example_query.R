#### Using the metadata to look for and read tables
library(PxWebApiData) ### Only install if querying the API

### Read the metadata table
snmd <- read.csv("snmd.csv", colClasses = c("table" = "character")) ### avoid replacing table as character with integer (keeps leading zeros in some table names)
str(snmd) 

### grep method (search $title for partial string (educ), ignore case-sensitivity)
utd <- snmd[grep("utdann", snmd$title, ignore.case = TRUE),] ## 578 unique tables containing word-stem
str(utd) ### 578 tables mention 'utdann' partial string

utdop <- utd[utd$closed == FALSE,] ### out of these, 357 tables are ongoing 
str(utdop)

## Subset on logical municipality value (remember, some are both on district and municipality level; spares is the lowest level of spatial resolution, which would not capture all on municipality level)
utdkop <- utdop[utdop$komm == TRUE,]
str(utdkop) ### There are 20 ongoing tables at the municipality level in the database with the "utdann"- stem 
utdkop[,1:3] ## List rows and first 3 columns. Note that all titles include (K), meaning municipality

## The same, but county level
utdf <- utdop[utdop$fylke == TRUE,]
str(utdf) ### 83 ongoing tables at the county level mentioning "utdann"-string
utdf[,2]

## You may open the URL directly through R to look at the table(s).
browseURL(utdkop[11,6])
sapply(utdkop[11:12, 6], browseURL)

## OR, you can query the API via PxWebApiData using the provided apilinks

### 1 table, specify values on variables (this requires some knowledge of the database)
educ <- ApiData(utdkop$api[11],
                ContentsCode = "PersonerProsent",
                Region = TRUE,
                Tid = TRUE,
                Kjonn = FALSE,
                Niva = TRUE)
str(educ) ### List of two objects; one with labels, one without. Same data.

edudf <- educ[[1]] ### This is the dataframe with labels. Extract.
str(edudf) ### Data on all municipalities (past and present). Note the consequences of the recent merger.
 
### Or, query the API for a vector of tables, place these in the same list. Function can be extended (as above), not shown.
listofdata <- lapply(utdkop$api[1:2], ApiData) ### Generates a list of 2 lists from two different tables (07944, 07940)
str(listofdata)


### Another example: health
health <- snmd[grep("helse", snmd$title, ignore.case = TRUE), ] ### partial string: helse
str(health)
health$title
table(health$spares)

### Subset this by municipality tables
khealth <- health[health$komm == TRUE,]
str(khealth)

### Ongoing municipality tables
konhealth <- khealth[khealth$closed == FALSE,]
str(konhealth)
konhealth$title
konhealth[1:2,1:4]
str(konhealth)

### Get metadata from selected tables
vars <- lapply(konhealth[1:2 ,c("api")], ApiData, returnMetaData = TRUE)
str(vars)
