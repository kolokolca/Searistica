
from z3 import *
import random
import timeit
import datetime
import time

def getNextNode(selectedEdges, startNode, traversedNode, traversedEdgeCounter, totalNode):
    node2 = None
    for index in range(len(selectedEdges)):
        var = selectedEdges[index]
        varName = str(var)[1:]
        nodes = varName.split('_');
        node1 = int(nodes[0])       
        if(node1 == startNode):
            traversedEdgeCounter += 1
            node2 = int(nodes[1])
            if( node1 not in traversedNode):
                traversedNode.append(node1)
            if( node2 in traversedNode and traversedEdgeCounter < totalNode):
                 traversedNode.append(node2)
                 print "\nINVALID TOUR at " + str(node1) + "->" + str(node2)
                 return
            else:
                traversedNode.append(node2)
            #print node1, node2         
            break
    if(traversedEdgeCounter == totalNode):
        print str(node1) + " " + str(node2) + ". Stop calling. Exit !"
        print "\nVALID TOUR:"
        return
    if(node2 != None):
        print str(node1) + " " + str(node2) + ". Calling for " + str(node2)  +", counter " + str(traversedEdgeCounter)
        getNextNode(selectedEdges,node2, traversedNode, traversedEdgeCounter, totalNode) 
    

if __name__ == '__main__':
    solver = Solver()
    totalNodes = 20
    startNodeIndex = 0
    endNodeIndex = 3
    # 4 nodes bound 40
    bound = 150
    
    edge_var_maps = {}
    for i in range(1, totalNodes + 1):
        for j in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                z3IntVar = Int(var)
                solver.add(Or(z3IntVar == 0, z3IntVar == 1))
                edge_var_maps[var] = (z3IntVar,random.randint(5,20))
                
    #Manually modified cost
    '''
    var = "e1_2"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e2_3"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e3_1"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e4_3"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    '''
    
    #-----------------------
    
    costFunctionElement = []
    for i in range(1, totalNodes + 1):
        s = ""
        for j in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                (varName, cost) = edge_var_maps[var]
                costFunctionElement.append(cost * varName)
                s += "  %s = %d;" % (varName , cost)
        print s + "\n"
    solver.add(Sum(costFunctionElement) <= bound)
    for j in range(1, totalNodes + 1):
        s = ""
        incomingEdgeSum = []
        for i in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                (varName, cost) = edge_var_maps[var]
                incomingEdgeSum.append(varName)
        solver.add(Sum(incomingEdgeSum) == 1)
    solver.add(True)
    for i in range(1, totalNodes + 1):
        s = ""
        outGoingEdgeSum = []
        for j in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                (varName, cost) = edge_var_maps[var]
                outGoingEdgeSum.append(varName)
        solver.add(Sum(outGoingEdgeSum) == 1)
    
    for i in range(1,totalNodes):
        for j  in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                (varName, cost) = edge_var_maps[var]
                ui = Int("u_%d" % i)
                uj = Int("u_%d" % j)
                solver.add(And(ui >=0, uj >= 0))
                c = ui - uj + totalNodes * varName <= totalNodes -1
                solver.add(c)
        solver.add(True)
        
    print solver
    
    if solver.check() == sat:
        print "----------------------"
        print "SAT"        
        m = solver.model()
        selectedEdges = []
        edgeCounter = 0
        for key in  edge_var_maps:
            (varName, cost) = edge_var_maps[key]
            val = m.evaluate(varName)            
            if(int(val.as_string()) == 1):
                selectedEdges.append(varName)
        print "\nModel: "
        print selectedEdges
        print "\n"
        traversedNode = []
        getNextNode(selectedEdges, 1 , traversedNode, edgeCounter, totalNodes )
        print traversedNode
    else:
        print "\nUNSAT"
