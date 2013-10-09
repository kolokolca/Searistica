MissionWindow.java
Running this will launch the interface.
javac MissionWindow.java
java MissionWindow

MissionFrame.java
Manages the interface the user will use to select maps and solvers, as well as input mission details.
Runs from MissionFrame.java

SolverRunner.java
Will take from the interface the needed information, access the maps, and pass the pertinent information for the selected solver.
(Will) run with MissionFrame.java

GetData.java
A stop-gap for extracting data from NetCDF files. 
Dependent upon the NetCDF Java Library available at http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/ under an MIT-style open source license which can be found at http://www.unidata.ucar.edu/software/netcdf/copyright.html
Currently takes from the least depth available in the map, which can be modified in the code.
Requires as command line arguements the two portions of a NetCDF map representing the U and V axis of the current information.
Data is output in plain text in a file created in the working directory of the code.
javac GetData.java
java GetData UVectorMap.nc VVectorMap.nc