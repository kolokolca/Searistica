﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
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
            GenerateGrid();
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

        public List<Cell> GetNthSurroundingCellsFrom3(Cell fixedCenterCell, int n)
        {
            var factor = GetFactorForNthLayer(n);
            double distanceBetweenNthTireCellsAndCenterCell = factor * HalfOfEachCellArea;
            double distanceBetween2AdjacentCell = 2 * HalfOfEachCellArea;
            var maxX = fixedCenterCell.X + distanceBetweenNthTireCellsAndCenterCell;
            var minX = fixedCenterCell.X - distanceBetweenNthTireCellsAndCenterCell;
            var maxY = fixedCenterCell.Y + distanceBetweenNthTireCellsAndCenterCell;
            var minY = fixedCenterCell.Y - distanceBetweenNthTireCellsAndCenterCell;

            var adjacentCells = new List<Cell>();
            //First and Lat Row
            for (double x = minX; x <= maxX; x = x + distanceBetween2AdjacentCell)
            {
                adjacentCells.Add(new Cell(x, maxY));
                adjacentCells.Add(new Cell(x, minY));
            }
            //First and last Column
            for (double y = minY + distanceBetween2AdjacentCell; y <= maxY - distanceBetween2AdjacentCell; y = y + distanceBetween2AdjacentCell)
            {
                adjacentCells.Add(new Cell(minX, y));
                adjacentCells.Add(new Cell(maxX, y));
            }

            return adjacentCells;
        } 

        private void GetMeanVectorAndSelectedPointsFor3(Cell fixedCenterCell, StreamWriter wr1, StreamWriter wr2, UnitOfWork work)
        {
            var dfoDataRepository = RepositoryContainer.GetRepository<DataAccess.DFOdata>(work);
            for (int nLayer = 1; nLayer <= 60; nLayer++)
            {
                var adjacentCells = GetNthSurroundingCellsFrom3(fixedCenterCell, nLayer);
                foreach (var adjacentCell in adjacentCells)
                {
                    Console.WriteLine(string.Format("{0},{1}",adjacentCell.X, adjacentCell.Y));
                }
                Console.Write(string.Format("Toal adjacent: {0}\n", adjacentCells.Count));
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
                    double uComp = uCompSum / totalDataPoint;
                    double vComp = vCompSum / totalDataPoint;
                    if (!Double.IsNaN(uComp) && !Double.IsNaN(vComp))
                    {
                        wr2.WriteLine("{0},{1},{2},{3}", adjacentCell.X, adjacentCell.Y, uComp, vComp);
                    }
                    Console.Write("Total {0} poins for cell {1},{2}.\n", totalDataPoint, adjacentCell.X, adjacentCell.Y);
                }
                Console.WriteLine("--------------------\n");


            }


        }


        private void GenerateGrid()
        {
            HalfOfEachCellArea = 1 * Math.Pow(10, 4);          
            try
            {
                var wr1 = GetFileWriterForSelectedPoints();
                var wr2 = GetFileWriterForCellMeanVector();
                using (var work = new UnitOfWork())
                {
                    var fixedCenterCell = new Cell(0.0, 0.0);
                    GetMeanVectorAndSelectedPointsFor3(fixedCenterCell, wr1, wr2, work);

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
