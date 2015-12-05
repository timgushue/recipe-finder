library(yaml)
library(stringr)

loadCredentials <- function(credentials="credentials/credentials.yml") {
    if (file.exists(credentials)) yaml.load_file(credentials)
}

writeDataFrame <- function(query_df, suffix) {
    write.table(query_df,
                file=paste("data/", format(Sys.time(), "%Y%m%d_%H%M%S"), "_", suffix, sep=""),
                quote=FALSE,
                row.names=FALSE,
                sep="\u0001") # This uses One Separated Value (OSV) as the delimeter.
}

saveSearchData <- function(searchDf) { writeDataFrame(searchDf, "search") }
saveIngredientsData <- function(ingredientsDf) { writeDataFrame(ingredientsDf, "ingredients") }

readDataFrame <- function(dataFile) {
    read.table(file=dataFile,
               header=TRUE,
               sep="\u0001")
}

mostRecentFile <- function(suffix, dir="data/") {
    # This method reads the data directory and returns the most recent file matching the suffix.
    # TODO: handle case of no file found.
    files <- dir(dir)
    fileComponents <- str_split(files, "_")
    componentDf <- data.frame(
        matrix(unlist(fileComponents), ncol=3, byrow=T),
        stringsAsFactors=FALSE)
    subCompDf <- subset(componentDf, X3==suffix)
    mostRecent <- subCompDf[order(-xtfrm(subCompDf[,1]), -xtfrm(subCompDf[,2])), ]
    paste(dir, paste(mostRecent[1,1], mostRecent[1,2], mostRecent[1,3], sep="_"), sep="")
}

loadSearchData <- function() { readDataFrame(mostRecentFile("search")) }
loadIngredientsData <- function() { readDataFrame(mostRecentFile("ingredients")) }
