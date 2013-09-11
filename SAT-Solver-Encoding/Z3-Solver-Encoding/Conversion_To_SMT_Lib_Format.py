from z3 import *
import random
import timeit
import datetime
import time
import os

def fromFormulaToSMT2Benchmark(f, status="unknown", name= "", logic=""):
  v = (Ast * 0)()
  return Z3_benchmark_to_smtlib_string(f.ctx_ref(), name, logic, status, "", 0, v, f.as_ast())

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
    filename = "SmtlibEncodings.smt2"
    if os.path.exists(filename):
        os.remove(filename)
    fo = open(filename, "w")
    fo.write(smtLibEncoding);
    fo.close()

def get_random_cost_value(i,j):
    return random.randint(1,20)

def create_cost_matrix(totalNodes):
    TravelingTimeMatrix = [ [ get_random_cost_value(i,j) for i in range(totalNodes) ]
                                                            for j in range(totalNodes) ]
    print "\nWe have these traveling cost matrix:"
    rows = []
    for i in range(totalNodes + 1 ):
        row =[i]
        for j in range(totalNodes + 1):
            if(j == 0):
                continue
            elif(i >=1 and j >= 1):
                row.append(TravelingTimeMatrix[i-1][j-1])
            else:
                row.append(j)
                
        rows.append(row)
    print_matrix(rows)
    return TravelingTimeMatrix
    #print_matrix(TravelingTimeMatrix)
    
    
    
def get_node_index_value_constraint(i, nodes, totalNodes):
    #f = And(nodes[i] >= 0, nodes[i] < totalNodes)
    #print toSMT2Benchmark(f)
    return And(nodes[i] >= 0, nodes[i] < totalNodes)
        
def node_index_value_constraint(nodes):
    totalNodes = len(nodes)
    nodes_index_constraint  = [ get_node_index_value_constraint(i,nodes, totalNodes) for i in range(totalNodes)]
    return nodes_index_constraint
        
def start_end_node_index_constraint(nodes, startNodeIndex, endNodeIndex ):
    totalNodes = len(nodes)
    start_end_constraint = And( nodes[0] == startNodeIndex, nodes[totalNodes - 1] == endNodeIndex)
    return start_end_constraint

def distinct_node_index_value_constraint(nodes):
    nodes_index_distinct_constraint  = Distinct(nodes)
    #print toSMT2Benchmark(nodes_index_distinct_constraint)
    return nodes_index_distinct_constraint



if __name__ == '__main__':
    
    s = Solver()
    totalNodes = 20
    startNodeIndex = 0
    endNodeIndex = 3
    bound = 200
    
    costMatrix = create_cost_matrix(totalNodes)
    nodes = [ Int("n_%s" % (i)) for i in range(totalNodes) ]
    nodes_index_constraint = node_index_value_constraint(nodes)
    
    s.add(nodes_index_constraint)
    
    start_end_constraint = start_end_node_index_constraint(nodes, startNodeIndex, endNodeIndex)
    s.add(start_end_constraint)

    nodes_index_distinct_constraint = distinct_node_index_value_constraint(nodes)
    s.add(nodes_index_distinct_constraint)
    
    cost = Function('cost', IntSort(), IntSort(),IntSort())
    costs  = []
    for i in range(totalNodes):
        for j in range(totalNodes):
            costs.append(cost(i,j) == costMatrix[i][j])
    costs_constraint = And(costs)
    s.add(costs_constraint)
    
    totalDistance  = []
    for i in range(totalNodes - 1):
      totalDistance.append(cost(nodes[i], nodes[i+1]))
    bound_constraint = Sum(totalDistance) <= bound
    s.add(bound_constraint)    
    print s
    
    # Remember to remove this option, before using other type of theory
    # for array theory (set-logic QF_AUFLIA)
    # (set-logic QF_UFLIA) is used, uninterpreted functions and linear integer arithmetic is available    
    smtLibEncoding = fromSolverToSMT2Benchmark(s, logic = "QF_UFLIA")
    
    configOptions = "(set-option :produce-models true)\n"
    smtLibEncoding = configOptions + smtLibEncoding
    otherOptions = "(get-model)\n"
    #otherOptions += "(get-info :all-statistics)"
    smtLibEncoding += otherOptions
    print smtLibEncoding
    writeSMTLibEncodingToFile(smtLibEncoding)
    #print smtLibEncoding
    start_time = time.time()
    if s.check() == sat:
        end_time = time.time()
        print "sat"
        m = s.model()
        nodeIndex = [ m.evaluate(nodes[i]) for i in range(totalNodes) ]
        print nodeIndex
        totalCost = 0
        for i in range(len(nodeIndex)-1):
            node1Index = int(nodeIndex[i].as_string())
            node2Index = int(nodeIndex[i+1].as_string())
            cost = costMatrix[node1Index][node2Index]
            print "%d -- %d : %d" % (node1Index , node2Index, cost) 
            totalCost += cost
        print "Total cost: %d" % totalCost
        print "Bound: %d" % bound
        print "Execution time %s" % str(datetime.timedelta(seconds = end_time - start_time))
    else:
        print "unsat"
    










