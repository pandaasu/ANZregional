/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi03_dim_retriever as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi03_dim_retriever
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Line Item

    This package contain the Line Item dimension retriever functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Created retriever from templace

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_table(par_dim_code in varchar2) return qvi_fppqvi03_dim_tab pipelined;

end qvi_fppqvi03_dim_retriever;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi03_dim_retriever as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_FPPQVI03_DIM_RETRIEVER';
   
   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Module name is fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_dim_code in varchar2) return qvi_fppqvi03_dim_tab pipelined is
      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data qvi_fppqvi03_dim_obj;

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
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.GET_TABLE';
      var_statement_tag := null;

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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

end qvi_fppqvi03_dim_retriever;
/

/**************************/
/* Package Synonym/Grants */
/**************************/

create or replace public synonym qvi_fppqvi03_dim_retriever for qv_app.qvi_fppqvi03_dim_retriever;
grant execute on qvi_fppqvi03_dim_retriever to lics_app, qv_user;



