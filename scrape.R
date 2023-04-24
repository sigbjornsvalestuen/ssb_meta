## Getting data overview from SSB statbank
install.packages("rvest") ### For scraping
library(rvest) ### For scraping
library(pbapply) ### Lapply progress bar

### These are the indvidual elements
link <- "https://www.ssb.no/statbank/list/fritidsbyggomr"
ssb_page <- read_html(link)

tab <- ssb_page %>%
    html_elements(css = c(".col1"))
html_text(tab)

name <- ssb_page %>%
    html_elements(css = c(".col2"))
class(name)

year <- ssb_page %>%
    html_elements(css = c(".col3"))
class(year)

d <- as.data.frame(cbind(html_text(tab), html_text(name), html_text(year)), header = FALSE)
str(d)


### Getting link texts (this is the TEXT, I want the LINK), however, text is also useful!
page <- read_html("https://www.ssb.no/statbank")
linknames <- page %>%
    html_elements(css = c(".link-text"))
linknames <- html_text(linknames)

### This gets the category LINKS
links <- page %>% html_nodes(".ssb-link") %>% html_attr("href")

### Keep only those links with consistent stems to database (https://www.ssb.no/statbank/list/)
urls <- links[grep("https://www.ssb.no/statbank/list/", links)] ###  

### "kosthald" doesn't exist (404 error, try the link directly), needs to be removed otherwise error occurs
urls <- urls[!grepl('^https://www.ssb.no/statbank/list/kosthald$', urls)]

### Get the suffixes (useful for later purposes)
suff <- sub("https://www.ssb.no/statbank/list/", "", x =urls)

### Lapply reads the individual link, extracts elements, and parses these into text
### There are three lists: the table number, its title, and the years covered. The code generates a list of lists for each column referred to. All columns have periodic occurences of table headers that will be dealt with later. These rows should correspond when cbinded later on.

### IMPORTANT: BE MINDFUL WHEN SCRAPING; SET A SLEEP TIMER PER ITERATION 
tablist <- pblapply(urls, function(i){
    Sys.sleep(3) ## Sys.sleep (3s)
    webpage <- read_html(i) # read page
    elements <- html_elements(webpage, ".col1") # select element
    text <- html_text(elements) # extract text from element
})

tablist
#save(tablist, file = "tablist.Rdata") ### SAVE TO AVOID RE-QUERY

titlelist <- pblapply(urls, function(i){
    Sys.sleep(3)
    webpage <- read_html(i)
    elements <- html_elements(webpage, ".col2")
    text <- html_text(elements)
})

str(titlelist)
#save(titlelist, file = "titlelist.Rdata")

yearlist <- pblapply(urls, function(i){
    Sys.sleep(3)
    webpage <- read_html(i)
    elements <- html_elements(webpage, ".col3")
    text <- html_text(elements)
})

str(yearlist)
#save(yearlist, file = "yearlist.Rdata")


### Lengths are the same
sum(lengths(tablist))
lengths(titlelist)
lengths(yearlist)
cor(lengths(tablist), lengths(yearlist)) ## cor = 1

### an overview of the useful data collected so far:
str(linknames) ### ALL linknames (732 links)
str(links) ### ALL URLs (740)
str(urls) ### URLs after reducing and removing kosthald (same length as lists)
linksub <- linknames[34:674]
linksub <- linksub[!grepl('^Kosthald$', linksub)]

linksub linknames
str(linksub)
str(tablist)
str(titlelist)
str(yearlist)

### If saved, load objects into memory
load("tablist.Rdata")
load("titlelist.Rdata")
load("yearlist.Rdata")

str(tablist)
str(titlelist)
str(yearlist)

## name list vectors
rep(urls, lengths(tablist))
rep(linksub, lengths(tablist))

### Now, get the data from listform to dataframe
ssbmeta <- as.data.frame(cbind(unlist(tablist), unlist(titlelist), unlist(yearlist))) ## makes dataframe object from cbinded, unlisted, objects (no names yet)
str(ssbmeta)
ssbmeta$urls <- rep(urls, lengths(tablist))
ssbmeta$category <- rep(linksub, lengths(tablist))

colnames(ssbmeta)[1:3] <- c("table", "title", "period")
head(ssbmeta)
tail(ssbmeta)

### Now, remove duplicates: this works BECAUSE several of the main categories inklude references to table collections; if categorized further up in the hierarchy, this WOULD NOT WORK
ssbmeta <- ssbmeta[!grepl("Tabellnr.", ssbmeta$table), ] ### first, remove "title"
str(ssbmeta)
sum(duplicated(ssbmeta)) ### Almost 8.5k duplicated tables, shows inefficiency when working in ssb database UX

ssbmetaclean <- ssbmeta[!duplicated(ssbmeta),]
str(ssbmetaclean)
head(ssbmetaclean)
tail(ssbmetaclean)

head(ssbmetaclean)
str(ssbmetaclean)

### Write the file, base data are available and stored
#write.csv(ssbmetaclean, file = "ssbmetaclean.csv", row.names = FALSE)

### SCRIPT END
