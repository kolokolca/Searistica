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
        public Response<ScoreBoardData> GetSoreBoardData()
        {
            return new ByteKnightLogic().GetSoreBoardData();
        }

        public Response<string> GetTeamName()
        {
            return new ByteKnightLogic().GetTeamName(StateHelper.TeamId);
        }

        public Response<Dimension> GetCurrentDataDimension()
        {
            return new ByteKnightLogic().GetCurrentDataDimension();
        }

        public Response<List<CellVector>> GetAllCellVector()
        {
            return new ByteKnightLogic().GetAllCellVector();
        }

        public Response<UnSolved> GetUnsolavedProblem()
        {
            return new ByteKnightLogic().GetUnsolavedProblem(StateHelper.TeamId);
        }

        public Response<string> SubmitProblem(string problemId, string key)
        {
            return new ByteKnightLogic().SubmitProblem(problemId, key, StateHelper.TeamId);
        }
    }
}
