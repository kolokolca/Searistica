#Use the same specifications and mapData files used in determining the path.

source("Resources/Map.R")

mapDataFile = "Data/mapData.dat"
specificationsDataFile = "Data/specifications.dat"
pathDirectory = "Data/Paths"
sourceNodesFile = "Data/sourceNodes.dat"
goalNodesFile = "Data/goalNodes.dat"

myColors <- list(12, 26, 30, 31, 32, 34, 42, 45, 47, 58, 62, 76, 81, 84, 89, 92, 96, 112, 113, 119, 125, 132, 136)

specifications <- scan(specificationsDataFile, list(maxCurrentSpeed=0, AUVspeed=0, latitudeOffset=0, longitudeOffset=0, latitudeDistance=0, longitudeDistance=0, mapWidth=0, mapHeight=0))
attach(specifications)

#Read map
mapComponents = c("latitude", "longitude", "northCurrent", "eastCurrent", "obstacle")
mapData <- loadMap(mapDataFile, mapWidth, mapHeight, mapComponents)

#Read map paths
pathFileList <- list.files(path = pathDirectory, pattern = "*.dat", full.names=TRUE)

pathList <- list()
for (pathFile in pathFileList) {
	unprocessedMapPath <- read.table(pathFile, header=TRUE)
	pathList[[length(pathList) + 1]] <- data.matrix(unprocessedMapPath)
	rm(unprocessedMapPath)
}

#Read source and goal node files
unprocessedSourceNodes <- read.table(sourceNodesFile, header=TRUE)
sourceNodes <- data.matrix(unprocessedSourceNodes)
rm(unprocessedSourceNodes)

unprocessedGoalNodes <- read.table(goalNodesFile, header=TRUE)
goalNodes <- data.matrix(unprocessedGoalNodes)
rm(unprocessedGoalNodes)

scaleLatitudeDistance = 1/mapWidth
scaleLongitudeDistance = 1/mapHeight

#set tile sizes here based on overall map size

#x and y represent the point at the lower left of the square.
drawArrow <- function(y, x)
{
	arrowX <- c(-0.5,0.5,0.3,0.3,0.5)
	arrowY <- c(0,0,0.07,-0.07,0)
	
	arrowX <- arrowX * scaleLatitudeDistance
	arrowY <- arrowY * scaleLongitudeDistance
	
	eastCurrent <- mapData[y,x,"eastCurrent"]
	northCurrent <- mapData[y,x,"northCurrent"]	
		
	#Scaling:
	scaleRatio <- sqrt(eastCurrent^2 + northCurrent^2) / maxCurrentSpeed
	arrowX <- arrowX * scaleRatio
	arrowY <- arrowY * scaleRatio	

	
	#Find angle of rotation (rotation):
	angleOfRotation <- 0
	if (eastCurrent != 0 || northCurrent != 0)
		angleOfRotation <- atan2(northCurrent, eastCurrent)

	rotationMatrix = matrix(c(cos(angleOfRotation), -sin(angleOfRotation), sin(angleOfRotation), cos(angleOfRotation)), c(2,2))
	
	for (i in 1:length(arrowX))
	{
		coords <- matrix(c(arrowX[i], arrowY[i]), c(1,2))
		coords <- coords %*% rotationMatrix
		arrowX[i] <- coords[1]
		arrowY[i] <- coords[2]
	}
	
	#Translation:
	arrowX <- arrowX + scaleLatitudeDistance * (x - 0.5)
	arrowY <- arrowY + scaleLongitudeDistance * (y - 0.5)

	#Draw:
	par(fg="blue")
	polypath(arrowX, arrowY)
}

drawObstacle <- function(y, x)
{
	xCoords <- c(0.5, 0.5, -0.5, -0.5)
	yCoords <- c(0.5, -0.5, -0.5, 0.5)
	
	#scale
	xCoords <- xCoords * scaleLatitudeDistance
	yCoords <- yCoords * scaleLongitudeDistance

	#Translate
	xCoords <- xCoords + scaleLatitudeDistance * (x - 0.5)
	yCoords <- yCoords + scaleLongitudeDistance * (y - 0.5)
	
	par(fg="black")
	polypath(xCoords, yCoords)
	
}

frame()
par(fg="black")
borderX <- c(1,1,0,0)
borderY <- c(1,0,0,1)
polypath(borderX, borderY)

title(main="AUV Path")
axis(side=1, at = seq(0.5 * scaleLatitudeDistance, 1 - 0.5 * scaleLatitudeDistance, by=scaleLatitudeDistance), labels=c(mapData[1,,"latitude"]))
axis(side=2, at = seq(0.5 * scaleLongitudeDistance, 1 - 0.5 * scaleLongitudeDistance, by=scaleLongitudeDistance), labels=c(mapData[,1,"longitude"]))
mtext("Latitude", side=1, line=2)
mtext("Longitude", side=2, line=2)

for(i in 1:length(mapData[,1,1]))
	for(j in 1:length(mapData[1,,1]))
	{
		if (mapData[i,j,"obstacle"])
			drawObstacle(i,j)
		else if (maxCurrentSpeed != 0)
			drawArrow(i,j)
	}
	
#Draw the paths:

if (length(pathList) > 0) {
	for (j in 1:length(pathList)){
		mapPath <- pathList[[j]]
		par(fg=colors()[myColors[[(j %% length(myColors)) + 1]]])

		for (i in 1:length(mapPath[,1]))
		{
			if (i == 1)
				next
			else
			{
				x <- c(mapPath[i - 1,1], mapPath[i,1])
				y <- c(mapPath[i - 1,2], mapPath[i,2])

				x <- (x /latitudeOffset - mapData[1,1,"latitude"] + 0.5) * scaleLatitudeDistance
				y <- (y /longitudeOffset - mapData[1,1,"longitude"] + 0.5) * scaleLongitudeDistance
				
				polypath(x,y)
			}
		}	
	}
}
#Draw goal and source nodes:
for (i in 1:length(sourceNodes[,1])) {
	sourceTile <- getStartTile(mapData, longitudeOffset, latitudeOffset, sourceNodes[[i, 1]], sourceNodes[[i, 2]])
	par(fg=colors()[81])
	text(scaleLatitudeDistance * (sourceTile@x - 0.5), scaleLongitudeDistance * (sourceTile@y - 0.5), labels="S",font=2)
}
for (i in 1:length(goalNodes[,1])) {
	goalTile <- getGoalTile(mapData, longitudeOffset, latitudeOffset, goalNodes[[i, 1]], goalNodes[[i, 2]])
	par(fg=colors()[81])
	text(scaleLatitudeDistance * (goalTile@x - 0.5), scaleLongitudeDistance * (goalTile@y - 0.5), labels="G",font=2)
}

detach(specifications)

par(fg="black")



#fig - NDC coords. Might be what is needed.
#fin is used for scaling, HOWEVER only effects scale of things drawn after call.
#din - device dimensions
#col - plotting color

#pin - current plot dimensions in inches.
#plt - the coords of the plot region as fractions of the current figure region.
#usr - giving the extremes of the user coordinates of the plotting region.
