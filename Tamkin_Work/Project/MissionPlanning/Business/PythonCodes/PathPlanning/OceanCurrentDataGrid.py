#!/usr/bin/env python
import time
from decimal import Decimal

class Dimension():
    def __init__(self, width, height):
        self.width = width
        self.height = height

class UVComponent():
    def __init__(self, u, v):
        scallingFactor = 1000000
        self.u = int(u * scallingFactor)
        self.v = int(v * scallingFactor * -1)
        self.ou = u
        self.ov = v

class OceanCurrentDataGrid():
    
    def __init__(self):
        self.dimension = Dimension(70,106)
        self.oceanCurrentDataGrid = {}
        
    def getCellKey(self,x,y):
        return "%d_%d"  % (x,y) 
    
    def getUVComponentOfDataCell(self, x , y ):
        cellKey = self.getCellKey(x,y)
        if(cellKey in self.oceanCurrentDataGrid.keys()):
            return self.oceanCurrentDataGrid[cellKey]
        return None
    
    def loadDataFromFile(self):
        print "Loading Cell Vectors ..."
        cellMeanVectosFileDump = 'cellMeanVectorsDump.txt'
        with open(cellMeanVectosFileDump) as infile:
            for line in infile:            
                parts = line.split(',')
                x = int(parts[0])
                y = int(parts[1])
                u = Decimal(parts[2])
                v = Decimal(parts[3])
                cellKey = self.getCellKey(x,y)
                if(cellKey == '47_50'):
                    print "Fu", u
                    print "Fu", v
                self.oceanCurrentDataGrid[cellKey] = UVComponent(u,v)
        print "Done.."

if __name__ == '__main__':
    grid = OceanCurrentDataGrid();
    grid.loadDataFromFile();
    
    