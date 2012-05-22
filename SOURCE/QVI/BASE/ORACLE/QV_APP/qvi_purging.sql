set define off;
/******************************************************************************/
/* Package Header                                                             */
/******************************************************************************/
create or replace package qvi_purging as

   /***************************************************************************/
   /* Package Definition                                                      */
   /***************************************************************************/
   /**
    System  : lics
    Package : qvi_purging
    Owner   : qv_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local QVI (QlikView Interface Control System) - Purging

    The package implements the purging functionality.

    Configuration Tables ***NOT*** Purged .. 
         qvi_das_defn - Dashboard Definition
         qvi_dim_defn - Dimension Definition
         qvi_fac_defn - Fact Definition
         qvi_fac_part - Fact Part Definition
         qvi_fac_tpar - Fact Time/Part History (Needed to reprocess)
         
    Content Header / Data Tables Purged ..
         qvi_dim_data
         qvi_fac_data
         qvi_fac_hedr
         qvi_fac_time
         qvi_src_data
         qvi_src_hedr

    **NOTES**
    ---------
    1. Only one instance of this package can execute at any one time to prevent
       database lock issues.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/08   Steve Gregan   Added interface header search purging
    2007/01   Steve Gregan   Modified selection and processing logic
    2011/02   Steve Gregan   End point architecture version
    2012/05   Mal Chambeyron Template QVI_PURGING from LICS_PURGING

   ****************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end qvi_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body qvi_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_dimensions;
   procedure purge_facts;
   procedure purge_source;

   /*-*/
   /* Private constants
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_PURGING';

   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.EXECUTE';
      var_statement_tag := null;

      /*-*/
      /* Purge the dimensions
      /*-*/
      purge_dimensions;

      /*-*/
      /* Purge the facts
      /*-*/
      purge_facts;

      /*-*/
      /* Purge the source
      /*-*/
      purge_source;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************************************/
   /* This procedure performs the purge dimension routine                     */
   /***************************************************************************/
   procedure purge_dimensions is

      /*-*/
      /* Local cursor to return the purge list, regardless of status
      /*-*/
      cursor csr_purge_list(var_days_old number) is
         select qdd_dim_code
         from qvi_dim_defn
         where qdd_str_date < sysdate - var_days_old
         order by qdd_str_date;

      /*-*/
      /* Local table to cache the purge list
      /*-*/
      type typ_purge_list is table of csr_purge_list%rowtype index by binary_integer;
      tbl_purge_list_cache typ_purge_list;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.PURGE_DIMENSIONS';
      var_statement_tag := null;

      /*-*/
      /* Cache the purge list
      /*-*/
      for csr_rec in csr_purge_list(qvi_parameter.purge_dimension_history_days)
      loop
         tbl_purge_list_cache(tbl_purge_list_cache.count+1).qdd_dim_code := csr_rec.qdd_dim_code;
      end loop;

      /*-*/
      /* Process the cached purge list
      /*-*/
      for idx in 1..tbl_purge_list_cache.count loop
         /*-*/
         /* Update dimension header
         /*-*/
         update qvi_dim_defn
         set qdd_lod_status = 0,
            qdd_str_date = sysdate,
            qdd_end_date = sysdate,
            qdd_upd_user = user,
            qdd_upd_date = sysdate
         where qdd_dim_code = tbl_purge_list_cache(idx).qdd_dim_code;

         /*-*/
         /* Purge dimension data
         /*-*/
         delete from qvi_dim_data
         where qdd_dim_code = tbl_purge_list_cache(idx).qdd_dim_code;

         /*-*/
         /* Commit per cycle
         /*-*/
         commit;
         
      end loop;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_dimensions;

   /***************************************************************************/
   /* This procedure performs the purge facts routine                         */
   /***************************************************************************/
   procedure purge_facts is

      /*-*/
      /* Local cursor to return the purge list, regardless of status
      /*-*/
      cursor csr_purge_list(var_days_old number) is
         select qfh_das_code,
            qfh_fac_code,
            qfh_tim_code
         from qvi_fac_hedr
         where qfh_str_date < sysdate - var_days_old
         order by qfh_str_date;
         
      /*-*/
      /* Local table to cache the purge list
      /*-*/
      type typ_purge_list is table of csr_purge_list%rowtype index by binary_integer;
      tbl_purge_list_cache typ_purge_list;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.PURGE_FACTS';
      var_statement_tag := null;

      /*-*/
      /* Cache the purge list
      /*-*/
      for csr_rec in csr_purge_list(qvi_parameter.purge_fact_history_days)
      loop
         tbl_purge_list_cache(tbl_purge_list_cache.count+1).qfh_das_code := csr_rec.qfh_das_code;
         tbl_purge_list_cache(tbl_purge_list_cache.count).qfh_fac_code := csr_rec.qfh_fac_code;
         tbl_purge_list_cache(tbl_purge_list_cache.count).qfh_tim_code := csr_rec.qfh_tim_code;
      end loop;

      /*-*/
      /* Process the cached purge list
      /*-*/
      for idx in 1..tbl_purge_list_cache.count loop
         /*-*/
         /* Purge fact header
         /*-*/
         delete from qvi_fac_hedr
         where qfh_das_code = tbl_purge_list_cache(idx).qfh_das_code
         and qfh_fac_code = tbl_purge_list_cache(idx).qfh_fac_code
         and qfh_tim_code = tbl_purge_list_cache(idx).qfh_tim_code;

         /*-*/
         /* Purge fact time
         /*-*/
         delete from qvi_fac_time
         where qft_das_code = tbl_purge_list_cache(idx).qfh_das_code
         and qft_fac_code = tbl_purge_list_cache(idx).qfh_fac_code
         and qft_tim_code = tbl_purge_list_cache(idx).qfh_tim_code;

         /*-*/
         /* Purge fact data
         /*-*/
         delete from qvi_fac_data
         where qfd_das_code = tbl_purge_list_cache(idx).qfh_das_code
         and qfd_fac_code = tbl_purge_list_cache(idx).qfh_fac_code
         and qfd_tim_code = tbl_purge_list_cache(idx).qfh_tim_code;

         /*-*/
         /* Commit per cycle
         /*-*/
         commit;
         
      end loop;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_facts;

   /***************************************************************************/
   /* This procedure performs the purge source routine                        */
   /***************************************************************************/
   procedure purge_source is

      /*-*/
      /* Local cursor to return the purge list, regardless of status
      /*-*/
      cursor csr_purge_list(var_days_old number) is
         select qsh_das_code,
            qsh_fac_code,
            qsh_tim_code,
            qsh_par_code
         from qvi_src_hedr
         where qsh_str_date < sysdate - var_days_old
         order by qsh_str_date;
         
      /*-*/
      /* Local table to cache the purge list
      /*-*/
      type typ_purge_list is table of csr_purge_list%rowtype index by binary_integer;
      tbl_purge_list_cache typ_purge_list;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.PURGE_SOURCE';
      var_statement_tag := null;

      /*-*/
      /* Cache the purge list
      /*-*/
      for csr_rec in csr_purge_list(qvi_parameter.purge_source_history_days)
      loop
         tbl_purge_list_cache(tbl_purge_list_cache.count+1).qsh_das_code := csr_rec.qsh_das_code;
         tbl_purge_list_cache(tbl_purge_list_cache.count).qsh_fac_code := csr_rec.qsh_fac_code;
         tbl_purge_list_cache(tbl_purge_list_cache.count).qsh_tim_code := csr_rec.qsh_tim_code;
         tbl_purge_list_cache(tbl_purge_list_cache.count).qsh_par_code := csr_rec.qsh_par_code;
      end loop;
      
      /*-*/
      /* Process the cached purge list
      /*-*/
      for idx in 1..tbl_purge_list_cache.count loop
         /*-*/
         /* Purge source header
         /*-*/
         delete from qvi_src_hedr
         where qsh_das_code = tbl_purge_list_cache(idx).qsh_das_code
         and qsh_fac_code = tbl_purge_list_cache(idx).qsh_fac_code
         and qsh_tim_code = tbl_purge_list_cache(idx).qsh_tim_code
         and qsh_par_code = tbl_purge_list_cache(idx).qsh_par_code;

         /*-*/
         /* Purge source data
         /*-*/
         delete from qvi_src_data
         where qsd_das_code = tbl_purge_list_cache(idx).qsh_das_code
         and qsd_fac_code = tbl_purge_list_cache(idx).qsh_fac_code
         and qsd_tim_code = tbl_purge_list_cache(idx).qsh_tim_code
         and qsd_par_code = tbl_purge_list_cache(idx).qsh_par_code;

         /*-*/
         /* Commit per cycle
         /*-*/
         commit;
         
      end loop;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_source;
   
end qvi_purging;
/  

/******************************************************************************/
/* Package Synonym/Grants                                                     */
/******************************************************************************/
create or replace public synonym qvi_purging for qv_app.qvi_purging;
grant execute on qvi_purging to public;

/******************************************************************************/
set define on;
set define ^;
