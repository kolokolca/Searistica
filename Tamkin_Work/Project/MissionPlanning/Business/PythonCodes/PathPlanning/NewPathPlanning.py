import random
from OceanCurrentDataGrid import *
from heapq import *
import math
import time
import random
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
            self.ou = uvComponent.u
            self.ov = uvComponent.v
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
        
class AStarPlanning:
    
    def readStartEndPosition(self):
        with open('C:\Users\Tamkin\Documents\GitHub\Searistica\Tamkin_Work\Project\MissionPlanning\Business\PythonCodes\PathPlanning\StartEndPoint.txt') as infile:
            i = 0
            for line in infile:
                if(i == 0):
                    robotPosXY = line
                    xy = robotPosXY.split(',')
                    rx = int(xy[0])
                    ry = int(xy[1])
                    self.robotPos = Position(rx,ry)
                if(i == 1):
                    goalPosXY = line
                    xy = goalPosXY.split(',')
                    gx = int(xy[0])
                    gy = int(xy[1])
                    self.goalPos = Position(gx,gy)
                i = i + 1
                    
        print "Robot pos:" , self.robotPos.x , ',', self.robotPos.y
        print "Goal pos:" , self.goalPos.x , ',', self.goalPos.y
        
    def __init__(self):
        self.readStartEndPosition()
        self.oceanCurrentDataGrid = OceanCurrentDataGrid()
        self.oceanCurrentDataGrid.loadDataFromFile()
        
    def robotPosChangedCallback(self, robotPos):
        self.robotPos = robotPos
        self.cmd_robotPos_sub.unregister()
        
    def goalPosChangedCallback(self, goalPos):
        self.goalPos = goalPos
    
    def computeEquledianDistance(self, currentCell):
        xDistance =  self.goalPos.x - currentCell.x
        yDistance =  self.goalPos.y - currentCell.y         
        return math.sqrt( math.pow(xDistance, 2) + math.pow(yDistance, 2) )
    
    def computeHOld(self, childGridCell):
        #childGridCell.hVal = self.computeEquledianDistance(childGridCell)
        euclideanDistanceToGoal = self.computeEquledianDistance(childGridCell)
        resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
        #childGridCell.hVal = euclideanDistanceToGoal / resultantOcceanCurrent
        factor = 10000
        resultantOcceanCurrent = None
        if(childGridCell.parentGridCell == None):
            resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
            childGridCell.addedU = childGridCell.u
            childGridCell.addedV = childGridCell.v
            childGridCell.hVal = (childGridCell.gVal / resultantOcceanCurrent) * factor
        else:
            neWaddedU = childGridCell.u + childGridCell.parentGridCell.addedU;
            neWaddedV = childGridCell.v + childGridCell.parentGridCell.addedV;
            childGridCell.addedU = neWaddedU
            childGridCell.addedV = neWaddedV            
            resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.addedU, 2) + math.pow(childGridCell.addedV, 2) )
            childGridCell.hVal = (childGridCell.gVal / resultantOcceanCurrent) * factor
            
    def computeAngle(self, childGridCell):
        #consider cell center as 0,0
        if(self.goalPos.x == childGridCell.x and self.goalPos.y == childGridCell.y):
            return None
        #print 'golx' , self.goalPos.x
        #print 'goly' , self.goalPos.y
        gx = self.goalPos.x - childGridCell.x
        gy = (self.goalPos.y - childGridCell.y) * -1
        #print childGridCell.x
        #print childGridCell.y
        #print childGridCell.ou
        #print childGridCell.ov

        resultantVectorX = childGridCell.addedU
        resultantVectorY = childGridCell.addedV * -1
        #print 'g', gx ,',', gy
        #print 'rv', resultantVectorX ,',', resultantVectorY
        #print 'resultantVectorX 2', math.pow(resultantVectorX, 2)
        #print 'resultantVectorY 2', math.pow(resultantVectorY, 2)
        aProductb = (gx * resultantVectorX) + (gy * resultantVectorY)
        magnOfa = math.sqrt( math.pow(gx, 2) + math.pow(gy, 2) )
        magnOfb = math.sqrt( math.pow(resultantVectorX, 2) + math.pow(resultantVectorY, 2) )
        cosTheta = aProductb / (magnOfa * magnOfb)
        #print "abp", aProductb
        #print "magnOfa", magnOfa
        #print "magnOfb", magnOfb
        theta = math.degrees(math.acos(cosTheta))
        if(theta < 0):
            theta = theta * -1;
        #print 'theta' , theta
        return theta
       
        
    def computeH(self, childGridCell):
        #childGridCell.hVal = self.computeEquledianDistance(childGridCell)
        euclideanDistanceToGoal = self.computeEquledianDistance(childGridCell)
        resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
        #childGridCell.hVal = euclideanDistanceToGoal / resultantOcceanCurrent
        factor = 10000
        resultantOcceanCurrent = None
        if(childGridCell.parentGridCell == None):
            resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.u, 2) + math.pow(childGridCell.v, 2) )
            childGridCell.addedU = childGridCell.u
            childGridCell.addedV = childGridCell.v
            childGridCell.hVal = (childGridCell.gVal / resultantOcceanCurrent) * factor
            theta = self.computeAngle(childGridCell)
            if(theta != None):
                childGridCell.hVal = childGridCell.hVal + theta
        else:
            neWaddedU = (childGridCell.u + childGridCell.parentGridCell.u) / 2;
            neWaddedV = (childGridCell.v + childGridCell.parentGridCell.v) / 2;
            childGridCell.addedU = neWaddedU
            childGridCell.addedV = neWaddedV            
            resultantOcceanCurrent = math.sqrt( math.pow(childGridCell.addedU, 2) + math.pow(childGridCell.addedV, 2) )
            childGridCell.hVal = (childGridCell.gVal / resultantOcceanCurrent) * factor
            theta = self.computeAngle(childGridCell)
            if(theta != None):
                childGridCell.hVal = childGridCell.hVal + theta
            
        
        
        
    def oneCellMoveCost(self):
        return 1;
    
    def isAnObstacle(self, gridCell):
        uvComponent = self.oceanCurrentDataGrid.getUVComponentOfDataCell(gridCell.x,gridCell.y)
        if(uvComponent == None):
            return True
        return False
        
    def getCellCost(self, gridCell):
        if(self.isAnObstacle(gridCell)):
            return 10000
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
        
    def getPath(self, gridCell):
        self.path.append(gridCell)
        if(gridCell.x == self.robotPos.x and gridCell.y == self.robotPos.y):
            return
       
        self.getPath(gridCell.parentGridCell)
    
    def printAjacentCell(self,adjacentCell):
        print "Adj:(" , adjacentCell.x , adjacentCell.y , adjacentCell.u , adjacentCell.v, ") " , "cost:", adjacentCell.gVal, "+",  adjacentCell.hVal
    def computePlan(self):
        
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
            
            i =0;
            while(len(openList) > 0):
                i = i + 1
                (cost, currentCell) = priorityQueue.pop()                            
                #print "low cell:(", currentCell.x , currentCell.y, currentCell.u , currentCell.v, ") cost:", cost
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
                        
                        #self.printAjacentCell(adjacentCell)
                        
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
                    #print "low cell:(", currentCell.x , currentCell.y, ") cost:", cost, " REMOVED"
                    #print "-----------"        
                    #if(i == 1):
                        #break
            #print "Goal:", goal.x, goal.y
            #print 'ieration: ', i
            end = time.time()
            elapsed = end - start
            s = "Time taken: " + str(elapsed) + " seconds.\n"
            #s += "Total node expanded: " + str(len(closeList)) + " out of " + "(30 * 30) = 900. \n"
            self.path = []
            if(goal is not None):
                self.getPath(goal)
                self.writePathToFile()
            else:
                s = "Goal not found !!!"
            print s            
            
    
    def writePathToFile(self):
        string =""
        for node in self.path:
            s = "%d,%d\n" % (node.x, node.y)
            c = "%d,%d,%d\n" % (node.x, node.y, node.hVal)
            print c
            string = string + s            
        fileObject = open('C:\Users\Tamkin\Documents\GitHub\Searistica\Tamkin_Work\Project\MissionPlanning\Business\PythonCodes\PathPlanning\path.txt', "wb")
        fileObject.write(string);
        fileObject.close()

    
    def makePalnning(self):
        print 'Running shortest path planning ....'
        self.computePlan()                
                


if __name__ == '__main__':
    planner = AStarPlanning();
    planner.makePalnning();
    #uvComponent = planner.oceanCurrentDataGrid.getUVComponentOfDataCell(31, 31)
    #cell = GridCell(31, 31, uvComponent, None)
    #planner.computeAngle(cell)

    
