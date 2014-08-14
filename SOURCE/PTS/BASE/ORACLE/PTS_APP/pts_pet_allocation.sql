/******************/
/* Package Header */
/******************/
create or replace
package         pts_pet_allocation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_allocation
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet allocation

    This package contain the pet allocation functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created
    2010/10   Steve Gregan   Modified to allow ranking test day count greater than sample count
                             Modified to store applicable market research code with allocation
    2011/11   Peter Tylee    Updated to support validation

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure perform_allocation(par_tes_code in number);
   procedure perform_allocation_validation(par_val_code in number, par_pet_code in number);

end pts_pet_allocation;
 

/

/****************/
/* Package Body */
/****************/
create or replace
package         pts_pet_allocation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_allocation
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet allocation

    This package contain the pet allocation functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created
    2010/10   Steve Gregan   Modified to allow ranking test day count greater than sample count
                             Modified to store applicable market research code with allocation
    2011/11   Peter Tylee    Updated to support validation

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure perform_allocation(par_tes_code in number);
   procedure perform_allocation_validation(par_val_code in number, par_pet_code in number);

end pts_pet_allocation;
 

/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_allocation for pts_app.pts_pet_allocation;
grant execute on pts_app.pts_pet_allocation to public;
