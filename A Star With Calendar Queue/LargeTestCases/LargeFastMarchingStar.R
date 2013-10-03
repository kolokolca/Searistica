#Assumptions#
#Each position is represented by the lat and long at the center of the square, and every square extends some distance in both latitude and longitude to either side of this center point.
##Map Table must have headers: latitude, longitude, northCurrent, eastCurrent, obstacle (1/0 - 1 = obstacle, 0 = no obstacle)
##Specficiation Table must have headers: maxCurrentSpeed, AUVspeed, latitudeOffset (the difference in latitude between tiles), longitudeOffset, latitudeDistance (the width of the tile, in arbitrary units m, km, etc.), longitudeDistance (the length of the tile, in the same units as longitudeDistance), startLat, startLong, goalLat, goalLong, mapWidth (in terms of tiles/divisions), mapHeight)
##The heursitic is measured in units of time rather than distance, so that current can be used in the heuristic.


source("Resources/Map.R")
source("Resources/PriorityQueue.R")
source("Resources/CalendarQueue.R")
source("Resources/BubbleQueue.R")

# mapDataFile <- "Data/mapData.dat"
# specificationsDataFile <- "Data/specifications.dat"
# sourceNodeFile <- "Data/sourceNodes.dat"
# goalNodeFile <- "Data/goalNodes.dat"

# calculatedPathDir <- "Data/Paths/"
# pathDir <- "./Data/Paths"

minAcceptableSpeed <- 0.01
diagonalDistance <- 0


performMemoizationTests <- function(mapWidth, mapHeight, reset=FALSE) {
	mapSizeDir <- paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir <- paste(mapSizeDir, "Maps/", sep="")
	specificationsDir <- paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir <- paste(mapSizeDir, "Sources/", sep="")
	goalDir <- paste(mapSizeDir, "Goals/", sep="")
	trialAnalysisDir <- paste(mapSizeDir, "TrialAnalysis/", sep="")
	analysisDir <- paste(trialAnalysisDir, "Memoization/", sep="")
	trialPathsDir <- paste(mapSizeDir, "TrialPaths/", sep="")
	pathDir <- paste(trialPathsDir, "Memoization/", sep="")
		
	dir.create(file.path(".", trialAnalysisDir), showWarnings = FALSE)
	dir.create(file.path(".", analysisDir), showWarnings = FALSE)
	dir.create(file.path(".", trialPathsDir), showWarnings = FALSE)
	dir.create(file.path(".", pathDir), showWarnings = FALSE)
	

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
		emptyDir(paste("./", analysisDir, sep=""))
		emptyDir(paste("./", pathDir, sep=""))	
	} else {
		deleteLastFileInDir(paste("./", analysisDir, sep=""))
		deleteLastFileInDir(paste("./", pathDir, sep=""))
	}
	
	mapFileList <- list.files(path = paste("./", mapDir, sep=""), pattern = "*.dat", full.names=TRUE)
	specificationsFileList <- list.files(path = paste("./", specificationsDir, sep=""), pattern = "*.dat", full.names=TRUE)
	sourceFileList <- list.files(path = paste("./", sourceDir, sep=""), pattern = "*.dat", full.names=TRUE)
	goalFileList <- list.files(path = paste("./", goalDir, sep=""), pattern = "*.dat", full.names=TRUE)
	
	for (trial in (length(list.files(path = paste("./", analysisDir, sep=""), pattern = "*", full.names=TRUE)) + 1):length(mapFileList)) {
		calculatedPathDir <<- paste(pathDir, "trial-", trial, "/", sep="")
		analysisFile <- paste(analysisDir, "trial-", trial, ".dat", sep="")
		
		dir.create(file.path(".", calculatedPathDir), showWarnings = FALSE)

		mapDataFile <<- mapFileList[[trial]]
		specificationsDataFile <<- specificationsFileList[[trial]]
		sourceNodeFile <<- sourceFileList[[trial]]
		goalNodeFile <<- goalFileList[[trial]]
		
		timeResults <- performSearch(analysis=TRUE)
		
		dim(timeResults) <- c(1, length(timeResults))
		cat("time", "\n", file=analysisFile)
		write(timeResults, ncolumns = 1, file=analysisFile, append=TRUE)
	}
}

performAllPairsTests <- function(mapWidth, mapHeight, reset=FALSE) {
	mapSizeDir <- paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir <- paste(mapSizeDir, "Maps/", sep="")
	specificationsDir <- paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir <- paste(mapSizeDir, "Sources/", sep="")
	goalDir <- paste(mapSizeDir, "Goals/", sep="")
	trialAnalysisDir <- paste(mapSizeDir, "TrialAnalysis/", sep="")
	analysisDir <- paste(trialAnalysisDir, "AllPairs/", sep="")
	trialPathsDir <- paste(mapSizeDir, "TrialPaths/", sep="")
	pathDir <- paste(trialPathsDir, "AllPairs/", sep="")
		
	dir.create(file.path(".", trialAnalysisDir), showWarnings = FALSE)
	dir.create(file.path(".", analysisDir), showWarnings = FALSE)
	dir.create(file.path(".", trialPathsDir), showWarnings = FALSE)
	dir.create(file.path(".", pathDir), showWarnings = FALSE)
	

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
		emptyDir(paste("./", analysisDir, sep=""))
		emptyDir(paste("./", pathDir, sep=""))	
	} else {
		deleteLastFileInDir(paste("./", analysisDir, sep=""))
		deleteLastFileInDir(paste("./", pathDir, sep=""))
	}
	
	mapFileList <- list.files(path = paste("./", mapDir, sep=""), pattern = "*.dat", full.names=TRUE)
	specificationsFileList <- list.files(path = paste("./", specificationsDir, sep=""), pattern = "*.dat", full.names=TRUE)
	sourceFileList <- list.files(path = paste("./", sourceDir, sep=""), pattern = "*.dat", full.names=TRUE)
	goalFileList <- list.files(path = paste("./", goalDir, sep=""), pattern = "*.dat", full.names=TRUE)
	
	for (trial in (length(list.files(path = paste("./", analysisDir, sep=""), pattern = "*", full.names=TRUE)) + 1):length(mapFileList)) {
		calculatedPathDir <<- paste(pathDir, "trial-", trial, "/", sep="")
		analysisFile <- paste(analysisDir, "trial-", trial, ".dat", sep="")
		
		dir.create(file.path(".", calculatedPathDir), showWarnings = FALSE)

		mapDataFile <<- mapFileList[[trial]]
		specificationsDataFile <<- specificationsFileList[[trial]]
		sourceNodeFile <<- sourceFileList[[trial]]
		goalNodeFile <<- goalFileList[[trial]]
		
		timeResults <- performSearch(analysis=TRUE, allPairs=TRUE)
		
		dim(timeResults) <- c(1, length(timeResults))
		cat("time", "\n", file=analysisFile)
		write(timeResults, ncolumns = 1, file=analysisFile, append=TRUE)
	}
}

performDijkstraTests <- function(mapWidth, mapHeight, reset=FALSE) {
	mapSizeDir <- paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir <- paste(mapSizeDir, "Maps/", sep="")
	specificationsDir <- paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir <- paste(mapSizeDir, "Sources/", sep="")
	goalDir <- paste(mapSizeDir, "Goals/", sep="")
	trialAnalysisDir <- paste(mapSizeDir, "TrialAnalysis/", sep="")
	analysisDir <- paste(trialAnalysisDir, "Dijkstra/", sep="")
	trialPathsDir <- paste(mapSizeDir, "TrialPaths/", sep="")
	pathDir <- paste(trialPathsDir, "Dijkstra/", sep="")
		
	dir.create(file.path(".", trialAnalysisDir), showWarnings = FALSE)
	dir.create(file.path(".", analysisDir), showWarnings = FALSE)
	dir.create(file.path(".", trialPathsDir), showWarnings = FALSE)
	dir.create(file.path(".", pathDir), showWarnings = FALSE)
	

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
		emptyDir(paste("./", analysisDir, sep=""))
		emptyDir(paste("./", pathDir, sep=""))	
	} else {
		deleteLastFileInDir(paste("./", analysisDir, sep=""))
		deleteLastFileInDir(paste("./", pathDir, sep=""))
	}
	
	mapFileList <- list.files(path = paste("./", mapDir, sep=""), pattern = "*.dat", full.names=TRUE)
	specificationsFileList <- list.files(path = paste("./", specificationsDir, sep=""), pattern = "*.dat", full.names=TRUE)
	sourceFileList <- list.files(path = paste("./", sourceDir, sep=""), pattern = "*.dat", full.names=TRUE)
	goalFileList <- list.files(path = paste("./", goalDir, sep=""), pattern = "*.dat", full.names=TRUE)
	
	for (trial in (length(list.files(path = paste("./", analysisDir, sep=""), pattern = "*", full.names=TRUE)) + 1):length(mapFileList)) {
		calculatedPathDir <<- paste(pathDir, "trial-", trial, "/", sep="")
		analysisFile <- paste(analysisDir, "trial-", trial, ".dat", sep="")
		
		dir.create(file.path(".", calculatedPathDir), showWarnings = FALSE)

		mapDataFile <<- mapFileList[[trial]]
		specificationsDataFile <<- specificationsFileList[[trial]]
		sourceNodeFile <<- sourceFileList[[trial]]
		goalNodeFile <<- goalFileList[[trial]]
		
		timeResults <- performSearch(analysis=TRUE, dijkstra=TRUE)
		
		dim(timeResults) <- c(1, length(timeResults))
		cat("time", "\n", file=analysisFile)
		write(timeResults, ncolumns = 1, file=analysisFile, append=TRUE)
	}
}






performQueueComparison <- function(mapWidth, mapHeight, reset=FALSE) {
	mapSizeDir <- paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir <- paste(mapSizeDir, "Maps/", sep="")
	specificationsDir <- paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir <- paste(mapSizeDir, "Sources/", sep="")
	goalDir <- paste(mapSizeDir, "Goals/", sep="")
	trialAnalysisDir <- paste(mapSizeDir, "TrialAnalysis/", sep="")
	analysisDir <- paste(trialAnalysisDir, "QueueComparison/", sep="")
	trialPathsDir <- paste(mapSizeDir, "TrialPaths/", sep="")
	pathDir <- paste(trialPathsDir, "QueueComparison/", sep="")
		
	dir.create(file.path(".", trialAnalysisDir), showWarnings = FALSE)
	dir.create(file.path(".", analysisDir), showWarnings = FALSE)
	dir.create(file.path(".", trialPathsDir), showWarnings = FALSE)
	dir.create(file.path(".", pathDir), showWarnings = FALSE)
	
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
		emptyDir(paste("./", analysisDir, sep=""))
		emptyDir(paste("./", pathDir, sep=""))	
	} else {
		deleteLastFileInDir(paste("./", analysisDir, sep=""))
		deleteLastFileInDir(paste("./", pathDir, sep=""))
	}
	
	mapFileList <- list.files(path = paste("./", mapDir, sep=""), pattern = "*.dat", full.names=TRUE)
	specificationsFileList <- list.files(path = paste("./", specificationsDir, sep=""), pattern = "*.dat", full.names=TRUE)
	sourceFileList <- list.files(path = paste("./", sourceDir, sep=""), pattern = "*.dat", full.names=TRUE)
	goalFileList <- list.files(path = paste("./", goalDir, sep=""), pattern = "*.dat", full.names=TRUE)
	
	for (trial in (length(list.files(path = paste("./", analysisDir, sep=""), pattern = "*", full.names=TRUE)) + 1):length(mapFileList)) {
		calculatedPathDir <<- paste(pathDir, "trial-", trial, "/", sep="")
		analysisFile <- paste(analysisDir, "trial-", trial, ".dat", sep="")
		
		dir.create(file.path(".", calculatedPathDir), showWarnings = FALSE)

		mapDataFile <<- mapFileList[[trial]]
		specificationsDataFile <<- specificationsFileList[[trial]]
		sourceNodeFile <<- sourceFileList[[trial]]
		goalNodeFile <<- goalFileList[[trial]]
		
		calendarQueueResults <- performSearch(analysis=TRUE, singleGoal = TRUE)
		mapDataFile <<- mapFileList[[trial]]
		
		priorityQueueResults <- performSearch(queueTypeName = "pq", analysis=TRUE, singleGoal = TRUE)
		results <- c(calendarQueueResults[[1]], priorityQueueResults[[1]])
		
		dim(results) <- c(1, length(results))
		cat("CalendarQueueTime", "PriorityQueueTime", "\n", file=analysisFile)
		write(results, ncolumns = 2, file=analysisFile, append=TRUE)
	}

}


performSpecificQueueComparison <- function(mapWidth, mapHeight, trialNumber) {
	mapSizeDir <- paste("Data/Map-", mapWidth, "x", mapHeight, "/", sep="")
	mapDir <- paste(mapSizeDir, "Maps/", sep="")
	specificationsDir <- paste(mapSizeDir, "MapSpecifications/", sep="")
	sourceDir <- paste(mapSizeDir, "Sources/", sep="")
	goalDir <- paste(mapSizeDir, "Goals/", sep="")
	trialAnalysisDir <- paste(mapSizeDir, "TrialAnalysis/", sep="")
	analysisDir <- paste(trialAnalysisDir, "QueueComparison/", sep="")
	trialPathsDir <- paste(mapSizeDir, "TrialPaths/", sep="")
	pathDir <- paste(trialPathsDir, "QueueComparison/", sep="")
		
	dir.create(file.path(".", trialAnalysisDir), showWarnings = FALSE)
	dir.create(file.path(".", analysisDir), showWarnings = FALSE)
	dir.create(file.path(".", trialPathsDir), showWarnings = FALSE)
	dir.create(file.path(".", pathDir), showWarnings = FALSE)
	
	deleteFile <- function(aDir) {
		fileList <- list.files(path = aDir, pattern = paste("trial-", trialNumber, ".dat", sep=""), full.names=TRUE)
		for (aFile in fileList) {
			unlink(aFile)
		}
	}
	
	deleteFile(paste("./", analysisDir, sep=""))
	deleteFile(paste("./", pathDir, sep=""))
	
	
	calculatedPathDir <<- paste(pathDir, "trial-", trialNumber, "/", sep="")
	analysisFile <- paste(analysisDir, "trial-", trialNumber, ".dat", sep="")
		
	dir.create(file.path(".", calculatedPathDir), showWarnings = FALSE)

	mapDataFile <<- paste(mapDir, "map-", trialNumber, ".dat", sep="")
	specificationsDataFile <<- paste(specificationsDir, "specifications-", trialNumber, ".dat", sep="")
	sourceNodeFile <<- paste(sourceDir, "sourceNodes-", trialNumber, ".dat", sep="")
	goalNodeFile <<- paste(goalDir, "goalNodes-", trialNumber, ".dat", sep="")
		
	calendarQueueResults <- performSearch(analysis=TRUE, singleGoal = TRUE)
	mapDataFile <<- paste(mapDir, "map-", trialNumber, ".dat", sep="")
		
	priorityQueueResults <- performSearch(queueTypeName = "pq", analysis=TRUE, singleGoal = TRUE)
	results <- c(calendarQueueResults[[1]], priorityQueueResults[[1]])
		
	dim(results) <- c(1, length(results))
	cat("CalendarQueueTime", "PriorityQueueTime", "\n", file=analysisFile)
	write(results, ncolumns = 2, file=analysisFile, append=TRUE)
	
}



performSearch <- function(queueTypeName = "cq", analysis = FALSE, useMemoization = TRUE, singleGoal = FALSE, allPairs=FALSE, dijkstra=FALSE) {
	timeResults = c()

	dir.create(file.path(".", "Data/"), showWarnings = FALSE)
	dir.create(file.path(".", "Data/Paths/"), showWarnings = FALSE)
	
	#Remove existing paths to avoid path buildup.
	pathFileList <- list.files(path = paste("./", calculatedPathDir), pattern = "*.dat", full.names=TRUE)
	for (pathFile in pathFileList) {
		unlink(pathFile)
	}
	
	#Read map meta-data
	specifications <- scan(specificationsDataFile, list(maxCurrentSpeed=0, AUVSpeed=0, latitudeOffset=0, longitudeOffset=0, latitudeDistance=0, longitudeDistance=0, mapWidth=0, mapHeight=0))
	attach(specifications)
	diagonalDistance <<- sqrt(latitudeDistance * latitudeDistance + longitudeDistance * longitudeDistance)
	
	#Read map
	mapComponents <- c("latitude", "longitude", "northCurrent", "eastCurrent", "obstacle", "acceptStatus", "heuristic", "travelTime")
	originalMap <- loadMap(mapDataFile, mapWidth, mapHeight, mapComponents)
	
	unprocessedSourceNodes <- read.table(sourceNodeFile, header=TRUE, colClasses="numeric")
	sourceNodeTable <- data.matrix(unprocessedSourceNodes)
	rm(unprocessedSourceNodes)
	
	sourceNodeList = list()
	for (row in 1:length(sourceNodeTable[,1])) {
		sourceNodeList[row] <- getStartTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, sourceNodeTable[row,1], sourceNodeTable[row, 2])
	}
	
	unprocessedGoalNodes <- read.table(goalNodeFile, header=TRUE, colClasses="numeric")
	goalNodeTable <- data.matrix(unprocessedGoalNodes)
	rm(unprocessedGoalNodes)
	
	goalNodeList = list()
	
	if (allPairs) {
		goalNodeList[1] <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, 0, 0)

		for (row in 1:length(goalNodeTable[,1])) {
			goalNodeList[row + 1] <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, goalNodeTable[row,1], goalNodeTable[row, 2])
		}
	} else {
		for (row in 1:length(goalNodeTable[,1])) {
			goalNodeList[row] <- getGoalTile2(longitudeOffset, latitudeOffset, longitudeOffset, latitudeOffset, goalNodeTable[row,1], goalNodeTable[row, 2])
		}
	
	}

	incalculablePaths <- 0
	
	if (queueTypeName == "cq") {
		queueType <- CalendarQueue
	} else if (queueTypeName == "pq") {
		queueType <- PriorityQueue
	}
	
	totalTime <- proc.time()

	for (sourceNode in sourceNodeList) {
	
		if (useMemoization) {
			map <<- originalMap
			queue <<- queueType$new()		
		}
		
		if (analysis) {
			sourceStartTime <- proc.time()
		}
		
		for (goalNode in goalNodeList) {
			
			if (!useMemoization) {
				map <<- originalMap
				queue <<- queueType$new()
			}
			
			if (analysis) {
				pathStartTime <- proc.time()
			}
		
			pathCoords <- findPath(sourceNode, goalNode, dijkstra)
			
			if (is.null(pathCoords)) {
				incalculablePaths <- incalculablePaths + 1
				if (analysis) {
					timeResults[[length(timeResults) + 1]] <- proc.time()[[1]] + proc.time()[[2]] - pathStartTime[[1]] - pathStartTime[[2]]
				}
			}
			else {
				pathOutputFile <- paste(calculatedPathDir, sourceNode@y, ",", sourceNode@x, "-", goalNode@y, ",", goalNode@x, ".dat", sep="")
				
				if (analysis) {
					timeResults[[length(timeResults) + 1]] <- proc.time()[[1]] + proc.time()[[2]] - pathStartTime[[1]] - pathStartTime[[2]]
				}
				
				cat("longitude", "latitude", "\n", file=pathOutputFile)
				write(pathCoords, ncolumns = 2, file=pathOutputFile, append=TRUE)
			}
			
			if (singleGoal == TRUE) {
				rm(specifications, originalMap)
				rm(queue)
				detach(specifications)
				return(timeResults)
			}
			
		}
		
		if (analysis) {
			timeResults[[length(timeResults) + 1]] <- proc.time()[[1]] + proc.time()[[2]] - sourceStartTime[[1]] - sourceStartTime[[2]]
		}
	}
	
	rm(specifications, originalMap)
	detach(specifications)
	
	return(timeResults)
}
	
# Determines if a tile is "valid".
# A valid tile is not an obstacle, has not yet been "accepted" as having the lowest possible cost found to it, is within the bounds of the map, and has a valid number for its current heuristic (unevaluated tiles have -1 as their heuristic).
isValidTile <- function(currentTile) {

	if (map[[currentTile@y, currentTile@x, "obstacle"]])
		return(FALSE)
	else if (map[[currentTile@y, currentTile@x, "acceptStatus"]])
		return(FALSE)
	else if (currentTile@y < 1 || currentTile@y > length(map[,1,1]) || currentTile@x < 1 || currentTile@x > length(map[1,,1]))
		return(FALSE)
	else if (is.null(map[[currentTile@y, currentTile@x, "heuristic"]]))
		return(FALSE)
		
	return(TRUE)
}

# --- Perhaps update this to account for the fact of being on a grid rather than using euclidean distance. ---
# Calculates the heuristic from the given tile to the given goal tile.
calculateHeuristic <- function(currentTile, goalTile) {
	if (!isValidTile(currentTile))
		return(NULL)
		
	distance <- sqrt(((goalTile@x - currentTile@x) * latitudeDistance)^2 + ((goalTile@y - currentTile@y) * longitudeDistance)^2)/(AUVSpeed + maxCurrentSpeed)
	bestCaseSpeedOfAUV <- AUVSpeed + maxCurrentSpeed
	bestCaseTravelTime <- distance / bestCaseSpeedOfAUV
}


# Returns the minimum possible travel time to the currentTile given its currently evaluated 8 surrounding neighbours.
calculateMinTravelTime <- function(currentTile, startTile, goalTile) {

	if(!isValidTile(currentTile)) {
		return(NULL)
	}

	# Returns the time to reach the currentTile from its neighbour defined as being 1 tile off of the currentTile in one of the 8 directions defined by yOffset and xOffset. +1 corresponds to above and to the right, -1 corresponds to below and to the left as appropriate.
	calculateTravelTime <- function(currentTile, yOffset, xOffset) {
		oldTile = MapPosition(y = currentTile@y + yOffset, x = currentTile@x + xOffset, priority = -1)

		if (!map[[oldTile@y, oldTile@x, "acceptStatus"]])
			return(NULL)
									
		# Calculations are done on a triangle.
		# The three sides (speeds/velocities) are the (current), the (goal) speed/velocity, and the speed/velocity the AUV is (required) to move in to achieve the goal speed/velocity.

		# Calculates goalAngle, longitudeDistance and latitudeDistance account for non-square tiles. It assumed the map is aligned with latitude and longitude.
		goalAngle <- atan2(-1 * yOffset * longitudeDistance, -1 * xOffset * latitudeDistance) %% (pi * 2)

		# Calculates the maximum speed attainable in the goal direction (goalAngle) given the northCurrent and eastCurrent.
		calculateSpeed <- function(northCurrent, eastCurrent) {

			if (eastCurrent == 0 && northCurrent == 0) {
				return(AUVSpeed)
			}
			
			angleBetweenCurrentAndGoal <- abs((atan2(northCurrent, eastCurrent) - goalAngle + pi) %% (2 * pi) - pi)
			angleBetweenGoalAndRequired <- asin(sqrt(northCurrent^2 + eastCurrent^2) * sin(angleBetweenCurrentAndGoal) / AUVSpeed)
			angleBetweenRequiredAndCurrent <- 2 * pi - angleBetweenCurrentAndGoal - angleBetweenGoalAndRequired

			#There is no answer (if angleBetweenGoalAndRequired is NaN, angleBetweenRequiredAndCurrent will be as well).
			if (is.nan(angleBetweenGoalAndRequired))
				return(NULL)
					
			finalSpeed <- abs(sin(angleBetweenRequiredAndCurrent) * AUVSpeed / sin(angleBetweenCurrentAndGoal))
			if (finalSpeed == Inf)
				return(NULL)
			else
				return(finalSpeed)
		}
			
		firstTileSpeed <- calculateSpeed(map[[oldTile@y, oldTile@x, "northCurrent"]], map[[oldTile@y, oldTile@x, "eastCurrent"]])
		secondTileSpeed <- calculateSpeed(map[[currentTile@y, currentTile@x, "northCurrent"]], map[[currentTile@y, currentTile@x, "eastCurrent"]])				
		
		# Determine if the speeds in both tiles is fast enough, if not fast enough, error could result in no movement or movement in wrong direction.
		# If speeds are acceptable, determine how long it will take to traverse the tile.
		if (!is.null(firstTileSpeed) && !is.null(secondTileSpeed) && firstTileSpeed >= minAcceptableSpeed && secondTileSpeed >= minAcceptableSpeed) {
			averageSpeed <- (firstTileSpeed + secondTileSpeed) / 2
			if (xOffset == 0)
				distance <- longitudeDistance
			else if (yOffset == 0)
				distance <- latitudeDistance
			else
				distance <- sqrt(longitudeDistance^2 + latitudeDistance^2)
			
			time <- distance / averageSpeed + map[[oldTile@y, oldTile@x, "travelTime"]]
		}
		else
			NULL
	}


	if (startTile@x == currentTile@x && startTile@y == currentTile@y) {
		return(0)
	}
		

	# Of the currently evaluated neighbours, determine through what neighbour this tile can be reached the quickest.
	minTravelTime <- -1	
	for (i in -1:1) {
		for (j in -1:1) {
			if (currentTile@y + i > 0 && currentTile@y + i <= length(map[,1,1]) && currentTile@x + j > 0 && currentTile@x + j <= length(map[1,,1])
					&& map[[currentTile@y + i, currentTile@x + j, "acceptStatus"]] == 1 && (i != 0 || j != 0)
					&& (i == 0 || j == 0 || !map[[currentTile@y + i, currentTile@x, "obstacle"]] || !map[[currentTile@y, currentTile@x + j, "obstacle"]])) {
					
						
				travelTime <- calculateTravelTime(currentTile, i, j)
				if (!is.null(travelTime) && (travelTime < minTravelTime || minTravelTime == -1)) {
					minTravelTime <- travelTime
				}
			}
		}
	}
		
	if (minTravelTime == -1)
		NULL
	else {
		minTravelTime		
	}
}



#Uses a "global" queue and map
findPath = function(startTile, goalTile, dijkstra=FALSE) {

	if (goalTile@y==0 || !map[[goalTile@y, goalTile@x, "acceptStatus"]]) {

	
		if (dijkstra == FALSE) {
	
			oldHeuristicTiles = list()
			i <- 1
			while (queue$elementCount > 0) {
				oldHeuristicTiles[i] <- queue$remove()
				i <- i + 1
			}
			queue$reset()
			while (length(oldHeuristicTiles) > 0) {
				tile <- oldHeuristicTiles[[1]]
				oldHeuristicTiles[[1]] <- NULL

				if (map[tile@y, tile@x, "acceptStatus"])
					next
				
				map[[tile@y, tile@x, "heuristic"]] <<- calculateHeuristic(tile, goalTile)
				tile@priority <- map[tile@y, tile@x, "heuristic"] + map[tile@y, tile@x, "travelTime"]
				queue$add(tile)
			}

		}
		
		currentTile <- startTile
		queue$add(startTile)

		while (currentTile@y != goalTile@y || currentTile@x != goalTile@x) {	

			while (map[[currentTile@y, currentTile@x, "acceptStatus"]]) {
				newTile <- queue$remove()
				
				if (is.null(newTile)) { #FAIL
					return(NULL)
				}

				currentTile <- newTile
			}
			if (currentTile@y == goalTile@y && currentTile@x == goalTile@x) {
				if (!dijkstra) {
					map[[currentTile@y, currentTile@x, "heuristic"]] <<- calculateHeuristic(currentTile, goalTile)
				} else {
					map[[currentTile@y, currentTile@x, "heuristic"]] <<- 0
				}
				map[[currentTile@y, currentTile@x, "travelTime"]] <<- calculateMinTravelTime(currentTile, startTile, goalTile)
				map[[currentTile@y, currentTile@x, "acceptStatus"]] <<- 1
				break
			}

			if (!map[[currentTile@y, currentTile@x, "acceptStatus"]])	{	
				if (!dijkstra) {
					map[[currentTile@y, currentTile@x, "heuristic"]] <<- calculateHeuristic(currentTile, goalTile)
				} else {
					map[[currentTile@y, currentTile@x, "heuristic"]] <<- 0
				}
				map[[currentTile@y, currentTile@x, "travelTime"]] <<- calculateMinTravelTime(currentTile, startTile, goalTile)	
			}
			else {
				stop("An accepted tile is being evaluated, investigate.")
			}
			map[[currentTile@y, currentTile@x, "acceptStatus"]] <<- 1

			updateNeighbour <- function(neighbourTile) {	
			
				if(!map[[neighbourTile@y, neighbourTile@x, "acceptStatus"]] && !map[[neighbourTile@y, neighbourTile@x, "obstacle"]]) {
					
					travelTime <- calculateMinTravelTime(neighbourTile, startTile, goalTile)

					if (is.null(travelTime)) {
						return()
					}
					
					if (!dijkstra) {
						heuristic <- calculateHeuristic(neighbourTile, goalTile)
					} else {
						heuristic <<- 0
					}
					
					if (map[[neighbourTile@y, neighbourTile@x, "heuristic"]] == -1 || map[[neighbourTile@y, neighbourTile@x, "travelTime"]] > travelTime){
						map[[neighbourTile@y, neighbourTile@x, "heuristic"]] <<- heuristic
						map[[neighbourTile@y, neighbourTile@x, "travelTime"]] <<- travelTime
							
						neighbourTile@priority <- map[neighbourTile@y, neighbourTile@x, "heuristic"] + map[neighbourTile@y, neighbourTile@x, "travelTime"]

						queue$add(neighbourTile)				
					}
				}
			}
			
			if (currentTile@y < length(map[,1,1]))
				updateNeighbour(MapPosition(y = currentTile@y + 1, x = currentTile@x, priority = -1))
			if (currentTile@y > 1)
				updateNeighbour(MapPosition(y = currentTile@y - 1, x = currentTile@x, priority = -1))
			if (currentTile@x < length(map[1,,1]))
				updateNeighbour(MapPosition(y = currentTile@y, x = currentTile@x + 1, priority = -1))
			if (currentTile@x > 1)
				updateNeighbour(MapPosition(y = currentTile@y, x = currentTile@x - 1, priority = -1))
	
		}
		rm(currentTile)
	}
	
	# This function determines and returns the path from the start to the goal as a list of MapPositions.
	getPath <- function(goalTile, startTile) {
		currentTile <- goalTile
		path <- list(goalTile)

		while(startTile@y != currentTile@y || startTile@x != currentTile@x) {
		
			maxDif <- 0
			nextTile <- currentTile
			for (i in -1:1) {
				for (j in -1:1) {
					if(currentTile@y + i <= length(map[,1,1]) && currentTile@y + i > 0 && currentTile@x + j <= length(map[1,,1]) && currentTile@x + j > 0) {
						if ((i != 0 || j != 0) && map[[currentTile@y + i, currentTile@x + j, "acceptStatus"]]) {

							if (i != 0 && j != 0 && map[[currentTile@y + i, currentTile@x, "obstacle"]] && map[[currentTile@y, currentTile@x + j, "obstacle"]])
								next	
							difference <- (map[[currentTile@y, currentTile@x, "travelTime"]] - map[[currentTile@y + i, currentTile@x + j, "travelTime"]])/sqrt((latitudeDistance * i)^2 + (longitudeDistance * j)^2)
							if (difference > maxDif) {
							
								maxDif <- difference
								nextTile <- MapPosition(y = currentTile@y + i, x = currentTile@x + j, priority = -1)						
							}
						}			
					}
				}
			}
			currentTile <- nextTile
			path <- c(currentTile, path)
		}
		path
	}

	path <- getPath(goalTile, startTile)

	pathCoords <- c()

	for (i in 1:length(path))
	{
		pathCoords <- c(pathCoords, map[[path[[i]]@y, path[[i]]@x, "latitude"]])
		pathCoords <- c(pathCoords, map[[path[[i]]@y, path[[i]]@x, "longitude"]])
	}
	
	dim(pathCoords) <- c(2, length(pathCoords)/2)
	
	return(pathCoords)
	
	# cat("longitude", "latitude", "\n", file=pathOutputFile)
	# write(pathCoords, ncolumns = 2, file=pathOutputFile, append=TRUE)
	# detach(specifications)

	# rm(startTile, goalTile, specifications, diagonalDistance, map)
}