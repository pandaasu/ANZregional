/******************/
/* Package Header */
/******************/
create or replace package qv_app.test_dim_retriever as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : test_dim_retriever
    Owner   : qv_app

    Description
    -----------
    QlikView - Test Dimension Retriever Function

    This package contain the test dimension table retrieval functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_table(par_dim_code in varchar2) return test_dim_table pipelined;

end test_dim_retriever;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.test_dim_retriever as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_dim_code in varchar2) return test_dim_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data test_dim_object;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_dimension_table is
         select t01.*
           from table(qvi_dim_function.get_table(par_dim_code)) t01;
      rcd_dimension_table csr_dimension_table%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the dimension data from the QVI_DIM_FUNCTION.GET_TABLE pipelined table function
      /*-*/
      open csr_dimension_table;
      loop
         fetch csr_dimension_table into rcd_dimension_table;
         if csr_dimension_table%notfound then
            exit;
         end if;
         var_pointer := rcd_dimension_table.dat_data.GetObject(var_data);
         pipe row(var_data);
      end loop;
      close csr_dimension_table;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Test Dimension Retriever - Get Table - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

end test_dim_retriever;
/