/******************/
/* Package Header */
/******************/
create or replace package dw_regional_dbp as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_regional_dbp
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Regional DBP

    This package contains the populate and extract procedures for the regional DBP. The package exposes
    one procedure EXECUTE that performs the populate and extract based on the following parameters:

    1. PAR_COMPANY_CODE (MANDATORY)

       The company code to extract.

    2. PAR_DATE (MANDATORY)

       The date to output.

    **notes**
    1. A web log is produced under the search value DW_REGIONAL_DBP where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/07   Steve Gregan   Created
    2007/04   Steve Gregan   Added multiple company functionality

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company_code in varchar2,
                     par_date in varchar2 default to_char(sysdate-1,'YYYYMMDD'));

end dw_regional_dbp;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_regional_dbp as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company_code in varchar2,
                     par_date in varchar2 default to_char(sysdate-1,'YYYYMMDD')) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_instance number(15,0);

      /*-*/
      /* Cursor Definitions
      /*-*/
      cursor csr_company is
         select t01.*
         from company t01
         where sap_company_code = par_company_code;
      rcd_company csr_company%rowtype;

      cursor csr_dbp_det is
         select '01' ||
                rpad(a.sap_material_code,18,' ') ||
                rpad(sum(cur_ty_gsv),10,' ') ||
                rpad(sum(cur_ty_gsv)+sum(ord_uc_gsv)+sum(ord_cn_gsv),10,' ') as dbp_det
         from pld_sal_mat_prd_0101 a
         where sap_company_code = par_company_code
         group by a.sap_material_code;
      rec_dbp_det csr_dbp_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'CLIO - DW_REGIONAL_DBP_' || par_company_code;
      var_log_search := 'DW_REGIONAL_DBP_' || par_company_code;

      /*-*/
      /* Validate parameter
      /*-*/
      if par_company_code is null then
         raise_application_error(-20000, 'Company code parameter must be specified');
      end if;

      /*-*/
      /* Company must exist
      /*-*/
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         raise_application_error(-20000, 'Company ' || par_company_code || ' not found');
      end if;
      close csr_company;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - Regional DBP Extract - Parameters(' || par_company_code || ' + ' || nvl(par_date,'NULL') || ')');

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('REGDBP01');

      /*-*/
      /* Append the header
      /*-*/
      lics_outbound_loader.append_data('HDR'
                                       || rpad(rcd_company.reg_company_code,6,' ')
                                       || rpad(rcd_company.sap_currcy_code,3,' ')
                                       || par_date
                                       || to_char(sysdate,'yyyymmdd'));

      /*-*/
      /* Append the details
      /*-*/
      open csr_dbp_det;
      loop
         fetch csr_dbp_det into rec_dbp_det;
         if csr_dbp_det%notfound then
            exit;
         end if;
         lics_outbound_loader.append_data('DET' || rec_dbp_det.dbp_det);
      end loop;
      close csr_dbp_det;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('END - Regional DBP Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_REGIONAL_DBP - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_regional_dbp;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_regional_dbp for dw_app.dw_regional_dbp;
grant execute on dw_regional_dbp to public;
