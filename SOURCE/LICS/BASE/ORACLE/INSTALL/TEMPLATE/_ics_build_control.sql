
Steps to build a new ICS instance
=================================

Copy this script and perform the following scan/replace to localise...

   A. Scan for <SOURCE_PATH> and replace with your local path to the source repository up to but not including \SOURCE (eg. D:\Vivian\LADS\SourceRepository)
   B. Scan for <ICS_FILE_SYSTEM> and replace with the ICS file system path for the installation (eg. /ics/lad/test)
   C. Scan for <DATABASE> and replace with the database name (eg. DB1296T.AP.MARS)
   D. Scan for <LICS_APP_PASSWORD> and replace with the LICS_APP password
   E. Scan for <INSTALLATION> and replace with the installation folder in the source repository (eg. NORTH_ASIA from the path <SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\NORTH_ASIA\TEST)
   F. Scan for <ENVIRONMENT> and replace with the environment folder in the source repository (eg. TEST from the path <SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\NORTH_ASIA\TEST)


1. Create a WO for the DBA with the following...

   1.1. The database setup instructions from ==> _ics_database_setup.txt

   1.2. The following scripts from the repository directory (<SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE)

          lics_db_trigger.sql
          lics_directory.sql

2. DBA creates a new database based on instructions in ==> _ics_database_setup.txt

3. Check that the database has been created as requested...

   3.1. Connect to the database as LICS_APP.

   3.2. Check the java permissions have been created using the statement==> select * from user_java_policy;

        The following rows should be returned...

        GRANT   LICS_APP   SYS   java.io.FilePermission        /bin/chmod            execute                                  ENABLED
	GRANT   LICS_APP   SYS   java.io.FilePermission        <ICS_FILE_SYSTEM>/-   read,write,execute,delete                ENABLED
	GRANT   LICS_APP   SYS   java.lang.RuntimePermission   *                     readFileDescriptor,writeFileDescriptor   ENABLED

   3.3. Check the oracle directories have been created using the statement ==> select * from all_directories;

        The following rows should be returned...

	   ICS_ARCHIVE   <ICS_FILE_SYSTEM>/archive
	   ICS_CONFIG    <ICS_FILE_SYSTEM>/config
	   ICS_BIN       <ICS_FILE_SYSTEM>/bin
	   ICS_VIEW      <ICS_FILE_SYSTEM>/webview
	   ICS_INBOUND   <ICS_FILE_SYSTEM>/inbound
	   ICS_OUTBOUND  <ICS_FILE_SYSTEM>/outbound

   3.4. Check the LICS_APP authority to dbms_pipe using the statement ==> desc dbms_pipe;

        The description of package dbms_pipe should be returned to indicate that the package is available to LICS_APP.

   3.5. Check the LICS_APP authority to dbms_lock using the statement ==> desc dbms_lock;

        The description of package dbms_lock should be returned to indicate that the package is available to LICS_APP.

4. Load the ICS java classes into the LICS_APP schema using the following commands...

      loadjava -f -v -r -u lics_app/<LICS_APP_PASSWORD>@<DATABASE> <SOURCE_PATH>\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cExternalProcess.class
      loadjava -f -v -r -u lics_app/<LICS_APP_PASSWORD>@<DATABASE> <SOURCE_PATH>\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cFileSystem.class

5. Connect as LICS_APP using SQL+ and compile the file system package as follows...

      @<SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE\lics_filesystem.sql;

6. DBA to connect as SYS using SQL+ and compile the following trigger and package scripts sent in 1.2 ...

      @...DBA local path to WO files...\lics_db_trigger.sql;
      @...DBA local path to WO files...\lics_directory.sql;

7. Check that the SYS packages were created correctly...

   7.1. Connect to the database as LICS_APP.

   7.2. Check the LICS_APP authority to lics_directory using the statement ==> desc lics_directory;

        The description of package lics_directory should be returned to indicate that the package has been created and is available to LICS_APP.

8. Compile the LICS schema objects using the script ==> @<SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\<INSTALLATION>\<ENVIRONMENT>\_lics_build.sql

9. Compile the LICS_APP schema objects using the script ==> @<SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\<INSTALLATION>\<ENVIRONMENT>\_lics_app_build.sql


