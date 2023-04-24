### Experimenting with table elements
library(rvest)
library(pbapply)

link <- "https://www.ssb.no/statbank/table/13371/"
ssb_page <- read_html(link)

browseURL(link)
str(ssb_page)

### Option contains all source table options
tab <- ssb_page %>%
    html_elements(css = c("option"))
html_text(tab[1:3])

### Every box has "Valg" "1" "av totalt" "N". This can be exploited to catch N variables ++
vars <- ssb_page %>%
    html_elements(css = ".variableselector_valuesselect_statistics")
html_text(vars[4]) ### Nth variable occupies the 4th spot


### Get the data from snmd
snmd <- read.csv("../ssb_meta/snmd.csv", colClasses = c("table" = "character"))
str(snmd)

urls <- snmd$tlinks
urls

#### Do two scrapes; first get a list of options, then get a list of variableselector information 
optlist <- pblapply(urls, function(i){
    Sys.sleep(3) ## Sys.sleep (3s)
    webpage <- read_html(i) # read page
    elements <- html_elements(webpage, "option") # select element
    text <- html_text(elements) # extract text from element
})

str(optlist)

save(optlist, file = "optlist.Rdata") ### SAVE TO AVOID RE-QUERY

nlist <- pblapply(urls, function(i){
    Sys.sleep(3) ## Sys.sleep (3s)
    webpage <- read_html(i) # read page
    elements <- html_elements(webpage, ".variableselector_valuesselect_statistics") # select element
    text <- html_text(elements) # extract text from element
})

str(nlist)
save(nlist, file = "nlist.Rdata") ### SAVE TO AVOID RE-QUERY

### Load objects
#load("nlist.Rdata")
#load("optlist.Rdata")

### Now to select subelements
lths <- lapply(nlist, '[[', 4) ### Get the lengths of variable index
lths <- lapply(lths, as.integer) ### Make integer 
lths <- lapply(lths, seq) ### Create sequence 1:N
lths

### Map the lists so that elements equal to lths is selected from optlist
vars <- mapply('[', optlist, lths)

## Names based on URLS (maybe tables instead?)
names(vars) <- snmd$table 
vars

### So now I know this works!
