loadMap <- function(fileName, width, height, dimNames) {

	unprocessedMapData <- read.table(fileName, header=TRUE, colClasses="numeric", nrows = width * height + 10)

	if (length(dimNames) == 8) {
		unprocessedMapData$acceptStatus <- apply(unprocessedMapData, 1, function(row) FALSE)
		unprocessedMapData$heuristic <- apply(unprocessedMapData, 1, function(row) -1)
		unprocessedMapData$travelTime <- apply(unprocessedMapData, 1, function(row) -1)
	}
	
	mapData <- data.matrix(unprocessedMapData)
	rm(unprocessedMapData)
	dim(mapData) <- c(height, width, length(dimNames))
	dimnames(mapData) <- list(NULL, NULL, dimNames)

	mapData
}

MapPosition <- setClass("MapPosition", representation(y="numeric", x="numeric", priority="numeric"))
		
getStartTile <- function(map, longitudeOffset, latitudeOffset, startLongitude, startLatitude) {
	MapPosition(y = round((startLongitude / longitudeOffset) - map[[1,1,"longitude"]] + 1), x = round((startLatitude / latitudeOffset) - map[[1,1,"latitude"]] + 1), priority = 0)
}

getStartTile2 <- function(originLongitude, originLatitude, longitudeOffset, latitudeOffset, startLongitude, startLatitude) {
	MapPosition(y = round((startLongitude / longitudeOffset) - originLongitude + 1), x = round((startLatitude / latitudeOffset) - originLatitude + 1), priority = 0)
}

getGoalTile <- function(map, longitudeOffset, latitudeOffset, goalLongitude, goalLatitude) {
	MapPosition(y = round((goalLongitude / longitudeOffset) - map[[1,1,"longitude"]] + 1), x = round((goalLatitude / latitudeOffset) - map[[1,1,"latitude"]] + 1), priority = 0)
}

getGoalTile2 <- function(originLongitude, originLatitude, longitudeOffset, latitudeOffset, goalLongitude, goalLatitude) {
	MapPosition(y = round((goalLongitude / longitudeOffset) - originLongitude + 1), x = round((goalLatitude / latitudeOffset) - originLatitude + 1), priority = 0)
}