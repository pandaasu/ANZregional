--
-- LICS_ALERTING_CONFIGURATION  (Package) 
--
CREATE OR REPLACE PACKAGE LICS_APP.lics_alerting_configuration as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_alerting_configuration
 Owner   : lics_app
 Author  : Steve Gregan - August 2006

 DESCRIPTION
 -----------
 Local Interface Control System - Alerting Configuration

 The package implements the alerting configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/10   Ben Halicki    Created

*******************************************************************************/


   /*-*/
   /* Public declarations
   /*-*/
   procedure update_setting(par_srch_txt in varchar2,
                           par_msg_txt in varchar2);
   procedure delete_setting(par_srch_txt in varchar2,
                           par_msg_txt in varchar2);

end lics_alerting_configuration;
/


--
-- LICS_ALERTING_CONFIGURATION  (Synonym) 
--
CREATE PUBLIC SYNONYM LICS_ALERTING_CONFIGURATION FOR LICS_APP.LICS_ALERTING_CONFIGURATION;



--
-- LICS_ALERTING_CONFIGURATION  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LICS_APP.lics_alerting_configuration as

   /******************************************************/
   /* This procedure performs the update setting routine */
   /******************************************************/
   procedure update_setting(par_srch_txt in varchar2,
                            par_msg_txt in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the setting value
      /*-*/
      update lics_alert
         set ale_msg_txt=upper(par_msg_txt)
       where ale_srch_txt=upper(par_srch_txt); 
       
      if sql%notfound then
         insert into lics_alert
            (ale_srch_txt,
             ale_msg_txt)
            values(upper(par_srch_txt),
                   upper(par_msg_txt));
      end if;
      
      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_setting;

   /******************************************************/
   /* This procedure performs the delete setting routine */
   /******************************************************/
   procedure delete_setting(par_srch_txt in varchar2,
                            par_msg_txt in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the setting value
      /*-*/
      delete from lics_alert
         where ale_srch_txt = upper(par_srch_txt)
           and ale_msg_txt = upper(par_msg_txt);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_setting;

end lics_alerting_configuration;
/


--
-- LICS_ALERTING_CONFIGURATION  (Synonym) 
--
CREATE PUBLIC SYNONYM LICS_ALERTING_CONFIGURATION FOR LICS_APP.LICS_ALERTING_CONFIGURATION;

