using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using SimpleHttpServer;

namespace NestleSpider
{
    class Program : IDeployServerCallback
    {
        [Get("")]
        public string Default()
        {
            return "Welcome to Nestle Spider!";
        }

        public void Stop()
        {
            stopEvent.Set();
        }

        static ManualResetEvent stopEvent = null;

        static void Main(string[] args)
        {
            if (SimpleHttpServerHost.StartService<Program>("NestleSpider"))
            {
                stopEvent = new ManualResetEvent(false);
                do
                {
                    Spider.Run();
                } while (!stopEvent.WaitOne(3600 * 1000));
            }
            else
            {
                Console.WriteLine("Press [ENTER] to exit.");
                Console.ReadLine();
            }
        }
    }
}
