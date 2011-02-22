/******************/
/* Package Header */
/******************/
create or replace package lics_constant as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_constant
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Constants

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /*-*/
   /* Public event constants
   /*-*/
   event_success constant varchar2(10) := '*SUCCESS';
   event_error constant varchar2(10) := '*ERROR';
   event_warning constant varchar2(10) := '*WARNING';
   event_fatal constant varchar2(10) := '*FATAL';

   /*-*/
   /* Public state constants
   /*-*/
   state_off constant varchar2(1) := '0';
   state_on constant varchar2(1) := '1';

   /*-*/
   /* Public status constants
   /*-*/
   status_inactive constant varchar2(1) := '0';
   status_active constant varchar2(1) := '1';

   /*-*/
   /* Public type constants
   /*-*/
   type_file constant varchar2(10) := '*FILE';
   type_inbound constant varchar2(10) := '*INBOUND';
   type_outbound constant varchar2(10) := '*OUTBOUND';
   type_passthru constant varchar2(10) := '*PASSTHRU';
   type_daemon constant varchar2(10) := '*DAEMON';
   type_poller constant varchar2(10) := '*POLLER';
   type_procedure constant varchar2(10) := '*PROCEDURE';

   /*-*/
   /* Public queue constants
   /*-*/
   queue_file constant varchar2(10) := 'FILE_';
   queue_inbound constant varchar2(10) := 'INBOUND_';
   queue_outbound constant varchar2(10) := 'OUTBOUND_';
   queue_passthru constant varchar2(10) := 'PASSTHRU_';
   queue_daemon constant varchar2(10) := 'DAEMON_';
   queue_poller constant varchar2(10) := 'POLLER_';

   /*-*/
   /* Public pipe constants
   /*-*/
   pipe_wake constant varchar2(10) := '*WAKE';
   pipe_stop constant varchar2(10) := '*STOP';
   pipe_suspend constant varchar2(10) := '*SUSPEND';
   pipe_release constant varchar2(10) := '*RELEASE';

   /*-*/
   /* Public job constants
   /*-*/
   job_startup constant varchar2(10) := '*STARTUP';
   job_suspend constant varchar2(10) := '*SUSPEND';
   job_release constant varchar2(10) := '*RELEASE';
   job_shutdown constant varchar2(10) := '*SHUTDOWN';
   job_loader constant varchar2(10) := '*LOADER';
   job_trigger constant varchar2(10) := '*TRIGGER';
   job_working constant varchar2(1) := '1';
   job_idle constant varchar2(1) := '2';
   job_suspended constant varchar2(1) := '3';
   job_completed constant varchar2(1) := '4';
   job_aborted constant varchar2(1) := '5';

   /*-*/
   /* Public file constants
   /*-*/
   file_available constant varchar2(1) := '1';
   file_error constant varchar2(1) := '2';

   /*-*/
   /* Public header constants
   /*-*/
   header_load_working constant varchar2(1) := '1';
   header_load_working_error constant varchar2(1) := '2';
   header_load_completed constant varchar2(1) := '3';
   header_load_completed_error constant varchar2(1) := '4';
   header_process_working constant varchar2(1) := '5';
   header_process_working_error constant varchar2(1) := '6';
   header_process_completed constant varchar2(1) := '7';
   header_process_completed_error constant varchar2(1) := '8';

   /*-*/
   /* Public data constants
   /*-*/
   data_available constant varchar2(1) := '1';
   data_error constant varchar2(1) := '2';

end lics_constant;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_constant for lics_app.lics_constant;
grant execute on lics_constant to public;