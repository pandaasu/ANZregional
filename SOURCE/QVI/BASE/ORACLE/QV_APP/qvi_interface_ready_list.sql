/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_interface_ready_list as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_interface_ready_list
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Material Hierarchy

    This package contain the Material Hierarchy dimension retriever functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Created retriever from templace

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_table(par_pol_type in varchar2, par_interface_code in varchar2, par_upd_seqn in number) return qvi_interface_ready_list_tab pipelined;

end qvi_interface_ready_list;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_interface_ready_list as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_INTERFACE_READY_LIST';
   
   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Module name is fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_pol_type in varchar2, par_interface_code in varchar2, par_upd_seqn in number) return qvi_interface_ready_list_tab pipelined is
      /*-*/
      /* Local definitions
      /*-*/

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_available is
         select qdd_dim_code "Interface Code",
            'select * from table('||qdd_dim_table||'('''||qdd_dim_code||'''))' "SQL Statement",
            'DIMENSION' "Interface Type",
            decode(qdd_pol_flag,1,'BATCH','FLAG') "Polling Type",
            null "Year",
            null "Period",
            qdd_upd_date "Last Update",
            qdd_upd_seqn "Update Sequence"
         from qvi_dim_defn
         where qdd_lod_status = '2'
         and (par_interface_code = '*ALL' or qdd_dim_code = par_interface_code)
         and (par_pol_type ='*ALL' or decode(upper(par_pol_type),'BATCH',1,'FLAG',0,-1) = qdd_pol_flag)
         and qdd_upd_seqn > par_upd_seqn
         
         union all
         
         select t2.qfh_das_code||'_'||t2.qfh_fac_code "Interface Code",
            'select * from table('||t1.qfd_fac_table||'('''||t2.qfh_das_code||''','''||t2.qfh_fac_code||''','''||t2.qfh_tim_code||'''))' "SQL Statement",
            'FACT' "Interface Type",
            decode(t1.qfd_pol_flag,1,'BATCH','FLAG') "Polling Type",
            substr(t2.qfh_tim_code,1,4) "Year",
            substr(t2.qfh_tim_code,5,2) "Period",
            t2.qfh_end_date "Last Update",
            t2.qfh_upd_seqn "Update Sequence"   
         from qvi_fac_defn t1, qvi_fac_hedr t2
         where t1.qfd_das_code = t2.qfh_das_code
         and t1.qfd_fac_code = t2.qfh_fac_code
         and t2.qfh_lod_status = '2'
         and (par_interface_code = '*ALL' or (
            t2.qfh_das_code = substr(par_interface_code,1,instr(par_interface_code,'_')-1)
            and t2.qfh_fac_code = substr(par_interface_code,instr(par_interface_code,'_')+1)))
         and (par_pol_type ='*ALL' or decode(upper(par_pol_type),'BATCH',1,'FLAG',0,-1) = t1.qfd_pol_flag)
         and t2.qfh_upd_seqn > par_upd_seqn;
         
      rec_available csr_available%rowtype;

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
      open csr_available;
      loop
         fetch csr_available into rec_available;
         if csr_available%notfound then
            exit;
         end if;
         pipe row(qvi_interface_ready_list_obj(
            rec_available."Interface Code",
            rec_available."SQL Statement",
            rec_available."Interface Type",
            rec_available."Polling Type",
            rec_available."Year",
            rec_available."Period",
            rec_available."Last Update",
            rec_available."Update Sequence"));
      end loop;
      close csr_available;

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

end qvi_interface_ready_list;
/

/**************************/
/* Package Synonym/Grants */
/**************************/

create or replace public synonym qvi_interface_ready_list for qv_app.qvi_interface_ready_list;
grant execute on qvi_interface_ready_list to lics_app;
grant execute on qvi_interface_ready_list to qv_user;


