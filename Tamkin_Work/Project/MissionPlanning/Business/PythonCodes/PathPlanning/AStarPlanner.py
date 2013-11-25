#!/usr/bin/env python  

#import roslib
#roslib.load_manifest('project')
#import rospy
import random
#from project.msg import Position
#from project.msg import Move
#from visualization_msgs.msg import MarkerArray
#from visualization_msgs.msg import Marker
#from geometry_msgs.msg import Point
#from geometry_msgs.msg import PoseStamped
from OccupancyGrid import *
from heapq import *
import math
import time

class GridCell:
	def __init__(self, x, y, parent):
		self.x = x
		self.y = y
		self.parentGridCell = parent
		self.gVal = 0
		self.hVal = 0
		
	def getCost(self):
		return self.gVal + self.hVal
		
	def getKey(self):
		return str(self.x) + "_" + str(self.y)
		
	def setParent(self, parent):
		self.parentGridCell = parent

class PriorityQueue:
	
	def __init__(self):
		self.h = []
		
	def push(self, val, obj):
		heappush(self.h, (val, obj))
	
	def pop(self):
		return heappop(self.h)
		
class AStarPlanning:
	
	def __init__(self):
		self.robotPos = Position(0,0)
		self.goalPos = None
		self.occupancy_grid = OccupancyGrid()
		self.occupancy_grid.initializeData()
		self.subscribeEvents()
		self.setMarkerPublishers()
		self.markerUniqueId = 10
		self.pathMarkerIds = []
		self.openListMarkerIds = {}
	
	def getMarkerUniqueId(self):
		self.markerUniqueId +=1
		return self.markerUniqueId

	def setMarkerPublishers(self):
		self.markerPublisher = rospy.Publisher('/planning_markers', Marker)
		self.markerArray_publisher = rospy.Publisher('/planning_multiple_markers', MarkerArray, latch=True)
		
	def subscribeEvents(self):
		rospy.Subscriber('/goal_pos', PoseStamped, self.rvizGoalPosCallBack)
	
	def rvizGoalPosCallBack(self, clickedPose):
		comandType = rospy.get_param('comandType')
		pos_x = int(clickedPose.pose.position.x)
		pos_y = int(clickedPose.pose.position.y)		
		
		if(comandType == "o"):	
			clickedPosition = Position(pos_x, pos_y)
			self.occupancy_grid.setData(clickedPosition.x, clickedPosition.y, 100)
		elif(comandType == "g"):
			r = rospy.Rate(4)
			self.publisRobotPoseMarker()
			self.deletePathMarkers()
			r.sleep()
			self.updatePlanning = True
			self.goalPos = Position(pos_x, pos_y)
			
	def deletePathMarkers(self):		
		for i in range(len(self.pathMarkerIds)):
			pathMarkerId = self.pathMarkerIds[i]
			marker = Marker()
			marker.header.frame_id = '/map'		
			marker.ns = 'AStartPlanning'
			marker.id = pathMarkerId
			marker.action = Marker.DELETE
			self.markerPublisher.publish(marker)
	
        def publisText(self, s):
		
		marker = Marker()		
		shape = Marker.TEXT_VIEW_FACING
		marker.header.frame_id = '/map'
		marker.header.stamp = rospy.Time() #rospy.Time.now()
		marker.ns = 'AStartPlanning'
		marker.id = 5
		marker.type = shape
	   	marker.action = Marker.ADD
		marker.text = s
		
		marker.pose.position.x = 17.0
		marker.pose.position.y = -3.0
		marker.pose.position.z = 2.0
		
		marker.scale.z =  1.1

		marker.color.r = 0.8
		marker.color.g = 0.0
		marker.color.b = 0.0
		marker.color.a = 0.9

		self.markerPublisher.publish(marker)
	
	def publisDrawPathLine(self):
		self.path.reverse()
		r = rospy.Rate(5)
		for i in range(len(self.path) - 1):
						
			pathPoint1 = self.path[i]
			pathPoint2 = self.path[i+1]			
			self.robotPos = Position(int(pathPoint2.x), int(pathPoint2.y))
			marker = Marker()		
			shape = Marker.LINE_STRIP
			marker.header.frame_id = '/map'
			marker.header.stamp = rospy.Time() #rospy.Time.now()
			marker.ns = 'AStartPlanning'
			marker.id = self.getMarkerUniqueId()
			self.pathMarkerIds.append(marker.id)
			marker.type = shape
			marker.action = Marker.ADD
			marker.points = [pathPoint1, pathPoint2]
			
			marker.scale.x = 0.4
			marker.scale.y = 1.0
			marker.scale.z = 1.0

			marker.color.r = 0.0
			marker.color.g = 1.0
			marker.color.b = 1.0
			marker.color.a = 1.0

			self.publisRobotPoseMarker()
			self.markerPublisher.publish(marker)
			r.sleep()
		
	def robotPosChangedCallback(self, robotPos):
		self.robotPos = robotPos
		self.cmd_robotPos_sub.unregister()
		
	def goalPosChangedCallback(self, goalPos):
		self.goalPos = goalPos
	
	def computeEquledianDistance(self, currentCell):
		xDistance =  self.goalPos.x - currentCell.x
		yDistance =  self.goalPos.y - currentCell.y 		
		return math.sqrt( math.pow(xDistance, 2) + math.pow(yDistance, 2) )
		
	def computeH(self, childGridCell):
		childGridCell.hVal = self.computeEquledianDistance(childGridCell)
	
	def oneCellMoveCost(self):
		return 1;
	
	def isAnObstacle(self, gridCell):
		gridCellData = self.occupancy_grid.data[gridCell.x][gridCell.y]
		if(gridCellData == 100):
			return True
		return False
		
	def getCellCost(self, gridCell):
		if(self.isAnObstacle(gridCell)):
			return 100
		return 1
		
	def computeG(self, gridCell):
		if(gridCell.parentGridCell is None):
			gridCell.gVal = 0
		else:			
			gridCell.gVal = gridCell.parentGridCell.gVal + self.getCellCost(gridCell)
		
	def computeTotalCost(self, childGridCell):
		self.computeG(childGridCell)
		self.computeH(childGridCell)
		return childGridCell.getCost()
	
	def isGoalGridCell(self, currentCell):
		return currentCell.x == self.goalPos.x and currentCell.y == self.goalPos.y
		
	def isInRange(self, x, y):
		return (x >= 0 and y >= 0) and ( x < self.occupancy_grid.dimension.width and y < self.occupancy_grid.dimension.height)
	
	def getAdjacentCells(self, currentCell):
		
		adjacentCells = []
		x = currentCell.x
		y = currentCell.y		
		
		if(self.isInRange(x + 1, y)):
			gridCell = GridCell(x + 1, y,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
					
		if(self.isInRange(x + 1, y + 1)):
			gridCell = GridCell(x + 1, y + 1,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x, y + 1)):
			gridCell = GridCell(x, y + 1,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x - 1, y + 1)):
			gridCell = GridCell(x - 1, y + 1,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x - 1, y)):
			gridCell = GridCell(x - 1, y,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x - 1, y - 1)):
			gridCell = GridCell(x - 1, y - 1,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x, y - 1)):
			gridCell = GridCell(x, y - 1, currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		if(self.isInRange(x + 1, y - 1)):
			gridCell = GridCell(x + 1, y - 1,currentCell)
			if(self.isAnObstacle(gridCell) == False):
				adjacentCells.append(gridCell)
		
		return adjacentCells
	
	def printAdjacentCells(self, adjs):
		s = "Adjs : "
		for i in range(len(adjs)):
			adj = adjs[i]
			s += "(" + str(adj.x) + "," + str(adj.y) + ") "  
		print s
		
	def getPath(self, gridCell):
		self.path.append(Point(gridCell.x + 0.5 ,gridCell.y + 0.5, 1))
		if(gridCell.x == self.robotPos.x and gridCell.y == self.robotPos.y):
			return
		
		self.getPath(gridCell.parentGridCell)		 
	
	def publisMultipleMarkers(self, dictionary):
		l = dictionary.items()
		
		marker_array = MarkerArray()		
		r = rospy.Rate(25)
		life = 6
		for i in range(len(l)):
			
			(key, gridCell) = l[i]
			marker = Marker()
			marker.header.frame_id = '/map'
			marker.header.stamp = rospy.Time()
			marker.ns = 'AStartPlanning'
			markerId = str(gridCell.x) +"_" + str(gridCell.y)
			if(markerId in self.openListMarkerIds):
				marker.id = self.openListMarkerIds[markerId]
			else:
				marker.id = self.getMarkerUniqueId()
				self.openListMarkerIds[markerId] = marker.id
			
			marker.type = Marker.CUBE
			marker.action = Marker.ADD
			marker.lifetime = rospy.Duration(life, 0)
			
			marker.pose.position.x = gridCell.x + 0.5
			marker.pose.position.y = gridCell.y + 0.5
			
			marker.scale.x = 1.0
			marker.scale.y = 1.0
			marker.scale.z = 1.0

			
			marker.color.r = 0.0
			marker.color.g = 100.0
			marker.color.b = 0.0
			marker.color.a = 0.7

			marker_array.markers.append(marker)				

		self.markerArray_publisher.publish(marker_array)
		r.sleep()
	
	def computePlan(self):
		
		if(self.robotPos != None and self.goalPos != None):			
			start = time.time()						
			startGridCell = GridCell(self.robotPos.x, self.robotPos.y, None)
			priorityQueue = PriorityQueue()
			closeList = {}
			openList = {}
			openList[startGridCell.getKey()] = startGridCell
			self.computeTotalCost(startGridCell)
			priorityQueue.push(startGridCell.getCost(),startGridCell)
			goal = None
			
			while(len(openList) > 0):		
				(cost, currentCell) = priorityQueue.pop()							
				#print "low cell:(", currentCell.x , currentCell.y, ") cost:", cost
				if(currentCell.getKey() in openList):
					del openList[currentCell.getKey()]
				
				if(self.isGoalGridCell(currentCell)):
					goal = currentCell
					break
				else:					
					adjacentCells = self.getAdjacentCells(currentCell)
					#self.printAdjacentCells(adjacentCells)
					#print "\n"
										
					for index in range(len(adjacentCells)):
						adjacentCell = adjacentCells[index]						
						allReadyVisited = adjacentCell.getKey() in closeList						
						if(allReadyVisited): continue
						self.computeTotalCost(adjacentCell)
						#print "Adj:(" , adjacentCell.x , adjacentCell.y , ") " , "cost:", adjacentCell.getCost() 
						exploredBefore = adjacentCell.getKey() in openList
						if(exploredBefore == False):							
							openList[adjacentCell.getKey()] = adjacentCell							
							priorityQueue.push(adjacentCell.getCost(),adjacentCell)
							#print "Adj:(" , adjacentCell.x , adjacentCell.y , ") ", "not in open list, added to open list"
						else:
							oldAdjacentCell = openList[adjacentCell.getKey()]
							#print "found old Adj:(" , oldAdjacentCell.x , oldAdjacentCell.y , ") " , "cost:", oldAdjacentCell.getCost(), " parent:" , oldAdjacentCell.parentGridCell.x , oldAdjacentCell.parentGridCell.y
							if(adjacentCell.getCost() < oldAdjacentCell.getCost()):
								oldAdjacentCell.setParent(currentCell)
								self.computeTotalCost(oldAdjacentCell)
								#print "old Adj upadte:(" , oldAdjacentCell.x , oldAdjacentCell.y , ") " , "new cost:", oldAdjacentCell.getCost(), " new parent:" , oldAdjacentCell.parentGridCell.x , oldAdjacentCell.parentGridCell.y
							#else:
								#print "Old Adj not updated"
						#print "\n"	
						
					closeList[currentCell.getKey()] = currentCell
					self.publisMultipleMarkers(closeList)
					#print "low cell:(", currentCell.x , currentCell.y, ") cost:", cost, " REMOVED"
					#print "-----------"		
			
			#print "Goal:", goal.x, goal.y
			
			end = time.time()
			elapsed = end - start
			s = "Time taken: " + str(elapsed) + " seconds.\n"
			s += "Total node expanded: " + str(len(closeList)) + " out of " + "(30 * 30) = 900. \n"
			self.path = []
			if(goal is not None):
				self.getPath(goal)				
				self.publisDrawPathLine()
			else:
				s = "Goal not found !!!"
			
			self.publisText(s)
	
	def publisRobotPoseMarker(self):
		
		marker = Marker()		
		shape = Marker.SPHERE
		marker.header.frame_id = '/map'
		marker.header.stamp = rospy.Time()
		marker.ns = 'AStartPlanning'
		marker.id = 1
		marker.type = shape
	   	marker.action = Marker.ADD

		marker.pose.position.x = self.robotPos.x + 0.5
		marker.pose.position.y = self.robotPos.y + 0.5
		marker.pose.position.z = 1.0

		marker.scale.x = 0.75
		marker.scale.y = 0.75
		marker.scale.z = 1.0

		marker.color.r = 0.0
		marker.color.g = 1.0
		marker.color.b = 0.0
		marker.color.a = 0.75

		self.markerPublisher.publish(marker)

	def makePalnning(self):
		r = rospy.Rate(5)
		print 'Running A start planner'
		self.publisRobotPoseMarker()
		while not rospy.is_shutdown():
			if self.updatePlanning:
				self.computePlan()				
				self.updatePlanning = False			
			r.sleep()


if __name__ == '__main__':
	planner = AStarPlanning();
	planner.makePalnning();
	
	
