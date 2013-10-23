
from z3 import *
import random
import timeit
import datetime
import time

def validateTour(selectedEdges, startNode, traversedNode, traversedEdgeCounter, totalNode):
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
                 return False
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
        validateTour(selectedEdges,node2, traversedNode, traversedEdgeCounter, totalNode)
    
    return True

def getSelectedEdgeFromModel(model, edge_var_maps):
    selectedEdges = []
    for key in  edge_var_maps:
        (varName, cost) = edge_var_maps[key]
        val = model.evaluate(varName)            
        if(int(val.as_string()) == 1):
            selectedEdges.append(varName)
    print "\nModel: "
    print selectedEdges
    print "\n"
    return selectedEdges

def fromSolverToSMT2Benchmark(f, status="unknown", name= "", logic=""):
  name = logic + "_Benchmark"
  v = (Ast * 0)()
  if isinstance(f, Solver):
    a = f.assertions()
    if len(a) == 0:
      f = BoolVal(True)
    else:
      f = And(*a)
  return Z3_benchmark_to_smtlib_string(f.ctx_ref(), name, logic, status, "", 0, v, f.as_ast())

def writeSMTLibEncodingToFile(smtLibEncoding):
    filename = "Smtlib_UF_Encoding.smt2"
    if os.path.exists(filename):
        os.remove(filename)
    fo = open(filename, "w")
    fo.write(smtLibEncoding);
    fo.close()

if __name__ == '__main__':
    solver = Solver()
    #Node starts from 1.....n
    totalNodes = 6
    # 4 nodes bound 40
    bound = 80
    
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
    
    var = "e3_4"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e4_5"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e5_6"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e6_7"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e7_8"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e8_9"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e9_10"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e10_11"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e11_12"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e12_13"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e13_14"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e14_15"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e15_16"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e16_17"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e17_18"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e18_19"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e19_20"
    (varName, cost)  = edge_var_maps[var]
    edge_var_maps[var] = (varName, 3)
    
    var = "e20_1"
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
    
    # video lecture :  i= (1..n-1), j = (2...n)
    # But seems results come with  j = (1...n)
    for i in range(1,totalNodes):
        ui = None
        for j  in range(1, totalNodes + 1):
            if(i != j):
                var = "e"+str(i)+"_" + str(j)
                (varName, cost) = edge_var_maps[var]
                if(ui == None):
                    ui = Int("u_%d" % i)
                uj = Int("u_%d" % j)
                #solver.add(And( 1 <= ui , ui <= totalNodes))
                #solver.add(And( 1 <= uj , uj <= totalNodes))
                c = ui - uj + totalNodes * varName <= totalNodes -1
                solver.add(c)
        solver.add(True)
    
    print solver
    smtLibEncoding = fromSolverToSMT2Benchmark(solver, logic = "QF_UFLIA")
    writeSMTLibEncodingToFile(smtLibEncoding)
    if solver.check() == sat:
        print "----------------------"
        print "SAT"        
        model = solver.model()
        selectedEdges = getSelectedEdgeFromModel(model, edge_var_maps)
        traversedNode = []
        edgeCounter = 0
        startNode = 1
        valid = validateTour(selectedEdges, startNode , traversedNode, edgeCounter, totalNodes )
        print traversedNode
        if(valid):
            totalCost = 0
            for i in range(len(traversedNode) - 1):
                node1 = traversedNode[i]
                node2 = traversedNode[i + 1]
                key = "e"+str(node1)+"_" + str(node2)
                (varName, cost) = edge_var_maps[key]
                totalCost += cost
            print "Total Node :" + str(totalNodes)
            print "Bound :" + str(bound)
            print "Cost: " + str(totalCost)
    else:
        print "\nUNSAT"
