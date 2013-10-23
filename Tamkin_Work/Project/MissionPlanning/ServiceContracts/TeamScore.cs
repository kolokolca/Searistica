using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class TeamScore
    {
        [DataMember]
        public int Id { get; set; }

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public int? Score { get; set; }

        [DataMember]
        public int Position { get; set; }

        [DataMember]
        public List<SolvedProblem> SolvedProblems { get; set; }

        public TeamScore()
        {
            SolvedProblems = new List<SolvedProblem>();
        }
    }
}
