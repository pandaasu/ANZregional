﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net;
using System.ServiceModel;
using PlantWebService.TestSite.ViewModels;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Text;

namespace PlantWebService.TestSite.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Result(ResultViewModel model)
        {
            return View(model);
        }

        public ActionResult RetrieveProcessOrder()
        {
            var viewModel = new RetrieveProcessOrderViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveMaterials(int DisplayTypes, int Modes, string SystemKey, string PlantCode)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveMaterials((FactoryService.RetrieveMode)Modes, PlantCode, SystemKey);

            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }

        public ActionResult RetrieveMaterials()
        {
            var viewModel = new RetrieveMaterialsViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveFactoryTransfers(int DisplayTypes, int Modes, string SystemKey, string BatchCode, string MatlCode)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveFactoryTransfers(BatchCode, MatlCode, (FactoryService.RetrieveMode)Modes, SystemKey);

            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }

        public ActionResult RetrieveFactoryTransfers()
        {
            var viewModel = new RetrieveFactoryTransfersViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveProcessOrder(int DisplayTypes, string SystemKey, string ProcessOrder)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveProcessOrder(ProcessOrder, SystemKey);

            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }

        public ActionResult RetrieveMaterialBatchList()
        {
            var viewModel = new RetrieveMaterialBatchListViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveMaterialBatchList(int DisplayTypes, int Modes, string SystemKey, string MatlCode, string BatchCode)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveMaterialBatchList(BatchCode, MatlCode, (FactoryService.RetrieveMode)Modes, SystemKey);

            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }

        public ActionResult RetrieveMarsCalendar()
        {
            var viewModel = new RetrieveMarsCalendarViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveMarsCalendar(int DisplayTypes, int Modes, string SystemKey, DateTime? Date, int HistoryYears)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveMarsCalendar(Date, HistoryYears, (FactoryService.RetrieveMode)Modes, SystemKey);

            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }

        public ActionResult RetrieveProcessOrderList()
        {
            var viewModel = new RetrieveProcessOrderListViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult RetrieveProcessOrderList(int DisplayTypes, int Modes, string SystemKey)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var result = svc.RetrieveProcessOrderList((FactoryService.RetrieveMode)Modes, SystemKey);


            XmlSerializer xmlSerializer = new XmlSerializer(result.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, result);

                if (DisplayTypes == 1)
                {
                    var model = new ResultViewModel();
                    model.ResultXml = textWriter.ToString();
                    return View("Result", model);
                }
                else
                {
                    this.Response.AddHeader("Content-Disposition", @"attachment; filename=result.xml");

                    return new ContentResult()
                    {
                        ContentEncoding = Encoding.UTF8,
                        ContentType = "application/text",
                        Content = textWriter.ToString()
                    };
                }
            }
        }
    }
}
