source("utilities/buildDataSet.R")

# Load the search and ingredient data frames
searchDf <- loadSearchData()
ingredientDf <- loadIngredientsData()

# If necessary the data frames can be supplimented with additional terms
# and reloaded from disk.
# supplementDataSet("vegetarian", searchDf, c(2:4))

