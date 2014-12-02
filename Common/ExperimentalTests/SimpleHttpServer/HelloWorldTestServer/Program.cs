using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using SimpleHttpServer;

namespace HelloWorldTestServer
{
    class Program : IDeployServerCallback
    {
        [Get("")]
        public string Default()
        {
            return string.Format(
                "<p>Hello, world!</p><p>The current machine name is: <strong>{0}</strong></p><p>{1}</p>",
                Environment.MachineName,
                new string[] { "Genius", "Vczh" }
                    .Select(s => string.Format("<a href=\"/HelloWorld/Person/{0}/\">{1}</a><br/>", s, s))
                    .Aggregate((a, b) => a + b)
                    );
        }

        [Get("/Person/{name}")]
        public string Person(string name)
        {
            return string.Format(
                "<p>Hi, {0}.</p><p>The current machine name is: <strong>{1}</strong></p><p><a href=\"/HelloWorld/\">Home Page</a></p>",
                name,
                Environment.MachineName);
        }

        public void Stop()
        {
            stopEvent.Set();
        }

        static ManualResetEvent stopEvent = null;

        static void Main(string[] args)
        {
            if (SimpleHttpServerHost.StartService<Program>("HelloWorld"))
            {
                stopEvent = new ManualResetEvent(false);
                stopEvent.WaitOne();
            }
            else
            {
                Console.WriteLine("Press [ENTER] to exit.");
                Console.ReadLine();
            }
        }
    }
}
