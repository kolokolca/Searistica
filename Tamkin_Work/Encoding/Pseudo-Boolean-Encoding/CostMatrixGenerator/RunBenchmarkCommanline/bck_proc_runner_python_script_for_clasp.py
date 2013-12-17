import random
import timeit
import datetime
import time
import os
import math

class RunBenchmarksAsBckProcess:
		def __init__(self):
			self.allBenchMarkFolder = "../../EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks";
		
		def getTerminalCommand(self, folderName, opbFileName):			
			return	"./clasp-2.1.4-x86-linux --stats=2 --configuration=handy ~/ResearchWorkSpace/EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks/{0}/{1}.opb > ~/ResearchWorkSpace/EncodingGenerator/PBEncoding/CostMatrixGenerator/BenchMarks/{0}/{1}_Clasp.res1 &".format(folderName, opbFileName )
			
		def start(self,folderNames):
			opbFiles = ['PBencd_OceanDataCost','PBencd_RandomCost','PBencd_EuclideanCost']
			
			print "-------"
			for folderName in folderNames:				
				benchMarkFolder = self.allBenchMarkFolder + "/" + folderName
				if(os.path.exists(benchMarkFolder)== False):
					print "%s doesn't exists.\n" % folderName
					continue
				fileCounter = 0;
				for opbFileName in opbFiles:
					opbFile = benchMarkFolder + "/" + opbFileName + ".opb"
					if(os.path.exists(opbFile) == False):
						print "%s/%s doesn't exists.\n" % (folderName,opbFile)
						continue
					fileCounter += 1;
					command = self.getTerminalCommand(folderName,opbFileName)
					#print command + "\n"
					os.system(command)
				print "{0} bckgrd process running for folder: {1}. \n".format(fileCounter , folderName)


if __name__ == '__main__':
	
	#command = "screen -D -r 26047.claspTest"
	#os.system(command)
	
	#command = "clear"
	#os.system(command)
	
	print "Changing dir to clasp solver"
	os.chdir("../../../../Solvers/clasp-2.1.4")
	print os.getcwd() + "\n"
		
	foldersName = []
	for i in range(37,38):
		foldersName.append("%d_Nodes" % i)
		
	runner = RunBenchmarksAsBckProcess()
	runner.start(foldersName)
