using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using ServiceContracts;

namespace Business
{
    public class UtilityFunctions
    {
        public static string GetMissionDataFolder()
        {
            return "E:\\MissionPlanningTempData";
        }

        public static string GetPythonCodesDir()
        {
            var basedir = AppDomain.CurrentDomain.BaseDirectory;
            var dir = basedir + "..\\Business\\PythonCodes";
            return dir;
        }

        public static string GetProjectFolder(string projectName)
        {
            return GetMissionDataFolder() + "\\" + projectName;
        }

        public static Response<bool> CreaNewProject(string projectName)
        {
            var response = new Response<bool>();
            var missionDataFolder = GetMissionDataFolder();
            var projectFolder = missionDataFolder + "\\" + projectName;
            if (Directory.Exists(projectFolder))
            {
                response.Data = false;
                response.ErrorMessage = "Project Name Exits !! Enter a new name.";
                return response;
            }
            Directory.CreateDirectory(projectFolder);
            response.Data = true;
            return response;

        }

        public static Response<bool> SaveSelectedPoints(List<CellVector> selectedPoints, string projectName)
        {
            var response = new Response<bool>();
            var missionDataFolder = GetMissionDataFolder();
            var projectFolder = missionDataFolder + "\\" + projectName;
            if (Directory.Exists(projectFolder) == false)
            {
                response.Data = false;
                response.ErrorMessage = string.Format("Project '{0}' folder not exits !.", projectName);
                return response;
            }
            var selectedPointsFile = projectFolder + "\\selectedPoints.txt";
            if (File.Exists(selectedPointsFile)) File.Delete(selectedPointsFile);

            var file = new StreamWriter(selectedPointsFile);
            foreach (var selectedPoint in selectedPoints)
            {
                var pointStr = string.Format("{0},{1}", selectedPoint.X, selectedPoint.Y);
                file.WriteLine(pointStr);
            }
            file.Close();
            response.Data = true;
            return response;
        }

        public static Response<string> GenerateRandomCostMatrix(string projectName, int numberOfNodes)
        {
            var response = new Response<string>();
            try
            {
                var projectFolderPath = GetProjectFolder(projectName);
                if (Directory.Exists(projectFolderPath) == false)
                {
                    response.Success = false;
                    response.ErrorMessage = string.Format("Projecr '{0}' folder notfound !.", projectName);
                    return response;
                }

                var costMatrixFilePath = WriteRandomCostMatrix(projectFolderPath, numberOfNodes);
                response.Data = Path.GetFileNameWithoutExtension(costMatrixFilePath);
                response.Success = true;
                return response;
            }
            catch(Exception ex)
            {
                response.Success = false;
                return response;
            }

        }

        private static string WriteRandomCostMatrix(string projectFolderPath, int numberOfNodes)
        {
            string costMatrixFilePath = projectFolderPath + "\\RandomCostMatrix.txt";
            if (File.Exists(costMatrixFilePath))
                File.Delete(costMatrixFilePath);

            var file = new StreamWriter(costMatrixFilePath);
            file.WriteLine(numberOfNodes);

            var random = new Random();
            for (int i = 1; i <= numberOfNodes; i++)
            {
                var line = "";
                for (int j = 1; j <= numberOfNodes; j++)
                {
                    if (i == j)
                    {
                        if (j == numberOfNodes) line += "0";
                        else
                            line += "0,";

                    }
                    else
                    {
                        if (j == numberOfNodes) line += random.Next(1, 25).ToString();
                        else
                            line += random.Next(1, 25).ToString() + ",";
                    }
                }
                file.WriteLine(line);
            }

            file.Close();

            return costMatrixFilePath;
        }

        public static Response<string> GenerateEuclideanDistanceCostGraph(string projectName, int numberOfNodes)
        {
            var response = new Response<string>(){Success = true};
            try
            {
                var selectedPointsFilePath = GetProjectFolder(projectName) + "\\selectedPoints.txt";
                var selectedPoints = new List<CellVector>();
                using (var reader = File.OpenText(selectedPointsFilePath))
                {
                    string line;
                    while ((line = reader.ReadLine()) != null)
                    {
                        var xy = line.Split(',');
                        var x = int.Parse(xy[0]);
                        var y = int.Parse(xy[1]);
                        selectedPoints.Add(new CellVector() {X = x, Y = y});
                    }
                }

                var costMatrixFilePath = GetProjectFolder(projectName) + "\\EuclideanDistanceCostmatrix.txt";
                var file = new StreamWriter(costMatrixFilePath);
                file.WriteLine(selectedPoints.Count);

                foreach (var selectedPointI in selectedPoints)
                {
                    var oneLine = "";
                    var j = 1;
                    foreach (var selectedPointJ in selectedPoints)
                    {
                        if (selectedPointI.X == selectedPointJ.X && selectedPointI.Y == selectedPointJ.Y)
                        {
                            if (j == selectedPoints.Count)
                                oneLine += "0";
                            else
                                oneLine += "0,";
                        }
                        else
                        {
                            var dis = Math.Pow(selectedPointI.X - selectedPointJ.X, 2) +
                                      Math.Pow(selectedPointI.Y - selectedPointJ.Y, 2);
                            int cost = Convert.ToInt32(Math.Sqrt(dis));

                            if (j == selectedPoints.Count) oneLine += cost;
                            else
                                oneLine += cost + ",";
                        }
                        j++;
                    }
                    file.WriteLine(oneLine);
                }

                file.Close();
                response.Data = Path.GetFileNameWithoutExtension(costMatrixFilePath);
            }
            catch(Exception ex)
            {
                response.Success = false;
                return response;
            }
            
            return response;
        }
        
    }
}
