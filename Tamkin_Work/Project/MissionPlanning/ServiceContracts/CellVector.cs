using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class CellVector
    {
        [DataMember]
        public int X { get; set; }

        [DataMember]
        public int Y { get; set; }

        [DataMember]
        public double U { get; set; }

        [DataMember]
        public double V { get; set; }

    }
}
