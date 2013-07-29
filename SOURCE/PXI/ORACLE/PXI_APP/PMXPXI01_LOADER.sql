create or replace 
package          pmxlad01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pmxlad01_loader
    Owner   : pmx_app

    Description
    -----------
    PMX Inbound Interface - Accruals 325

    YYYY/MM   Author                 Description
    -------   ------                 -----------
    2013/05   Jonathan Girling       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end pmxlad01_loader;