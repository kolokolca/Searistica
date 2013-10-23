using System.Collections.Generic;
using System.Runtime.Serialization;

namespace ServiceContracts
{
    [DataContract]
    public class Response<T>
    {
        public Response()
        {
            Success = true;
        }
        [DataMember]
        public bool Success { get; set; }

        [DataMember]
        public T Data { get; set; }

        [DataMember]
        public string ErrorMessage { get; set; }
        
    }
}
