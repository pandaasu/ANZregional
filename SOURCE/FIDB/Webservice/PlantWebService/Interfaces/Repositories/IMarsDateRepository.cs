using System;
using System.Collections.Generic;
using System.Linq;
using PlantWebService.Models;
using System.Threading.Tasks;

namespace PlantWebService.Interfaces.Repositories
{
    public interface IMarsDateRepository
    {
        RetrieveMarsCalendarResponse RetrieveMarsCalendar(RetrieveMarsCalendarRequest request);
    }
}
