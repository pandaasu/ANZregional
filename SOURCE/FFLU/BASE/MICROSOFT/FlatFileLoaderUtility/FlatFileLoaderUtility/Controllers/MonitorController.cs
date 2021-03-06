using System;
using System.Linq;
using System.Collections.Generic;
using System.Web.Mvc;
using System.Threading;
using FlatFileLoaderUtility.ViewModels;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using Net.Code.Csv;

namespace FlatFileLoaderUtility.Controllers
{
    public class MonitorController : BaseController
    {
        #region Override Methods

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            filterContext.Controller.ViewBag.IsMenuMonitor = true;
            base.OnActionExecuting(filterContext);
        }

        #endregion

        #region Index

        public ActionResult Index()
        {
            var viewModel = new InterfaceMonitorListViewModel();

            if (this.Container.Connection == null)
                return this.View(viewModel);

            viewModel.InterfaceGroups = this.GetInterfaceGroups(false, "*ALL");
            viewModel.Interfaces = this.GetInterfaces(true, string.Empty, string.Empty, string.Empty, false, true);
            viewModel.IcsStatuses = this.GetIcsStatuses(string.Empty);
            viewModel.InterfaceTypes = this.GetInterfaceTypes(string.Empty);
            
            return this.View(viewModel);
        }

        [HttpPost]
        public JsonResult MonitorList(string interfaceGroupCode, string interfaceTypeCode, string interfaceCode, int? licsId, string icsStatusCode, DateTime? startDate, DateTime? endDate, int? jtStartIndex = 0, int? jtPageSize = 0)
        {
            try
            {
                var total = 0;
                var result = this.Container.MonitorRepository.Load(
                    interfaceGroupCode,
                    interfaceTypeCode,
                    interfaceCode,
                    licsId,
                    icsStatusCode,
                    startDate,
                    endDate,
                    jtStartIndex ?? 0,
                    jtPageSize ?? 0,
                    ref total
                ).ToList();

                // Set whether or not the user has access to process each item
                foreach (var item in result)
                {
                    item.HasProcessAccess = (
                        from x in this.Container.User.InterfaceOptions
                        where x.InterfaceCode == item.InterfaceCode
                            && x.OptionCode == Option.Process
                        select 1).Count() > 0;
                }

                return this.Json(new { Result = "OK", Records = result, TotalRecordCount = total });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        [HttpPost]
        public JsonResult ReprocessList(string licsIds, string interfaceCodes)
        {
            // Ok... you may be wondering: "why is this method such a diabolical mess?!? Why not pass in a list of objects?
            // Answer: the JsonDotNetValueProviderFactory can't deserialise into lists :(
            // It can't deserialise into arrays either.
            // And it's required to support the large volumes of data passed to the server, to work around
            // what appears to be a bug in the framework json deserialiser (that ignores the max request length parameter in the web.config)
            // So we're stuck with this.

            try
            {
                var splitOn = new char[] { ',' };
                var ids = licsIds.Split(splitOn, StringSplitOptions.RemoveEmptyEntries);
                var codes = interfaceCodes.Split(splitOn, StringSplitOptions.RemoveEmptyEntries);

                if (ids.Length != codes.Length)
                    throw new Exception("Array for codes and ids are not the same length.");

                for (var i = 0; i < ids.Length; i++)
                {
                    this.Container.InterfaceRepository.Reprocess(Tools.ZeroInvalidInt(ids[i]), codes[i]);
                }

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        [HttpPost]
        public JsonResult RowDataList(int licsId, int traceId, bool isErrorRowsOnly, int? jtStartIndex = 0, int? jtPageSize = 0)
        {
            try
            {
                var firstRow = jtStartIndex ?? 0;
                var pageSize = jtPageSize ?? 15;
                var monitor = (
                    from x in this.Container.MonitorRepository.GetTraceHistory(licsId)
                    where x.TraceId == traceId
                    select x).FirstOrDefault() ?? new FlatFileLoaderUtility.Models.Monitor();

                var result = this.Container.MonitorRepository.RowDataLoad(
                    licsId,
                    traceId,
                    isErrorRowsOnly,
                    firstRow,
                    pageSize
                );

                // Delimited fields
                if (monitor.FileType == "csv" || monitor.FileType == "tab")
                {
                    var qualifier = (monitor.CsvQualifier.Length > 0) ? monitor.CsvQualifier[0] : ' ';
                    var layout = new CsvLayout(qualifier, ((monitor.FileType == "csv") ? ',' : '\t'), qualifier);
                    var behaviour = new CsvBehaviour(ValueTrimmingOptions.All, MissingFieldAction.ReplaceByEmpty, true, QuotesInsideQuotedFieldAction.Ignore);
                    var converter = new Converter();
                    
                    foreach (var item in result)
                    {
                        using (var reader = item.Data.ReadStringAsCsv(layout, behaviour, converter))
                        {
                            if (reader.Read())
                            {
                                item.ColumnData = new List<string>();
                                for (var i = 0; i < reader.FieldCount; i++)
                                {
                                    item.ColumnData.Add(reader.GetString(i));
                                }
                            }
                        }
                    }
                }

                // Fixed fields
                if (monitor.FileType != "csv" && monitor.FileType != "tab" && result.Count > 0)
                {
                    var columnCounterRow = new IcsRowData();
                    var dataRowLength = result.Max(x => x.Data.Length);
                    for (var i = 1; i <= dataRowLength; i++)
                    {
                        if (i % 10 == 0)
                        {
                            columnCounterRow.Data += i.ToString();
                            i += (i.ToString().Length - 1);
                        }
                        else
                        {
                            columnCounterRow.Data += ".";
                        }
                    }
                    result.Insert(0, columnCounterRow);
                }

                return this.Json(new { Result = "OK", Records = result, TotalRecordCount = (isErrorRowsOnly) ? monitor.RowInErrorCount : monitor.RecordCount });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        #endregion

        #region View

        public ActionResult View(int? id)
        {
            var viewModel = new InterfaceMonitorDetailViewModel();

            if (this.Container.Connection == null)
            {
                viewModel.Record = new Models.Monitor();
                return this.View(viewModel);
            }

            var records = this.Container.MonitorRepository.GetTraceHistory(id ?? 0);

            viewModel.Monitors = records;
            viewModel.Record = records.FirstOrDefault() ?? new FlatFileLoaderUtility.Models.Monitor();
            viewModel.HasProcessAccess = (
                from x in this.Container.User.InterfaceOptions 
                where x.InterfaceCode == viewModel.Record.InterfaceCode
                    && x.OptionCode == Option.Process
                select 1).Count() > 0;

            // Delimited fields: must know how many columns there are in the data.
            // The only way to know that is to sample the data...
            if (viewModel.Record.FileType == "csv" || viewModel.Record.FileType == "tab")
            {
                viewModel.ColumnCount = 0;

                var data = this.Container.MonitorRepository.RowDataLoad(viewModel.Record.LicsId, viewModel.Record.TraceId, false, 0, 10);
                if (data.Count > 0)
                {
                    var qualifier = (viewModel.Record.CsvQualifier.Length > 0) ? viewModel.Record.CsvQualifier[0] : ' ';
                    var layout = new CsvLayout(qualifier, ((viewModel.Record.FileType == "csv") ? ',' : '\t'), qualifier);
                    var behaviour = new CsvBehaviour(ValueTrimmingOptions.All, MissingFieldAction.ReplaceByEmpty, true, QuotesInsideQuotedFieldAction.Ignore);
                    var converter = new Converter();

                    foreach (var item in data)
                    {
                        using (var reader = item.Data.ReadStringAsCsv(layout, behaviour, converter))
                        {
                            while (reader.Read())
                            {
                                viewModel.ColumnCount = Math.Max(viewModel.ColumnCount, reader.FieldCount);
                            }
                        }
                    }
                }
            }

            if (viewModel.Record.InterfaceErrorCount > 0)
                viewModel.InterfaceErrors = this.Container.MonitorRepository.GetInterfaceErrors(id ?? 0, viewModel.Record.TraceId);

            return this.View(viewModel);
        }

        [HttpPost]
        public JsonResult GetMonitorDetails(int licsId, int traceId)
        {
            try
            {
                var errors = new List<IcsError>();
                var monitor = (
                    from x in this.Container.MonitorRepository.GetTraceHistory(licsId)
                    where x.TraceId == traceId
                    select x).FirstOrDefault() ?? new FlatFileLoaderUtility.Models.Monitor();

                if (monitor.InterfaceErrorCount > 0)
                    errors = this.Container.MonitorRepository.GetInterfaceErrors(licsId, traceId);

                return this.Json(new { Result = "OK", Monitor = monitor, InterfaceErrors = errors });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        [HttpPost]
        public JsonResult Reprocess(int licsId, string interfaceCode)
        {
            try
            {
                this.Container.InterfaceRepository.Reprocess(licsId, interfaceCode);

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        [HttpPost]
        public JsonResult GetStatus(int licsId)
        {
            try
            {
                // There are 3 possible statuses, but the status numbers are the same as used in UploadController.GetStatus
                // 1- Error/Exception
                // 4- The Lics processing is underway
                // 5- The Lics processing is complete
                var status = new Status(string.Empty, string.Empty);

                this.Container.UploadRepository.GetLicsStatus(licsId, ref status);

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
                    EstimatedTime = status.EstimatedTime
                });
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());

                return this.Json(new
                {
                    Result = "ERROR",
                    Message = ex.ApplicationMessage()
                });
            }
        }

        #endregion        
    }
}
