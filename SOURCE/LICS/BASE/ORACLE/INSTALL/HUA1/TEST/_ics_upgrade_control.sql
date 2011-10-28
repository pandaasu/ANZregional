
Steps to upgrade an existing ICS instance with V2 functionality
===============================================================

Copy this script and perform the following scan/replace to localise...

   A. Scan for <SOURCE_PATH> and replace with your local path to the source repository up to but not including \SOURCE (eg. D:\Vivian\LADS\SourceRepository)
   B. Scan for <ICS_FILE_SYSTEM> and replace with the ICS file system path for the installation (eg. /ics/lad/test)
   C. Scan for <DATABASE> and replace with the database name (eg. DB1296T.AP.MARS)
   D. Scan for <LICS_APP_PASSWORD> and replace with the LICS_APP password
   E. Scan for <INSTALLATION> and replace with the installation folder in the source repository (eg. NORTH_ASIA from the path <SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\NORTH_ASIA\TEST)
   F. Scan for <ENVIRONMENT> and replace with the environment folder in the source repository (eg. TEST from the path <SOURCE_PATH>\SOURCE\LICS\BASE\ORACLE\INSTALL\NORTH_ASIA\TEST)

1. Create a WO for the DBA with the following...

   1.1. The DBA needs to connect as LICS when executing the following commands.

        1.1.2. Check the LICS_TRIGGERED table for column (tri_log_data)

               If the column DOES NOT exist then add the following to the WO...

                  /*-*/
                  /* Modify the LICS_TRIGGERED table
                  /*-*/
                  alter table lics_triggered add tri_log_data varchar2(512 char) null;
                  comment on column lics_triggered.tri_log_data is 'Triggered - log data';

        1.1.3. Check the LICS_INTERFACE table for columns (int_usr_invocation, int_usr_validation and int_usr_message) and do ONLY ONE of the following...

               If the columns DO NOT exist then add the following to the WO...

                  /*-*/
                  /* Modify the LICS_INTERFACE table
                  /*-*/
                  alter table lics_interface add 
                     (int_usr_invocation varchar2(1 char) null,
                      int_usr_validation varchar2(256 char) null,
                      int_usr_message varchar2(64 char) null,
                      int_lod_type varchar2(10 char) null,
                      int_lod_group varchar2(10 char) null);
                  comment on column lics_interface.int_usr_invocation is 'Interface - user invocation indicator (0=No or 1=Yes)';
                  comment on column lics_interface.int_usr_validation is 'Interface - user invocation validation procedure';
                  comment on column lics_interface.int_usr_message is 'Interface - user invocation message name (*OUTBOUND only)';
                  comment on column lics_interface.int_lod_type is 'Interface - interface load type (*NONE=outbound interfaces, *PUSH=load pushing, *POLL=load polling)';
                  comment on column lics_interface.int_lod_group is 'Interface - interface load group (*NONE=load type *PUSH or *NONE, group=load type *POLL)';
                  update lics_interface set int_usr_invocation = '0', int_usr_validation = null, int_usr_message = null, int_lod_type = '*PUSH', int_lod_group = '*NONE' where int_type != '*OUTBOUND';
                  update lics_interface set int_usr_invocation = '0', int_usr_validation = null, int_usr_message = null, int_lod_type = '*NONE', int_lod_group = '*NONE' where int_type = '*OUTBOUND';
                  commit;
                  alter table lics_interface modify (int_lod_type varchar2(10 char) not null, int_lod_group varchar2(10 char) not null);

               Otherwise the columns DO exist so add the following to the WO...

                  /*-*/
                  /* Modify the LICS_INTERFACE table
                  /*-*/
                  alter table lics_interface add 
                     (int_lod_type varchar2(10 char) null,
                      int_lod_group varchar2(10 char) null);
                  comment on column lics_interface.int_lod_type is 'Interface - interface load type (*NONE=outbound interfaces, *PUSH=load pushing, *POLL=load polling)';
                  comment on column lics_interface.int_lod_group is 'Interface - interface load group (*NONE=load type *PUSH or *NONE, group=load type *POLL)';
                  update lics_interface set int_lod_type = '*PUSH', int_lod_group = '*NONE' where int_type != '*OUTBOUND';
                  update lics_interface set int_lod_type = '*NONE', int_lod_group = '*NONE' where int_type = '*OUTBOUND';
                  commit;
                  alter table lics_interface modify (int_lod_type varchar2(10 char) not null, int_lod_group varchar2(10 char) not null);

        1.1.4. Add the following to the WO...

               /*-*/
               /* Create the LICS_FILE table
               /*-*/
               create table lics_file
                  (fil_file                     number(15,0)                    not null,
                   fil_path                     varchar2(64 char)               not null,
                   fil_name                     varchar2(256 char)              not null,
                   fil_status                   varchar2(1 char)                not null,
                   fil_crt_user                 varchar2(30 char)               not null,
                   fil_crt_time                 date                            not null,
                   fil_message                  varchar2(2000 char)             null);
               comment on table lics_file is 'LICS File Table';
               comment on column lics_file.fil_file is 'File - file sequence number (sequence generated)';
               comment on column lics_file.fil_path is 'File - file path';
               comment on column lics_file.fil_name is 'File - file name';
               comment on column lics_file.fil_status is 'File - file status';
               comment on column lics_file.fil_crt_user is 'File - creation user';
               comment on column lics_file.fil_crt_time is 'File - creation time';
               comment on column lics_file.fil_message is 'File - file message';
               alter table lics_file
                  add constraint lics_file_pk primary key (fil_file);
               create unique index lics_file_ix01 on lics_file
                  (fil_path, fil_name);
               create index lics_file_ix02 on lics_file
                  (fil_path, fil_status, fil_file);
               grant select, insert, update, delete on lics_file to lics_app;
               create or replace public synonym lics_file for lics.lics_file;

               /*-*/
               /* Create the file sequence
               /*-*/
               create sequence lics_file_sequence
                  increment by 1
                  start with 1
                  maxvalue 999999999999999
                  minvalue 1
                  nocycle
                  nocache;
               grant select on lics_file_sequence to lics_app;
               create or replace public synonym lics_file_sequence for lics.lics_file_sequence;

   1.2. The DBA needs to connect as SYS when executing the following commands.

        1.2.1. Add the following to the WO...

               /*-*/
               /* Create the java permissions and directory objects
               /*-*/
               execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/bin/chmod','execute');
	       execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/cad/test/-','execute');
               execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/cad/test/-','read');
	       execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/cad/test/-','write');
	       execute dbms_java.grant_permission('LICS_APP','java.io.FilePermission','/ics/cad/test/-','delete');
               execute dbms_java.grant_permission( 'DBEC', 'SYS:java.io.FilePermission', '/ics/cad/test/bin/-', 'execute' );
               commit;
               create directory ics_bin as '/ics/cad/test/bin';
               create directory ics_config as '/ics/cad/test/config';
               create directory ics_archive as '/ics/cad/test/archive';
               create directory ics_outbound as '/ics/cad/test/outbound';
               create directory ics_inbound as '/ics/cad/test/inbound';
               grant all on directory ics_bin to lics_app;
               grant all on directory ics_config to lics_app;
               grant all on directory ics_archive to lics_app;

   1.3. The following script from the repository directory (D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE)

          lics_directory.sql

2. Before the DBA performs the WO the following actions need to be taken by the ICS support team...

   2.1. The ICS jobs need to be stopped until the upgrade is completed.

   2.2. All AMI message feeds need to be stopped until the upgrade is completed.

3. DBA performs the WO as above.

4. Check that the database has been updated as requested...

   4.1. Connect to the database as LICS_APP.

   4.2. Check the java permissions have been created using the statement ==> select * from user_java_policy;

        The following row should be returned...

        GRANT   LICS_APP   SYS   java.io.FilePermission        /bin/chmod            execute         ENABLED

   4.3. Check the oracle directories have been created using the statement ==> select * from all_directories;

        The following rows should be returned...

	   ICS_ARCHIVE   /ics/cad/test/archive
	   ICS_CONFIG    /ics/cad/test/config
	   ICS_BIN       /ics/cad/test/bin

5. Load the ICS java classes into the LICS_APP schema using the following commands...

      loadjava -f -v -r -u lics_app/licsapp_dev@DB1324T.AP.MARS D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cExternalProcess.class
      loadjava -f -v -r -u lics_app/licsapp_dev@DB1324T.AP.MARS D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\JAVA\ICS_General\build\classes\com\isi\ics\cFileSystem.class

6. Connect as LICS_APP using SQL+ and compile the file system package as follows...

      @D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE\lics_filesystem.sql;

7. DBA to connect as SYS using SQL+ and compile the following package script sent in 1.3 ...

      @...DBA local path to WO file...\lics_directory.sql;

8. Check that the SYS packages were created correctly...

   8.1. Connect to the database as LICS_APP.

   8.2. Check the LICS_APP authority to lics_directory using the statement ==> desc lics_directory;

        The description of package lics_directory should be returned to indicate that the package has been created and is available to LICS_APP.

9. Connect as LICS_APP using SQL+ and execute the following...

      drop package lics_file;
      drop type lics_store_table;
      drop type lics_datastore_table;
      drop type lics_security_table;
      drop type lics_stream_table;

10. Recompile the LICS_APP schema objects using the script ==> @D:\Vivian\LADS\SourceRepository\SOURCE\LICS\BASE\ORACLE\INSTALL\HUA1\TEST\_lics_app_build.sql


