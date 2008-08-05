using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace ICS.LICS.UpgradeManager
{
    class IOManager
    {
        private const string SITE_LIST_FILE = "SiteList.txt";
        private const int FILE_TOKEN_COUNT = 7;

        private const int CODE_POS = 0;
        private const int DESC_POS = 1;
        private const int PROD_PASS_POS = 2;
        private const int PROD_DB_POS = 3;
        private const int TEST_PASS_POS = 4;
        private const int TEST_LICS_PASS_POS = 5;
        private const int TEST_DB_POS = 6;

        public IOManager()
        {
            
        }

        public ArrayList LoadSiteList()
        {
            StreamReader stream = null;
            ArrayList result = null;
            Site site = null;

            string line;
            string[] splitList;

            try
            {
                stream = new StreamReader(SITE_LIST_FILE);
                result = new ArrayList();

                while ((line = stream.ReadLine()) != null)
                {
                    splitList = line.Split(new char[] { '~' }, FILE_TOKEN_COUNT);
                    
                    site = new Site(splitList[CODE_POS], splitList[DESC_POS]);
                    site.AddProdDetails(splitList[PROD_DB_POS], splitList[PROD_PASS_POS]);
                    site.AddTestDetails(splitList[TEST_DB_POS], splitList[TEST_PASS_POS], splitList[TEST_LICS_PASS_POS]);

                    result.Add(site);
                }
            }
            finally
            {
                if (stream != null)
                {
                    stream.Close();
                    stream = null;
                }
            }

            return result;
        }

        public void ExtractPathInfo(string path, out string directory, out string fileName)
        {
            directory = string.Empty;
            fileName = string.Empty;

            if (File.Exists(path) == true)
            {
                directory = Path.GetDirectoryName(path);
                fileName = Path.GetFileName(path);
            }
        }

        public string ValidatePath(string path)
        {
            string result = path;

            if (path.EndsWith(@"\") == true)
            {
                result = path.Substring(0, path.Length - 1);
            }

            return result;
        }

        public void GenerateScript(ProjectType type, ArrayList fileList, string installPath, string sourcePath, DatabaseAccess access)
        {
            StringBuilder fileContents = new StringBuilder();
            StreamWriter writer = null;

            string outputFileName = string.Empty;

            fileContents.AppendFormat(@"/******************************************************************/
/* System  : {0}                                                  */
/* Object  : _{1}_build                                           */
/* Author  : Upgrade Manager                                      */
/* Date    : {3}                                                  */
/*                                                                */
/******************************************************************/

/**/
/* Set the echo off
/**/
set echo off;

/**/
/* Set the define character
/**/
set define ^;

/**/
/* Define the work variables
/**/
define dat_path = {4}\{2}
define spl_path = {4}
define database = {5}
define datauser = {1}
define data_password = {6}

/**/
/* Start the spool process
/**/
spool ^spl_path\_{1}_build.log

/**/
/* Compile the tables
/**/
prompt CONNECTING ({0}) ...

connect ^datauser/^data_password@^database

prompt CREATING {0} OBJECTS ...
", (type == ProjectType.Lics ? "LICS" : "LICS_APP")
              , (type == ProjectType.Lics ? "lics" : "lics_app")
              , (type == ProjectType.Lics ? @"LICS\TABLE" : @"LICS_APP\CODE")
              , DateTime.Now.ToString("y")
              , installPath
              , access.Database
              , (type == ProjectType.Lics ? access.LicsPassword : access.Password));

            foreach (string fileName in fileList)
            {
                fileContents.AppendFormat(@"
@^dat_path\{0};", fileName);
            }

            fileContents.Append(@"

/**/
/* Undefine the work variables
/**/
undefine dat_path
undefine spl_path
undefine database
undefine datauser
undefine data_password

/**/
/* Stop the spool process
/**/
spool off;

/**/
/* Set the define character
/**/
set define &;");

            if (type == ProjectType.Lics)
            {
                outputFileName = installPath + @"\_lics_build.sql";
            }
            else
            {
                outputFileName = installPath + @"\_lics_app_build.sql";
            }

            try
            {
                writer = new StreamWriter(outputFileName, false);
                writer.Write(fileContents.ToString());
            }
            finally
            {
                if (writer != null)
                {
                    writer.Close();
                    writer = null;
                }
            }

            this.MoveFiles(type, fileList, installPath, sourcePath);
        }

        private void MoveFiles(ProjectType type, ArrayList fileList, string installPath, string sourcePath)
        {
            string typeDir = string.Empty;
            string typePath = string.Empty;

            string objDir = string.Empty;
            string objPath = string.Empty;

            string sourceFileName = string.Empty;
            string targetFileName = string.Empty;

            if (type == ProjectType.Lics)
            {
                typeDir = "LICS";
                objDir = "TABLE";
            }
            else
            {
                typeDir = "LICS_APP";
                objDir = "CODE";
            }

            typePath = installPath + @"\" + typeDir;
            objPath = typePath + @"\" + objDir;

            if (Directory.Exists(typePath) == false)
            {
                Directory.CreateDirectory(typePath);
            }

            if (Directory.Exists(objPath) == false)
            {
                Directory.CreateDirectory(objPath);
            }

            foreach (string fileName in fileList)
            {
                sourceFileName = sourcePath + @"\" + fileName;
                targetFileName = objPath + @"\" + fileName;

                File.Copy(sourceFileName, targetFileName, true);
            }
        }
    }
}
