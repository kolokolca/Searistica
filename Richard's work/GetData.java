import java.io.*;
import javax.swing.*;
import java.awt.*;

//Requires the NetCDF Java Library, see http://www.unidata.ucar.edu/downloads/netcdf/netcdf-java-4/index.jsp
import ucar.nc2.*;
import ucar.ma2.*;

import java.util.*;


public class GetData{

	//Include the two files containing the U and V current vectors as command line arguements.
	public static void main(String args[]) {

		String uMapDir = args[0];
		String vMapDir = args[1];
		NetcdfFile uMap = null;
		NetcdfFile vMap = null;


		try {
    		uMap = NetcdfFile.open(uMapDir);
    		vMap = NetcdfFile.open(vMapDir);
    		double[] stats = process( uMap, vMap);
    		System.out.println("Max Current: " + stats[0]);
    		System.out.println("Min Lat: " + stats[1]);
    		System.out.println("Max Lat: " + stats[2]);
    		System.out.println("Min Lon: " + stats[3]);
    		System.out.println("Max Lon: " + stats[4]);
  		}
  		catch (IOException ioe) {
    		System.out.println("trying to open " + uMapDir + ioe);
  		}
  		finally {
    		if (null != uMap)
    		try {
      			uMap.close();
    		}
    		catch (IOException ioe) {
      		System.out.println("trying to close " + uMapDir + ioe);
      		}
      		if (null != vMap)
    		try {
      			vMap.close();
    		}
    		catch (IOException ioe) {
      		System.out.println("trying to close " + vMapDir + ioe);
      		}
    	}



	}




	private static double[] process(NetcdfFile uMap, NetcdfFile vMap) {

		double maxCurrentSpeed = 0;
		double minLat = 5000;
		double maxLat = -5000;
		double minLon = 5000;
		double maxLon = -5000;
		int cells = 50;
		int size = 250;
		double degDifference = size/6371.0*180.0;
		double originLon = -50;
		double originLat = 50;
		java.util.List<Variable> uData = uMap.getVariables();
		java.util.List<Variable> vData = vMap.getVariables();

		Variable lon = uData.get(0);
		Variable lat = uData.get(1);


		File file = null;
		PrintWriter pr = null;
		File prefFile = null;
		PrintWriter pr2 = null;

		Variable uCurrent = uData.get(uData.size()-2);
		Variable vCurrent = vData.get(vData.size()-2);

		try {

			file = new File("mapData2.txt");
			pr = new PrintWriter(new BufferedWriter(new java.io.FileWriter(file, true)));
 			pr.println("latitude longitude northCurrent eastCurrent obstacle");
			Array lonArrayTemp = lon.read();
			double[] lonArray = (double[])lonArrayTemp.get1DJavaArray(Double.TYPE);
			Array latArrayTemp = lat.read();
			double[] latArray = (double[])latArrayTemp.get1DJavaArray(Double.TYPE);
			Array uDataTemp = uCurrent.read("0, 0, :, :");
			double[] uCurrentData = (double[])uDataTemp.get1DJavaArray(Double.TYPE);
			Array vDataTemp = vCurrent.read("0, 0, :, :");
			double[] vCurrentData = (double[])vDataTemp.get1DJavaArray(Double.TYPE);
			boolean obstacle = false;
			double[][] cellsU = new double[cells][cells];
			double[][] cellsV = new double[cells][cells];

			for (int i = 0; i < 50; i++) {
				for (int j = 0; j<50; j++) {
					cellsU[i][j] = Double.MAX_VALUE;
					cellsV[i][j] = Double.MAX_VALUE;
				}
			}

			for (int i = 0; i < lonArray.length; i++) {
				// System.out.println("Lat: " + latArray[i] + ", OriginLat: " + originLat + ", OriginLat plus diff: " + (originLat + degDifference));
// 				System.out.println("Lon: " + lonArray[i] + ", OriginLon: " + originLon + ", OriginLon less diff: " + (originLon - degDifference));
				if (latArray[i] < (originLat+degDifference) && latArray[i] >= originLat&& lonArray[i] <= originLon && lonArray[i]> (originLon-degDifference )) {
					//System.out.println("Do I make it here?");
					obstacle = (vCurrentData[i] == 0 && vCurrentData[i] == 0);
					double currentSpeed = Math.abs(vCurrentData[i]*uCurrentData[i]);
					if (currentSpeed > maxCurrentSpeed) maxCurrentSpeed = currentSpeed;
					if (minLat> latArray[i]) minLat = latArray[i];
					if (maxLat < latArray[i]) maxLat = latArray[i];
					if (minLon > lonArray[i]) minLon = lonArray[i];
					if (maxLon < lonArray[i]) maxLon = lonArray[i];
					int cellLat = (int)Math.floor((latArray[i]-originLat)/degDifference*cells);
					int cellLon = (int)Math.floor((originLon-lonArray[i])/degDifference*cells);
					if (cellsU[cellLon][cellLat] == Double.MAX_VALUE) {
						cellsU[cellLon][cellLat] = uCurrentData[i];
					}
					else if (obstacle) cellsU[cellLon][cellLat] = Double.MIN_VALUE;
					else cellsU[cellLon][cellLat] = (cellsU[cellLon][cellLat] + uCurrentData[i])/2;
					if (cellsV[cellLon][cellLat] == Double.MAX_VALUE) {
						cellsV[cellLon][cellLat] = vCurrentData[i];
					}
					else if (obstacle) cellsV[cellLon][cellLat] = Double.MIN_VALUE;
					else cellsV[cellLon][cellLat] = (cellsV[cellLon][cellLat] + vCurrentData[i])/2;
					//pr.println(lonArray[i] + " " + latArray[i] + " " + vCurrentData[i] + " " + uCurrentData[i] + " " + (obstacle? 1 : 0));
				}
			}

		for (int i = 0; i < 50; i++) {
			for (int j = 0; j<50; j++) {
				int obs = ((cellsV[i][j] == Double.MIN_VALUE || cellsU[i][j] == Double.MIN_VALUE)? 1 : 0);
				pr.println(i + " " + j + " " + cellsV[i][j] + " " + cellsU[i][j] + " " + obs);

			}
		}

		prefFile = new File("preferences.txt");
		pr2 = new PrintWriter(new BufferedWriter(new java.io.FileWriter(prefFile, true)));
		double AUVspeed = 1;
		//pr2.println("maxCurrentSpeed AUVspeed latitudeOffset longitudeOffset latitudeDistance longitudeDistance mapWidth mapHeight");
		pr2.println(maxCurrentSpeed + " " + AUVspeed + " " + 1 + " " + 1 + " " + (size/cells) + " " + (size/cells) + " " + cells + " " + cells);


		}
		catch (Exception e) {
			System.out.println(e);
		}
		finally {
			if (pr != null) {
				pr.flush();
				pr.close();
			}
			if (pr2 != null) {
				pr2.flush();
				pr2.close();
			}
		}






		double[] toReturn = new double[5];
		toReturn[0] = maxCurrentSpeed;
		toReturn[1] = minLat;
		toReturn[2] = maxLat;
		toReturn[3] = minLon;
		toReturn[4] = maxLon;
		return toReturn;
	}
}
