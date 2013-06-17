using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using System.Xml;
using System.Xml.Serialization;
using System.ComponentModel;

namespace FlatFileLoaderUtility.Models.Shared
{
    public static class Tools
    {
        public static object ToSqlNullable<T>(this object o) where T : struct
        {
            if (o == null)
                return DBNull.Value;
            else
                return o;
        }

        public static object ToSqlNullable(this string o)
        {
            if (string.IsNullOrWhiteSpace(o))
                return DBNull.Value;
            else
                return o;
        }

        public static object ToSqlNullable(this string o, string nullStart)
        {
            if (string.IsNullOrWhiteSpace(o) || o.StartsWith(nullStart))
                return DBNull.Value;
            else
                return o;
        }

        public static Nullable<T> ToNullable<T>(this object o) where T : struct
        {
            if (o == DBNull.Value)
                return null;

            if (o is string && string.IsNullOrWhiteSpace((string)o))
                return null;
            
            var converter = TypeDescriptor.GetConverter(typeof(T?));
            return (T?)converter.ConvertFrom(o);
        }

        public static int ZeroInvalidInt(object input)
        {
            int result;
            bool tryit;
            if (input == null || input == DBNull.Value)
                return 0;

            tryit = int.TryParse(input.ToString(), out result);
            if (tryit)
                return result;
            else
                return 0;
        }

        public static int? ToNullableInt(object input)
        {
            int result;
            bool tryit;
            if (input == null || input == DBNull.Value)
                return null;

            tryit = int.TryParse(input.ToString(), out result);
            if (tryit)
                return result;
            else
                return null;
        }

        public static DateTime? TryDateTime(string input, string format)
        {
            DateTime output;

            var isDateTime = DateTime.TryParseExact(input, format, CultureInfo.InvariantCulture, DateTimeStyles.None, out output);

            if (isDateTime)
                return output;
            else
                return null;
        }

        /// <summary>
        /// Given an list of objects, serialises the list into an XML document
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="RootAttribute"></param>
        /// <param name="objects"></param>
        /// <returns></returns>
        public static XmlDocument GetEntityXml<T>(string rootAttribute, List<T> objects)
        {
            var xmlDoc = new XmlDocument();
            var nav = xmlDoc.CreateNavigator();

            using (var writer = nav.AppendChild())
            {
                var ser = new XmlSerializer(typeof(List<T>), new XmlRootAttribute(rootAttribute));
                ser.Serialize(writer, objects);
            }
            return xmlDoc;
        }

        public static string ApplicationMessage(this Exception ex)
        {
            if (ex.Message.IndexOf("ORA-200", StringComparison.InvariantCultureIgnoreCase) > -1)
            {
                var message = ex.Message.Substring(ex.Message.IndexOf(": ") + 2);
                if (message.IndexOf("ORA-", StringComparison.InvariantCultureIgnoreCase) > -1)
                {
                    message = message.Substring(0, message.IndexOf("ORA-", StringComparison.InvariantCultureIgnoreCase));
                }
                return message.Trim();
            }
            else
            {
                return ex.Message;
            }
        }
    }
}