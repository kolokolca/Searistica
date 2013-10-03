source("Resources/Map.R")

maxCurrentSpeed <- 1.5 #This must actually be determined after processing the generated map data.
AUVspeed <- 1.0
latitudeOffset <- 1.0
longitudeOffset <- 1.0
latitudeDistance <- 10.0
longitudeDistance <- 10.0
obstacleProbability <- 10.0 #probability is 1 / obstacleProbability
numberOfGoals <- 10
numberOfSources <- 1

dir.create(file.path(".", "Data/"), showWarnings = FALSE)

generateTestCases <- function(mapWidth, mapHeight, quantity, reset=FALSE) {

	mapSizeDir = paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir = paste(mapSizeDir, "Maps/", sep="")
	specificationsDir = paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir = paste(mapSizeDir, "Sources/", sep="")
	goalDir = paste(mapSizeDir, "Goals/", sep="")
	
	dir.create(file.path(".", mapSizeDir), showWarnings = FALSE)	
	dir.create(file.path(".", mapDir), showWarnings = FALSE)
	dir.create(file.path(".", specificationsDir), showWarnings = FALSE)
	dir.create(file.path(".", sourceDir), showWarnings = FALSE)
	dir.create(file.path(".", goalDir), showWarnings = FALSE)

	emptyDir <- function(aDir) {
		fileList <- list.files(path = aDir, pattern = "*", full.names=TRUE)
		for (aFile in fileList) {
			unlink(aFile)
		}
		
		for (directory in list.dirs(path = aDir, full.names=TRUE)) {
			if (directory == aDir)
				next
			emptyDir(directory)
		}
	}
	
	deleteLastFileInDir <- function(aDir) {
		fileList <- list.files(path = aDir, pattern = "*", full.names=TRUE)
		fileToDelete <- ""
		for (fileName in fileList) {
			if (fileToDelete == "") {
				fileToDelete <- fileName
				next
			}

			if (strsplit(strsplit(fileToDelete, "-", fixed=TRUE)[[1]][[3]], ".", fixed=TRUE)[[1]][[1]] < strsplit(strsplit(fileName, "-", fixed=TRUE)[[1]][[3]], ".", fixed=TRUE)[[1]][[1]]) {
				fileToDelete <- fileName
			}
		}
	}

	if (reset == TRUE) {
		emptyDir(paste("./", mapDir, sep=""))
		emptyDir(paste("./", specificationsDir, sep=""))
		emptyDir(paste("./", sourceDir, sep=""))
		emptyDir(paste("./", goalDir, sep=""))
	} else {
		deleteLastFileInDir(paste("./", mapDir, sep=""))
		deleteLastFileInDir(paste("./", specificationsDir, sep=""))
		deleteLastFileInDir(paste("./", sourceDir, sep=""))
		deleteLastFileInDir(paste("./", goalDir, sep=""))
	}

	for (testNumber in (length(list.files(path = paste("./", mapDir, sep=""), pattern = "*", full.names=TRUE)) + 1):quantity) {
	
		startLat <- runif(1, 1, mapWidth)
		startLong <- runif(1, 1, mapHeight)
		
		cat(maxCurrentSpeed, AUVspeed, latitudeOffset, longitudeOffset, latitudeDistance, longitudeDistance, mapWidth, mapHeight, file=paste(specificationsDir, "specifications-", testNumber, ".dat", sep=""))
	
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

		cat("longitude", "latitude", "\n", file=paste(sourceDir, "sourceNodes-", testNumber, ".dat", sep=""))
		write(sourceCoords, ncolumns = 2, file=paste(sourceDir, "sourceNodes-", testNumber, ".dat", sep=""), append=TRUE)
		cat("longitude", "latitude", "\n", file=paste(goalDir, "goalNodes-", testNumber, ".dat", sep=""))
		write(goalCoords, ncolumns = 2, file=paste(goalDir, "goalNodes-", testNumber, ".dat", sep=""), append=TRUE)

		#origin should be top left corner.
		originLat <- 0.0
		originLong <- 0.0

		cat("latitude", "longitude", "northCurrent", "eastCurrent", "obstacle", "\n", file=paste(mapDir, "map-", testNumber, ".dat", sep=""))

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
			for (j in 1:mapHeight)
			{
				mapTile <- c()

				mapTile[1] <- originLat + i * latitudeOffset	
				mapTile[2] <- originLong + j * longitudeOffset

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
				
				write(mapTile, file=paste(mapDir, "map-", testNumber, ".dat", sep=""), append=TRUE)
			}
		}			
	}
}