import random
from NewPathPlanning import *
from Position import *
import math
import time
import os
import shutil


class BatchInstancesGenerator():
	
	def loadDataPointsFromFile(self):
		
		print "Loading Ocean Data x,y points..."
		cellMeanVectosFileDump = 'cellMeanVectorsDump.txt'
		with open(cellMeanVectosFileDump) as infile:
			for line in infile:			
				parts = line.split(',')
				x = int(parts[0])
				y = int(parts[1])
				self.OceanDataPoints.append(Position(x,y));	
		print "Done.."
	
	def selectRandomNumberOfDataPoints(self, totalNumOfPoint):
		
		totalPointsAvailable = len(self.OceanDataPoints);
		selectedDataPointIndex = []
		self.selectedDataPoints = []
		i = 0;
		while( i != totalNumOfPoint):			
			randIndex = random.randint(0, totalPointsAvailable - 1);
			if((randIndex in selectedDataPointIndex) == False):
				selectedDataPointIndex.append(randIndex)
				dataPoint = self.OceanDataPoints[randIndex]
				self.selectedDataPoints.append(dataPoint)
				i = i + 1
	
	def getRandomCost(self):		
		return random.randint(1, 100);
		
	def getEuclideanCost(self, robotPos, goalPos):
		xDistance =  robotPos.x - goalPos.x
		yDistance =  robotPos.y - goalPos.y		 
		distance = math.sqrt( math.pow(xDistance, 2) + math.pow(yDistance, 2) )
		return int(distance)
		
	def getCostUnderOceanData(self, robotPos, goalPos):
		self.pathPlanner.setGoalPostion(robotPos.x, robotPos.y);
		self.pathPlanner.setRobotPostion(goalPos.x, goalPos.y);
		self.pathPlanner.makePalnning();
		return self.pathPlanner.totalCost;
		
	def generateCosts(self, folderName):
		
		randomCostFile = open( folderName + "/RandomCost.txt",'wb');
		euclideanCostFile = open(folderName + "/EuclideanCost.txt",'wb');
		oceanDataCostFile = open(folderName + "/OceanDataCost.txt",'wb');
		
		totalSelectedDataPoints = len(self.selectedDataPoints)
		totalNodes = str(totalSelectedDataPoints) + "\n"
		randomCostFile.write(totalNodes);
		euclideanCostFile.write(totalNodes);
		oceanDataCostFile.write(totalNodes);		
		
		for i in range(totalSelectedDataPoints):
			
			randomCostFileLine = ""
			euclideanCostFileLine = ""
			oceanDataCostFileLine = ""
			
			for j in range(totalSelectedDataPoints):				
				if( i == j):
					randomCostFileLine += "0,"
					euclideanCostFileLine += "0,"
					oceanDataCostFileLine += "0,"		
				else:					
					randomCostFileLine += str(self.getRandomCost()) + ","
					robotPos = self.selectedDataPoints[i]
					goalPos = self.selectedDataPoints[j]
					euclideanCostFileLine += str(self.getEuclideanCost(robotPos,goalPos)) + ","	
					oceanDataCostFileLine += str(self.getCostUnderOceanData(robotPos,goalPos))+ ","
			
			randomCostFileLine = randomCostFileLine[:-1]
			euclideanCostFileLine = euclideanCostFileLine[:-1]
			oceanDataCostFileLine = oceanDataCostFileLine[:-1]
			
			randomCostFile.write(randomCostFileLine.strip() + "\n");
			euclideanCostFile.write(euclideanCostFileLine.strip() + "\n");
			oceanDataCostFile.write(oceanDataCostFileLine.strip() + "\n");
				
		randomCostFile.close()
		euclideanCostFile.close()
		oceanDataCostFile.close()
		
		
	def __init__(self):
		self.OceanDataPoints = []	
		self.loadDataPointsFromFile();
		
		self.pathPlanner = PathPlanning();
		
		for n in range(31,40):
			folderName = "../BenchMarks/%d_Nodes" %  n
			if(os.path.exists(folderName)):
				shutil.rmtree(folderName)
			os.makedirs(folderName);
			
			self.selectRandomNumberOfDataPoints(n);
			selectedDataPointFile = open( folderName + "/selectedPoint.txt",'wb');
			for dataPoint in self.selectedDataPoints:
				point = str(dataPoint.x) + ',' + str(dataPoint.y) + "\n"				
				selectedDataPointFile.write(point)
			selectedDataPointFile.close()
			
			print "Generating costs for %d nodes" % n
			self.generateCosts(folderName)
			
		
		
		
		'''
		posA = Position(14,12);
		posB = Position(32,83);
		
		self.pathPlanner.setRobotPostion(1, 59);
		self.pathPlanner.setGoalPostion(69,50);
		
		self.pathPlanner.makePalnning();
		'''
		

if __name__ == '__main__':
	generator = BatchInstancesGenerator();
