using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace ICS.LogReader
{
    class Utilities
    {
        public static bool ContainsText(string line, string checkString)
        {
            return line.Contains(checkString);
        }

        public static bool ValidateFile(string path)
        {
            if (File.Exists(path) == false)
            {
                System.Windows.Forms.MessageBox.Show("File not found!");     

                return false;
            }
            else
            {
                return true;
            }
        }

        public static bool ArrayIsEmpty(object[] array)
        {
            return (array == null || array.Length == 0);
        }

        public static bool StringIsEmpty(string line)
        {
            return (line == null || line.Length == 0);
        }

        public static DateTime GetDate(string line)
        {
            string year = string.Empty;
            string month = string.Empty;
            string day = string.Empty;
            string hour = string.Empty;
            string minute = string.Empty;
            string second = string.Empty;

            for (int i = 1; i <= 20; i++)
            {
                if (i > 0 && i < 5)
                {
                    year += line[i];
                }
                else if (i > 5 && i < 8)
                {
                    month += line[i];
                }
                else if (i > 8 && i < 11)
                {
                    day += line[i];
                }
                else if (i > 11 && i < 14)
                {
                    hour += line[i];
                }
                else if (i > 14 && i < 17)
                {
                    minute += line[i];
                }
                else if (i > 17 && i < 20)
                {
                    second += line[i];
                }
            }

            try
            {
                return new DateTime(Convert.ToInt32(year)
                    , Convert.ToInt32(month)
                    , Convert.ToInt32(day)
                    , Convert.ToInt32(hour)
                    , Convert.ToInt32(minute)
                    , Convert.ToInt32(second));
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(ex.ToString());

                return DateTime.MinValue;
            }
        }

        public static int GetProcessId(string line)
        {
            int startPos = -1;
            int endPos = -1;

            int result = -1;

            try
            {
                startPos = line.IndexOf('[', 1, line.Length - 1);

                if (startPos > 0)
                {
                    endPos = line.IndexOf(']', startPos, line.Length - startPos - 1);

                    if (startPos > 0 && endPos > startPos)
                    {
                        startPos++;
                        result = Convert.ToInt32(line.Substring(startPos, endPos - startPos));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(ex.ToString());
            }

            return result;
        }
    }
}