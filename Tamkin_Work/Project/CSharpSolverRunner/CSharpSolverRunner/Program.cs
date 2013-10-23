using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace CSharpSolverRunner
{
    class Program
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

        static void Main(string[] args)
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
