set define off;
/******************************************************************************/
/* Package Header                                                             */
/******************************************************************************/
create or replace package qvi_parameter as

   /***************************************************************************/
   /* Package Definition                                                      */
   /***************************************************************************/
   /**
    System  : lics
    Package : qvi_parameter
    Owner   : qv_app
    Author  : Mal Chambeyron - May 2012

    DESCRIPTION
    -----------
    QVI Local Interface Control System - Parameters

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/04   Mal Chambeyron Modeled after Steve Gregan lics_parameter package.

   ****************************************************************************/

   /*-*/
   /* Public purge parameters
   /*-*/
   purge_dimension_history_days constant number(5,0) := 14;
   purge_fact_history_days constant number(5,0) := 14; 
   purge_source_history_days constant number(5,0) := purge_fact_history_days; -- source should always equal fact  

end qvi_parameter;
/

/******************************************************************************/
/* Package Synonym/Grants                                                     */
/******************************************************************************/
create or replace public synonym qvi_parameter for qv_app.qvi_parameter;
grant execute on qvi_parameter to public;

/******************************************************************************/
set define on;
set define ^;


