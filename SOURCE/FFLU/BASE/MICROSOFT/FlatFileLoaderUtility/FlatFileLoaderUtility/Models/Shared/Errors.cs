using System;
using System.Linq;
using System.Web;
using System.Text;

namespace FlatFileLoaderUtility.Models.Shared
{
    public static class Errors
    {
        public static void HandleException(this Exception exception, HttpContextBase context) 
        {
            if (context != null && context.Session != null)
                context.Session["exception"] = exception;

            // Do not log errors that occur in the logs class or
            // it could set up an infinite loop
            if (exception.TargetSite.ReflectedType != typeof(Logs))
            {
                try
                {
                    Logs.Log(1, exception.ToString());
                }
                catch
                {
                    // No infinite loops...
                }
            }

            // Do not send errors to support if the error comes from
            // the Mail class or it can create an infinite loop
            if (exception.TargetSite.ReflectedType != typeof(Mail))
            {
                if (Properties.Settings.Default.MailSupport)
                {
                    try
                    {
                        var message = new StringBuilder();
                        message.AppendLine("Hi,");
                        message.AppendLine();
                        message.Append("The following exception occurred in ");
                        message.AppendLine(Properties.Settings.Default.AppName);
                        message.AppendLine();
                        message.AppendLine(exception.ToString());

                        Mail.SendMail(message.ToString(), false);
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            Logs.Log(1, ex.ToString());
                        }
                        catch
                        {
                            // No infinite loops...
                        }
                    }
                }
            }
        }
    }
}