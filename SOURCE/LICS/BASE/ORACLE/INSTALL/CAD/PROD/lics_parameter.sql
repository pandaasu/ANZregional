CREATE OR REPLACE package LICS_APP.lics_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_parameter
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Parameters

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /*-*/
   /* Public parameters
   /*-*/
   system_code constant varchar2(10) := 'ICS';
   system_unit constant varchar2(10) := 'CAE';
   system_environment constant varchar2(20) := 'PROD';
   system_url constant varchar2(128) := 'http://china.apps.ap.mars/ics/';
   log_environment constant varchar2(128) := 'PROD';
   log_database constant varchar2(128) := 'db1342p.ap.mars';
   ics_path constant varchar2(128) := '/ics/cad/prod/';
   ami_path constant varchar2(128) := '/opt/apps/ami/';
   folder_delimiter constant varchar2(1) := '/';
   file_attribute_command constant varchar2(64) := '/bin/chmod 777 <FILE>';

   /*-*/
   /* Public directory parameters
   /*-*/
   ics_inbound constant varchar2(128) := 'ICS_INBOUND';
   ics_outbound constant varchar2(128) := 'ICS_OUTBOUND';
   inbound_directory constant varchar2(128) := ics_path||'inbound'||folder_delimiter;
   outbound_directory constant varchar2(128) := ics_path||'outbound'||folder_delimiter;
   archive_directory constant varchar2(128) := ics_path||'archive'||folder_delimiter;
   view_directory constant varchar2(128) := ics_path||'webview'||folder_delimiter;
   script_directory constant varchar2(128) := ics_path||'bin'||folder_delimiter;
   log_directory constant varchar2(128) := ics_path||'log'||folder_delimiter;
   ami_logfile constant varchar2(128) := log_directory||'ics_integration.log';

   /*-*/
   /* Public fatal parameters
   /*-*/
   fatal_opr_alert constant varchar2(256) := null;
   fatal_ema_group constant varchar2(64) := '"Global ISI ICS-LADS Application Support"@smtp.ap.mars';

   /*-*/
   /* Public email parameters
   /*-*/
   email_smtp_host constant varchar2(64) := 'smtp.ap.mars';
   email_smtp_port constant number(2,0) := 25;

   /*-*/
   /* Public inbound parameters
   /*-*/
   inbound_line_max constant number(5,0) := 4000;
   inbound_array_size constant number(5,0) := 200;

   /*-*/
   /* Public purge parameters
   /*-*/
   purge_event_history_days constant number(5,0) := 14;
   purge_log_history_days constant number(5,0) := 14;

   /*-*/
   /* Public script parameters
   /*-*/
   purge_file_script constant varchar2(128) := script_directory||'ics_cleanup.sh';
   restore_script constant varchar2(128) := script_directory||'ics_restore.sh';
   inbound_sap_script constant varchar2(128) := script_directory||'ics_inbound_sap.sh';

end lics_parameter;
/