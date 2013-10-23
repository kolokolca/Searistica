using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ServiceContracts;

namespace Business
{
    public static class Mapper
    {
       

        public static Problem ToDataTransferObject(DataAccess.Problem p)
        {
            if (p == null) return null;
            return new Problem(){Name = p.Name, Id = p.Id};
        }

        public static List<Problem> ToDataTransferObjects(IEnumerable<DataAccess.Problem> problems)
        {
            if (problems == null) return null;
            return problems.Select(ToDataTransferObject).ToList();
        }
    }
}
