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

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_parameter as

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'ICS';
   system_unit constant varchar2(10) := 'MCH';
   system_environment constant varchar2(20) := 'MCH_PLANT_TEST';
   system_url constant varchar2(128) := 'http://plant.bth.ap.mars/';
   system_startup constant varchar2(128) := '/ics/test/bin/restart_jobs.sh';

   /*-*/
   /* Public environment parameters
   /*-*/
   folder_delimiter constant varchar2(1) := '/';

   /*-*/
   /* Public fatal parameters
   /*-*/
   fatal_opr_alert constant varchar2(256) := null;
   fatal_ema_group constant varchar2(64) := '"ISI ICS Test Group"@esosn1';

   /*-*/
   /* Public operator parameters
   /*-*/
   operator_alert_script constant varchar2(64) := '/ics/test/bin/ics_tivoli_alert.sh';

   /*-*/
   /* Public email parameters
   /*-*/
   email_smtp_host constant varchar2(64) := 'esosn1.ap.mars';
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
   purge_file_script constant varchar2(128) := '/ics/test/bin/ics_cleanup.sh';

   /*-*/
   /* Public script parameters
   /*-*/
   script_directory constant varchar2(128) := '/ics/test/bin/';
   restore_script constant varchar2(128) := '/ics/test/bin/ics_restore.sh';
   inbound_sap_script constant varchar2(128) := '/ics/test/bin/ics_inbound_sap.sh';

end lics_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create public synonym lics_parameter for lics_app.lics_parameter;
grant execute on lics_parameter to public;