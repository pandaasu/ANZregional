create or replace 
package          pmxpxi02_loader as


   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pmxpxi02_loader
    Owner   : pxi_app

    Description
    -----------
    Promax PX Payments 331 -> LADS (Inbound) -> Atlas PXIATL02 - AP Claims
                                             -> Atlas PXIATL03 - AR Claims

    YYYY/MM   Author         		Description
    -------   ------         		-----------
    2013/05   Jonathan Girling  Created
    2013/07   Chris Horn        Updated

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end pmxpxi02_loader;