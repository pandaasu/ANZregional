using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using PlantWebService.Models;
using PlantWebService.Data;
using PlantWebService.Data.Repositories;
using PlantWebService.Data.UnitOfWork;
using PlantWebService.Interfaces;
using PlantWebService.Interfaces.Repositories;
using PlantWebService.Interfaces.UnitOfWork;
using PlantWebService.Classes;

namespace PlantWebService
{
    public class FactoryService : IFactoryService
    {
        public RetrieveProcessOrderResponse RetrieveProcessOrder(RetrieveProcessOrderRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.RetrieveProcessOrder(request);
            }
        }

        public RetrieveProcessOrderListResponse RetrieveProcessOrderList(RetrieveProcessOrderListRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.RetrieveProcessOrderList(request);
            }
        }

        public RetrieveMaterialsResponse RetrieveMaterials(RetrieveMaterialsRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var materialRepository = new MaterialRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return materialRepository.RetrieveMaterials(request);
            }
        }

        public RetrieveMaterialBatchListResponse RetrieveMaterialBatchList(RetrieveMaterialBatchListRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var materialRepository = new MaterialRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return materialRepository.RetrieveMaterialBatchList(request);
            }
        }

        public RetrieveFactoryTransfersResponse RetrieveFactoryTransfers(RetrieveFactoryTransfersRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var materialRepository = new MaterialRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return materialRepository.RetrieveFactoryTransfers(request);
            }
        }

        public RetrieveMarsCalendarResponse RetrieveMarsCalendar(RetrieveMarsCalendarRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var marsDateRepository = new MarsDateRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return marsDateRepository.RetrieveMarsCalendar(request);
            }
        }

        public Response AcknowledgeProcessOrder(AcknowledgeProcessOrderRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.Acknowledge(request);
            }
        }

        public Response CreateGRProcessOrder(CreateGRProcessOrderRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CreateGR(request);
            }
        }

        public Response CancelGRProcessOrder(CancelGRProcessOrderRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CancelGR(request);
            }
        }

        public Response CreateConsumption(CreateConsumptionRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CreateConsumption(request);
            }
        }

        public Response CreateStockAdjustment(CreateStockAdjustmentRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CreateStockAdjustment(request);
            }
        }

        public Response LoadStockBalance(LoadStockBalanceRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.LoadStockBalance(request);
            }
        }

        public Response CreateBlend(CreateBlendRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CreateBlend(request);
            }
        }

        public Response CreateScrapMaterial(CreateScrapMaterialRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.CreateScrapMaterial(request);
            }
        }

        public Response StartProcessOrder(StartProcessOrderRequest request)
        {
            var dataContext = new DataContext();
            var unitOfWorkManager = new UnitOfWorkManager(dataContext);
            var processOrderRepository = new ProcessOrderRepository(dataContext);

            using (var unitOfWork = unitOfWorkManager.NewUnitOfWork(false))
            {
                return processOrderRepository.Start(request);
            }
        }
    }
}
