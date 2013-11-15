using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using ServiceContracts;

namespace NewByteKnight.Service
{
    [ServiceContract]
    public interface IService
    {
        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<Dimension> GetCurrentDataDimension();

        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<List<CellVector>> GetAllCellVector();

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> GenerateEncoding(string encodingType, string projectName, string costMatrixFileName);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<List<CellVector>> DecodeSolverResult(string encodingType, string projectName, string solverResultFileName);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<bool> CreateNewProject(string projectName);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<bool> SaveSelectedPoints(List<CellVector> selectedPoints, string projectName);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> GenerateRandomCostGraph(string projectName, int numberOfNodes);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> GenerateEuclideanDistanceCostGraph(string projectName, int numberOfNodes);

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> RunSolver(string projectName, string encodingType, string encodingFilename);
    }
}
