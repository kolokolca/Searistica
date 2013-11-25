import random
from OceanCurrentDataGrid import *
from heapq import *
import math
import time


class Position:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
class GridCell:
    def __init__(self, x, y, uvComponent, parent):
        self.x = x
        self.y = y
        if(uvComponent != None):
            self.u = uvComponent.u
            self.v = uvComponent.v
            self.isAnObstacle = False
        else:
            self.isAnObstacle = True
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



class PathPlanning:
    
    def __init__(self):
        self.robotPos = Position(9, 15)
        self.goalPos =  Position(41, 106)
        self.oceanCurrentDataGrid = OceanCurrentDataGrid()
        self.oceanCurrentDataGrid.loadDataFromFile()
    
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
    
    def computeEuclideanDistance(self, currentCell):
        xDistance =  self.goalPos.x - currentCell.x
        yDistance =  self.goalPos.y - currentCell.y         
        return math.sqrt( math.pow(xDistance, 2) + math.pow(yDistance, 2) )
        
    def computeH(self, gridCell):
        euclideanDistanceToGoal = self.computeEuclideanDistance(gridCell)
        #print 'ec: ' + str(euclideanDistanceToGoal)
        resultantOcceanCurrent = math.sqrt( math.pow(gridCell.u, 2) + math.pow(gridCell.v, 2) )
        #print 'rv: ' + str(resultantOcceanCurrent)
        #gridCell.hVal = euclideanDistanceToGoal / resultantOcceanCurrent
        gridCell.hVal = euclideanDistanceToGoal
    
    def oneCellMoveCost(self):
        return 1;
    
    def isAnObstacle(self, gridCell):
        gridCellData = self.oceanCurrentDataGrid.data[gridCell.x][gridCell.y]
        if(gridCellData == 100):
            return True
        return False
        
    def getMovingToACellCost(self, gridCell):
        if(gridCell.isAnObstacle):
            return 10000
        return 1
        
    def computeG(self, gridCell):
        if(gridCell.parentGridCell is None):
            gridCell.gVal = 0
        else:            
            gridCell.gVal = gridCell.parentGridCell.gVal + self.getMovingToACellCost(gridCell)
        
    def computeTotalCost(self, gridCell):
        self.computeG(gridCell)
        self.computeH(gridCell)
        return gridCell.getCost()
    
    def isGoalGridCell(self, currentCell):
        return currentCell.x == self.goalPos.x and currentCell.y == self.goalPos.y
        
    def isInRange(self, x, y):
        return (x >= 0 and y >= 0) and ( x < self.oceanCurrentDataGrid.dimension.width and y < self.oceanCurrentDataGrid.dimension.height)
    
    def getAdjacentCells(self, currentCell):
        
        adjacentCells = []
        x = currentCell.x
        y = currentCell.y        
        
        if(self.isInRange(x + 1, y)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x + 1, y)
            gridCell = GridCell(x + 1, y, uvComponent ,currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
                    
        if(self.isInRange(x + 1, y + 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x + 1, y + 1)
            gridCell = GridCell(x + 1, y + 1, uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x, y + 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x, y + 1)
            gridCell = GridCell(x, y + 1, uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x - 1, y + 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x - 1, y + 1)
            gridCell = GridCell(x - 1, y + 1,uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x - 1, y)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x - 1, y)
            gridCell = GridCell(x - 1, y, uvComponent ,currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x - 1, y - 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x - 1, y - 1)
            gridCell = GridCell(x - 1, y - 1, uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x, y - 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x, y - 1)
            gridCell = GridCell(x, y - 1, uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        if(self.isInRange(x + 1, y - 1)):
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(x + 1, y - 1)
            gridCell = GridCell(x + 1, y - 1, uvComponent, currentCell)
            if(gridCell.isAnObstacle == False):
                adjacentCells.append(gridCell)
        
        return adjacentCells
    
    def printAdjacentCells(self, adjs):
        s = "Adjs : "
        for i in range(len(adjs)):
            adj = adjs[i]
            s += "(" + str(adj.x) + "," + str(adj.y) + ") "  
        print s
        
    def getPath(self, gridCell):
        self.path.append(gridCell)
        if(gridCell.x == self.robotPos.x and gridCell.y == self.robotPos.y):
            return        
        self.getPath(gridCell.parentGridCell)
    
    def computePlan(self):
        obj = self.oceanCurrentDataGrid.getUVComponentOfDataCell(self.goalPos.x, self.goalPos.y)
        print obj.u
        print obj.v
        print "Goal is exists."
        
        if(self.robotPos != None and self.goalPos != None):            
            start = time.time()
            uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(self.robotPos.x, self.robotPos.y)
            startGridCell = GridCell(self.robotPos.x, self.robotPos.y, uvComponent, None)
            priorityQueue = PriorityQueue()
            closeList = {}
            openList = {}
            openList[startGridCell.getKey()] = startGridCell
            self.computeTotalCost(startGridCell)
            priorityQueue.push(startGridCell.getCost(),startGridCell)
            goal = None
            
            i = 0;
            while(len(openList) > 0):        
                (cost, currentCell) = priorityQueue.pop()                            
                print "low cell:(", currentCell.x , currentCell.y, ") cost:", cost
                if(currentCell.getKey() in openList):
                    del openList[currentCell.getKey()]
                
                if(self.isGoalGridCell(currentCell)):
                    goal = currentCell
                    print "found !!"
                    break
                else:                    
                    adjacentCells = self.getAdjacentCells(currentCell)
                    #self.printAdjacentCells(adjacentCells)
                    #print "\n"
                                        
                    for index in range(len(adjacentCells)):
                        adjacentCell = adjacentCells[index]
                        #print adjacentCell.u                       
                        allReadyVisited = adjacentCell.getKey() in closeList                        
                        if(allReadyVisited): continue
                        self.computeTotalCost(adjacentCell)
                        print "Adj:(" , adjacentCell.x , adjacentCell.y , ") " , "cost:", adjacentCell.getCost()
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
                                #if(oldAdjacentCell.isAnObstacle):
                                    #print "o: %d, %d" % (oldAdjacentCell.x, oldAdjacentCell.y)
                                    #print "ofp: %d, %d" % (oldAdjacentCell.parentGridCell.x, oldAdjacentCell.parentGridCell.y)
                                self.computeTotalCost(oldAdjacentCell)
                                #print "old Adj upadte:(" , oldAdjacentCell.x , oldAdjacentCell.y , ") " , "new cost:", oldAdjacentCell.getCost(), " new parent:" , oldAdjacentCell.parentGridCell.x , oldAdjacentCell.parentGridCell.y
                            #else:
                                #print "Old Adj not updated"
                        #print "\n"    
                        
                    closeList[currentCell.getKey()] = currentCell
                    #print "low cell:(", currentCell.x , currentCell.y, ") cost:", cost, " REMOVED"
                    print "-----------"        
                    i = i + 1
                    #if(i == 1000):
                        #break
            #print "Goal:", goal.x, goal.y
            
            end = time.time()
            elapsed = end - start
            s = "Time taken: " + str(elapsed) + " seconds.\n"
            s += "Total node expanded: " + str(len(closeList)) + " out of " + "(30 * 30) = 900. \n"
            self.path = []
            print len(openList)
            if(goal is not None):
                self.getPath(goal)
            else:
                s = "Goal not found !!!"
            for node in self.path:
                print "%d,%d" % (node.x, node.y) 

    def makePalnning(self):
        print 'Running ocean path planner'
        self.computePlan()                

    def computeHNew(self, childGridCell):
        #childGridCell.hVal = self.computeEquledianDistance(childGridCell)
        euclideanDistanceToGoal = self.computeEquledianDistance(childGridCell)
        resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
        #childGridCell.hVal = euclideanDistanceToGoal / resultantOcceanCurrent
        resultantOcceanCurrent = None
        if(childGridCell.parentGridCell == None):
            resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
        else:
            addedU = childGridCell.u + childGridCell.parentGridCell.u;
            addedV = childGridCell.v + childGridCell.parentGridCell.v * -1;             
            resultantOcceanCurrent = math.sqrt( math.pow(addedU, 2) + math.pow(addedV, 2) )
            
        childGridCell.hVal = childGridCell.gVal / resultantOcceanCurrent

if __name__ == '__main__':
    planner = PathPlanning();
    planner.makePalnning();
    
    
