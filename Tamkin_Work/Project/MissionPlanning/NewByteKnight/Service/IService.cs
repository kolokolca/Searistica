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
        Response<ScoreBoardData> GetSoreBoardData();

        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<UnSolved> GetUnsolavedProblem();

        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> GetTeamName();

        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<string> SubmitProblem(string problemId, string key);

        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<Dimension> GetCurrentDataDimension();

        [WebGet(BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        Response<List<CellVector>> GetAllCellVector();
    }
}
