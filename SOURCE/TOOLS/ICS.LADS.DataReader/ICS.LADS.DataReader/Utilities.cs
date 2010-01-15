using System;
using System.Collections.Generic;
using System.Text;

namespace ICS.LADS.DataReader
{
    public static class Utilities
    {
        static Utilities()
        {
            // empty constructor
        }

        public static string[] SplitText(string line)
        {
            string[] result = null;

            result = line.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            return result;
        }

        public static string GetStringInQuotes(string text)
        {
            string result = string.Empty;
            int startPos = 0;
            int endPos = 0;

            startPos = text.IndexOf("'");
            endPos = text.IndexOf("'", startPos+1);

            if (startPos >= 0 && endPos >= 0)
            {
                result = text.Substring(startPos+1, endPos - startPos - 1);
            }

            return result;
        }

        public static int GetLength(string text)
        {
            string result = string.Empty;
            int endPos = 0;
            int length = 0;

            endPos = text.IndexOf(")");

            if (endPos >= 0)
            {
                result = text.Substring(0, endPos);
                length = Convert.ToInt32(result);
            }

            return length;
        }

        public static string GetContentTableType(string line)
        {
            string result = string.Empty;

            if (line != null && line.Length >= 3)
            {
                result = line.Substring(0, 3);
            }

            return result;
        }
    }
}
