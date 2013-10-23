using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using DataAccess;

namespace Business.DFOdata
{
    public class Cell
    {
        public Cell(double x, double y)
        {
            X = x;
            Y = y;
        }
        public double X { get; set; }
        public double Y { get; set; }
    }

    public class DFOdataProcessor
    {
        protected double HalfOfEachCellArea { get; set; }

        public string GetDataFolderPath()
        {
            var baseDir = AppDomain.CurrentDomain.BaseDirectory;
            var folderPath = baseDir + "\\..\\..\\..\\Business\\DFOdata\\extractedData";
            return folderPath;
        }

        public void DeletePreviousData()
        {

            try
            {
                using (var work = new UnitOfWork())
                {
                    Console.WriteLine("Deleting Previous Data");
                    var dfoDataRepository = RepositoryContainer.GetRepository<DataAccess.DFOdata>(work);
                    dfoDataRepository.ExecuteCommandDirectly("delete from DFOdata");
                    //foreach (var dfOdata in dfoDataRepository.All())
                    //{
                    //    dfoDataRepository.Remove(dfOdata);
                    //}
                    //work.SaveChanges();
                    Console.WriteLine("Done");
                }

            }
            catch (Exception ex)
            {
                throw new Exception("Data deletion fails !");
            }

        }

        public void InsertNewDFOData()
        {
            var folderPath = GetDataFolderPath();
            var xyFilePath = folderPath + "\\paresedXY.txt";
            var velocityPath = folderPath + "\\parsedVelocity.txt";
            var xyFileLines = File.ReadAllLines(xyFilePath);
            var velocityFileLines = File.ReadAllLines(velocityPath);

            try
            {
                using (var work = new UnitOfWork())
                {
                    var dfoDataRepository = RepositoryContainer.GetRepository<DataAccess.DFOdata>(work);

                    for (int i = 0; i < xyFileLines.Count(); i++)
                    {
                        var xyFileLine = xyFileLines.ElementAt(i).Split(',');
                        var velocityFileLine = velocityFileLines.ElementAt(i).Split(',');
                        if (xyFileLine.Count() == 3 && velocityFileLine.Count() == 3)
                        {
                            var x = float.Parse(xyFileLine[1], CultureInfo.InvariantCulture.NumberFormat);
                            var y = float.Parse(xyFileLine[2], CultureInfo.InvariantCulture.NumberFormat);

                            var u = float.Parse(velocityFileLine[1], CultureInfo.InvariantCulture.NumberFormat);
                            var v = float.Parse(velocityFileLine[2], CultureInfo.InvariantCulture.NumberFormat);

                            var dfOdata = new DataAccess.DFOdata()
                            {
                                X = x,
                                Y = y,
                                U = u,
                                V = v
                            };
                            dfoDataRepository.Insert(dfOdata);
                            Console.WriteLine(xyFileLine[0]);

                        }
                        else
                        {
                            throw new Exception("txt files is not in perfect format !");
                        }

                    }
                    Console.WriteLine("Saving new data");
                    work.SaveChanges();
                    Console.WriteLine("Done");


                }
            }
            catch (Exception ex)
            {

            }
        }

        public void Strat()
        {
            //DeletePreviousData();
            //InsertNewData();
            Generate();
        }

        private StreamWriter GetFileWriterForSelectedPoints()
        {
            var selectedPointsTxtFile = GetDataFolderPath();
            var filePathForMathLab = selectedPointsTxtFile + "\\selectedPoints.txt";
            if (File.Exists(filePathForMathLab)) File.Delete(filePathForMathLab);
            return File.AppendText(filePathForMathLab);
        }

        private StreamWriter GetFileWriterForCellMeanVector()
        {
            var selectedPointsTxtFile = GetDataFolderPath();
            var filePathForMathLab = selectedPointsTxtFile + "\\cellMeanVector.txt";
            if (File.Exists(filePathForMathLab)) File.Delete(filePathForMathLab);
            return File.AppendText(filePathForMathLab);
        }

        private int GetFactorForNthLayer(int n)
        {
            var factor = 0;
            for (int i = 1; i <= n; i++)
            {
                factor += 2;
            }
            return factor;
        }
        public List<Cell> GetNthSurroundingCellsFrom(Cell fixedCenterCell, int n)
        {
            var factor = GetFactorForNthLayer(n);
            var adjacentCells = new List<Cell>
                                    {
                                        new Cell(0, fixedCenterCell.Y + factor * HalfOfEachCellArea),
                                        new Cell(fixedCenterCell.X - factor * HalfOfEachCellArea, fixedCenterCell.Y +  factor * HalfOfEachCellArea),
                                        new Cell(fixedCenterCell.X - factor * HalfOfEachCellArea, 0),
                                        new Cell(fixedCenterCell.X - factor * HalfOfEachCellArea, fixedCenterCell.Y - factor * HalfOfEachCellArea),
                                        new Cell(0, fixedCenterCell.Y - factor * HalfOfEachCellArea),
                                        new Cell(fixedCenterCell.X + factor * HalfOfEachCellArea, fixedCenterCell.Y - factor * HalfOfEachCellArea),
                                        new Cell(fixedCenterCell.X + factor * HalfOfEachCellArea, 0),
                                        new Cell(fixedCenterCell.X + factor * HalfOfEachCellArea, fixedCenterCell.Y + factor * HalfOfEachCellArea)
                                    };

            return adjacentCells;
        } 

        private void GetMeanVectorAndSelectedPointsFor(Cell fixedCenterCell, StreamWriter wr1, StreamWriter wr2, UnitOfWork work)
        {
            var dfoDataRepository = RepositoryContainer.GetRepository<DataAccess.DFOdata>(work);
            var sqlQuery = string.Format("Select * from DFOdata where X >= {0} and X <= {1} and Y >= {0} and Y <= {1}", fixedCenterCell.X - HalfOfEachCellArea, fixedCenterCell.X + HalfOfEachCellArea);
            var dfoDataPoints = dfoDataRepository.ExecuteCommand<DataAccess.DFOdata>(sqlQuery);
            var uCompSum = 0.0;
            var vCompSum = 0.0;
            foreach (var dfoDataPoint in dfoDataPoints)
            {
                wr1.WriteLine("{0},{1},{2},{3}", dfoDataPoint.X, dfoDataPoint.Y, dfoDataPoint.U, dfoDataPoint.V);
                uCompSum += dfoDataPoint.U;
                vCompSum += dfoDataPoint.V;
            }
            var totalDataPoint = dfoDataPoints.Count;
            wr2.WriteLine("{0},{1},{2},{3}", fixedCenterCell.X, fixedCenterCell.Y, uCompSum / totalDataPoint, vCompSum / totalDataPoint);
            Console.Write("Total {0} poins for cell {1},{2}.", totalDataPoint, fixedCenterCell.X, fixedCenterCell.Y);

        }

        private void GetMeanVectorAndSelectedPointsFor2(Cell fixedCenterCell, StreamWriter wr1, StreamWriter wr2, UnitOfWork work)
        {
            var dfoDataRepository = RepositoryContainer.GetRepository<DataAccess.DFOdata>(work);
            for (int nLayer = 1; nLayer <= 10; nLayer++)
            {
                var adjacentCells = GetNthSurroundingCellsFrom(fixedCenterCell, nLayer);
                foreach (var adjacentCell in adjacentCells)
                {
                    var sqlQuery = string.Format("Select * from DFOdata where X >= {0} and X <= {1} and Y >= {2} and Y <= {3}", 
                                                                                adjacentCell.X - HalfOfEachCellArea, 
                                                                                adjacentCell.X + HalfOfEachCellArea,
                                                                                adjacentCell.Y - HalfOfEachCellArea,
                                                                                adjacentCell.Y + HalfOfEachCellArea);
                    var dfoDataPoints = dfoDataRepository.ExecuteCommand<DataAccess.DFOdata>(sqlQuery);
                    var uCompSum = 0.0;
                    var vCompSum = 0.0;
                    foreach (var dfoDataPoint in dfoDataPoints)
                    {
                        wr1.WriteLine("{0},{1},{2},{3}", dfoDataPoint.X, dfoDataPoint.Y, dfoDataPoint.U, dfoDataPoint.V);
                        uCompSum += dfoDataPoint.U;
                        vCompSum += dfoDataPoint.V;
                    }
                    var totalDataPoint = dfoDataPoints.Count;
                    wr2.WriteLine("{0},{1},{2},{3}", adjacentCell.X, adjacentCell.Y, uCompSum / totalDataPoint, vCompSum / totalDataPoint);
                    Console.Write("Total {0} poins for cell {1},{2}.\n", totalDataPoint, adjacentCell.X, adjacentCell.Y);
                }
                Console.WriteLine("--------------------\n");
                

            }
            
            

        }

        private void Generate()
        {
            HalfOfEachCellArea = 2 * Math.Pow(10, 4);          
            try
            {
                var wr1 = GetFileWriterForSelectedPoints();
                var wr2 = GetFileWriterForCellMeanVector();
                using (var work = new UnitOfWork())
                {
                    var fixedCenterCell = new Cell(0.0, 0.0);
                    GetMeanVectorAndSelectedPointsFor2(fixedCenterCell, wr1, wr2, work);

                }
                wr1.Close();
                wr2.Close();
            }
            catch (Exception exception)
            {

                throw new Exception("Error while generating grid !");
            }
            Console.ReadLine();
        }

        

       
    }


}
