create or replace 
package df_forecast as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : df_forecast
    Owner   : df_app

    Description
    -----------
    Integrated Planning Demand Financials - Forecast

    This package contain the load and aggregation procedures for sales data. The package exposes
    one procedure PROCESS that performs the load and aggregation based on the following parameters:

    1. PAR_ACTION (*DEMAND_FINAL, *DEMAND_DRAFT, *SUPPLY_FINAL, *SUPPLY_DRAFT) (MANDATORY)

       The processing action that controls the forecast processing.

    2. PAR_FILE_ID (file identifier number) (MANDATORY)

       The file identifier generated by the interface loader of the file containing the forecast data.

    **notes**
    1. A web log is produced under the search value DF_FCST_PROCESSING where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/01   Steve Gregan       Created
    2009/04   Steve Gregan       Included the demand SKU mapping logic
                                 Included the MOE demand mapping switch
		2011/12		Rob Bishop				 Added extra comments in process_demand_file()
		
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure process(par_action in varchar2, par_file_id in number);

end df_forecast;