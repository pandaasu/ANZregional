using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net;
using System.ServiceModel;
using PlantWebService.TestSite.ViewModels;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Text;
using PlantWebService.TestSite.Classes;

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

        public ActionResult AcknowledgeProcessOrder()
        {
            var viewModel = new AcknowledgeProcessOrderViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult AcknowledgeProcessOrder(int DisplayTypes, string SystemKey, string ProcessOrder, string Processed, string Message)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var request = new FactoryService.AcknowledgeProcessOrderRequest();
            request.SystemKey = SystemKey;
            request.Message = Message;
            request.Processed = Processed == "Y";
            request.ProcessOrder = ProcessOrder;

            var result = svc.AcknowledgeProcessOrder(request);

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
        
        public ActionResult CreateGRProcessOrder()
        {
            var viewModel = new CreateGRProcessOrderViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult CreateGRProcessOrder(int DisplayTypes, string SystemKey, string ProcessOrder, string PlantCode, string MaterialCode, string UserID, string SenderName, string TransactionDate, string BatchCode, string BatchStatus, string UseByDate, string PalletCode, decimal Quantity, string FullPallet, string LastGRFlag, string PalletType, string StartDate, string EndDate)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.ID = new FactoryService.IdentifierType()
            {
                Value = ProcessOrder
            };
            productionPerformance.Description = new FactoryService.DescriptionType[1];
            productionPerformance.Description[0] = new FactoryService.DescriptionType()
            {
                Value = SenderName
            };
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionScheduleID = new FactoryService.ProductionScheduleIDType()
            {
                Value = ProcessOrder
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = ProcessOrder
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = ProcessOrder
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData = new FactoryService.ProductionDataType[2];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[0] = new FactoryService.ProductionDataType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "USER_ID"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = UserID ?? ""
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[1] = new FactoryService.ProductionDataType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "SENDER_NAME"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[1].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = SenderName
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                MaterialUse = new FactoryService.MaterialUseType(),
                Quantity = new FactoryService.QuantityValueType[1],
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[8]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialUse = new FactoryService.MaterialUseType()
            {
                Value = "Produced"
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = "kg"
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "BATCH_STATUS"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = BatchStatus
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[1] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "EXPIRY_DATE"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[1].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = UseByDate
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "DateTime"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[2] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "SSCC_NUMBER"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[2].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = PalletCode
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[3] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "FULL_PALLET"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[3].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = FullPallet == "Y" ? "true" : "false"
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "boolean"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[4] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "LAST_PROCESS_ORDER_GOODS_RECEIPT"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[4].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = LastGRFlag == "Y" ? "true" : "false" 
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "boolean"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[5] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "PALLET_TYPE"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[5].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = PalletType
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[6] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "PALLET_START_DT"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[6].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = StartDate
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "DateTime"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[7] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "PALLET_END_DT"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[7].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = EndDate
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "DateTime"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };

            var request = new FactoryService.CreateGRProcessOrderRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CreateGRProcessOrder(request);
            
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

        public ActionResult CancelGRProcessOrder()
        {
            var viewModel = new CancelGRProcessOrderViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult CancelGRProcessOrder(int DisplayTypes, string SystemKey, string UserID, string SenderName, string TransactionDate, string PalletCode)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.Description = new FactoryService.DescriptionType[1];
            productionPerformance.Description[0] = new FactoryService.DescriptionType()
            {
                Value = SenderName
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData = new FactoryService.ProductionDataType[2];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[0] = new FactoryService.ProductionDataType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "USER_ID"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = UserID ?? ""
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[1] = new FactoryService.ProductionDataType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "SENDER_NAME"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData[1].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = SenderName
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "SSCC_NUMBER"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = PalletCode
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };

            var request = new FactoryService.CancelGRProcessOrderRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CancelGRProcessOrder(request);

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

        public ActionResult CreateConsumption()
        {
            var viewModel = new CreateConsumptionViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult CreateConsumption(int DisplayTypes, string SystemKey, string ProcessOrder, string PlantCode, string MaterialCode, string TransactionID, string TransactionDate, string BatchCode, decimal Quantity)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.ID = new FactoryService.IdentifierType()
            {
                Value = ProcessOrder
            };
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionScheduleID = new FactoryService.ProductionScheduleIDType()
            {
                Value = ProcessOrder
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = ProcessOrder
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = ProcessOrder
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                Quantity = new FactoryService.QuantityValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = "kg"
                }
            };
            productionPerformance.Any = new FactoryService.AnyType[1];
            productionPerformance.Any[0] = new FactoryService.AnyType();
            productionPerformance.Any[0].Any = new XmlElement[1];
            productionPerformance.Any[0].Any[0] = Tools.GetElement(string.Format(@"<EIG>EVENT_ID={0}</EIG>", TransactionID));

            var request = new FactoryService.CreateConsumptionRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CreateConsumption(request);

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

        [HttpPost]
        public ActionResult CreateStockAdjustment(int DisplayTypes, string SystemKey, string Uom, string ExpiryDate, string StorageLocation, string MovementCode, string PlantCode, string MaterialCode, string TransactionDate, string BatchCode, decimal Quantity)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.ID = new FactoryService.IdentifierType()
            {
                Value = MovementCode
            };
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                Quantity = new FactoryService.QuantityValueType[1],
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[1],
                Location = new FactoryService.LocationType()
                {
                    EquipmentID = new FactoryService.EquipmentIDType()
                    {
                        Value = StorageLocation
                    }
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = Uom ?? "kg"
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "EXPIRY_DATE"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = ExpiryDate
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "DateTime"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };
            

            var request = new FactoryService.CreateStockAdjustmentRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CreateStockAdjustment(request);

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

        public ActionResult CreateStockAdjustment()
        {
            var viewModel = new CreateStockAdjustmentViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult CreateBlend(int DisplayTypes, string SystemKey, string Uom, string ExpiryDate, string StorageLocation, string MovementCode, string PlantCode, string MaterialCode, string TransactionDate, string BatchCode, decimal Quantity)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.ID = new FactoryService.IdentifierType()
            {
                Value = MovementCode
            };
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                Quantity = new FactoryService.QuantityValueType[1],
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[1],
                Location = new FactoryService.LocationType()
                {
                    EquipmentID = new FactoryService.EquipmentIDType()
                    {
                        Value = StorageLocation
                    }
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = Uom ?? "kg"
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "EXPIRY_DATE"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = ExpiryDate
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "DateTime"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };


            var request = new FactoryService.CreateBlendRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CreateBlend(request);

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

        public ActionResult CreateBlend()
        {
            var viewModel = new CreateBlendViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult CreateScrapMaterial(int DisplayTypes, string SystemKey, string Uom, string StorageLocation, string ReasonCode, string PlantCode, string MaterialCode, string TransactionDate, string BatchCode, decimal Quantity)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                Quantity = new FactoryService.QuantityValueType[1],
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[1],
                Location = new FactoryService.LocationType()
                {
                    EquipmentID = new FactoryService.EquipmentIDType()
                    {
                        Value = StorageLocation
                    }
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = Uom ?? "kg"
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0] = new FactoryService.MaterialActualPropertyType()
            {
                ID = new FactoryService.IdentifierType()
                {
                    Value = "REASON_CODE"
                },
                Value = new FactoryService.ValueType[1]
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty[0].Value[0] = new FactoryService.ValueType()
            {
                ValueString = new FactoryService.ValueStringType()
                {
                    Value = ReasonCode
                },
                DataType = new FactoryService.DataTypeType()
                {
                    Value = "string"
                },
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
            };


            var request = new FactoryService.CreateScrapMaterialRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.CreateScrapMaterial(request);

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

        public ActionResult CreateScrapMaterial()
        {
            var viewModel = new CreateScrapMaterialViewModel();

            return View(viewModel);
        }

        public ActionResult StartProcessOrder()
        {
            var viewModel = new StartProcessOrderViewModel();

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult StartProcessOrder(int DisplayTypes, string SystemKey, string ProcessOrder, string FlocCode)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.ID = new FactoryService.IdentifierType()
            {
                Value = ProcessOrder
            };
            productionPerformance.ProductionScheduleID = new FactoryService.ProductionScheduleIDType()
            {
                Value = FlocCode
            };

            var request = new FactoryService.StartProcessOrderRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.StartProcessOrder(request);

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

        [HttpPost]
        public ActionResult LoadStockBalance(int DisplayTypes, string SystemKey, string StorageLocation, string PlantCode, string MaterialCode, string TransactionDate, string BatchCode, decimal Quantity)
        {
            var binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferSize = 2147483647;

            var txDate = Tools.TryDateTime(TransactionDate, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

            var endpoint = new EndpointAddress(Properties.Settings.Default.ServiceURL);
            var svc = new FactoryService.FactoryServiceClient(binding, endpoint);

            var productionPerformance = new FactoryService.ProductionPerformanceType();
            productionPerformance.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = "101122106"
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Site"
                }
            };
            productionPerformance.Location.Location = new FactoryService.LocationType()
            {
                EquipmentID = new FactoryService.EquipmentIDType()
                {
                    Value = PlantCode
                },
                EquipmentElementLevel = new FactoryService.EquipmentElementLevelType()
                {
                    Value = "Area"
                }
            };
            productionPerformance.PublishedDate = new FactoryService.PublishedDateType()
            {
                Value = txDate ?? DateTime.Now
            };
            productionPerformance.ProductionResponse = new FactoryService.ProductionResponseType[1];
            productionPerformance.ProductionResponse[0] = new FactoryService.ProductionResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse = new FactoryService.SegmentResponseType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0] = new FactoryService.SegmentResponseType();
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual = new FactoryService.MaterialActualType[1];
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0] = new FactoryService.MaterialActualType()
            {
                MaterialDefinitionID = new FactoryService.MaterialDefinitionIDType[1],
                MaterialLotID = new FactoryService.MaterialLotIDType[1],
                MaterialSubLotID = new FactoryService.MaterialSubLotIDType[1],
                Quantity = new FactoryService.QuantityValueType[1],
                MaterialActualProperty = new FactoryService.MaterialActualPropertyType[1],
                Location = new FactoryService.LocationType()
                {
                    EquipmentID = new FactoryService.EquipmentIDType()
                    {
                        Value = StorageLocation
                    }
                }
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0] = new FactoryService.MaterialDefinitionIDType()
            {
                Value = MaterialCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0] = new FactoryService.MaterialLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialSubLotID[0] = new FactoryService.MaterialSubLotIDType()
            {
                Value = BatchCode
            };
            productionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0] = new FactoryService.QuantityValueType()
            {
                QuantityString = new FactoryService.QuantityStringType()
                {
                    Value = Quantity.ToString()
                },
                DataType = new FactoryService.DataTypeType(),
                UnitOfMeasure = new FactoryService.UnitOfMeasureType()
                {
                    Value = "kg"
                }
            };

            var request = new FactoryService.LoadStockBalanceRequest();
            request.SystemKey = SystemKey;
            request.ProductionPerformance = productionPerformance;

            var result = svc.LoadStockBalance(request);

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

        public ActionResult LoadStockBalance()
        {
            var viewModel = new LoadStockBalanceViewModel();

            return View(viewModel);
        }
    }
}
