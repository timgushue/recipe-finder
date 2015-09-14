library(RCurl)
library(jsonlite)
library("clients/diskIOClient.R")

# The Food 2 Fork
apiKey <- loadCredentials("credentials/credentials.yml")$food2fork$key

# Searching for recipes 
# key: API Key
# q: Search Query (Ingredients should be separated by commas, no spaces).
# sort: (optional) How the results should be sorted. 
#  The Food2Fork API offers two kinds of sorting for queries. 
#  The first is by rating (default):  sort=r
#  This rating is based off of social media scores to determine the best recipes.
#  The second is by trendingness: sort=t
#  The most recent recipes from publishers have a trend score based on how quickly they are gaining popularity.
# page: (optional) Used to get additional results.
#  Any request will return a maximum of 30 results. 
#  To get the next set of results send the same request again but with page = 2. The default if omitted is page = 1 
#
#
# The response is a data frame with 8 columns:
#  publisher: Name of the Publisher
#  f2f_url: Url of the recipe on Food2Fork.com
#  title: Title of the recipe
#  source_url: Original Url of the recipe on the publisher's site
#  recipe_id: Food2Fork unique recipe id
#  image_url: URL of the image
#  social_rank: The Social Ranking of the Recipe (As determined by the Food2Fork Ranking Algorithm)
#  publisher_url: Base url of the publisher
#
# Sample request: searchRequest(q="vegetarian", key=apiKey)
# Sample response:
#   "publisher"                  "f2f_url"
#   Two Peas and Their Pod       http://food2fork.com/view/54419
#   "title"                      "source_url"
#   Vegetarian Quinoa Chili      http://www.twopeasandtheirpod.com/vegetarian-quinoa-chili/
#   "recipe_id"                  "image_url"
#   54419                        http://static.food2fork.com/quinoachili15b76.jpg
#   "social_rank                 "publisher_url"
#   100                          http://www.twopeasandtheirpod.com


searchQuery <- function(q, sort="r", page="1", key) { 
    searchUrl <- paste(
        "http://food2fork.com/api/search?key=", key,
        "&q=", q,
        "&sort=", sort,
        "&page=", page, 
        sep="") 
    response <- getURI(searchUrl)
    # f2f returns a list where the first element is a count of results returned 
    # and the second element is the actual results that we are interested in.
    data <- fromJSON(response)[2][[1]]
}


# Requesting recipes by id
# key: API Key
# rId: Id ("recipe_id") of desired recipe as returned by Search Query 
#
#
# The response is a list with 9 objects:
#  publisher: Name of the Publisher
#  f2f_url: Url of the recipe on Food2Fork.com
#  ingredients: A list of the ingredients of this recipe
#  source_url: Original Url of the recipe on the publisher's site
#  recipe_id: Food2Fork unique recipe id
#  image_url: URL of the image
#  social_rank: The Social Ranking of the Recipe (As determined by our Ranking Algorithm)
#  publisher_url: Base url of the publisher
#  title: Title of the recipe
#  
# Sample request: searchRequest(q="vegetarian", key=apiKey)
# Sample response:
#  $publisher                      $f2f_url
#  "Two Peas and Their Pod"        "http://food2fork.com/view/54419"
#  $ingredients                    $source_url
#    [1] "1/2 cup quinoa, rinsed"  "http://www.twopeasandtheirpod.com/vegetarian-quinoa-chili/"
#    [2] "... etc."
#  $recipe_id                      $image_url
#  "54419"                         "http://static.food2fork.com/quinoachili15b76.jpg"
#  $social_rank                    $publisher_url
#  100                             "http://www.twopeasandtheirpod.com"
#  $title
#  "Vegetarian Quinoa Chili"

getRecipe <- function(rId, key) { 
    recipeUrl <- paste("http://food2fork.com/api/get?key=", key, "&rId=", rId, sep="") 
    response <- getURI(recipeUrl)
    recipeData <- fromJSON(response)[[1]]
}

# Requesting recipe ingredients by id
# key: API Key
# rId: Id ("recipe_id") of desired recipe as returned by Search Query 
#
#
# The response is a data frame with 2 columns:
#  recipe_id: Food2Fork unique recipe id
#  ingredients: An ingredient of the recipe
getRecipeIngredients <- function() {
    response <- getRecipe(rId, key)
    as.data.frame(response[c("recipe_id", "ingredients")], stringsAsFactors=FALSE)
}
