using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using ServiceContracts;

namespace Business
{
    public class PsuedoBooleanEncoding
    {

        public string GenerateFromCostMatrixFile(string projectName, string costMatrixFileName)
        {
            //new SolverRunner().GeneratePsuedoBooleanEncodingFromRandomCostGraph("");
            //return;

            var projectFolderPath = UtilityFunctions.GetProjectFolder(projectName);
            var costMatrixFilePath = projectFolderPath + string.Format("\\{0}.txt", costMatrixFileName);
            var outputFilename = string.Format("PBEncoding_From_{0}.opb", costMatrixFileName);
            var outputFilenamepath = projectFolderPath + "\\" + outputFilename;

            var pythonCodesDir = UtilityFunctions.GetPythonCodesDir();
            var scriptCommand = string.Format(" --costMatrixFilePath {0} --outputFilePath {1}", costMatrixFilePath, outputFilenamepath);

            var pythonPBEInstanceGeneratorScript = pythonCodesDir + string.Format("\\InstantceGenerator_From_CostMatrix.py {0}", scriptCommand);

            var command = string.Format("{0}", pythonPBEInstanceGeneratorScript);
            var processStartInfo = new ProcessStartInfo(@"C:\Python27\python.exe", command)
            {
                UseShellExecute = true,
                RedirectStandardOutput = false,
                RedirectStandardInput = false,
            };

            var cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            cmdExe.Start();
            cmdExe.WaitForExit();

            return outputFilename;
        }

        public List<CellVector> Decoding(string projectName, string solverResultFileName)
        {
            //new SolverRunner().GeneratePsuedoBooleanEncodingFromRandomCostGraph("");
            //return;

            var projectFolderPath = UtilityFunctions.GetProjectFolder(projectName);
            var solverResultFilePath = projectFolderPath + string.Format("\\{0}.txt", solverResultFileName);
            var selectedPointsFilePath = projectFolderPath + string.Format("\\selectedPoints.txt");

            var outputFilename = string.Format("{0}_Tour.txt", solverResultFileName);
            var outputFilenamepath = projectFolderPath + "\\" + outputFilename;

            var pythonCodesDir = UtilityFunctions.GetPythonCodesDir();
            var scriptCommand = string.Format(" --selectedPointsFilePath {0}  --solverResultFilePath {1} --outputFilePath {2}", selectedPointsFilePath, solverResultFilePath, outputFilenamepath);

            var pythonPBEInstanceGeneratorScript = pythonCodesDir + string.Format("\\modelOutputParser.py {0}", scriptCommand);

            var command = string.Format("{0}", pythonPBEInstanceGeneratorScript);
            var processStartInfo = new ProcessStartInfo(@"C:\Python27\python.exe", command)
            {
                UseShellExecute = true,
                RedirectStandardOutput = false,
                RedirectStandardInput = false,
            };

            var cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            cmdExe.Start();
            cmdExe.WaitForExit();


            return GetTour(outputFilenamepath);
        }

        private List<CellVector> GetTour(string outputFilenamepath)
        {
            var tour = new List<CellVector>();
            using (var reader = File.OpenText(outputFilenamepath))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    var xyuv = line.Split(',');
                    
                    var x = int.Parse(xyuv[0]);
                    var y = int.Parse(xyuv[1]);
                    var u = int.Parse(xyuv[2]);
                    var v = int.Parse(xyuv[3]);
                    tour.Add(new CellVector(){X = x, Y = y, U = u, V = v});

                }
            }
            return tour;
        }
    }
}
