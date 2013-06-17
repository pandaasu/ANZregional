using System;
using System.Collections.Generic;
using System.Linq;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IUploadRepository
    {
        int Start(string interfaceCode, string fileName);
        void LoadSegment(int uploadId, string interfaceCode, string fileName, int segmentNumber, int segmentSize, int segmentRows, string segmentData);
        void Cancel(int uploadId, string interfaceCode, string fileName);
        void Complete(int uploadId, string interfaceCode, string fileName, int segmentCount, int rowCount);
        void GetUploadStatus(int uploadId, ref Status status);
        void GetLicsStatus(int licsId, ref Status status);
    }
}
