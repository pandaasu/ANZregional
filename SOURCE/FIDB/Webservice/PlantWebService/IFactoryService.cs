using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using PlantWebService.Models;
using System.Xml;
using System.Xml.Serialization;
using WCFExtrasPlus;
using WCFExtrasPlus.Soap;

namespace PlantWebService
{
    [ServiceContract(Namespace = "http://www.w3.org/2001/XMLSchema-instance")]
    [SoapHeaders]
    public interface IFactoryService
    {
        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveProcessOrderResponse RetrieveProcessOrder(RetrieveProcessOrderRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveProcessOrderListResponse RetrieveProcessOrderList(RetrieveProcessOrderListRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveMaterialsResponse RetrieveMaterials(RetrieveMaterialsRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveMaterialBatchListResponse RetrieveMaterialBatchList(RetrieveMaterialBatchListRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveFactoryTransfersResponse RetrieveFactoryTransfers(RetrieveFactoryTransfersRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        RetrieveMarsCalendarResponse RetrieveMarsCalendar(RetrieveMarsCalendarRequest request);
        
        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response AcknowledgeProcessOrder(AcknowledgeProcessOrderRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CreateGRProcessOrder(CreateGRProcessOrderRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CancelGRProcessOrder(CancelGRProcessOrderRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CreateConsumption(CreateConsumptionRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CreateStockAdjustment(CreateStockAdjustmentRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response LoadStockBalance(LoadStockBalanceRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CreateBlend(CreateBlendRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response CreateScrapMaterial(CreateScrapMaterialRequest request);

        [XmlSerializerFormat(Style = OperationFormatStyle.Document)]
        [OperationContract]
        Response StartProcessOrder(StartProcessOrderRequest request);
    }
}
