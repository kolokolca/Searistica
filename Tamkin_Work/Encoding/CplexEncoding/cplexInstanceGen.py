import time
import os
import math
import random

class CplexBenchmarkGen:
	def __init__(self):
		self.varMap = 0

	def objectiveFunc(self, nodes):
		s = "Minimize\n"
		for i in nodes:
			for j in nodes:
				if(i == j):
					continue
				varName = "x{0}_{1}".format(i,j)
				cost = random.randint(1, 20);
				s += "+ {0} {1} ".format(cost,varName)
			s +="\n"
		return s
	
	def inOutDegreeConstraints(self, nodes):
		s = ""
		for i in nodes:
			sumStr = ""
			for j in nodes:
				if(i == j):
					continue
				varName = "x{0}_{1}".format(i,j)
				sumStr += "+ {0} ".format(varName)
			s += sumStr + " = 1\n"
		
		s += "\n"
		for j in nodes:
			sumStr = ""
			for i in nodes:
				if(i == j):
					continue
				varName = "x{0}_{1}".format(i,j)
				sumStr += "+ {0} ".format(varName)
			s += sumStr + " = 1\n"	
		
		return s
		
	def subTours(self, nodes):
		s ="\n"
		totalNodes = len(nodes)
		for i in range(2, totalNodes + 1):
			for j in range(2, totalNodes + 1):
				if(i == j ): 
					continue
				varName = "x{0}_{1}".format(i,j)
				p = totalNodes -1
				c = "u{0} - u{1} + {2} {3} <= {4}\n".format(i,j,p,varName,p - 1)
				s += c
			s += "\n"
		return s
	
	def getBounds(self, nodes):
		s ="Bounds\n"
		totalNodes = len(nodes)
		for i in range(2, totalNodes + 1):
			c = "2 <= u{0} <= {1}\n".format(i, totalNodes)
			s += c
		s += "\n"
		return s
	
	def getBinaries(self, nodes):
		s ="Binary\n"
		totalNodes = len(nodes)
		for i in nodes:
			for j in nodes:
				if(i == j):
					continue
				varName = "x{0}_{1}\n".format(i,j)
				s += varName
		return s	
		
	def start(self,totalNodes):
		nodes = []
		for n in range(1, totalNodes + 1):
			nodes.append(n);
		string = "";	
		string += self.objectiveFunc(nodes) + "\n"
		string += "Subject To\n"
		string += self.inOutDegreeConstraints(nodes)
		string += self.subTours(nodes)
		string += self.getBounds(nodes)
		string += self.getBinaries(nodes)
		string += "End"
		return string

if __name__ == '__main__':
	
	fileObj = open("out.lp","w+")
	gen = CplexBenchmarkGen()
	s = gen.start(25)
	fileObj.write(s)
	fileObj.close()
