create or replace 
package df_fcst_supply_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : df_fcst_supply_load
    Owner   : df_app
    Author  : Jonathan Girling

    Description
    -----------
    Integrated Planning Demand Financials - Forecast Supply Load

    YYYY/MM   Author             Description
    -------   ------             -----------
    2008/08   Jonathan Girling   Created
    2008/12   Steve Gregan       Modified for parallel processing

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end df_fcst_supply_load;
 