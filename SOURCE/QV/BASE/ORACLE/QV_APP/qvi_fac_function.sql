/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fac_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fac_function
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Fact Functions

    This package contain the fact data functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure start_loader(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2);
   procedure append_data(par_data in sys.anydata);
   procedure finalise_loader;
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_fac_table pipelined;

end qvi_fac_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fac_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_das_code varchar2(32);
   pvar_fac_code varchar2(32);
   pvar_tim_code varchar2(32);
   pvar_dat_seqn number;

   /********************************************************/
   /* This function performs the start fact loader routine */
   /********************************************************/
   procedure start_loader(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      rcd_qvi_fac_hedr qvi_fac_hedr%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_das_defn is
         select t01.*
           from qvi_das_defn t01
          where t01.qdd_das_code = par_das_code;
      rcd_das_defn csr_das_defn%rowtype;

      cursor csr_fac_defn is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = par_das_code
            and t01.qfd_fac_code = par_fac_code;
      rcd_fac_defn csr_fac_defn%rowtype;

      cursor csr_fac_time is
         select t01.*
           from qvi_fac_time t01
          where t01.qft_das_code = par_das_code
            and t01.qft_fac_code = par_fac_code
            and t01.qft_tim_code = par_tim_code;
      rcd_fac_time csr_fac_time%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the package variables
      /*-*/
      pvar_das_code := null;
      pvar_fac_code := null;
      pvar_tim_code := null;
      pvar_dat_seqn := 0;

      /*-*/
      /* Retrieve the requested dashboard
      /* notes - must exist
      /*         must be active
      /*-*/
      var_found := false;
      open csr_das_defn;
      fetch csr_das_defn into rcd_das_defn;
      if csr_das_defn%notfound then
         var_found := true;
      end if;
      close csr_das_defn;
      if var_found = false then
         raise_application_error(-20000, 'Start Loader - Dashboard ('||par_das_code||') does not exist');
      end if;
      if rcd_das_defn.qdd_das_status != '1' then
         raise_application_error(-20000, 'Start Loader - Dashboard ('||par_das_code||') is not active');
      end if;

      /*-*/
      /* Retrieve the requested dimension fact
      /* notes - must exist
      /*         must be active
      /*-*/
      var_found := false;
      open csr_fac_defn;
      fetch csr_fac_defn into rcd_fac_defn;
      if csr_fac_defn%notfound then
         var_found := true;
      end if;
      close csr_fac_defn;
      if var_found = false then
         raise_application_error(-20000, 'Start Loader - Fact ('||par_das_code||'/'||par_fac_code||') does not exist');
      end if;
      if rcd_fac_defn.qfd_fac_status != '1' then
         raise_application_error(-20000, 'Start Loader - Fact ('||par_das_code||'/'||par_fac_code||') is not active');
      end if;

      /*-*/
      /* Retrieve the requested dimension fact time
      /* notes - must exist
      /*         must be active
      /*-*/
      var_found := false;
      open csr_fac_time;
      fetch csr_fac_time into rcd_fac_time;
      if csr_fac_time%notfound then
         var_found := true;
      end if;
      close csr_fac_time;
      if var_found = false then
         raise_application_error(-20000, 'Start Loader - Fact Time ('||par_das_code||'/'||par_fac_code||'/'||par_tim_code||') does not exist');
      end if;
      if rcd_fac_time.qft_tim_status != '2' then
         raise_application_error(-20000, 'Start Loader - Fact Time ('||par_das_code||'/'||par_fac_code||'/'||par_tim_code||') is not completed (missing parts)');
      end if;

      /*-*/
      /* Lock the requested fact header (oracle default wait behaviour - lock will hold until commit or rollback)
      /* 1. Set the load status to 1 (loading)
      /* 2. Set the load start date to sysdate
      /* 3. Set the load end date to sysdate
      /*-*/
      begin
         rcd_qvi_fac_hedr.qfh_das_code := par_das_code;
         rcd_qvi_fac_hedr.qfh_fac_code := par_fac_code;
         rcd_qvi_fac_hedr.qfh_tim_code := par_tim_code;
         rcd_qvi_fac_hedr.qfh_lod_status := '1';
         rcd_qvi_fac_hedr.qfh_str_date := sysdate;
         rcd_qvi_fac_hedr.qfh_end_date := sysdate;
         insert into qvi_fac_hedr values rcd_qvi_fac_hedr;
      exception
         when dup_val_on_index then
            update qvi_fac_hedr
               set qfh_lod_status = '1',
                   qfh_str_date = sysdate,
                   qfh_end_date = sysdate
             where qfh_das_code = par_das_code
               and qfh_fac_code = par_fac_code
               and qfh_tim_code = par_tim_code;
            if sql%notfound then
               raise_application_error(-20000, 'Start Loader - Fact ('||par_das_code||'/'||par_fac_code||'/'||par_tim_code||') does not exist');
            end if;

            /*-*/
            /* Remove the existing fact data
            /*-*/
            delete from qvi_fac_data
             where qfd_das_code = par_das_code
               and qfd_fac_code = par_fac_code
               and qfd_tim_code = par_tim_code;

      end;

      /*-*/
      /* Set the package variables
      /*-*/
      pvar_das_code := par_das_code;
      pvar_fac_code := par_fac_code;
      pvar_tim_code := par_tim_code;
      pvar_dat_seqn := 0;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Fact Function - Start Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_loader;

   /********************************************************/
   /* This procedure performs the append fact data routine */
   /********************************************************/
   procedure append_data(par_data in sys.anydata) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_qvi_fac_data qvi_fac_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Fact loader must be started
      /*-*/
      if pvar_das_code is null then
         raise_application_error(-20000, 'Append Data - Fact loader has not been started');
      end if;

      /*-*/
      /* Create the new fact data
      /*-*/
      pvar_dat_seqn := pvar_dat_seqn + 1;
      rcd_qvi_fac_data.qfd_das_code := pvar_das_code;
      rcd_qvi_fac_data.qfd_fac_code := pvar_fac_code;
      rcd_qvi_fac_data.qfd_tim_code := pvar_tim_code;
      rcd_qvi_fac_data.qfd_dat_seqn := pvar_dat_seqn;
      rcd_qvi_fac_data.qfd_dat_data := par_data;
      insert into qvi_fac_data values rcd_qvi_fac_data;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Fact Function - Append Data - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /************************************************************/
   /* This procedure performs the finalise fact loader routine */
   /************************************************************/
   procedure finalise_loader is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Fact loader must be started
      /*-*/
      if pvar_das_code is null then
         raise_application_error(-20000, 'Append Data - Fact loader has not been started');
      end if;

      /*-*/
      /* Update the fact load status
      /* 1. Set the load status to 2 (loaded)
      /* 2. Set the load end date to sysdate
      /*-*/
      update qvi_fac_hedr
         set qfh_lod_status = '2',
             qfh_end_date = sysdate
       where qfh_das_code = pvar_das_code
         and qfh_fac_code = pvar_fac_code
         and qfh_tim_code = pvar_tim_code;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Loader - Fact ('||pvar_das_code||'/'||pvar_fac_code||'/'||pvar_tim_code||') does not exist');
      end if;

      /*-*/
      /* Reset the package variables
      /*-*/
      pvar_das_code := null;
      pvar_fac_code := null;
      pvar_tim_code := null;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Reset the package variables
         /*-*/
         pvar_das_code := null;
         pvar_fac_code := null;
         pvar_tim_code := null;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Fact Function - Finalise Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_loader;

   /******************************************************/
   /* This procedure performs the get fact table routine */
   /******************************************************/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_fac_table pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fac_hedr is
         select t01.*
           from qvi_fac_hedr t01
          where t01.qfh_das_code = par_das_code
            and t01.qfh_fac_code = par_fac_code
            and t01.qfh_tim_code = par_tim_code;
      rcd_fac_hedr csr_fac_hedr%rowtype;

      cursor csr_fac_data is
         select t01.*
           from qvi_fac_data t01
          where t01.qfd_das_code = rcd_fac_hedr.qfh_das_code
            and t01.qfd_fac_code = rcd_fac_hedr.qfh_fac_code
            and t01.qfd_tim_code = rcd_fac_hedr.qfh_tim_code
          order by t01.qfd_dat_seqn asc;
      rcd_fac_data csr_fac_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the selected fact header
      /*-*/
      open csr_fac_hedr;
      fetch csr_fac_hedr into rcd_fac_hedr;
      if csr_fac_hedr%found then

         /*-*/
         /* Retrieve and pipe the fact data
         /*-*/
         open csr_fac_data;
         loop
            fetch csr_fac_data into rcd_fac_data;
            if csr_fac_data%notfound then
               exit;
            end if;
            pipe row(qvi_fac_object(rcd_fac_data.qfd_das_code,
                                    rcd_fac_data.qfd_fac_code,
                                    rcd_fac_data.qfd_tim_code,
                                    rcd_fac_data.qfd_dat_seqn,
                                    rcd_fac_data.qfd_dat_data));
         end loop;
         close csr_fac_data;

      end if;
      close csr_fac_hedr;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   pvar_das_code := null;
   pvar_fac_code := null;
   pvar_tim_code := null;
   pvar_dat_seqn := 0;

end qvi_fac_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_fac_function for qv_app.qvi_fac_function;
