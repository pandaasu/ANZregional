
Please create the following a new database on [server name] ...

   [database name] - ICS (Interface Control System) [devp/test/prod] Environment

   **DATABASE NOTES** 

   1. Database should be new empty databases NOT a copy of an existing database.
   2. Database to be Oracle 9i.
   3. Database to be UTF-8.
   4. Database to have job queue processes set to 100.
   5. Database to have the following user profiles:

         LICS
         LICS_APP

   - Please execute the following commands .....

      execute dbms_java.grant_permission('DBEC','java.io.FilePermission','/ics/[dir]/-','read,write,execute,delete');
      execute dbms_java.grant_permission('DBEC','java.lang.RuntimePermission','*','readFileDescriptor,writeFileDescriptor');
      execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/[dir]/-','read,write,execute,delete');
      execute dbms_java.grant_permission('LICS_APP','java.lang.RuntimePermission','*','readFileDescriptor,writeFileDescriptor');
      commit;

      create directory ics_inbound as '/ics/[dir]/inbound';
      create directory ics_outbound as '/ics/[dir]/outbound';
      create directory ics_view as '/ics/[dir]/webview';
      create directory ics_statistics as '/ics/[dir]/statistics';

      grant all on directory ics_inbound to lics_app;
      grant all on directory ics_outbound to lics_app;
      grant all on directory ics_view to lics_app;
      grant all on directory ics_statistics to lics_app;

      grant execute on dbms_pipe to lics_app;

      grant execute on dbms_lock to ics_app;
      grant execute on dbms_lock to lics_app;

   - Please compile lics_db_trigger using SYS.

   - please grant create public synonym rights to LICS