import sys
import math
from os import listdir
from os.path import isfile, join

def getTrialAnalysisDirectory(mapWidth, mapHeight, evaluationType):
	directory = "./Data/Map-" + str(mapWidth) + "x" + str(mapHeight) + "/TrialAnalysis/"
	
	if evaluationType == "memoization":
		directory += "Memoization/"
	elif evaluationType == "queueComparison":
		directory += "QueueComparison/"
	
	return directory
	
def getPathDirectory(mapWidth, mapHeight, evaluationType):
	directory = "./Data/Map-" + str(mapWidth) + "x" + str(mapHeight) + "/TrialPaths/"
	
	if evaluationType == "memoization":
		directory += "Memoization/"
	elif evaluationType == "queueComparison":
		directory += "QueueComparison/"
		
	return directory

def createDiscrepencyList(directory):
	fileList = listdir(directory)
	fileListContents = []
	
	#NEED TO MODIFY SO THAT MAPS SIZES ARE ACCOUNTED FOR
	
	try:
		fileNumber = 0
		discFiles = []
		
		while fileNumber < len(fileList):
			
			file = open(directory + fileList[fileNumber])
			
			for line in file:
				if "calendarqueuetime" in line.lower() or "priorityqueuetime" in line.lower():
					continue
				else:
					fileContents = []
					first = -1
					for value in line.rsplit():
						val = float(value)
						
						
						if first == -1:
							first = val
						elif first > val:
							discFiles.append(fileList[fileNumber].rsplit("/")[len(fileList[fileNumber].rsplit("/")) - 1])
			fileNumber += 1					
			
	
			
		return discFiles
		
	except IOError:
		print "There was an error reading file",fileList[fileNumber]
		sys.exit(1)
	except ValueError:
		print "There was a value error reading file", fileList[fileNumber]
		sys.exit(1)



if __name__ == "__main__":
	if len(sys.argv) != 3:
		print "usage: python", sys.argv[0], "width", "height"
		sys.exit(1)
		
	mapWidth = sys.argv[1]
	mapHeight = sys.argv[2]
	
	discList = createDiscrepencyList(getTrialAnalysisDirectory(mapWidth,mapHeight,"queueComparison"))
	
	file = open("DiscrepencyList-" + str(mapWidth) + "," + mapHeight + ".txt", "w")
	for number in discList:
		file.write(str(number) + "\n")
	file.close()