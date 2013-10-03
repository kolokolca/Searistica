source("Resources/Map.R")

#Generate a specifications file.

maxCurrentSpeed <- 1.0 #This must actually be determined after processing the generated map data.
AUVspeed <- 1.0
latitudeOffset <- 1.0
longitudeOffset <- 1.0
latitudeDistance <- 10.0
longitudeDistance <- 10.0
obstacleProbability <- 10.0 #probability is 1 / obstacleProbability
mapWidth <- 50
mapHeight <- 50
startLat <- runif(1, 1, mapWidth)
startLong <- runif(1, 1, mapHeight)

numberOfGoals <- 1
numberOfSources <- 1

sourceCoords = c()
sourceTiles = list()

goalCoords = c()
goalTiles = list()

tileExists <- function(newTile) {
	for (tile in sourceTiles) {
		if (tile@x == newTile@x && tile@y == newTile@y) {
			return(TRUE)
		}
	}
	for (tile in goalTiles) {
		if (tile@x == newTile@x && tile@y == newTile@y) {
			return(TRUE)
		}
	}

	FALSE
}

for (i in 1:numberOfSources) {
	sourceLat <- runif(1, 1, mapWidth)
	sourceLong <- runif(1, 1, mapHeight)
	sourceTile <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, sourceLong, sourceLat)

	while(tileExists(sourceTile)) {
		sourceLat <- runif(1, 1, mapWidth)
		sourceLong <- runif(1, 1, mapHeight)
		sourceTile <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, sourceLong, sourceLat)
	}
	
	sourceCoords[i * 2 - 1] <- sourceLong
	sourceCoords[i * 2] <- sourceLat
	sourceTiles[i] <- sourceTile
}

for (i in 1:numberOfGoals) {
	goalLat <- runif(1, 1, mapWidth)
	goalLong <- runif(1, 1, mapHeight)
	goalTile <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, goalLong, goalLat)

	while(tileExists(goalTile)) {
		goalLat <- runif(1, 1, mapWidth)
		goalLong <- runif(1, 1, mapHeight)
		goalTile <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, goalLong, goalLat)
	}
	
	goalCoords[i * 2 - 1] <- goalLong
	goalCoords[i * 2] <- goalLat
	goalTiles[i] <- goalTile
}


	
# print(paste("startLat: ", startLat, ", startLong: ", startLong))
# print(paste("goalLat: ", goalLat, ", goalLong: ", goalLong))

cat("longitude", "latitude", "\n", file="Data/sourceNodes.dat")
write(sourceCoords, ncolumns = 2, file="Data/sourceNodes.dat", append=TRUE)
cat("longitude", "latitude", "\n", file="Data/goalNodes.dat")
write(goalCoords, ncolumns = 2, file="Data/goalNodes.dat", append=TRUE)

cat(maxCurrentSpeed, AUVspeed, latitudeOffset, longitudeOffset, latitudeDistance, longitudeDistance, mapWidth, mapHeight, file="Data/specifications.dat")



#origin should be top left corner.
originLat <- 0.0
originLong <- 0.0

cat("latitude", "longitude", "northCurrent", "eastCurrent", "obstacle", "\n", file="Data/mapData.dat")

isSourceOrGoalTile <- function(y, x) {
	for (tile in sourceTiles) {
		if (tile@x == x && tile@y == y) {
			return(TRUE)
		}
	}
	for (tile in goalTiles) {
		if (tile@x == x && tile@y == y) {
			return(TRUE)
		}
	}
	
	FALSE
}


for (i in 1:mapWidth)
{

	cat((i / mapWidth) * 100,"%\n")

	for (j in 1:mapHeight)
	{
		mapTile <- c()

		mapTile[1] <- originLat + i * latitudeOffset	
		mapTile[2] <- originLong + j * longitudeOffset

		###UPDATE THIS
		if (runif(1, 0, obstacleProbability) < 2 && !isSourceOrGoalTile(j, i)) {
			mapTile[3] <- 0
			mapTile[4] <- 0
			mapTile[5] <- 1
		}
		else {
			mapTile[3] <- runif(1, -1 * maxCurrentSpeed, maxCurrentSpeed) #northCurrent
			mapTile[4] <- runif(1, -1 * (maxCurrentSpeed - abs(mapTile[3])), maxCurrentSpeed - abs(mapTile[3])) #eastCurrent
			mapTile[5] <- 0
		}
		
		write(mapTile, file="Data/mapData.dat", append=TRUE)
	}
}
