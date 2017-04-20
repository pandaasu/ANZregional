using System;
using System.Collections.Generic;
using System.Linq;
using PlantWebService.Models;
using System.Threading.Tasks;

namespace PlantWebService.Interfaces.Repositories
{
    public interface IMaterialRepository
    {
        RetrieveMaterialsResponse RetrieveMaterials(RetrieveMaterialsRequest request);
        RetrieveMaterialBatchListResponse RetrieveMaterialBatchList(RetrieveMaterialBatchListRequest request);
        RetrieveFactoryTransfersResponse RetrieveFactoryTransfers(RetrieveFactoryTransfersRequest request);
    }
}
