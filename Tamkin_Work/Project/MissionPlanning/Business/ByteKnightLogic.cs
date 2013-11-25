using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using DataAccess;
using ServiceContracts;
using Problem = ServiceContracts.Problem;

namespace Business
{
    public class ByteKnightLogic
    {

        public Response<Dimension> GetCurrentDataDimension()
        {
            var response = new Response<Dimension>();
            try
            {
                using (var work = new UnitOfWork())
                {
                    var cellRepository = RepositoryContainer.GetRepository<Cell>(work);
                    const string sqlQuery = "select max(X) as MaxX, min(X) as MinX, max(Y) as MaxY, min(Y) as MinY from Cells";
                    var dimension = cellRepository.ExecuteCommand<Dimension>(sqlQuery);
                    response.Data = dimension.ElementAt(0);
                    return response;
                }

            }
            catch (Exception)
            {
                response.Success = false;
                response.ErrorMessage = "failed";
                return response;
            }
        }

        public Response<List<CellVector>> GetAllCellVector()
        {
            //Thread.Sleep(2000);
            var response = new Response<List<CellVector>>();
            try
            {
                using (var work = new UnitOfWork())
                {
                    var cellRepository = RepositoryContainer.GetRepository<Cell>(work);
                    const string sqlQuery = "select X,Y,U,V from Cells";
                    var cellVectors = cellRepository.ExecuteCommand<CellVector>(sqlQuery);
                    response.Data = cellVectors;
                    return response;
                }

            }
            catch (Exception)
            {
                response.Success = false;
                response.ErrorMessage = "failed";
                return response;
            }
        }

        public Response<List<CellVector>> RunSolverOrginal(string solverName, string projectName, int timeoutInMin)
        {
            var solverRunner = new SolverRunner();
            solverRunner.GeneratePsuedoBooleanEncodingFromRandomCostGraph("");
            solverRunner.RunSAT4J();

            return null;
        }

        public Response<string> RunSolver(string projectName, string encodingType, string encodingFilename)
        {
            var response = new Response<string>(){Success = true};
            try
            {
                var encodingFilePath = UtilityFunctions.GetProjectFolder(projectName) + "\\" + encodingFilename;
                var encodingFileName = Path.GetFileNameWithoutExtension(encodingFilePath);
                var resultFilepath = UtilityFunctions.GetProjectFolder(projectName) + "\\" + string.Format("{0}_SAT4j.txt", encodingFileName);
                var solverRunner = new SolverRunner();
                var resultFilename = solverRunner.RunSolverSAT4J(encodingFilePath, resultFilepath);
                response.Data = resultFilename;
            }
            catch(Exception ex)
            {
                response.Success = false;
                response.ErrorMessage = "Error while running the solver!";
                return response;
            }
            return response;
        }

        public Response<bool> CreateNewProject(string projectName)
        {
            Thread.Sleep(2500);
            return UtilityFunctions.CreaNewProject(projectName);
        }

        public Response<bool> SaveSelectedPoints(List<CellVector> selectedPoints, string projectName)
        {
            Thread.Sleep(2500);
            return UtilityFunctions.SaveSelectedPoints(selectedPoints, projectName);
        }

        public Response<string> GenerateRandomCostGraph(string projectName, int numberOfNodes)
        {
            Thread.Sleep(2500);
            return UtilityFunctions.GenerateRandomCostMatrix(projectName, numberOfNodes);
        }

        public Response<string> GenerateEuclideanDistanceCostGraph(string projectName, int numberOfNodes)
        {
            Thread.Sleep(2500);
            return UtilityFunctions.GenerateEuclideanDistanceCostGraph(projectName, numberOfNodes);
        }

        public Response<string> GenerateEncoding(string encodingType, string projectName, string costMatrixFileName)
        {
            Thread.Sleep(2500);
            var response = new Response<string> {Success = true};
            if(encodingType  == "PB")
            {
                try
                {
                    var resultFileName = new PsuedoBooleanEncoding().GenerateFromCostMatrixFile(projectName, costMatrixFileName);
                    response.Data = resultFileName;
                }
                catch (Exception ex)
                {
                    response.Success = false;
                    response.ErrorMessage = "Error occured while generating encoding !.";
                    return response;
                }
            }
            return response;
        }

        public Response<List<CellVector>> DecodeSolverResult(string encodingType, string projectName, string solverResultFileName)
        {
            Thread.Sleep(2500);
            var response = new Response<List<CellVector>> { Success = true };
            if (encodingType == "PB")
            {
                try
                {
                    var resultFileName = new PsuedoBooleanEncoding().Decoding(projectName, solverResultFileName);
                    response.Data = resultFileName;
                }
                catch (Exception ex)
                {
                    response.Success = false;
                    response.ErrorMessage = "Error occured while generating encoding !.";
                    return response;
                }
            }
            return response;
        }

        public Response<bool> SetStartEndForPathPlanning(List<CellVector> startEndPoints)
        {
            Thread.Sleep(2500);
            var response = new Response<bool> { Success = true };
            try
            {
                UtilityFunctions.SetStartEndForPathPlanning(startEndPoints);
            }
            catch(Exception ex)
            {
                response.Success = false;
                response.ErrorMessage = "Error Occured !!";
            }
            return response;
        }

        public Response<List<CellVector>> ShowPath()
        {
            var selectedPoints = new List<CellVector>();
            try
            {
                const string filePath = @"C:\Users\Tamkin\Documents\GitHub\Searistica\Tamkin_Work\Project\MissionPlanning\Business\PythonCodes\PathPlanning\path.txt";
               
                using (var reader = File.OpenText(filePath))
                {
                    string line;
                    while ((line = reader.ReadLine()) != null)
                    {
                        var xy = line.Split(',');
                        var x = int.Parse(xy[0]);
                        var y = int.Parse(xy[1]);
                        selectedPoints.Add(new CellVector() { X = x, Y = y });
                    }
                }
            }
            catch (Exception)
            {
                return new Response<List<CellVector>>() { Success = false}; 
                throw;
            }
            
            return  new Response<List<CellVector>>(){ Data = selectedPoints, Success = true}; 
        }
    }
}
