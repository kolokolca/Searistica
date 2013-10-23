using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class ScoreBoardData
    {
        [DataMember]
        public List<TeamScore> TeamsOrderByScore { get; set; }

        public ScoreBoardData()
        {
            TeamsOrderByScore = new List<TeamScore>();
        }
    }
}
