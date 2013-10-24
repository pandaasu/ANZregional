using System;
using System.Collections.Generic;
using System.Web.Caching;
using System.Linq;
using System.Web;
using System.Threading;
using FlatFileLoaderUtility.Models.Shared;

namespace FlatFileLoaderUtility.Models
{
    /// <summary>
    /// Used to store segment data and keep track of the status of an upload.
    /// It is via this class that the user's controller thread and the worker "uploader" thread
    /// communicate. The references to several of the members must be synchronised with locks to
    /// keep them threadsafe.
    /// </summary>
    public class Status
    {
        #region Constants

        private const string CacheKey = "Status_";

        #endregion

        #region Properties

        public bool IsAllUploaded { get; set; }
        public Thread Thread { get; set; }
        public Exception Exception { get; set; }
        public int Line { get; set; }
        public string ErrorMessage { get; set; }
        public string FileName { get; set; }
        public string InterfaceCode { get; set; }
        public bool IsDone { get; set; }
        public bool IsCancelling { get; set; }
        public int TotalRowCount { get; set; }
        public int CompletedRowCount { get; set; }
        public int InterfaceErrorCount { get; set; }
        public int RowErrorCount { get; set; }
        public long FileSize { get; set; }
        public string LicsStatus { get; set; }
        public int EstimatedSeconds { get; set; }
        public int ReceivedStringLength { get; set; }

        public string EstimatedTime
        {
            get
            {
                return TimeSpan.FromSeconds(this.EstimatedSeconds).ToString();
            }
        }

        private int mUploadId = 0;
        public int UploadId
        {
            get
            {
                lock (mLock)
                    return mUploadId;
            }
            set 
            {
                lock (mLock)
                    mUploadId = value;
            }
        }

        private int mLicsId = 0;
        public int LicsId
        {
            get
            {
                lock (mLock)
                    return mLicsId;
            }
            set
            {
                lock (mLock)
                    mLicsId = value;
            }
        }

        public bool IsError
        {
            get
            {
                lock (mLock)
                    return mIsError;
            }
        }

        private bool mIsError = false;
        private readonly object mLock = new object();
        private List<Segment> Segments { get; set; }

        #endregion

        #region Constructors

        public Status(string interfaceCode, string filename) 
        {
            this.Segments = new List<Segment>();
            this.InterfaceCode = interfaceCode;
            this.FileName = filename;
        }

        #endregion

        #region Instance Methods

        // Packets are deliberately not exposed here as a property.
        // Doing so will cause synchronisation issues because the segment members are not thread-safe.
        // Instead, access via methods in this class

        public void AddSegment(Segment segment, bool isAllUploaded)
        {
            lock (mLock)
            {
                this.Segments.Add(segment);
                this.IsAllUploaded = isAllUploaded;
                this.ReceivedStringLength += segment.Data.Length;
            }
        }

        /// <summary>
        /// Required to support 0 byte files.
        /// </summary>
        public void SetIsAllUploaded()
        {
            lock (mLock)
            {
                this.IsAllUploaded = true;
            }
        }

        /// <summary>
        /// Returns next string to process if there are any unprocessed strings.
        /// Returns empty string if it is waiting for more data to be uploaded.
        /// Returns null if there is no more data expected.
        /// </summary>
        /// <returns></returns>
        public string GetNextData()
        {
            lock (mLock)
            {
                var segment = this.Segments.FirstOrDefault(x => !x.IsProcessed);
                if (segment == null) {
                    return (this.IsAllUploaded) ? null : string.Empty;
                }
                else 
                    return segment.Data;
            }
        }

        public void SetDataProcessed(int lines)
        {
            lock (mLock)
            {
                var segment = this.Segments.FirstOrDefault(x => !x.IsProcessed);
                if (segment != null)
                {
                    segment.IsProcessed = true;
                    segment.Lines = lines;
                    segment.Data = string.Empty; // No need to store it anymore and it's just taking up space.
                }
            }
        }

        public void SetLineSizeError(int line)
        {
            lock (mLock)
            {
                this.mIsError = true;
                this.Line = (from x in this.Segments where x.IsProcessed select x.Lines).Sum() + line;
                this.ErrorMessage = "Line " + this.Line.ToString() + " exceeds 4,000 bytes. Upload cannot proceed.";
            }
        }

        public int GetSegmentCount()
        {
            lock (mLock)
            {
                return this.Segments.Count();
            }
        }

        public int GetReceivedStringLength()
        {
            lock (mLock)
            {
                return this.ReceivedStringLength;
            }
        }

        public int GetSegmentProcessedCount()
        {
            lock (mLock)
            {
                return this.Segments.Where(x => x.IsProcessed).Count();
            }
        }

        #endregion

        #region Static Methods

        public static Status GetOrSetStatus(string username, Connection connection, string interfaceCode, string filename)
        {
            // Status will be stored on a Windows-user basis
            return HttpRuntime.Cache.GetOrStore<Status>(CacheKey + connection.ConnectionId.ToString() + "_" + username, () => new Status(interfaceCode, filename));
        }

        public static Status GetStatus(string username, Connection connection)
        {
            // Status will be stored on a Windows-user basis
            return (Status)HttpRuntime.Cache.Get(CacheKey + connection.ConnectionId.ToString() + "_" + username);
        }

        public static void SetStatus(string username, Connection connection, Status status)
        {
            // Status will be stored on a Windows-user basis
            HttpRuntime.Cache.Insert(CacheKey + connection.ConnectionId.ToString() + "_" + username, status, null, Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(CacheExtensions.DefaultCacheExpiration));
        }

        public static void ClearStatus(string username, Connection connection)
        {
            // Status will be stored on a Windows-user basis
            HttpRuntime.Cache.Remove(CacheKey + connection.ConnectionId.ToString() + "_" + username);
        }

        #endregion
    }
}