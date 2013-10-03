import numpy as np
import matplotlib.pyplot as plt
from pylab import *
import math
from os import listdir
from os.path import isfile, join

	
def getTrialAnalysisDirectory(mapWidth, mapHeight, evaluationType):
	directory = "./Data/Map-" + str(mapWidth) + "x" + str(mapHeight) + "/TrialAnalysis/"
	
	if evaluationType == "memoization":
		directory += "Memoization/"
	elif evaluationType == "queueComparison":
		directory += "QueueComparison/"
	elif evaluationType == "allPairs":
		directory += "AllPairs/"
	
	return directory
	
def getPathDirectory(mapWidth, mapHeight, evaluationType):
	directory = "./Data/Map-" + str(mapWidth) + "x" + str(mapHeight) + "/TrialPaths/"
	
	if evaluationType == "memoization":
		directory += "Memoization/"
	elif evaluationType == "queueComparison":
		directory += "QueueComparison/"
	elif evaluationType == "allPairs":
		directory += "AllPairs/"
		
	return directory

def readFileList(evaluationType, directory, pathsDirectory):
	fileList = listdir(directory)
	fileListContents = []
	
	#NEED TO MODIFY SO THAT MAPS SIZES ARE ACCOUNTED FOR
	
	try:
		fileNumber = 0
		while fileNumber < len(fileList):
			fileContents = []
			
			file = open(directory + fileList[fileNumber])
			
			if evaluationType == "memoization" or evaluationType == "allPairs":
				for line in file:
					if line.lower().rstrip() == "time":
						continue
					else:
						fileContents.append(float(line))				
				fileListContents.append(fileContents)
			
			elif evaluationType == "queueComparison":
				for line in file:
					if "calendarqueuetime" in line.lower() or "priorityqueuetime" in line.lower():
						continue
					else:
						fileContents = []
						for value in line.rsplit():
							fileContents.append(float(value))
						fileListContents.append(fileContents)
			
			if evaluationType == "queueComparison":
				if len(fileList[fileNumber]) == 0:
					fileListContents.pop(len(fileListContents) - 1)
				else:
				
					pathFileDirectory = pathsDirectory + "trial-" + fileList[fileNumber].rsplit("-")[1].rsplit(".")[0] + "/"
					if  len(listdir(pathFileDirectory)) == 0:
						fileListContents.pop(len(fileListContents) - 1)
					else:
						pathFileName = pathFileDirectory + listdir(pathFileDirectory)[0]
						
						pathFile = open(pathFileName)
						
						pathLength = -1
						for line in pathFile:
							pathLength += 1
						
						pathFile.close()
						
						fileListContents[len(fileListContents) - 1].append(pathLength)

			fileNumber += 1
			
		return fileListContents
		
	except IOError:
		print "There was an error reading file",fileList[fileNumber]
		sys.exit(1)
	except ValueError:
		print "There was a value error reading file", fileList[fileNumber]
		sys.exit(1)
		
def createSingleMapSizeQueueComparisonGraph(timesList, mapWidth, mapHeight):	
	pathLengths = []	
	maxQueueTime = max([timesList[i][2] for i in range(len(timesList))])
	calendarQueueTimes = [[] for i in range(maxQueueTime + 1)]
	priorityQueueTimes = [[] for i in range(maxQueueTime + 1)]
	calendarQueueYValues = []
	priorityQueueYValues = []
	
	for timesetList in timesList:
		calendarQueueTimes[timesetList[2]].append(timesetList[0])
		priorityQueueTimes[timesetList[2]].append(timesetList[1])
		
	for i in range(len(calendarQueueTimes)):
		for j in range(len(calendarQueueTimes[i])):
			pathLengths.append(i)
			
			calendarQueueYValues.append(calendarQueueTimes[i][j])
			priorityQueueYValues.append(priorityQueueTimes[i][j])
		
	fig = figure(1, figsize=(7.5, 5.0), dpi=100)
	ax = fig.add_subplot(111)
	calendarQueuePoints = ax.plot(pathLengths, calendarQueueYValues, 'ro')[0]
	priorityQueuePoints = ax.plot(pathLengths, priorityQueueYValues, 'yo')[0]
		
	ylim = ([0, max(max(calendarQueueYValues), max(priorityQueueYValues)) + 5])
	xlim = ([0, max(pathLengths) + 5])
	
	a = gca()
	a.set_xlim(xlim)
	a.set_ylim(ylim)	
	
	calendarQueuePoints.set_linewidth(2.0)
	calendarQueuePoints.set_color("#C0FF00")
	calendarQueuePoints.set_markerfacecolor("purple")
	calendarQueuePoints.set_markeredgecolor("0.1")
	calendarQueuePoints.set_markersize(5)
	
	priorityQueuePoints.set_linewidth(2.0)
	priorityQueuePoints.set_color("#FFFFFF")
	priorityQueuePoints.set_markerfacecolor("yellow")
	priorityQueuePoints.set_markeredgecolor("0.1")
	priorityQueuePoints.set_markersize(5)
	
	
	ax.set_ylabel("Path Calculation Time (seconds)")
	ax.set_xlabel("Path Length in Terms of Nodes Visited")
	figtext(0.5,0.95, "Queue Comparison of Path Calculation Time with Respect to Path Length", fontsize=12, ha="center")
	figtext(0.5,0.925,"Map Dimensions: " + str(mapWidth) + "x" + str(mapHeight),fontsize=10, ha="center")
	ax.legend((calendarQueuePoints, priorityQueuePoints),("Calendar Queue", "Priority Queue"), loc=2)
	
	savefig("Graphs/QueueComparison-" + mapWidth + "x" + mapHeight + ".png")
	show()

	
"""
def createQueueComparisonGraph(timesList):
	pathLengths = []
	maxQueueTime = max([timesList[i][j][2] for i in range(len(timesList)) for j in range(len(timesList[i]))])
	calendarQueueTimes = [[] for i in range(maxQueueTime + 1)]
	priorityQueueTimes = [[] for i in range(maxQueueTime + 1)]
	calendarQueueYValues = []
	priorityQueueYValues = []
	
	for timesetList in timesList:
		for timeset in timesetList:
			calendarQueueTimes[timeset[2]].append(timeset[0])
			priorityQueueTimes[timeset[2]].append(timeset[1])
		
	for i in range(len(calendarQueueTimes)):
		for j in range(len(calendarQueueTimes[i])):
			pathLengths.append(i)
			
			# if (calendarQueueTimes[i][j] > 1600):
				# print(calendarQueueTimes[i][j])
				# print j
				# print readFileList("queueComparison", getTrialAnalysisDirectory(200,200,"queueComparison"), getPathDirectory(200,200,"queueComparison"))[j]
			
			
			calendarQueueYValues.append(calendarQueueTimes[i][j])
			priorityQueueYValues.append(priorityQueueTimes[i][j])
		
	figure(1, figsize=(7.5, 5.0), dpi=100)
	calendarQueuePoints = plot(pathLengths, calendarQueueYValues, 'ro')[0]
	priorityQueuePoints = plot(pathLengths, priorityQueueYValues, 'yo')[0]
		
	ylim = (0, max(max(calendarQueueYValues), max(priorityQueueYValues)) + 5)
	xlim = (0, max(pathLengths) + 5)
	
	calendarQueuePoints.set_linewidth(2.0)
	calendarQueuePoints.set_color("#C0FF00")
	calendarQueuePoints.set_markerfacecolor("purple")
	calendarQueuePoints.set_markeredgecolor("0.1")
	calendarQueuePoints.set_markersize(5)
	
	priorityQueuePoints.set_linewidth(2.0)
	priorityQueuePoints.set_color("#FFFFFF")
	priorityQueuePoints.set_markerfacecolor("red")
	priorityQueuePoints.set_markeredgecolor("0.1")
	priorityQueuePoints.set_markersize(5)
	
		
	savefig("lol.png")
	show()

"""	


def createMemoizationBarGraph(timesList, mapWidth, mapHeight):
	numberOfTimes = 11
	averageTimes = [0 for i in range(numberOfTimes)]
	
	goalTimeList = [[] for i in range(numberOfTimes)]
	for testCase in timesList:
		for i in range(len(testCase)):
			goalTimeList[i].append(testCase[i])
	
	
	
	
	N = numberOfTimes - 1
	mean = (sum(goalTimeList[0])/len(goalTimeList[0]),
	sum(goalTimeList[1])/len(goalTimeList[1]),
	sum(goalTimeList[2])/len(goalTimeList[2]),
	sum(goalTimeList[3])/len(goalTimeList[3]),
	sum(goalTimeList[4])/len(goalTimeList[4]),
	sum(goalTimeList[5])/len(goalTimeList[5]),
	sum(goalTimeList[6])/len(goalTimeList[6]),
	sum(goalTimeList[7])/len(goalTimeList[7]),
	sum(goalTimeList[8])/len(goalTimeList[8]),
	sum(goalTimeList[9])/len(goalTimeList[9]))
	
	#std = (np.std(goalTimeList[0]), np.std(goalTimeList[1]), np.std(goalTimeList[2]), np.std(goalTimeList[3]), np.std(goalTimeList[4]), np.std(goalTimeList[5]), np.std(goalTimeList[6]), np.std(goalTimeList[7]), np.std(goalTimeList[8]), np.std(averageTimes[9]))
	
	ind = np.arange(N)
	width = 1.0
	
	fig = plt.figure()
	ax = fig.add_subplot(111, xticks=(1,2,3,4,5,6,7,8,9,10))
	rects = ax.bar(ind + 1, mean, width, color='r', align="center")
	
	
	ax.set_ylabel("Mean Path Calculation Time (seconds)")
	ax.set_xlabel("Paths in Order of Calculation")
	figtext(0.5,0.95, "Effect of Memoization on Reducing Cost of calculating Multiple Paths", fontsize=12, ha="center")
	figtext(0.5,0.925,"Map Dimensions: " + str(mapWidth) + "x" + str(mapHeight),fontsize=10, ha="center")
	
	#ax.set_title("Effect of Memoization on Reducing Cost of calculating Multiple Paths")
	
	
	
	savefig("Graphs/Memoization-" + mapWidth + "x" + mapHeight + ".png")
	plt.show()
	
def createCumulativeMemoizationBarGraph(timesList, mapWidth, mapHeight):
	numberOfTimes = 11
	averageTimes = [0 for i in range(numberOfTimes)]
	
	goalTimeList = [[] for i in range(numberOfTimes)]
	for testCase in timesList:
		for i in range(len(testCase)):
			goalTimeList[i].append(testCase[i])
	
	
	bar1 = sum(goalTimeList[0])/len(goalTimeList[0])
	bar2 = bar1 + sum(goalTimeList[1])/len(goalTimeList[1])
	bar3 = bar2 + sum(goalTimeList[2])/len(goalTimeList[2])
	bar4 = bar3 + sum(goalTimeList[3])/len(goalTimeList[3])
	bar5 = bar4 + sum(goalTimeList[4])/len(goalTimeList[4])
	bar6 = bar5 + sum(goalTimeList[5])/len(goalTimeList[5])
	bar7 = bar6 + sum(goalTimeList[6])/len(goalTimeList[6])
	bar8 = bar7 + sum(goalTimeList[7])/len(goalTimeList[7])
	bar9 = bar8 + sum(goalTimeList[8])/len(goalTimeList[8])
	bar10 = bar9 + sum(goalTimeList[9])/len(goalTimeList[9])
	
	
	
	
	N = numberOfTimes - 1
	mean = (bar1, bar2, bar3, bar4, bar5, bar6, bar7, bar8, bar9, bar10)
	
	#std = (np.std(goalTimeList[0]), np.std(goalTimeList[1]), np.std(goalTimeList[2]), np.std(goalTimeList[3]), np.std(goalTimeList[4]), np.std(goalTimeList[5]), np.std(goalTimeList[6]), np.std(goalTimeList[7]), np.std(goalTimeList[8]), np.std(averageTimes[9]))
	
	ind = np.arange(N)
	width = 1.0
	
	fig = plt.figure()
	ax = fig.add_subplot(111, xticks=(1,2,3,4,5,6,7,8,9,10))
	plt.ylim(0, max(mean) * 1.07)
	rects = ax.bar(ind + 1, mean, width, color='r', align="center")
		
	ax.set_ylabel("Cumulative Mean Path Calculation Time (seconds)")
	ax.set_xlabel("Paths in Order of Calculation")
	figtext(0.5,0.95, "Effect of Memoization on Reducing Cost of calculating Multiple Paths", fontsize=12, ha="center")
	figtext(0.5,0.925,"Map Dimensions: " + str(mapWidth) + "x" + str(mapHeight),fontsize=10, ha="center")
	
	#ax.set_title("Effect of Memoization on Reducing Cost of calculating Multiple Paths")
	
	def autolabel(rects):
		for rect in rects:
			height = rect.get_height()
			ax.text(rect.get_x()+rect.get_width()/2.,1.02 * height, "%d"%int(height), ha="center", va="bottom")

	autolabel(rects)
	
	savefig("Graphs/Memoization-Cumulative-" + mapWidth + "x" + mapHeight + ".png")
	plt.show()
	
def createAllPairsBarGraph(timesList, sizes):
	numberOfTimes = 12
	averageTimes = [0 for i in range(len(timesList))]
	
	for mapSize in range(len(timesList)):
		for testCase in timesList[mapSize]:
			for i in range(len(testCase) - 1):
				averageTimes[mapSize] += testCase[i]
				

	N = len(timesList)
	mean = tuple([averageTimes[mapSize]/len(timesList[mapSize]) for mapSize in range(len(timesList))])
	
	ind = np.arange(N)
	width = 1.0
	
	fig = plt.figure()
	ax = fig.add_subplot(111)
	ax.set_xticklabels(tuple([str(size) + "x" + str(size) for size in sizes]))
	ax.set_xticks(ind)
	rects = ax.bar(ind, mean, width, color='r', align="center")
	
	def autolabel(rects):
		for rect in rects:
			height = rect.get_height()
			ax.text(rect.get_x()+rect.get_width()/2.,1.05 * height, "%d"%int(height), ha="center", va="bottom")
			
	autolabel(rects)
	
	
	
	ax.set_ylabel("Mean Path Calculation Time of All Paths (seconds)")
	ax.set_xlabel("Map Size")
	figtext(0.5,0.95, "Calculating 10 Paths using All Pairs at Various Map Sizes", fontsize=12, ha="center")
	
	#ax.set_title("Effect of Memoization on Reducing Cost of calculating Multiple Paths")
	
	
	
	savefig("Graphs/AllPairs-" + mapWidth + "x" + mapHeight + ".png")
	plt.show()
			
	
if __name__ == "__main__":
	
	if len(sys.argv) != 4:
		print "usage: python", sys.argv[0], "width", "height", "memoization OR queueComparison"
		sys.exit(1)
	
	mapWidth = sys.argv[1]
	mapHeight = sys.argv[2]

	if sys.argv[3].lower() == "memoization" or sys.argv[3].lower() == "m":
		evaluationType = "memoization"
	elif sys.argv[3].lower() == "queuecomparison" or sys.argv[3].lower() == "qc":
		evaluationType = "queueComparison"
	elif sys.argv[3].lower() == "allpairs" or sys.argv[3].lower() == "ap":
		evaluationType = "allPairs"
	elif sys.argv[3].lower() == "memoizationCumulative" or sys.argv[3].lower() == "mc":
		evaluationType = "memoizationCumulative"
	

#	print(readFileList(evaluationType, getTrialAnalysisDirectory(mapWidth,mapHeight,evaluationType), getPathDirectory(mapWidth,mapHeight,evaluationType)))
	
#	print(readFileList(evaluationType, getTrialAnalysisDirectory(mapWidth,mapHeight,evaluationType), getPathDirectory(mapWidth,mapHeight,evaluationType)))
	
	
	if evaluationType == "memoization":
		timesList = []
		timesList = readFileList(evaluationType, getTrialAnalysisDirectory(mapWidth,mapHeight,evaluationType), getPathDirectory(mapWidth,mapHeight,evaluationType))
		createMemoizationBarGraph(timesList, mapWidth, mapHeight)
	
	if evaluationType == "queueComparison":
		timesList = []
		timesList = readFileList(evaluationType, getTrialAnalysisDirectory(mapWidth,mapHeight,evaluationType), getPathDirectory(mapWidth, mapHeight, evaluationType))
		createSingleMapSizeQueueComparisonGraph(timesList, mapWidth, mapHeight)
	
	if evaluationType == "allPairs":
		timesList = []
		
		mapSizeList = [50,100,200,300]
		
		for size in mapSizeList:
			timesList.append(readFileList(evaluationType, getTrialAnalysisDirectory(size,size,evaluationType), getPathDirectory(size, size, evaluationType)))
		
		createAllPairsBarGraph(timesList, mapSizeList)
		
	if evaluationType == "memoizationCumulative":
		evaluationType = "memoization"
		
		timesList = []
		timesList = readFileList(evaluationType, getTrialAnalysisDirectory(mapWidth,mapHeight,evaluationType), getPathDirectory(mapWidth,mapHeight,evaluationType))
		createCumulativeMemoizationBarGraph(timesList, mapWidth, mapHeight)
		