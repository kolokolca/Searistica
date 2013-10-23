using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class UnSolved
    {
        [DataMember]
        public List<Problem> Problems { get; set; }

        [DataMember]
        public int Count { get; set; }

        public UnSolved()
        {
            Problems = new List<Problem>();
        }
    }
}
