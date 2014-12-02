using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace SimpleHttpServer
{
    public static class SimpleHttpServerHost
    {
        class RouteMethodRecord
        {
            public RouteAttribute RouteProperties { get; set; }
            public MethodInfo RouteMethod { get; set; }
            public Regex RoutePathRegex { get; set; }

            private string[] Parameters { get; set; }
            private int[] ParameterIndexMapping { get; set; }

            private static Regex regexRoutePathParser = new Regex(@"\{(?<name>\w+)\}");

            public RouteMethodRecord(RouteAttribute routeProperties, string prefix, MethodInfo routeMethod)
            {
                string routePath = routeProperties.RoutePath.Trim().TrimEnd('/');
                var matches = regexRoutePathParser.Matches(routePath);
                {
                    this.RouteProperties = routeProperties;
                    this.RouteMethod = routeMethod;
                }
                {
                    List<string> regexFragments = new List<string>();
                    int index = 0;
                    foreach (Match match in matches)
                    {
                        regexFragments.Add(Regex.Escape(routePath.Substring(index, match.Index - index)));
                        regexFragments.Add(string.Format(@"(?<{0}>[^/]*?)", match.Groups["name"].Value));
                        index = match.Index + match.Length;
                    }
                    regexFragments.Add(Regex.Escape(routePath.Substring(index, routePath.Length - index)));

                    string regex = regexFragments.Aggregate((a, b) => a + b);
                    this.RoutePathRegex = new Regex(string.Format("^{0}{1}$", Regex.Escape(prefix), regex));
                }
                {
                    this.Parameters = matches
                        .Cast<Match>()
                        .Select(m => m.Groups["name"].Value)
                        .ToArray();
                }
                {
                    var parameterInfoNames = this.RouteMethod
                        .GetParameters()
                        .Select(p => p.Name)
                        .ToArray();

                    var parameterIndices = Enumerable
                        .Range(0, parameterInfoNames.Length)
                        .ToDictionary(i => parameterInfoNames[i], i => i);

                    this.ParameterIndexMapping = this.Parameters
                        .Select(p => parameterIndices[p])
                        .ToArray();
                }
            }

            public string Execute(Match match, object serverObject)
            {
                var parameters = this.Parameters
                    .Select(p => match.Groups[p].Value)
                    .Cast<object>()
                    .ToArray();
                var parametersInOrder = this.ParameterIndexMapping
                    .Select(i => parameters[i])
                    .ToArray();
                return this.RouteMethod.Invoke(serverObject, parametersInOrder).ToString();
            }
        }

        class RouteContext
        {
            private object serverObject = null;
            private RouteMethodRecord[] methods = null;

            public Object ServerObject
            {
                get
                {
                    return this.serverObject;
                }
            }

            public RouteContext(Type serverType, string prefix)
            {
                this.serverObject = serverType
                    .GetConstructor(new Type[] { })
                    .Invoke(new object[] { });

                methods = serverType
                    .GetMethods()
                    .Select(m => Tuple.Create(
                        m.GetCustomAttributes().Where(a => a is RouteAttribute).FirstOrDefault(),
                        m)
                        )
                    .Where(t => t.Item1 != null)
                    .Select(t => new RouteMethodRecord(t.Item1 as RouteAttribute, prefix, t.Item2))
                    .ToArray();
            }

            public string Route(string url, HttpListenerContext context)
            {
                foreach (var method in this.methods)
                {
                    var match = method.RoutePathRegex.Match(url);
                    if (match.Success)
                    {
                        if (method.RouteProperties.Method == context.Request.HttpMethod)
                        {
                            return method.Execute(match, this.serverObject);
                        }
                    }
                }
                return null;
            }
        }

        private static void DriveHttpListener(HttpListener httpListener, RouteContext routeContext)
        {
            httpListener.BeginGetContext((ar) =>
            {
                var context = httpListener.EndGetContext(ar);
                DriveHttpListener(httpListener, routeContext);

                string path = context.Request.Url.AbsolutePath.Trim().TrimEnd('/');
                var result = routeContext.Route(path, context);
                if (result == null)
                {
                    context.Response.StatusCode = 404;
                    context.Response.ContentLength64 = 0;
                }
                else
                {
                    context.Response.ContentEncoding = Encoding.UTF8;
                    byte[] buffer = Encoding.UTF8.GetBytes(result);
                    context.Response.ContentLength64 = buffer.Length;
                    context.Response.OutputStream.Write(buffer, 0, buffer.Length);
                }
                context.Response.Close();
            }, null);
        }

        private static RouteContext Run(Type serverType, string host, int port, string prefix)
        {
            HttpListener httpListener = new HttpListener();
            httpListener.Prefixes.Add(string.Format("http://{0}:{1}{2}/", host, port, prefix));
            httpListener.Start();

            RouteContext context = new RouteContext(serverType, prefix);
            DriveHttpListener(httpListener, context);
            return context;
        }

        class DeployServerCallback
        {
            public IDeployServerCallback CallbackInterface { get; set; }
            public Semaphore ServiceSemaphore;

            [Get("/Stop")]
            public string Stop()
            {
                this.CallbackInterface.Stop();
                return "The \"Stop\" signal has been sent to the service.";
            }
        }

        public static bool StartService<T>(string name)
            where T : IDeployServerCallback
        {
            XDocument configuration = XDocument.Load("ServiceConfiguration.xml");
            XElement service = configuration
                .Root
                .Element("services")
                .Elements("service")
                .Where(s => s.Element("name").Value == name)
                .First();

            int port = int.Parse(service.Element("port").Value);
            string key = service.Element("key").Value;

            string semaphoreName = "SERVICE-IDENTIFIER-" + key;
            Semaphore semaphore = null;
            if (Semaphore.TryOpenExisting(semaphoreName, out semaphore))
            {
                Console.WriteLine("Service {0} already exists.", name);
                return false;
            }
            else
            {
                semaphore = new Semaphore(0, 1, semaphoreName);
                IDeployServerCallback callbackInterface = (IDeployServerCallback)Run(typeof(T), "+", port, "/" + name).ServerObject;
                DeployServerCallback callbackService = (DeployServerCallback)Run(typeof(DeployServerCallback), "localhost", port, "/Private-Service-" + name).ServerObject;
                callbackService.CallbackInterface = callbackInterface;
                callbackService.ServiceSemaphore = semaphore;

                Console.WriteLine("Service has been started.");
                Console.WriteLine("Address: http://localhost:{0}/{1}/", port, name);
                Console.WriteLine("Stop using: http://localhost:{0}/Private-Service-{1}/Stop/", port, name);
                return true;
            }
        }
    }

    public interface IDeployServerCallback
    {
        void Stop();
    };

    public class DeployServerCallbackProxy : IDeployServerCallback
    {
        private string urlPrefix;
        private string semaphoreName;
        private string executablePath;

        public DeployServerCallbackProxy(string name, string configurationFile, XDocument configuration)
        {
            XElement service = configuration
                .Root
                .Element("services")
                .Elements("service")
                .Where(s => s.Element("name").Value == name)
                .First();

            int port = int.Parse(service.Element("port").Value);
            string key = service.Element("key").Value;
            string executable = service.Element("executable").Value;

            this.urlPrefix = string.Format("http://localhost:{0}/Private-Service-{1}/", port, name);
            this.semaphoreName = "SERVICE-IDENTIFIER-" + key;
            this.executablePath = Path.GetDirectoryName(Path.GetFullPath(configurationFile)) + "/" + executable;

            this.Url = string.Format("http://localhost:{0}/{1}/", port, name);
            this.Name = name;
            this.Error = "";
        }

        public string Url { get; private set; }
        public string Name { get; private set; }
        public string Error { get; private set; }

        public bool Running
        {
            get
            {
                Semaphore semaphore = null;
                if (Semaphore.TryOpenExisting(this.semaphoreName, out semaphore))
                {
                    semaphore.Dispose();
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public void Start()
        {
            if (!this.Running)
            {
                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.FileName = this.executablePath;
                    psi.WorkingDirectory = Path.GetDirectoryName(psi.FileName);
                    psi.UseShellExecute = true;
                    psi.ErrorDialog = false;
                    Process.Start(psi);
                    this.Error = "";
                }
                catch (Exception ex)
                {
                    this.Error = ex.Message;
                }
            }
        }

        public void Stop()
        {
            try
            {
                string url = this.urlPrefix + "Stop/";
                HttpWebRequest request = HttpWebRequest.CreateHttp(url);
                request.Method = "GET";
                request.ContentLength = 0;
                request.GetResponse();
                this.Error = "";
            }
            catch (Exception ex)
            {
                this.Error = ex.Message;
            }
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public abstract class RouteAttribute : Attribute
    {
        public string RoutePath { get; set; }
        public string Method { get; set; }

        public RouteAttribute(string method, string routePath)
        {
            this.Method = method;
            this.RoutePath = routePath;
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public class GetAttribute : RouteAttribute
    {
        public GetAttribute(string routePath)
            : base("GET", routePath)
        {
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public class PostAttribute : RouteAttribute
    {
        public PostAttribute(string routePath)
            : base("POST", routePath)
        {
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public class PutAttribute : RouteAttribute
    {
        public PutAttribute(string routePath)
            : base("PUT", routePath)
        {
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public class DeleteAttribute : RouteAttribute
    {
        public DeleteAttribute(string routePath)
            : base("DELETE", routePath)
        {
        }
    }
}
