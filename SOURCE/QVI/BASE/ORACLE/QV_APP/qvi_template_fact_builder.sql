/******************/
/* Package Header */
/******************/
create or replace package qv_app.template_fact_builder as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : template_fact_builder
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Fact Builder Template

    This package contain the fact builder template.

    **NOTES**

    1. A fact builder package is required for each fact definition.

    2. A unique template_object_type is required for each fact part that describes the data layout.

    3. The source loader package procedure are invoked directly from the ICS inbound processor.

    4. Commit and rollback should be executed at the appropriate places in code.

    5. Any untrapped exceptions will cause the load processing to abort in the ICS inbound processor
       and the database will be rolled back.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2);
   function final_pass(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return template_intermediate_table_type pipelined;
   function first_pass(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return template_intermediate_table_type pipelined;

end template_fact_builder;

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.template_fact_builder as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_data template_object_type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_src_table is
         select t01.*
           from table(template_fact_builder.final_pass(par_das_code, par_fac_code, par_tim_code)) t01;
      rcd_fact_table csr_fact_table%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the fact loader
      /*-*/
      qvi_fac_function.start_loader(par_das_code, par_fac_code, par_tim_code);

      /*-*/
      /* Retrieve the fact data from the intermediate pipelined table function
      /* **notes**
      /* 1. Create DAT_DATA using the TEMPLATE_OBJECT_TYPE
      /* 2. The DAT_DATA is cast to SYS.ANYDATA using SYS.ANYDATA.CONVERTTOOBJECT
      /*-*/
      open csr_src_table;
      loop
         fetch csr_src_table into rcd_src_table;
         if csr_src_table%notfound then
            exit;
         end if;

         /*-*/
         /* Create the fact object
         /*-*/
         var_data := template_object_type(rcd_src_table.field01,
                                          rcd_src_table.field02,
                                          rcd_src_table.field03,
                                          rcd_src_table.field04,
                                          rcd_src_table.field05,
                                          rcd_src_table.field06);

         /*-*/
         /* Append the fact data
         /*-*/
         qvi_fac_function.append_data(sys.anydata.ConvertObject(var_data));

      end loop;
      close csr_src_table;

      /*-*/
      /* Finalise the fact loader
      /*-*/
      qvi_fac_function.finalise_loader;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Template Fact Builder - Execute - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /*********************************************************/
   /* This procedure performs the select fact table routine */
   /*********************************************************/
   function final_pass(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return template_src_table_type pipelined;

      /*-*/
      /* Local definitions
      /*-*/
      var_data template_src_object_type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_src_table is
         select t01.*
           from table(qvi_src_function.get_tables(par_das_code, par_fac_code, par_tim_code, '*ALL')) t01;
      rcd_fact_table csr_fact_table%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the source data from the QVI_SRC_FUNCTION.GET_TABLES pipelined table function
      /* **notes**
      /* 1. The QVI_FAC_FUNCTION.GET_TABLE function returns a table of QVI_FAC_OBJECT type rows
      /* 2. The QVI_FAC_OBJECT type contains the fact data in column DAT_DATA as SYS.ANYDATA
      /* 3. The column DAT_DATA is cast to the TEMPLATE_OBJECT_TYPE using SYS.ANYDATA.GET_OBJECT
      /* 4. The TEMPLATE_OBJECT_TYPE is piped to the consumer
      /* 5. An Exception will be raised when DAT_DATA is unable to be cast to TEMPLATE_OBJECT_TYPE
      /*-*/
      open csr_src_table;
      loop
         fetch csr_src_table into rcd_src_table;
         if csr_src_table%notfound then
            exit;
         end if;
         rcd_src_table.dat_data.GetObject(var_data)
         pipe row(var_data);
      end loop;
      close csr_fact_table;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end final_pass;

end template_fact_builder;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym template_fact_builder for qv_app.template_fact_builder;
