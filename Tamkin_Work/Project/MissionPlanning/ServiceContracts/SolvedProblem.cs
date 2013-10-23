using System;
using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class SolvedProblem
    {
        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string Time { get; set; }
    }
}
