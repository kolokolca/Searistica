import random
import timeit
import datetime
import time
import os
import math


class PBContraintInstanceGenerator:
    def __init__(self):
        self.variableCounter = 0;
        self.constraintCounter = 0;

    def getShortestPaths(self, numberOfNodes, givenShortestPaths):
        if(givenShortestPaths == None):
            print "No Shortest paths found"
            givenShortestPaths ={}
            aShortestPath = []
            
            for i in range(2, numberOfNodes + 1):
                aShortestPath.append(i)
            random.shuffle(aShortestPath)
            aShortestPath.insert(0,1)
            print "Adding a ShortestPath: "       
            print aShortestPath
            givenShortestPaths['path1'] = aShortestPath
            return givenShortestPaths
        else:
            return givenShotestPaths

    def get_random_cost_value(self,i,j):
        return random.randint(1,5)

    def printCostMatrix(self,TravelingTimeMatrix):
        print "Cost Matrix: "
        for i in range(len(TravelingTimeMatrix)):
            print TravelingTimeMatrix[i]
    
    def getAdamCostMatrix(self):
        TravelingTimeMatrix = []
        with open("AdamCostMatrix.dat") as infile:
            numberOfNodes = 0;
            for line in infile:            
                costs = line.split(',')
                intCosts = []
                for c in costs:
                    intCosts.append(int(c))
                if(len(costs) == 1):
                    numberOfNodes = int(costs[0])
                else:
                    intCosts.insert(0,0)
                    TravelingTimeMatrix.append(intCosts)
        firstRow = []
        for i in range(numberOfNodes + 1):
             firstRow.append(0)
        TravelingTimeMatrix.insert(0,firstRow)
        self.printCostMatrix(TravelingTimeMatrix)
        return (numberOfNodes, TravelingTimeMatrix)
    
    def getCostMatrix(self, numberOfNodes, givenShortestPaths):
        TravelingTimeMatrix = []
        for i in range(numberOfNodes + 1):
            row = []
            for j in range(numberOfNodes + 1):
                if(i == 0 or j==0):
                    row.append(0)
                else:
                    row.append(self.get_random_cost_value(i,j))
            TravelingTimeMatrix.append(row)
        #TravelingTimeMatrix = [ [ self.get_random_cost_value(i,j) for i in range(numberOfNodes) ]
                                                                   # for j in range(numberOfNodes) ]
        self.printCostMatrix(TravelingTimeMatrix)
        '''
        path = ""
        self.totalShortestCost = 0
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
                #cost = random.randint(1,5)
                cost = 1
                self.totalShortestCost += cost
                TravelingTimeMatrix[currentNode][nextNode] = cost
        #print "Given shortest cost: " + str(self.totalShortestCost)
        print "After modifying for shortest paths: " + path
        self.printCostMatrix(TravelingTimeMatrix)
        '''
        return TravelingTimeMatrix

    def closeFileobject(self, fo):
        fo.close()
        
    def getaFileobject(self):
        filename = "generatedForVideoTutorial.opb"
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
                if (i == j or i == 0 or j == 0): continue
                edgeKey = self.getEdgekey(i,j)
                self.variableCounter += 1 
                edgeVar = "x" + str(self.variableCounter)
                self.edge_variable_map[edgeKey] = edgeVar
                cost = str(TravelingTimeMatrix[i][j])
                string += "+" + cost.ljust(5) + edgeVar.ljust(5)
                print edgeKey + " : " + self.edge_variable_map[edgeKey]
            if(i != len(TravelingTimeMatrix) - 1):
                string += "\n\t"               
                
        return string
    
    def getIncoming_OutGoingEdgeConstraint(self, numberOfNodes):
        PBString = "\t"          
        #"Out going edge from i"
        for i in range(1, numberOfNodes + 1):
            for j in range(1, numberOfNodes + 1):                
                if(i != j):
                    edgekey = self.getEdgekey(i,j)
                    edgeVar = self.edge_variable_map[edgekey]
                    PBString += "+" + "1".ljust(5) + edgeVar.ljust(5)
            PBString += "= 1 ;\n\t"
            self.constraintCounter += 1;

        
        PBString += "\n\t"
        #"In coming edge at j"
        for j in range(1, numberOfNodes + 1):
            for i in range(1, numberOfNodes + 1):
                if(i != j):
                    edgekey = self.getEdgekey(i,j)
                    edgeVar = self.edge_variable_map[edgekey]
                    PBString += "+" + "1".ljust(5) + edgeVar.ljust(5)
            PBString += "= 1 ;\n\t"
            self.constraintCounter += 1;
        return PBString
    
    def getNbitsVar(self, n):
        var = []
        for i in range(0, n ):
            self.variableCounter += 1
            var.append("x%d" % self.variableCounter)
        return var
    def getUvariable(self, nBits, sign = "+"):
        u = ""
        for i in range(0, len(nBits)):
            d = int(math.pow( 2, i ))
            u += sign + str(d) + " " + nBits[i] + " "
        return u
    
    def getSoubtourEliminationConstraint(self, totalNodes):
        # video lecture :  i= (1..n-1), j = (2...n)
        # But seems results come with  j = (1...n)
        subTourConstraints = ""
        
        self.uVar_bits_maps = {}
        bitCount = len(bin(totalNodes)[2:]) + 1
        #bitCount = totalNodes
        for i in range(1, totalNodes + 1):
            varkey = "u" + str(i)
            uiBits = self.getNbitsVar(bitCount)
            self.uVar_bits_maps[varkey] = uiBits
            ui = self.getUvariable(uiBits)
            uiPositiveConstraint =  ui + " >= 0 ;"
            subTourConstraints +=  "\n\t" + uiPositiveConstraint
            self.constraintCounter += 1
        subTourConstraints += "\n"
        
        for i in range(1, totalNodes):
            ui = None           
            for j  in range(1, totalNodes + 1):
                if (i == j): continue
                if(ui == None):
                    uiVarkey = "u" + str(i)
                    uiBits = self.uVar_bits_maps[uiVarkey]
                    ui = self.getUvariable(uiBits)
                
                ujVarkey = "u" + str(j)
                ujBits = self.uVar_bits_maps[ujVarkey]
                negUj = self.getUvariable(ujBits,"-")
                
                slackVarBits = self.getNbitsVar(bitCount)
                slackVar = self.getUvariable(slackVarBits)
                
                edgekey = self.getEdgekey(i,j)
                varName = self.edge_variable_map[edgekey]                
                
                slackVarPositiveConstraint =  slackVar + " >= 0 ;"
                subTourConstraint =  ui + negUj + "+%d %s " % (totalNodes, varName) + slackVar + " = %d ;" % (totalNodes - 1) 
                
                finalConstraints = "\n\t" + slackVarPositiveConstraint
                self.constraintCounter += 1
                finalConstraints += "\n\t" + subTourConstraint + "\n"
                self.constraintCounter += 1
                
                #s = ui - uj + totalNodes * varName <= totalNodes -1
                subTourConstraints += finalConstraints
            subTourConstraints += "\n"
        return subTourConstraints
        
    def generate(self,givenShortestPaths = None):
        
        #givenShortestPaths = self.getShortestPaths(numberOfNodes,givenShortestPaths)
        #TravelingTimeMatrix = self.getCostMatrix(numberOfNodes,givenShortestPaths)
        (numberOfNodes, TravelingTimeMatrix) = self.getAdamCostMatrix()
        file = self.getaFileobject()        
        objectiveFunction = self.generateObjectiveFunction(TravelingTimeMatrix)
        in_out_edge_contraint = self.getIncoming_OutGoingEdgeConstraint(numberOfNodes)
        
        PBstring = "min:\n\t";
        PBstring += objectiveFunction + ";\n\t"
        
        PBstring += objectiveFunction + ">= 0 ;\n\n"
        self.constraintCounter += 1
        
        PBstring += in_out_edge_contraint
        
        subtourEliminationConstraints = self.getSoubtourEliminationConstraint(numberOfNodes)
        PBstring += subtourEliminationConstraints
        
        fileHeader = "* #variable= {0} #constraint= {1}\n".format(self.variableCounter, self.constraintCounter)
        PBstring = fileHeader + PBstring
        
        file.write(PBstring)
        self.closeFileobject(file)
        
        #for pathName in givenShortestPaths:
            #pathList = givenShortestPaths[pathName]
            #print "Given shortest path: " + str(pathList)
            #print "Given shortest cost: " + str(self.totalShortestCost)

if __name__ == '__main__':
    generator = PBContraintInstanceGenerator()
    generator.generate()