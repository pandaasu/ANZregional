using System;
using System.Linq;
using System.Web;
using System.Net;
using System.Net.Mail;

namespace FlatFileLoaderUtility.Models.Shared
{
    /// <summary>
    /// Mail.cs
    /// 
    /// This static class handles the sending of mail for the app. Settings used by this class:
    /// 
    /// SmtpHost - the SMTP host used to send the mail.
    /// 
    /// SmtpUsername - the username required when connecting to the SmtpHost.
    /// 
    /// SmtpPassword - the password required when connecting to the SmtpHost.
    /// 
    /// MailTo - A semicolon (;) separated list of e-mail addresses that will
    /// form the To field for the emails.
    /// 
    /// MailCC - A semicolon (;) separated list of e-mail addresses that will
    /// form the CC field for the emails.
    /// 
    /// MailSupport - Whether or not e-mails will be sent at all.
    /// 
    /// AppName - The application name, used here in the mail subject.
    /// 
    /// </summary>
    public static class Mail
    {
        /// <summary>
        /// Sends the provided message via e-mail according to the configuration options.
        /// </summary>
        /// <param name="message">The message to send</param>
        /// <param name="propagateException">True to throw exceptions, false to ingore exceptions</param>
        /// <returns></returns>
        public static bool SendMail(string message, bool propagateException)
        {
            return SendMail(message, false, propagateException);
        }

        /// <summary>
        /// Sends the provided message via e-mail with attachment according to the configuration options.
        /// </summary>
        /// <param name="message">The message to send</param>
        /// <param name="attachmentFilename">The filename of the attachment to include</param>
        /// <param name="propagateException">True to throw exceptions, false to ignore exceptions</param>
        /// <returns></returns>
        public static bool SendMail(string message, bool sendAttachment, bool propagateException)
        {
            try
            {
                if (!Properties.Settings.Default.MailSupport)
                    return false;

                using (var mail = new MailMessage())
                    using (var smtp = new SmtpClient())
                    {
                        // Configure the smpt client
                        smtp.Host = Properties.Settings.Default.SmtpHost;

                        if (Properties.Settings.Default.SmtpUsername != String.Empty)
                        {
                            smtp.Credentials = new NetworkCredential(
                                Properties.Settings.Default.SmtpUsername,
                                Properties.Settings.Default.SmtpPassword);
                        }

                        // Configure the mail
                        mail.Subject = Properties.Settings.Default.AppName + " " + Environment.MachineName + " Message";
                        mail.From = new MailAddress(Properties.Settings.Default.AppName + "@" + Environment.MachineName);
                        mail.Body = message;
                        mail.IsBodyHtml = false;

                        // Add recipients
                        if (Properties.Settings.Default.MailTo != String.Empty)
                        {
                            string[] mailTo = Properties.Settings.Default.MailTo.Split(';');
                            for (int i = 0; i < mailTo.Length; i++)
                            {
                                mail.To.Add(new MailAddress(mailTo[i]));
                            }
                        }

                        // Add CC recipients
                        if (Properties.Settings.Default.MailCC != String.Empty)
                        {
                            string[] mailCC = Properties.Settings.Default.MailCC.Split(';');
                            for (int i = 0; i < mailCC.Length; i++)
                            {
                                mail.CC.Add(new MailAddress(mailCC[i]));
                            }
                        }

                        // Add attachment
                        // Separate the send method this way so that locking
                        // can be implemented on the attachment if one is to be sent
                        if (sendAttachment)
                        {
                            string filename = DateTime.Now.ToString("yyyy_MM_dd") + ".log";
                            string path = Properties.Settings.Default.LoggingPath;

                            // Support relative paths and full paths
                            if (!path.Contains(":"))
                                path = HttpRuntime.AppDomainAppPath + @"\" + path;

                            lock (Logs.logLock)
                            {
                                using (Attachment attachment = new Attachment(path + filename))
                                {
                                    attachment.Name = filename;
                                    attachment.ContentDisposition.Inline = false;
                                    mail.Attachments.Add(attachment);

                                    // Send the mail
                                    smtp.Send(mail);
                                }
                            }
                        }
                        else
                        {
                            // Send the mail
                            smtp.Send(mail);
                        }

                        return true;
                    }
            }
            catch (Exception ex)
            {
                // Make sure that any exceptions occurring here are sent to the
                // global error handler with the correct TargetSite type, to avoid
                // an infinite loop that would happen if the exception occurred
                // in another module called from here (eg System.Net.Mail)
                // But at the same time don't propagate errors that come from the
                // global error handler.
                if (propagateException)
                    throw ex;
                return false;
            }
        }
    }
}