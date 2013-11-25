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
            var dfOdataProcessor = new DFOdataProcessor();
            dfOdataProcessor.Strat();
            //dfOdataProcessor.DupmCellMeanVectors();

        }
    }
}
