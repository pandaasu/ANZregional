DROP PACKAGE CR_APP.SIL_PARAMETER;

CREATE OR REPLACE PACKAGE CR_APP.sil_parameter as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : STANDARD INTERFACE LOADER
 Package : sil_parameter
 Owner   : cr_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 STANDARD INTERFACE LOADER - Parameters

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Linden Glen    Created

*******************************************************************************/


   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'SIL-CARE';
   system_unit constant varchar2(10) := 'AP';
   system_environment constant varchar2(20) := 'PRODUCTION';
   system_url constant varchar2(128) := 'http://xxxxxxx/';

   /*-*/
   /* Public environment parameters
   /*-*/
   folder_delimiter constant varchar2(1) := '/';

   /*-*/
   /* Public mail parameters
   /*-*/
   email_data_load constant varchar2(64) := 'AP_CARE_REPORT@ap.effem.com';
   email_sales_load constant varchar2(64) := 'AP_CARE_REPORT@ap.effem.com';
   email_sender constant varchar2(64) := '"AP CARE DATA LOAD"@AP0101P.AP.MARS';


   /*-*/
   /* Public fatal parameters
   /*-*/
   fatal_ema_group constant varchar2(64) := 'AP_CARE_REPORT@ap.effem.com';

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
   purge_log_history_days constant number(5,0) := 21;
   purge_file_script constant varchar2(128) := '/sil/care/prod/bin/sil_cleanup.sh';

   /*-*/
   /* Public interface status parameters
   /*-*/
   inbound_intfc_active constant varchar2(1) := '1';
   inbound_intfc_inactive constant varchar2(1) := '0';

   /*-*/
   /* Public IDOC control definition
   /*-*/
   type idoc_control is record(idoc_name varchar2(30),
                               idoc_number number(16,0),
                               idoc_timestamp varchar2(14));

end sil_parameter;
/


DROP PUBLIC SYNONYM SIL_PARAMETER;

CREATE PUBLIC SYNONYM SIL_PARAMETER FOR CR_APP.SIL_PARAMETER;


GRANT EXECUTE ON CR_APP.SIL_PARAMETER TO PUBLIC;

