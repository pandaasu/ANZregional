create or replace 
package          pxiatl01_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pxiatl01_extract
    Owner   : pmx_app

    Description
    -----------
    PMX Outbound Interface - Accruals 325

    1. PAR_INT_ID (MANDATORY)

       ## - Interface id for the extract

    This package extracts the accrual information that has been loaded for the 
    specified interface and sends the extract file to the ATLAS environment.

    YYYY/MM   Author                 Description
    -------   ------                 -----------
    2013/05   Jonathan Girling       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(i_datime in date default sysdate-7);
   procedure execute_old(par_int_id in number);
   --function execute_old(par_int_id in number) return number;

end pxiatl01_extract;