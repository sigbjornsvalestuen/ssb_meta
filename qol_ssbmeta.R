#### Quality of life features for ssbmetaclean.csv; end result: more detailed .csv-file called snmb.csv
library(stringr)

snmd <- read.csv("../datamapping/ssbmetaclean.csv", colClasses = c("table" = "character"))
str(snmd)
head(snmd)
snmd <- snmd[!duplicated(snmd$table),]

str(test)

### Add spatial resolution defined by title, lowest level by table
snmd$komm <- str_detect(snmd$title, "\\(K\\)") ## Municipality data
snmd$fylke <- str_detect(snmd$title, "\\(F\\)") ## County
snmd$gkrets <- str_detect(snmd$title, "\\(G\\)") ## Basic statistical unit
snmd$bydel <- str_detect(snmd$title, "\\(B\\)") ## District
snmd$tett <- str_detect(snmd$title, "\\(T\\)") ## Urban area

table(snmd$fylke, snmd$komm)

### Make one variable overview, for lowest spatial resolution

snmd$spares <- ifelse(snmd$fylke == TRUE, "Fylke", NA)
snmd$spares <- ifelse(snmd$komm == TRUE, "Kommune", snmd$spares)
snmd$spares <- ifelse(snmd$tett == TRUE, "Tettsted", snmd$spares)
snmd$spares <- ifelse(snmd$bydel == TRUE, "Bydel", snmd$spares)
snmd$spares <- ifelse(snmd$gkrets == TRUE, "Grunnkrets", snmd$spares)
snmd$spares <- ifelse(is.na(snmd$spares), "Land", snmd$spares)
table(snmd$spares, snmd$komm)

test <- snmd[snmd$komm == TRUE & snmd$bydel == TRUE,]
test

### Add temporal resolution defined by period
snmd$month <- str_detect(snmd$period, "M") ## Monthly
snmd$kvart <- str_detect(snmd$period, "K") ## Quarterly

snmd$tunit <- ifelse(snmd$month == TRUE, "Måned", NA)
snmd$tunit <- ifelse(snmd$kvart == TRUE, "Kvartal", snmd$tunit)
snmd$tunit <- ifelse(is.na(snmd$tunit), "År", snmd$tunit)

### Closed series
snmd$closed <- str_detect(snmd$title, "\\(avslutta serie\\)")
#snmd$closed <- ifelse(snmd$closed == TRUE, "Avsluttet", "Pågående")

### Add column with table link
snmd$tlinks <- paste0("https://www.ssb.no/statbank/table/", snmd$table, sep = "")

### Add apilinks (if consistent)
snmd$api <- paste0("https://data.ssb.no/api/v0/no/table/", snmd$table, sep = "")
snmd$api

## Rearrange
snmd <- snmd[, c(1:3, 5, 4, 16, 17, 11, 14, 15, 6:10, 12:13)]

### add from - to in years (more involved, separate script I think.)
str(snmd)

write.csv(snmd, "snmd.csv", row.names = FALSE)

### SCRIPT END
View(snmd)
table(snmd$spares)
