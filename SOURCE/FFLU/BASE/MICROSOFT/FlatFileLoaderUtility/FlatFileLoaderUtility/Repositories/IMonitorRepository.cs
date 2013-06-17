using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IMonitorRepository
    {
        List<Monitor> Load(string interfaceGroupCode, string interfaceTypeCode, string interfaceCode, int? licsId, string icsStatusCode, DateTime? startDate, DateTime? endDate, int startIndex, int pageSize, ref int total);
        List<Monitor> GetTraceHistory(int licsId);
        List<IcsError> GetInterfaceErrors(int licsId, int traceId);
        List<IcsRowData> RowDataLoad(int licsId, int traceId, bool isErrorRowsOnly, int startIndex, int pageSize);
    }
}
