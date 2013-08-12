using System;
using System.Linq;
using System.Web.Mvc;
using System.Threading;
using System.Web;
using System.Text;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using FlatFileLoaderUtility.ViewModels;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Upload;

namespace FlatFileLoaderUtility.Controllers
{
    public class UploadsController : BaseController
    {
        #region Override Methods

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            filterContext.Controller.ViewBag.IsMenuUpload = true;
            filterContext.Controller.ViewBag.SegmentBytes = Properties.Settings.Default.SegmentBytes;
            base.OnActionExecuting(filterContext);
        }

        #endregion

        #region Index

        public ActionResult Index()
        {
            var viewModel = new FileUploadViewModel();

            // Restore seelcted interface cookie, if available
            var interfaceCookie = this.Request.Cookies["interface"];
            
            viewModel.InterfaceGroups = this.GetInterfaceGroups(false, "*ALL");
            viewModel.Interfaces = this.GetInterfaces(true, string.Empty, "*INBOUND", (interfaceCookie != null) ? interfaceCookie.Value : string.Empty, true, false);
            viewModel.Status = Status.GetStatus(this.Container.Access.Username, this.Container.Connection);

            if (viewModel.Status != null)
            {
                var segmentCount = viewModel.Status.GetSegmentCount();
                if (!viewModel.Status.IsDone && viewModel.Status.UploadId > 0 && viewModel.Status.Exception == null)
                {
                    var interfaces = this.Container.InterfaceRepository.Get(string.Empty);
                    var iface = (from x in interfaces where x.InterfaceCode == viewModel.Status.InterfaceCode select x).FirstOrDefault();

                    if (iface != null)
                    {
                        viewModel.LastSegment = segmentCount;
                        viewModel.InterfaceName = iface.InterfaceName;
                        viewModel.InterfaceCode = iface.InterfaceCode;
                        viewModel.FileName = viewModel.Status.FileName;
                        viewModel.FileSize = viewModel.Status.FileSize;
                    }
                    else
                    {
                        Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);
                    }
                }
                else
                {
                    Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);
                }
            }

            return this.View(viewModel);
        }

        [HttpPost]
        public JsonResult Start(string interfaceCode, string filename)
        {
            try
            {
                var interfaces = this.Container.InterfaceRepository.Get(string.Empty);
                var iface = (from x in interfaces where x.InterfaceCode == interfaceCode select x).FirstOrDefault();
                var status = Status.GetOrSetStatus(this.Container.Access.Username, this.Container.Connection, interfaceCode, filename);
                var segmentCount = status.GetSegmentCount();

                if (iface == null)
                    throw new Exception("Unknown interface");

                if (segmentCount > 0 && !status.IsDone)
                    throw new Exception("An upload is already in progress for " + this.Container.Access.Username);

                // Check that the filename is of the correct filetype
                if (string.IsNullOrEmpty(iface.FileType))
                    throw new Exception("This interface does not have a file type defined, and so cannot currently be used with this file upload utility.");

                if (iface.FileType == "csv" && Path.GetExtension(filename).ToLower() != ".csv")
                    throw new Exception("Invalid file type. This interface only accepts .csv files.");

                if (iface.FileType != "csv" && Path.GetExtension(filename).ToLower() != ".dat" && Path.GetExtension(filename).ToLower() != ".txt")
                    throw new Exception("Invalid file type. This interface only accepts fixed fixed width files (.dat or .txt).");

                if (segmentCount > 0)
                {
                    status = new Status(interfaceCode, filename);
                    Status.SetStatus(this.Container.Access.Username, this.Container.Connection, status);
                }

                // Create a status object and start the uploader thread
                var uploader = new Uploader(this.Container.Connection, this.Container.Access, this.Container.User);
                uploader.Status = status;

                var threadStart = new ThreadStart(uploader.Upload);
                var thread = new Thread(threadStart);
                thread.IsBackground = false;
                uploader.Status.Thread = thread;

                thread.Start();

                // Save the interface in cookie to pre-select the last used interface on next page load
                var cookie = new HttpCookie("interface", interfaceCode);
                cookie.Expires = DateTime.Now.AddYears(5);
                this.Response.Cookies.Add(cookie);

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());

                Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);

                return this.Json(new
                {
                    Result = "ERROR",
                    Message = ex.ApplicationMessage(),
                    UploadId = 0,
                    LicsId = 0
                });
            }
        }

        [HttpPost]
        public JsonResult Segment(string interfaceCode, string filename, string segmentData, bool isFinalSegment, long fileSize, bool needsEncodingFix)
        {
            var status = default(Status);

            try
            {
                status = Status.GetOrSetStatus(this.Container.Access.Username, this.Container.Connection, interfaceCode, filename);

                if (status.Exception != null)
                    throw status.Exception;

                if (status.IsError)
                    throw new Exception(status.ErrorMessage);

                if (status.IsDone)
                    throw new Exception("Upload has terminated");

                if (!status.IsDone && !status.Thread.IsAlive)
                {
                    // Thread needs re-starting, apparently.
                    // This can happen if there has been more than 5 minutes since the thread last had a data packet to process
                    var uploader = new Uploader(this.Container.Connection, this.Container.Access, this.Container.User);
                    uploader.Status = status;

                    var threadStart = new ThreadStart(uploader.Upload);
                    var thread = new Thread(threadStart);
                    thread.IsBackground = false;
                    uploader.Status.Thread = thread;

                    thread.Start();
                }

                if (interfaceCode != status.InterfaceCode)
                    throw new Exception("Expected interface code is " + status.InterfaceCode);

                if (filename != status.FileName)
                    throw new Exception("Expected filename is " + status.FileName);

                // Ok... this may need some explanation...
                // For uploading the data, the HTML5 FileReader works without any problems, just as expected. 
                // But as it turns out, getting it to work in IE7/8 is not so simple. IE 7/8 has to rely on ActiveX components 
                // to access the file system. There are two possible components it can use to do that:
                //
                // Scripting.FileSystemObject – this is a light-weight reader. It is considered a “safe” ActiveX component 
                // and doesn’t generate security warnings in the browser. It can read files encoded as ASCII and “Unicode”. 
                // But it turns out that when the documentation says “Unicode” it really means UTF-16 only. It has no support 
                // for UTF-8 encoding.
                //
                // ADODB.Stream – this is a fully functional stream component, but is considered a security risk and in the Mars 
                // environment it seems to be completely locked down. Even though the security settings in IE8 are set to allow 
                // cross-domain data sources for trusted and intranet sites, and even though the *.ap.mars domain is set as an 
                // intranet site, it *does not work*. I can’t see why, but the group policy security settings are set such that 
                // nothing is editable, so I don’t really even have access to investigate.
                //
                // So the only option was to use Scripting.FileSystemObject, and read the file as UTF-16. It passes the data to 
                // the server as "UTF-16 encoded", but is really UTF-8 data. The server then has to fix the encoding to get it 
                // back to UTF-8. This encoding fix is only needed when uploading via old versions of Internet Explorer, and 
                // should place negligible extra load on the server.
                if (needsEncodingFix)
                {
                    segmentData = Encoding.UTF8.GetString(Encoding.Unicode.GetBytes(segmentData));
                }

                status.AddSegment(new Segment(segmentData), isFinalSegment);
                status.FileSize = fileSize;

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());

                Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);

                return this.Json(new
                {
                    Result = "ERROR",
                    Message = ex.ApplicationMessage(),
                    UploadId = 0,
                    LicsId = 0
                });
            }
        }

        [HttpPost]
        public JsonResult Cancel()
        {
            var status = default(Status);

            try
            {
                status = Status.GetStatus(this.Container.Access.Username, this.Container.Connection);

                if (status.Exception != null)
                    throw status.Exception;

                if (!status.IsDone)
                {
                    // First, terminate the uploader thread
                    if (status.Thread.IsAlive)
                    {
                        status.IsCancelling = true;

                        status.Thread.Join(5000);
                        if (status.Thread.IsAlive)
                        {
                            status.Thread.Abort();
                            Thread.Sleep(1000);
                        }
                    }

                    // Check again that it isn't already done (it may have finished while the thread was ending
                    if (!status.IsDone && status.UploadId > 0)
                    {
                        // Now, cancel the upload
                        this.Container.UploadRepository.Cancel(status.UploadId, status.InterfaceCode, status.FileName);
                    }

                    // Now get rid of the status
                    Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);
                }

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());

                return this.Json(new
                {
                    Result = "ERROR",
                    Message = ex.ApplicationMessage(),
                    UploadId = (status == null) ? 0 : status.UploadId,
                    LicsId = (status == null) ? 0 : status.LicsId
                });
            }
        }

        [HttpPost]
        public JsonResult GetStatus()
        {
            var status = default(Status);

            try
            {
                // There are 5 possible statuses:
                // 1- Error/Exception
                // 2- The load to Oracle is still being done by the uploader
                // 3- The load to Lics is still underway
                // 4- The Lics processing is underway
                // 5- The Lics processing is complete

                status = Status.GetStatus(this.Container.Access.Username, this.Container.Connection);

                if (status.Exception != null)
                    throw status.Exception;

                if (status.IsError)
                    throw new Exception(status.ErrorMessage);

                if (!status.IsDone && !status.Thread.IsAlive)
                {
                    // Thread needs re-starting, apparently.
                    // This can happen if there has been more than 5 minutes since the thread last had a data packet to process
                    var uploader = new Uploader(this.Container.Connection, this.Container.Access, this.Container.User);
                    uploader.Status = status;

                    var threadStart = new ThreadStart(uploader.Upload);
                    var thread = new Thread(threadStart);
                    thread.IsBackground = false;
                    uploader.Status.Thread = thread;

                    thread.Start();
                }

                if (!status.IsDone)
                {
                    var segmentCount = status.GetSegmentCount();
                    var processedCount = status.GetSegmentProcessedCount();

                    return this.Json(new { 
                        Result = "OK", 
                        Total = segmentCount, 
                        Current = processedCount,
                        CurrentStep = 3 
                    });
                }
                else 
                {
                    if (status.LicsId == 0)
                        this.Container.UploadRepository.GetUploadStatus(status.UploadId, ref status);

                    if (status.LicsId == 0)
                    {
                        return this.Json(new
                        {
                            Result = "OK",
                            Total = status.TotalRowCount,
                            Current = status.CompletedRowCount,
                            CurrentStep = 4,
                            EstimatedTime = status.EstimatedTime
                        });
                    }
                    else
                    {
                        this.Container.UploadRepository.GetLicsStatus(status.LicsId, ref status);

                        var constLoadComplete = this.Container.LicsRepository.GetLoadCompletedConst();
                        var constProcessWorking = this.Container.LicsRepository.GetProcessWorkingConst();
                        var constProcessWorkingError = this.Container.LicsRepository.GetProcessWorkingErrorConst();

                        return this.Json(new
                        {
                            Result = "OK",
                            Total = status.TotalRowCount,
                            Current = status.CompletedRowCount,
                            IsComplete = (!string.IsNullOrEmpty(status.LicsStatus) && status.LicsStatus != constLoadComplete && status.LicsStatus != constProcessWorking && status.LicsStatus != constProcessWorkingError),
                            InterfaceErrorCount = status.InterfaceErrorCount,
                            RowErrorCount = status.RowErrorCount,
                            CurrentStep = 5,
                            LicsId = (status == null) ? 0 : status.LicsId,
                            EstimatedTime = status.EstimatedTime
                        });
                    }   

                }
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());

                Status.ClearStatus(this.Container.Access.Username, this.Container.Connection);

                return this.Json(new { 
                    Result = "ERROR", 
                    Message = ex.ApplicationMessage(),
                    UploadId = (status == null) ? 0 : status.UploadId,
                    LicsId = (status == null) ? 0 : status.LicsId
                });
            }
        }

        #endregion
    }
}
