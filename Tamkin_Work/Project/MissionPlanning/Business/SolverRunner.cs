using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

namespace Business
{
    class SolverRunner
    {
        private static Process _cmdExe;
        public static DateTime StartTime { get; set; }
        public static DateTime CurrentTime { get; set; }

        [DllImport("User32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);

        private static void SendCtrlC(IntPtr hWnd)
        {
            const uint keyeventfKeyup = 2;
            const byte vkControl = 0x11;
            //set it to foreground or u can not send commands
            SetForegroundWindow(hWnd);
            //sending keyboard event Ctrl+C
            keybd_event(vkControl, 0, 0, 0);
            keybd_event(0x43, 0, 0, 0);
            keybd_event(0x43, 0, keyeventfKeyup, 0);
            keybd_event(vkControl, 0, keyeventfKeyup, 0);
        }

        public void Run1()
        {
            var bdir = AppDomain.CurrentDomain.BaseDirectory;
            var param = "/c "+"java -jar " + bdir + "sat4j-pb.jar " + bdir + "generatedForVideoTutorial.opb > c:\\myou.txt";
            var processStartInfo = new ProcessStartInfo(@"cmd.exe", param)
            {
                UseShellExecute = false,
                RedirectStandardOutput = false,
                RedirectStandardInput = false
            };
           
            _cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            _cmdExe.Start();

            StartTime = DateTime.Now;
            while (true)
            {
                CurrentTime = DateTime.Now;
                var diff = CurrentTime.Subtract(StartTime).TotalSeconds;
                if (diff >= 10)
                {
                    try
                    {
                        SendCtrlC(_cmdExe.MainWindowHandle);
                    }
                    catch (Exception exception)
                    {
                        _cmdExe.CloseMainWindow();
                        throw;
                    }
                    _cmdExe.CloseMainWindow();
                    break;
                }
            }

            

        }

        public string GetSolverDir()
        {
            var bdir = AppDomain.CurrentDomain.BaseDirectory;
            var solverDir = bdir + "..\\Business\\Solver";
            return solverDir;
        }

        public string GenerateRandomCostMatrix(int numberOfNodes)
        {
            var solverDir = GetSolverDir();
            const string costMatrixFilePath = "E:\\MissionPlanningTempData" + "\\RandomCostMatrix.txt";
            if (File.Exists(costMatrixFilePath))
                File.Delete(costMatrixFilePath);
            var file = new StreamWriter(costMatrixFilePath);
            file.WriteLine(numberOfNodes);
            var random = new Random();
            for (int i = 1; i <= numberOfNodes; i++)
            {
                var line = "";
                for (int j = 1; j <= numberOfNodes; j++)
                {
                    if (i == j)
                    {
                        if (j == numberOfNodes) line += "0";
                        else
                            line += "0,";
   
                    }
                    else
                    {
                        if (j == numberOfNodes) line += random.Next(1, 25).ToString();
                        else
                            line += random.Next(1, 25).ToString() + ",";
                    }
                }
                file.WriteLine(line);
            }
            
            file.Close();
            return costMatrixFilePath;
        }

        public void GeneratePsuedoBooleanEncodingFromRandomCostGraph(string costMatrixFilePath)
        {
            var solverDir = GetSolverDir();
            var pythonPBEInstanceGeneratorScript = solverDir + "\\InstantceGenerator_From_CostMatrix.py";
            var cmd = string.Format("{0}", pythonPBEInstanceGeneratorScript);
            var processStartInfo = new ProcessStartInfo(@"C:\Python27\python.exe", cmd)
            {
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardInput = false
            };

            _cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            _cmdExe.Start();
            _cmdExe.StandardOutput.ReadToEnd();
            _cmdExe.WaitForExit();
        }

        public void RunSAT4J()
        {
            var bdir = AppDomain.CurrentDomain.BaseDirectory;
            var solverDir = bdir + "..\\Business\\Solver\\";
            const string outputFilePath = "E:\\MissionPlanningTempData\\" + "solverResult.txt";
            const string encodingFilePath = "E:\\MissionPlanningTempData\\" + "generatedForVideoTutorial.opb";

            if (File.Exists(outputFilePath))
                File.Delete(outputFilePath);
            var jarFilePath = solverDir + "sat4j-pb.jar";

            var cmd = string.Format("/c java -jar {0} DefaultOptimizer 60 {1} > {2}", jarFilePath, encodingFilePath, outputFilePath);

            //var param = "/c " + "java -jar " + bdir + "sat4j-pb.jar " + bdir + " DefaultOptimizer 10 generatedForVideoTutorial.opb > c:\\myou.txt";
            var processStartInfo = new ProcessStartInfo(@"cmd.exe", cmd)
            {
                UseShellExecute = true,
                RedirectStandardOutput = false,
                RedirectStandardInput = false,
                CreateNoWindow = false,
                WindowStyle = ProcessWindowStyle.Minimized
                //WorkingDirectory = ''
            };

            _cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            _cmdExe.Start();
            _cmdExe.WaitForExit();

        }

        public string RunSolverSAT4J(string encodingFilePath, string outputFilePath)
        {
            if (File.Exists(outputFilePath)) File.Delete(outputFilePath);
            var jarFilePath = GetSolverDir() + "\\sat4j-pb.jar";

            var cmd = string.Format("/c java -jar {0} DefaultOptimizer 120 {1} > {2}", jarFilePath, encodingFilePath, outputFilePath);

            var processStartInfo = new ProcessStartInfo(@"cmd.exe", cmd)
            {
                UseShellExecute = true,
                RedirectStandardOutput = false,
                RedirectStandardInput = false,
                CreateNoWindow = false,
                WindowStyle = ProcessWindowStyle.Minimized
                //WorkingDirectory = ''
            };

            _cmdExe = new Process { StartInfo = processStartInfo, EnableRaisingEvents = true };
            _cmdExe.Start();
            _cmdExe.WaitForExit();
            return Path.GetFileNameWithoutExtension(outputFilePath);
        }

        private static void OnOutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            Console.WriteLine(e.Data);
            CurrentTime = DateTime.Now;
            var diff = CurrentTime.Subtract(StartTime).TotalSeconds;
            Console.WriteLine(diff);
            if(CurrentTime.Subtract(StartTime).TotalSeconds  >= 20)
            {
                SendCtrlC(_cmdExe.MainWindowHandle);
            }
        }
    }
}
