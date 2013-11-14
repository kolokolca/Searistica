from optparse import OptionParser

class OutPutModelParser:
    def __init__(self):
        self.variableCounter = 0;
        self.constraintCounter = 0;

    def getEdge(self, i, j):
        return str(i) + "," + str(j)
    
    def generateEdgeVarMap(self, numberOfNode):
        self.variable_edge_map = {}
        #print "Variable - Edge map: "
        for i in range(numberOfNode + 1):
            for j in range(numberOfNode+ 1):
                if (i == j or i == 0 or j == 0): continue
                edge = self.getEdge(i,j)
                self.variableCounter += 1 
                edgeVar = "x" + str(self.variableCounter)
                self.variable_edge_map[edgeVar] = (i,j)
                #print edgeVar + " : " + self.variable_edge_map[edgeVar]
    
    def parseModels(self,numberOfNode, outputFilePath):
        o.generateEdgeVarMap(numberOfNode)
        models = None
        positiveModels = {}
        with open(outputFilePath) as infile:
            for line in infile:
                if(line[0] == 'v'):
                   modelString =  line.strip()
                   models = modelString.split(' ')
                   del models[0]              
                   break
        print "Parsed Models:"
        totalVars = len(self.variable_edge_map.keys())
        for index in range(1, totalVars + 1):
            model = models[index-1]
            if(model[0] == 'x'):
                edge = self.variable_edge_map[model]
                positiveModels[model] = edge
                (i , j) = edge
                print model + " : " + str(i) + "," + str(j)
        return positiveModels
    
    def readSourceNodes(self, selectedPointsFilePath):
        self.nodeName_xy_maps = {}
        totalNodes = 0
        with open(selectedPointsFilePath) as infile:
            for line in infile:
                line =  line.strip()
                xy = line.split(',')
                totalNodes = totalNodes + 1
                nodeNameKey = totalNodes
                self.nodeName_xy_maps[nodeNameKey] = (int(xy[0]),int(xy[1]))
        print self.nodeName_xy_maps        
        return totalNodes
    
    def generatePathForMathlab(self,positiveModels, outputFilePath):
        string  =""
        for selectedEdge in positiveModels.values():
            (node1, node2) = selectedEdge
            (x1,y1) = self.nodeName_xy_maps[node1]
            (x2,y2) = self.nodeName_xy_maps[node2]
            print "%d : (%d,%d)" % (node1, x1, y1)
            print "%d : (%d,%d)" % (node2, x2, y2)
            print "%d,%d,%d,%d\n\n" % (x1, y1, x2-x1, y2-y1)
            s = "%d,%d,%d,%d\n" % (x1, y1, x2-x1, y2-y1)
            string = string + s
        fileObject = open(outputFilePath, "wb")
        fileObject.write(string);
        fileObject.close()

    def generatePathForWebInterface(self,positiveModels, outputFilePath):
        string  =""
        for selectedEdge in positiveModels.values():
            (node1, node2) = selectedEdge
            (x1,y1) = self.nodeName_xy_maps[node1]
            (x2,y2) = self.nodeName_xy_maps[node2]
            print "%d : (%d,%d)" % (node1, x1, y1)
            print "%d : (%d,%d)" % (node2, x2, y2)
            print "%d,%d,%d,%d\n\n" % (x1, y1, x2, y2)
            s = "%d,%d,%d,%d\n" % (x1, y1, x2, y2)
            string = string + s
        fileObject = open(outputFilePath, "wb")
        fileObject.write(string);
        fileObject.close()
        
if __name__ == "__main__":
    
    parser = OptionParser()
    parser.add_option("--selectedPointsFilePath", dest="selectedPointsFilePath", help="Selected points file path", type="string")
    parser.add_option("--solverResultFilePath", dest="solverResultFilePath", help="Solver result file path", type="string")
    parser.add_option("--outputFilePath", dest="outputFilePath", help="output file path", type="string")
    
    (options, args) = parser.parse_args()
    
    o = OutPutModelParser()
    totalNodes = o.readSourceNodes(options.selectedPointsFilePath)
    positiveModels = o.parseModels(totalNodes, options.solverResultFilePath)
    o.generatePathForWebInterface(positiveModels, options.outputFilePath)
    
    #fileObject = open("tourForMatlab.txt", "wb")
    #fileObject.write(modeString);
    #fileObject.close()