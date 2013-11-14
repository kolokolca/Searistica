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
            return UtilityFunctions.CreaNewProject(projectName);
        }

        public Response<bool> SaveSelectedPoints(List<CellVector> selectedPoints, string projectName)
        {
            return UtilityFunctions.SaveSelectedPoints(selectedPoints, projectName);
        }

        public Response<bool> GenerateRandomCostGraph(string projectName, int numberOfNodes)
        {
            return UtilityFunctions.GenerateRandomCostMatrix(projectName, numberOfNodes);
        }

        public Response<string> GenerateEncoding(string encodingType, string projectName, string costMatrixFileName)
        {
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
    }
}
