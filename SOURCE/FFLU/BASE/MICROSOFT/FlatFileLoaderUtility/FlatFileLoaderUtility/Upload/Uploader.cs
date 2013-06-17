using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Threading;
using FlatFileLoaderUtility.Models;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Repositories;
using FlatFileLoaderUtility.Repositories.DataAccess;

namespace FlatFileLoaderUtility.Upload
{
    /// <summary>
    /// Class used to manage the upload of the file data from the status list to the database.
    /// It runs in a separate thread.
    /// </summary>
    public class Uploader
    {
        #region properties

        public RepositoryContainer Container { get; set; }
        public Status Status { get; set; }
        
        #endregion

        #region constructor

        public Uploader(Connection connection, Access access, User user)
        {
            this.Container = new RepositoryContainer();
            this.Container.Connection = connection;
            this.Container.Access = access;
            this.Container.User = user;
        }

        #endregion

        #region methods

        public void Upload()
        {
            try
            {
                // The uploader does 3 things:
                // 1) Initiate the upload process
                // 2) Upload the segments until there are no more segments to upload
                // 3) Finalise the upload process

                var encoding = Encoding.UTF8;
                var segmentCount = 0;
                var idleCounter = 0;

                if (this.Status.IsDone)
                    return;

                // Initiate the upload process
                if (this.Status.UploadId == 0)
                    this.Status.UploadId = this.Container.UploadRepository.Start(this.Status.InterfaceCode, this.Status.FileName);

                while (true)
                {
                    if (this.Status.IsCancelling)
                        return;

                    var data = this.Status.GetNextData();

                    // If the data is null, there are no more data packets to upload
                    if (data == null)
                        break;

                    // If the data is an empty string, the client is still uploading packets but they are not yet available
                    if (data == string.Empty)
                    {
                        Thread.Sleep(2000);

                        // It is possible that the client stopped the upload by just closing their browser
                        // And we don't want this thread to run forever...
                        // Give it 5 minutes of being idle before terminating the thread.
                        // The UploadController will re-start the thread if necessary
                        idleCounter++;

                        // 150 * 2s = 5 minutes
                        if (idleCounter >= 150)
                            return; // Not break! We do not want to complete or cancel the upload, just stop the thread from waiting forever.
                    }
                    else
                    {
                        // Reset the idle counter
                        idleCounter = 0;

                        // The data needs to be sanitised by removing char 13
                        data = data.Replace("\r", string.Empty);

                        // Each line must end with a newline character
                        if (data.Last().ToString() != "\n")
                            data += "\n";

                        // The length of any row cannot exceed 4,000 *bytes*
                        var lines = data.Split(new char[] { '\n' });
                        var isSafeToUpload = true;
                        var errorLine = 0;
                        var lineCount = lines.Length - 1;

                        // Deliberately do not use the last item in the array
                        // The split methods above must preserve empty lines
                        // But the string has to end on a newline character
                        // Which means there will always be an unwanted empty
                        // line at the last position in the array.
                        for (var i = 0; i < lineCount; i++)
                        {
                            var line = lines[i];
                            errorLine++;

                            var byteCount = encoding.GetByteCount(line);

                            // Note that the 4000 characters has to include the newline character, which has been removed when splitting into lines
                            // So if the byte count equals 4000 then it has still exceeded 4000 characters
                            if (byteCount >= 4000)
                            {
                                // A line has been detected that is too long to process. It is not safe to upload.
                                isSafeToUpload = false;
                                break;
                            }
                        }

                        if (isSafeToUpload)
                        {
                            segmentCount++;

                            this.Container.UploadRepository.LoadSegment(
                                this.Status.UploadId,
                                this.Status.InterfaceCode,
                                this.Status.FileName,
                                segmentCount,
                                encoding.GetByteCount(data),
                                lineCount,
                                data);

                            this.Status.TotalRowCount += lineCount;
                            this.Status.SetDataProcessed(lineCount);
                        }
                        else
                        {
                            // Notify the client
                            this.Status.SetLineSizeError(errorLine);
                            break;
                        }
                    }
                }

                if (!this.Status.IsError)
                {
                    // Finalise the upload process
                    this.Container.UploadRepository.Complete(
                        this.Status.UploadId,
                        this.Status.InterfaceCode,
                        this.Status.FileName,
                        this.Status.GetSegmentCount(),
                        this.Status.TotalRowCount);
                }
                else
                {
                    // Cancel the upload
                    this.Container.UploadRepository.Cancel(
                        this.Status.UploadId,
                        this.Status.InterfaceCode,
                        this.Status.FileName);
                }

                this.Status.IsDone = true;
            }
            catch (Exception ex)
            {
                Logs.Log(1, ex.ToString());
                this.Status.Exception = ex;
                this.Status.ErrorMessage = ex.ApplicationMessage();
            }
        }

        #endregion
    }
}