using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class Dimension
    {
        [DataMember]
        public int MaxX { get; set; }

        [DataMember]
        public int MaxY { get; set; }

        [DataMember]
        public int MinX { get; set; }

        [DataMember]
        public int MinY { get; set; }

    }
}
