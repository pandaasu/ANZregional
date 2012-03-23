/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi06_src_retriever as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi06_src_retriever
    Owner   : qv_app

    Description
    -----------
    QlikView - Test Dimension Retriever Function

    This package contain the test dimension table retrieval functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Created retriever from templace

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) return qvi_fppqvi06_src_tab pipelined;

end qvi_fppqvi06_src_retriever;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi06_src_retriever as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) return qvi_fppqvi06_src_tab pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data qvi_fppqvi06_src_obj;

      /*-*/
      /* Local cursors
      /*-*/
      
      cursor csr_src_table is
         select t01.*
           from table(qvi_src_function.get_tables(par_das_code, par_fac_code, par_tim_code, par_par_code)) t01;
      rcd_src_table csr_src_table%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the source data from the QVI_SOURCE_FUNCTION.GET_TABLES pipelined table function
      /*-*/
      open csr_src_table;
      loop
         fetch csr_src_table into rcd_src_table;
         if csr_src_table%notfound then
            exit;
         end if;
         var_pointer := rcd_src_table.dat_data.GetObject(var_data);
         pipe row(var_data);
      end loop;
      close csr_src_table;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - FPPQVI06 - FPPS Plan/Actual - Source Retriever - Get Table - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

end qvi_fppqvi06_src_retriever;
/