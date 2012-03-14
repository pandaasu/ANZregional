/******************/
/* Package Header */
/******************/
create or replace package qvi_app.template_fact_retrieval as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : template_fact_retrieval
    Owner   : qv_app

    Description
    -----------
    QlikView - Fact Table Retrieval Template

    This package contain the dimension table retrieval functions.

    **NOTES**

    1. A fact retrieval pipelined table function is required for each fact definition.

    2. A unique template_object_type is required for each fact that describes the data layout.

    3. A unique template_table_type is required for each fact that encapsulates the template_object_type as a table.

    4. Replacing the template_table_type and template_object_type names and comments are the only required code changes.

    5. QlikView is passed the function string, for example, qvi_app.template_fact_retrieval.get_table('DAS_CODE','FAC_CODE','TIME_CODE')
       that it will substitute in a select * from table(xxxx) statement to retrieve the fact data based on the template_object_type layout.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return template_table_type pipelined;

end template_fact_retrieval;
/

/****************/
/* Package Body */
/****************/
create or replace package body qvi_app.template_fact_retrieval as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return template_table_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data template_object_type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fact_table is
         select t01.*
           from table(qvi_fac_function.get_table(par_das_code, par_fac_code, par_tim_code)) t01;
      rcd_fact_table csr_fact_table%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the fact data from the QVI_FAC_FUNCTION.GET_TABLE pipelined table function
      /* **notes**
      /* 1. The QVI_FAC_FUNCTION.GET_TABLE function returns a table of QVI_FAC_OBJECT type rows
      /* 2. The QVI_FAC_OBJECT type contains the fact data in column DAT_DATA as SYS.ANYDATA
      /* 3. The column DAT_DATA is cast to the TEMPLATE_OBJECT_TYPE using SYS.ANYDATA.GET_OBJECT
      /* 4. The TEMPLATE_OBJECT_TYPE is piped to the consumer
      /* 5. An Exception will be raised when DAT_DATA is unable to be cast to TEMPLATE_OBJECT_TYPE
      /*-*/
      open csr_fact_table;
      loop
         fetch csr_fact_table into rcd_fact_table;
         if csr_fact_table%notfound then
            exit;
         end if;
         var_pointer := rcd_fact_table.dat_data.GetObject(var_data);
         pipe row(var_data);
      end loop;
      close csr_fact_table;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Template Fact Retrieval - Get Table - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

end qvi_app.template_fact_retrieval;
/
