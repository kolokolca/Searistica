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
            if(File.Exists(selectedPointsFile)) File.Delete(selectedPointsFile);

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

        public static Response<bool> GenerateRandomCostMatrix(string projectName, int numberOfNodes)
        {
            var response = new Response<bool>();
            var projectFolderPath = GetProjectFolder(projectName);
            if (Directory.Exists(projectFolderPath) == false)
            {
                response.Data = false;
                response.ErrorMessage = string.Format("Projecr '{0}' folder notfound !.", projectName);
                return response;
            }

            WriteRandomCostMatrix(projectFolderPath, numberOfNodes);
            response.Data = true;
            return response;

        }

        private static void WriteRandomCostMatrix(string projectFolderPath, int numberOfNodes)
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

        }

    }
}
