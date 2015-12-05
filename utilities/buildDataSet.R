source("clients/diskIOClient.R")
source("clients/food2forkClient.R")

# A set of functions to build, supplement, and maintain recipe and ingredient data frames.

removeDupicateRows <- function(df) {
    return(df[!duplicated(df), ]) 
}

# Recursively search for a query over a range of pages and bind the result to df
multiPageSearch <- function(query, df, page_list=c(1:1)) {
    if (!any(page_list)) {
        df <- removeDupicateRows(df)
        return(df)
    } else {
        result <- searchQuery(query, page=page_list[1])
        rbind(df, multiPageSearch(query, result, page_list[-1]))
    }
}

# Recursively query a list of recipe ids and bind the result to df
multiRecipeSearch <-  function(df, recipe_list) {
    if (length(recipe_list) == 0) {
        df <- removeDupicateRows(df)
        return(df)
    } else {
        result <- getRecipeIngredients(recipe_list[1])
        rbind(df, multiRecipeSearch(result, recipe_list[-1]))
    }
}

# Add any new recipes from the search df to the ingredient df
hydrateIngredients <- function(searchDf, ingredientDf=data.frame(recipe_id=-1, ingredients="")) {
    search_recipe_ids <- searchDf$recipe_id
    ingred_recipe_ids <- unique(ingredientDf$recipe_id)
    new_recipes_to_query <- setdiff(search_recipe_ids, ingred_recipe_ids)
    
    multiRecipeSearch(ingredientDf, new_recipes_to_query)
}

# This is a side effect function that reads both data sets from disk, makes http calls 
# and writes the results back to disk. It takes an optional list of pages to use in the
# search query.
#
# Sample usage: supplementDataSet("vegetarian", searchDf, c(2:4))
#
supplementDataSet <- function(searchString, pageOpt=c(1:1)) {
	# Load the latest search and ingredient data sets
	# TODO: handle the case where some data set doesn't exist yet.
	searchDf <- loadSearchData()
	ingredientDf <- loadIngredientsData()
	
	# Search for more recipes and add their ingredients
	searchDf <- multiPageSearch(searchString, pageOpt)
	saveSearchData(searchDf)
	ingredientDf <- hydrateIngredients(searchDf, ingredientDf)
	saveIngredientsData(ingredientDf)
}