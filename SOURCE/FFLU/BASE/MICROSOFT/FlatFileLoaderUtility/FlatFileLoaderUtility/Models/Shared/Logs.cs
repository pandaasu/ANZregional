using System;
using System.Linq;
using System.Web;
using System.IO;

namespace FlatFileLoaderUtility.Models.Shared
{
    /// <summary>
    /// This static class handles the application logging.
    /// </summary>
    public static class Logs
    {
        /// <summary>
        /// The locks hashtable needs to be public so that it can be accessed
        /// from the mail class. This is required so that the mail class can 
        /// send log files as attachments, otherwise an exception could be 
        /// generated when sending an exception email!
        /// </summary>
        public static object logLock = new object();

        /// <summary>
        /// Logs the provided message.
        /// </summary>
        /// <param name="logLevel">The logging level: 1-5. 1 being most important.</param>
        /// <param name="message">The message to log</param>
        public static void Log(int logLevel, string message)
        {
            Log(logLevel, message, true);
        }

        /// <summary>
        /// Logs the provided message.
        /// </summary>
        /// <param name="logLevel">The logging level: 1-5. 1 being most important.</param>
        /// <param name="message">The message to log</param>
        /// <param name="propagateException">True to throw any exceptions generated, false to ignore exceptions</param>
        public static void Log(int logLevel, string message, bool propagateException)
        {
            try
            {
                // Check if Logging Required
                if (logLevel > Properties.Settings.Default.LoggingLevel)
                    return;

                string filename = DateTime.Now.ToString("yyyy_MM_dd") + ".log";
                string path = Properties.Settings.Default.LoggingPath;
                char[] trimChars = { '\\' };

                // Support relative paths and full paths
                if (!path.Contains(":"))
                    path = HttpRuntime.AppDomainAppPath.Trim(trimChars) + @"\" + path;

                lock (logLock)
                {
                    // Write the message to the log file
                    using (StreamWriter writer = new StreamWriter(path + filename, true))
                    {
                        writer.Write(DateTime.Now.ToString(Properties.Settings.Default.DateTimeFormatLong));
                        for (int i = 0; i < logLevel; i++)
                            writer.Write("   ");
                        writer.WriteLine(message);
                    }
                }
            }
            catch (Exception ex)
            {
                // Make sure that any exceptions occurring here are sent to the
                // global error handler with the correct TargetSite type, to avoid
                // an infinite loop that would happen if the exception occurred
                // in another module called from here (eg System.IO.TextWriter)
                // But at the same time don't propagate errors that come from the
                // global error handler. Also, it is possible that access errors
                // could occur here (eg, if the logfile is being downloaded via FTP
                // at the time. Such errors should not be propagated.
                bool isAccessError = false;

                if (ex.Message.ToLower().IndexOf("access") > -1)
                    isAccessError = true;

                if (propagateException && !isAccessError)
                    throw ex;
            }
        }
    }
}