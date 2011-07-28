
Steps to create a new ICS instance
==================================


1. Create a WO for the DBA with the following...

   1.1. The database setup instructions from ==> _ics_database_setup.txt

   1.2. The following scripts from the repository directory (D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE)

          lics_db_trigger.sql
          lics_directory.sql

2. DBA creates a new database based on instructions in ==> _ics_database_setup.txt

3. Check that the database has been created as requested...

   3.1. Connect to the database as LICS_APP.

   3.2. Check the java permissions have been created using the statement ==> select * from user_java_policy;

        The following rows should be returned...

        GRANT   LICS_APP   SYS   java.io.FilePermission        /bin/chmod        execute                                  ENABLED
	GRANT   LICS_APP   SYS   java.io.FilePermission        /ics/lad/test/-   read,write,execute,delete                ENABLED
	GRANT   LICS_APP   SYS   java.lang.RuntimePermission   *                 readFileDescriptor,writeFileDescriptor   ENABLED

   3.3. Check the oracle directories have been created using the statement ==> select * from all_directories;

        The following rows should be returned...

	   ICS_ARCHIVE   /ics/lad/test/archive
	   ICS_CONFIG    /ics/lad/test/config
	   ICS_BIN       /ics/lad/test/bin
	   ICS_VIEW      /ics/lad/test/webview
	   ICS_INBOUND   /ics/lad/test/inbound
	   ICS_OUTBOUND  /ics/lad/test/outbound

   3.4. Check the LICS_APP authority to dbms_pipe using the statement ==> desc dbms_pipe;

        The following data should be returned...

           CREATE_PIPE (FUNCTION)

   3.5. Check the LICS_APP authority to dbms_lock using the statement ==> desc dbms_lock;

        The following data should be returned...

           ALLOCATE_UNIQUE

4. Load the ICS java classes into the LICS_APP schema using the following commands...

      loadjava -f -v -r -u lics_app/kwi9s92a@db1296t.ap.mars D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cExternalProcess.class
      loadjava -f -v -r -u lics_app/kwi9s92a@db1296t.ap.mars D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cFileSystem.class

5. Connect as LICS_APP using SQL+ and compile the file system package as follows...

      @D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE\lics_filesystem.sql;

6. DBA to connect as SYS using SQL+ and compile the following trigger and package scripts send in 1.2 ...

      @dba_pc_local_path\lics_db_trigger.sql;
      @dba_pc_local_path\lics_directory.sql;

7. Check that the SYS packages were created correctly...

   7.1. Check the LICS_APP authority to lics_directory using the statement ==> desc lics_directory;

        The following data should be returned...

           CREATE_DIRECTORY

8. Compile the LICS schema objects using the script ==> _lics_build.sql

9. Compile the LICS_APP schema objects using the script ==> _lics_app_build.sql


