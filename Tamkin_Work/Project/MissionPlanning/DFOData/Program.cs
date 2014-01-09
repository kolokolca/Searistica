using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Business.DFOdata;


namespace DFOData
{
    class Program
    {
        static void Main(string[] args)
        {
            //var dfOdataProcessor = new DFOdataProcessor();
            //dfOdataProcessor.Strat();
            //dfOdataProcessor.DupmCellMeanVectors();

            var youShould = from c in "3%.$@9/52@2%35-%@4/@./3,!#+%23 !2#526%N#/-"
                            select (char)(c);

            foreach (var VARIABLE in youShould)
            {
                Console.Write(VARIABLE);    
            }
            
            Console.WriteLine();
            var youShould2 = from c in "3%.$@9/52@2%35-%@4/@./3,!#+%23 !2#526%N#/-"
                            select (char)(c ^ 3 << 5);

            foreach (var VARIABLE in youShould2)
            {
                Console.Write(VARIABLE);
            }

            var s = "SEND YOUR RESUME TO NOSLACKERS@ARCURVE.COM";
            var youShould3 = EncodeString(s);

            Console.WriteLine();
            foreach (var VARIABLE in youShould3)
            {
                Console.Write(VARIABLE);
            }

        }

        static IEnumerable<char> EncodeString(string input)
        {
            var output = from c in input
                             select (char)(c ^ 3 << 5);
            return output;

        }
    }
}
