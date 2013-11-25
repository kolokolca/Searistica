using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.Text;
using Business;
using NewByteKnight.Common;
using ServiceContracts;

namespace NewByteKnight.Service
{
    [ServiceBehavior(       IncludeExceptionDetailInFaults = true, 
                            InstanceContextMode = InstanceContextMode.PerCall, 
                            ConcurrencyMode = ConcurrencyMode.Multiple)
    ]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    
    public class Service : IService
    {

        public Response<Dimension> GetCurrentDataDimension()
        {
            return new ByteKnightLogic().GetCurrentDataDimension();
        }

        public Response<List<CellVector>> GetAllCellVector()
        {
            return new ByteKnightLogic().GetAllCellVector();
        }

        public Response<string> GenerateEncoding(string encodingType, string projectName, string costMatrixFileName)
        {
            return new ByteKnightLogic().GenerateEncoding(encodingType, projectName, costMatrixFileName);
        }

        public Response<List<CellVector>> DecodeSolverResult(string encodingType, string projectName, string solverResultFileName)
        {
            return new ByteKnightLogic().DecodeSolverResult(encodingType, projectName, solverResultFileName);
        }

        public Response<bool> CreateNewProject(string projectName)
        {
            return new ByteKnightLogic().CreateNewProject(projectName);
        }

        public Response<bool> SaveSelectedPoints(List<CellVector> selectedPoints, string projectName)
        {
            return new ByteKnightLogic().SaveSelectedPoints(selectedPoints, projectName);
        }

        public Response<string> GenerateRandomCostGraph(string projectName, int numberOfNodes)
        {
            return new ByteKnightLogic().GenerateRandomCostGraph(projectName, numberOfNodes);
        }

        public Response<string> GenerateEuclideanDistanceCostGraph(string projectName, int numberOfNodes)
        {
            return new ByteKnightLogic().GenerateEuclideanDistanceCostGraph(projectName, numberOfNodes);
        }

        public Response<bool> SetStartEndForPathPlanning(List<CellVector> startEndPoints)
        {
            return new ByteKnightLogic().SetStartEndForPathPlanning(startEndPoints);
        }

        public Response<List<CellVector>> ShowPath()
        {
            return new ByteKnightLogic().ShowPath();
        }

        public Response<string> RunSolver(string projectName, string encodingType, string encodingFilename)
        {
            return new ByteKnightLogic().RunSolver(projectName, encodingType, encodingFilename);
        }
    }
}
