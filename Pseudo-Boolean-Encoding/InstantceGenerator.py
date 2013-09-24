import random
import timeit
import datetime
import time
import os

class PBContraintInstanceGenerator:
    def __init__(self):
        self.variableCounter = 0;
        self.constraintCounter = 0;

    def getShortestPaths(self,numberOfNodes, givenShortestPaths):
        if(givenShortestPaths == None):
            print "No Shortest paths found"
            givenShortestPaths ={}
            aShortestPath = []
            
            for i in range(1, numberOfNodes):
                aShortestPath.append(i)
            random.shuffle(aShortestPath)
            aShortestPath.insert(0,0)
            print "Adding a ShortestPath: "       
            print aShortestPath
            givenShortestPaths['path1'] = aShortestPath
            return givenShortestPaths
        else:
            return givenShotestPaths

    def get_random_cost_value(self,i,j):
        return random.randint(5,25)

    def printCostMatrix(self,TravelingTimeMatrix):
        print "Cost Matrix: "
        for i in range(len(TravelingTimeMatrix)):
            print TravelingTimeMatrix[i]
        
    def getCostMatrix(self, numberOfNodes, givenShortestPaths):
        TravelingTimeMatrix = [ [ self.get_random_cost_value(i,j) for i in range(numberOfNodes) ]
                                                                    for j in range(numberOfNodes) ]
        self.printCostMatrix(TravelingTimeMatrix)
        path = ""
        for pathName in givenShortestPaths:
            pathList = givenShortestPaths[pathName]
            pathLen = len(pathList)
            for nodeIndex in range(pathLen):
                if(nodeIndex == pathLen - 1):            
                    currentNode = pathList[nodeIndex]
                    nextNode = pathList[0]                
                else:
                    currentNode = pathList[nodeIndex]
                    nextNode = pathList[nodeIndex + 1]
                
                path +=  "(" + str(currentNode) + "," + str(nextNode) + ")"
                TravelingTimeMatrix[currentNode][nextNode] = 3
        print "After modifying for shortest paths: " + path
        self.printCostMatrix(TravelingTimeMatrix)
        return TravelingTimeMatrix

    def closeFileobject(self, fo):
        fo.close()
        
    def getaFileobject(self):
        filename = "PBEncoding.opb"
        if os.path.exists(filename):
            os.remove(filename)
        fo = open(filename, "a")
        return fo
    def printNodeVariableMap(self):
        print "Node variable map: "
        for nodekey in self.edge_variable_map:
            print nodekey + " : " + self.node_variable_map[nodekey]
    
    def getEdgekey(self, i, j):
        return "edge" + str(i) + "," + str(j)
    
    def generateObjectiveFunction(self, TravelingTimeMatrix):
        string = "";
        self.edge_variable_map = {}
        print "Edge - Variable map: "
        for i in range(len(TravelingTimeMatrix)):
            row = TravelingTimeMatrix[i]
            for j in range(len(row)):
                if (i == j): continue
                edgeKey = self.getEdgekey(i,j)
                self.variableCounter += 1 
                edgeVar = "x" + str(self.variableCounter)
                self.edge_variable_map[edgeKey] = edgeVar
                cost = str(TravelingTimeMatrix[i][j])
                string += " +" + cost.ljust(5) + edgeVar.ljust(5)
                print edgeKey + " : " + self.edge_variable_map[edgeKey]
            if(i != len(TravelingTimeMatrix) - 1):
                string += "\n\t"               
                
        return string
    
    def getIncoming_OutGoingEdgeConstraint(self, numberOfNodes):
        PBString = "\t"          
        #"Out going edge from i"
        for i in range(numberOfNodes):
            for j in range(numberOfNodes):                
                if(i != j):
                    edgekey = self.getEdgekey(i,j)
                    edgeVar = self.edge_variable_map[edgekey]
                    PBString += " +" + "1".ljust(5) + edgeVar.ljust(5)
            PBString += "= 1 ;\n\t"
            self.constraintCounter += 1;

        
        PBString += "\n\t"
        #"In coming edge at j"
        for j in range(numberOfNodes):
            for i in range(numberOfNodes):
                if(i != j):
                    edgekey = self.getEdgekey(i,j)
                    edgeVar = self.edge_variable_map[edgekey]
                    PBString += " +" + "1".ljust(5) + edgeVar.ljust(5)
            PBString += "= 1 ;\n\t"
            self.constraintCounter += 1;
        return PBString

    def generate(self,numberOfNodes, givenShortestPaths = None):
        givenShortestPaths = self.getShortestPaths(numberOfNodes,givenShortestPaths)
        TravelingTimeMatrix = self.getCostMatrix(numberOfNodes,givenShortestPaths)
        file = self.getaFileobject()        
        objectiveFunction = self.generateObjectiveFunction(TravelingTimeMatrix)
        in_out_edge_contraint = self.getIncoming_OutGoingEdgeConstraint(numberOfNodes)
        
        PBstring = "min:\n\t";
        PBstring += objectiveFunction + ";\n\n\t"
        PBstring += objectiveFunction + ">= 0 ;\n\n"
        self.constraintCounter += 1
        PBstring += in_out_edge_contraint
        fileHeader = "* #variable= {0} #constraint= {1}\n".format(self.variableCounter, self.constraintCounter)
        PBstring = fileHeader + PBstring
        file.write(PBstring)
        self.closeFileobject(file)


if __name__ == '__main__':
    generator = PBContraintInstanceGenerator()
    generator.generate(40)
    
'''
    
'''