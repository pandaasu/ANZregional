using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using System.Xml;
using System.Xml.Serialization;
using System.ComponentModel;
using System.IO;
using Oracle.ManagedDataAccess.Types;

namespace PlantWebService.Classes
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

        public static int? ToNullableInt(this object o)
        {
            if (o == DBNull.Value)
                return null;

            if (o is OracleDecimal)
            {
                return (int?)(((OracleDecimal)o).ToInt32());
            }
            else
            {
                return Convert.ToInt32(o);
            }
        }

        public static decimal? ToNullableDecimal(this object o)
        {
            if (o == null || o == DBNull.Value)
                return null;

            decimal result;
            bool tryit;

            tryit = decimal.TryParse(o.ToString(), out result);
            if (tryit)
                return result;
            else
                return 0;
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

        public static decimal ZeroInvalidDecimal(object input)
        {
            decimal result;
            bool tryit;
            if (input == null || input == DBNull.Value)
                return 0;

            tryit = decimal.TryParse(input.ToString(), out result);
            if (tryit)
                return result;
            else
                return 0;
        }

        public static decimal? TryDecimal(object input)
        {
            decimal result;
            bool tryit;
            if (input == null || input == DBNull.Value)
                return null;

            tryit = decimal.TryParse(input.ToString(), out result);
            if (tryit)
                return result;
            else
                return null;
        }

        public static long ZeroInvalidLong(object input)
        {
            long result;
            bool tryit;
            if (input == null || input == DBNull.Value)
                return 0;

            tryit = long.TryParse(input.ToString(), out result);
            if (tryit)
                return result;
            else
                return 0;
        }

        public static DateTime? TryDateTime(string input, string format)
        {
            DateTime output;

            var isDateTime = DateTime.TryParseExact(input.Replace("CET", "+01:00"), format, CultureInfo.InvariantCulture, DateTimeStyles.None, out output);

            if (isDateTime)
                return output;
            else
                return null;
        }

        public static bool? TryBoolean(string input)
        {
            bool output;

            var isBoolean = bool.TryParse(input, out output);

            if (isBoolean)
                return output;
            else
                return null;
        }

        public static byte[] ToByteArray(this Stream stream)
        {
            using (stream)
            {
                using (var memStream = new MemoryStream())
                {
                    stream.CopyTo(memStream);
                    return memStream.ToArray();
                }
            }
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

        public static List<T> Sort<T>(this List<T> list, string sorting)
        {
            if (!string.IsNullOrWhiteSpace(sorting))
            {
                try
                {
                    var sortParts = sorting.Split(' ');
                    if (sortParts[0].IndexOf(".") > -1)
                    {
                        if (sortParts.Last() == "ASC")
                            return list.OrderBy(x => GetNestedPropertyValue(sortParts.First(), x)).ToList();
                        else
                            return list.OrderByDescending(x => GetNestedPropertyValue(sortParts.First(), x)).ToList();
                    }
                    else
                    {
                        if (sortParts.Last() == "ASC")
                            return list.OrderBy(x => x.GetType().GetProperty(sortParts.First()).GetValue(x, null)).ToList();
                        else
                            return list.OrderByDescending(x => x.GetType().GetProperty(sortParts.First()).GetValue(x, null)).ToList();
                    }
                }
                catch
                {
                    throw new Exception("Invalid sort descriptor for this object: " + sorting);
                }
            }
            else
            {
                return list;
            }
        }

        public static object GetNestedPropertyValue(string name, object obj)
        {
            foreach (string part in name.Split('.'))
            {
                if (obj == null)
                    return null;

                var type = obj.GetType();
                var info = type.GetProperty(part);
                if (info == null)
                    return null;

                obj = info.GetValue(obj, null);
            }
            return obj;
        }

        public static List<int> MakeListInt(this object o)
        {
            if (!(o is string))
                return new List<int>();

            return Array.ConvertAll<string, int>(((string)o).Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries), new Converter<string, int>(s => Tools.ZeroInvalidInt(s))).ToList<int>();
        }

        public static List<string> MakeList(this string s)
        {
            return s.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
        }

        public static DateTime StartOfWeek(this DateTime dt, DayOfWeek startOfWeek)
        {
            int diff = dt.DayOfWeek - startOfWeek;
            if (diff < 0)
            {
                diff += 7;
            }
            return dt.AddDays(-1 * diff).Date;
        }

        public static DateTime FirstDateOfWeekISO8601(int year, int weekOfYear)
        {
            DateTime jan1 = new DateTime(year, 1, 1);
            int daysOffset = DayOfWeek.Thursday - jan1.DayOfWeek;

            DateTime firstThursday = jan1.AddDays(daysOffset);
            var cal = CultureInfo.CurrentCulture.Calendar;
            int firstWeek = cal.GetWeekOfYear(firstThursday, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);

            var weekNum = weekOfYear;
            if (firstWeek <= 1)
            {
                weekNum -= 1;
            }
            var result = firstThursday.AddDays(weekNum * 7);
            return result.AddDays(-3);
        }
    }
}