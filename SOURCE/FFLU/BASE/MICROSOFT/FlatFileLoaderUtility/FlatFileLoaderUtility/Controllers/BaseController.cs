using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.SessionState;
using System.Web.Mvc;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Repositories;
using FlatFileLoaderUtility.Repositories.DataAccess;

namespace FlatFileLoaderUtility.Controllers
{
    [SessionState(SessionStateBehavior.Required)]
    public class BaseController : Controller
    {
        #region Private/Protected Members

        protected IRepositoryContainer Container { get; private set; }

        #endregion

        #region Constructor

        public BaseController()
        {
            this.Container = new RepositoryContainer();
        }

        #endregion

        #region Override Methods

        protected override void Dispose(bool disposing)
        {
            this.Container.Dispose();
            base.Dispose(disposing);
        }

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Populate the common objects 
            this.Container.Access = Access.GetAccess(this.HttpContext);
            filterContext.Controller.ViewBag.Access = this.Container.Access;
            filterContext.Controller.ViewBag.User = new User(); // Populated in case of exception
            filterContext.Controller.ViewBag.IsTest = Properties.Settings.Default.IsTest;

            // If the user is setting the connection, do not populate any of the connection-dependend data
            if (filterContext.ActionDescriptor.ActionName != "SetConnection")
            {
                // Get the connection
                var connection = Connection.GetConnection(this.HttpContext);

                // Set it in the ViewBag
                filterContext.Controller.ViewBag.Connection = connection;
                filterContext.Controller.ViewBag.Connections = this.GetConnections(false, connection.ConnectionId);

                // This step happens last, because if it can't connect to the database it will produce an exception
                if (this.Container.Connection == null)
                    this.Container.Connection = connection;

                // Get the user connection data
                filterContext.Controller.ViewBag.User = this.Container.UserRepository.Get();
            }

            this.Container.User = filterContext.Controller.ViewBag.User;

            base.OnActionExecuting(filterContext);
        }

        #endregion

        #region Connections

        [HttpPost]
        public JsonResult GetConnectionOptions()
        {
            try
            {
                var result = this.GetConnections(false, null).Select(c => new { DisplayText = c.Text, Value = c.Value });
                return this.Json(new { Result = "OK", Options = result });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        protected List<SelectListItem> GetConnections(bool withSelectOption, int? selectedConnectionId)
        {
            var connectionsBase = this.Container.ConnectionRepository.Get(string.Empty);

            if (!selectedConnectionId.HasValue || selectedConnectionId.Value == 0)
            {
                selectedConnectionId = (
                                  from x in connectionsBase
                                  orderby x.ConnectionName
                                  select x.ConnectionId).FirstOrDefault();
            }

            var connections = (
                         from x in connectionsBase
                         orderby x.ConnectionName
                         select new SelectListItem
                         {
                             Text = x.ConnectionName,
                             Value = x.ConnectionId.ToString(),
                             Selected = x.ConnectionId == selectedConnectionId
                         }).ToList();

            if (withSelectOption)
                connections.Insert(0, new SelectListItem { Text = "- select -", Value = string.Empty });

            return connections;
        }

        [HttpPost]
        public JsonResult SetConnection(int connectionId)
        {
            try
            {
                var connection = (from x in this.Container.ConnectionRepository.Get(string.Empty) where x.ConnectionId == connectionId select x).FirstOrDefault();

                if (connection == null)
                    throw new Exception("Unknown ConnectionId");

                Connection.SetConnection(this.HttpContext, connection);

                //// Set the connection in the ViewBag
                //this.ViewBag.Connection = connection;
                //this.ViewBag.Connections = this.GetConnections(false, connection.ConnectionId);

                //// This step happens last, because if it can't connect to the database it will produce an exception
                //if (this.Container.Connection == null)
                //    this.Container.Connection = connection;

                //// Get the user connection data
                //this.ViewBag.User = this.Container.UserRepository.Get();

                return this.Json(new { Result = "OK" });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        #endregion

        #region Interface Groups

        protected List<SelectListItem> GetInterfaceGroups(bool withSelectOption, string selectedInterfaceGroupCode)
        {
            var itemsBase = this.Container.InterfaceGroupRepository.Get(string.Empty);

            if (string.IsNullOrWhiteSpace(selectedInterfaceGroupCode))
            {
                selectedInterfaceGroupCode = (
                                  from x in itemsBase
                                  orderby x.InterfaceGroupName
                                  select x.InterfaceGroupCode).FirstOrDefault();
            }

            var items = (
                         from x in itemsBase
                         orderby x.InterfaceGroupName
                         select new SelectListItem
                         {
                             Text = x.InterfaceGroupName,
                             Value = x.InterfaceGroupCode,
                             Selected = x.InterfaceGroupCode == selectedInterfaceGroupCode
                         }).ToList();

            if (withSelectOption)
                items.Insert(0, new SelectListItem { Text = "- select -", Value = string.Empty });

            return items;
        }

        #endregion

        #region Interface

        protected List<SelectListItem> GetInterfaces(bool withSelectOption, string interfaceGroupCode, string interfaceTypeCode, string selectedInterfaceCode, bool isLoaderRequired, bool isMonitorRequired)
        {
            var items = (
                              from x in this.Container.InterfaceRepository.Get(string.Empty)
                              join y in this.Container.InterfaceGroupJoinRepository.Get(string.Empty) on x.InterfaceCode equals y.InterfaceCode
                              join z in this.Container.User.InterfaceOptions on x.InterfaceCode equals z.InterfaceCode
                              where (interfaceGroupCode == string.Empty || y.InterfaceGroupCode == interfaceGroupCode)
                                    && (!isLoaderRequired || z.OptionCode == Option.Loader)
                                    && (!isMonitorRequired || z.OptionCode == Option.Monitor)
                                    && (string.IsNullOrEmpty(interfaceTypeCode) || x.InterfaceTypeCode == interfaceTypeCode)
                              orderby x.InterfaceName
                              select new
                              {
                                  x.InterfaceCode,
                                  x.InterfaceName
                              })
                              .Distinct()
                              .Select(x => new SelectListItem {
                                  Text = "(" + x.InterfaceCode + ") " + x.InterfaceName,
                                  Value = x.InterfaceCode,
                                  Selected = x.InterfaceCode == selectedInterfaceCode
                              })
                              .ToList();


            if (withSelectOption)
                items.Insert(0, new SelectListItem { Text = "- select -", Value = string.Empty });

            return items;
        }

        [HttpPost]
        public ActionResult GetInterfaceOptions(string interfaceGroupCode, string interfaceTypeCode, bool isLoaderRequired, bool isMonitorRequired)
        {
            try
            {
                var result = (
                              from x in this.Container.InterfaceRepository.Get(string.Empty)
                              join y in this.Container.InterfaceGroupJoinRepository.Get(string.Empty) on x.InterfaceCode equals y.InterfaceCode
                              join z in this.Container.User.InterfaceOptions on x.InterfaceCode equals z.InterfaceCode
                              where (interfaceGroupCode == string.Empty || y.InterfaceGroupCode == interfaceGroupCode)
                                    && (!isLoaderRequired || z.OptionCode == Option.Loader)
                                    && (!isMonitorRequired || z.OptionCode == Option.Monitor)
                                    && (string.IsNullOrEmpty(interfaceTypeCode) || x.InterfaceTypeCode == interfaceTypeCode)
                              orderby x.InterfaceName
                              select new { DisplayText = "(" + x.InterfaceCode + ") " + x.InterfaceName, Value = x.InterfaceCode }).Distinct();

                return this.Json(new { Result = "OK", Options = result });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        [HttpPost]
        public ActionResult GetInterfaceDetails(string interfaceCode)
        {
            try
            {
                var iface = (from x in this.Container.InterfaceRepository.Get(string.Empty) where x.InterfaceCode == interfaceCode select x).FirstOrDefault();
                
                if (iface == null)
                    throw new Exception("Interface not found");

                if (string.IsNullOrEmpty(iface.FileType))
                    throw new Exception("This interface does not have a file type defined. It cannot be used with this file upload utility.");

                return this.Json(new { Result = "OK", Data = iface });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        #endregion

        #region InterfaceType

        protected List<SelectListItem> GetInterfaceTypes(string selectedInterfaceTypeCode)
        {
            var items = (   from x in this.Container.InterfaceRepository.Get(string.Empty)
                            select x.InterfaceTypeCode
                            )
                            .Distinct()
                            .Select(x => new SelectListItem
                            {
                                Text = x,
                                Value = x,
                                Selected = x == selectedInterfaceTypeCode
                            })
                            .ToList();

            items.Insert(0, new SelectListItem { Text = "ALL Interfaces", Value = string.Empty });

            return items;
        }

        [HttpPost]
        public ActionResult GetInterfaceTypeOptions(bool isLoaderRequired)
        {
            try
            {
                var result = (from x in this.Container.InterfaceRepository.Get(string.Empty)
                              select new { DisplayText = x.InterfaceTypeCode, Value = x.InterfaceTypeCode }).Distinct();

                return this.Json(new { Result = "OK", Options = result });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        #endregion

        #region IcsStatus

        protected List<SelectListItem> GetIcsStatuses(string selectedIcsStatusCode)
        {
            var items = (   from x in this.Container.IcsStatusRepository.Get(string.Empty)
                            select new SelectListItem {
                                Text = x.IcsStatusName,
                                Value = x.IcsStatusCode,
                                Selected = x.IcsStatusCode == selectedIcsStatusCode
                            }).ToList();


            return items;
        }

        [HttpPost]
        public ActionResult GetIcsStatusOptions(bool isLoaderRequired)
        {
            try
            {
                var result = (from x in this.Container.IcsStatusRepository.Get(string.Empty)
                              select new { DisplayText = x.IcsStatusName, Value = x.IcsStatusCode });

                return this.Json(new { Result = "OK", Options = result });
            }
            catch (Exception ex)
            {
                return this.Json(new { Result = "ERROR", Message = ex.ApplicationMessage() });
            }
        }

        #endregion
    }
}
