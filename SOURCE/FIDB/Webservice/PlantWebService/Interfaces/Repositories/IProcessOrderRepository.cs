using System;
using System.Collections.Generic;
using System.Linq;
using PlantWebService.Models;
using System.Threading.Tasks;

namespace PlantWebService.Interfaces.Repositories
{
    public interface IProcessOrderRepository
    {
        RetrieveProcessOrderListResponse RetrieveProcessOrderList(RetrieveProcessOrderListRequest request);
        RetrieveProcessOrderResponse RetrieveProcessOrder(RetrieveProcessOrderRequest request);
        Response CreateGR(CreateGRProcessOrderRequest request);
        Response Acknowledge(AcknowledgeProcessOrderRequest request);
        Response CancelGR(CancelGRProcessOrderRequest request);
        Response CreateConsumption(CreateConsumptionRequest request);
        Response CreateStockAdjustment(CreateStockAdjustmentRequest request);
        Response LoadStockBalance(LoadStockBalanceRequest request);
        Response CreateBlend(CreateBlendRequest request);
        Response CreateScrapMaterial(CreateScrapMaterialRequest request);
        Response Start(StartProcessOrderRequest request);
    }
}
