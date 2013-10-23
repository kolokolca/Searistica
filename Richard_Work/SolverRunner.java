import java.lang.*;
import java.io.*;
import ucar.nc2.*;

//Requires the NetCDF Java Library
public class SolverRunner{



	private String solverDir;
	private String uMapDir;
	private String vMapDir;
	private NetcdfFile uMap;
	private NetcdfFile vMap;

	public SolverRunner(String solverDirectory, String uMapDirectory, String vMapDirectory) {
		solverDir = solverDirectory;
		uMapDir = uMapDirectory;
		vMapDir = vMapDirectory;

  		try {
    		uMap = NetcdfFile.open(uMapDir);
    		process( uMap);
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
    	}

  		try {
    		vMap = NetcdfFile.open(vMapDir);
    		process( vMap);
  		}
  		catch (IOException ioe) {
    		System.out.println("trying to open " + vMapDir + ioe);
  		}
  		finally {
    		if (null != vMap)
    		try {
      			vMap.close();
    		}
    		catch (IOException ioe) {
      		System.out.println("trying to close " + vMapDir + ioe);
    	}

    	//Need to pass information to solvers
  	}


}

	private void process(NetcdfFile map) {
		return;
  	}
}
