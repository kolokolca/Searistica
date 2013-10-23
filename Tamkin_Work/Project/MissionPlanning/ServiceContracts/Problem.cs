using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class Problem
    {
        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public int Id { get; set; }

        [DataMember]
        public int? Point { get; set; }
    }
}
