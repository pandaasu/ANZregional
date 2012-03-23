/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_src_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_src_function
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Source Functions

    This package contain the source data functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Corrected cursor notfounds in start_loader and sequence update in append_data
    
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure start_loader(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2);
   procedure append_data(par_data in sys.anydata);
   procedure finalise_loader;
   function get_tables(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) return qvi_src_table pipelined;

end qvi_src_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_src_function as

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
   pvar_par_code varchar2(32);
   pvar_dat_seqn number;

   /**********************************************************/
   /* This function performs the start source loader routine */
   /**********************************************************/
   procedure start_loader(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      rcd_qvi_fac_time qvi_fac_time%rowtype;
      rcd_qvi_src_hedr qvi_src_hedr%rowtype;

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

      cursor csr_fac_part is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = par_das_code
            and t01.qfp_fac_code = par_fac_code
            and t01.qfp_par_code = par_par_code;
      rcd_fac_part csr_fac_part%rowtype;

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
      pvar_par_code := null;
      pvar_dat_seqn := 0;

      /*-*/
      /* Retrieve the requested dashboard
      /* notes - must exist
      /*         must be active
      /*-*/
      var_found := true;
      open csr_das_defn;
      fetch csr_das_defn into rcd_das_defn;
      if csr_das_defn%notfound then
         var_found := false;
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
      var_found := true;
      open csr_fac_defn;
      fetch csr_fac_defn into rcd_fac_defn;
      if csr_fac_defn%notfound then
         var_found := false;
      end if;
      close csr_fac_defn;
      if var_found = false then
         raise_application_error(-20000, 'Start Loader - Fact ('||par_das_code||'/'||par_fac_code||') does not exist');
      end if;
      if rcd_fac_defn.qfd_fac_status != '1' then
         raise_application_error(-20000, 'Start Loader - Fact ('||par_das_code||'/'||par_fac_code||') is not active');
      end if;

      /*-*/
      /* Retrieve the requested dimension fact part
      /* notes - must exist
      /*         must be active
      /*-*/
      var_found := true;
      open csr_fac_part;
      fetch csr_fac_part into rcd_fac_part;
      if csr_fac_part%notfound then
         var_found := false;
      end if;
      close csr_fac_part;
      if var_found = false then
         raise_application_error(-20000, 'Start Loader - Fact Part ('||par_das_code||'/'||par_fac_code||'/'||par_par_code||') does not exist');
      end if;
      if rcd_fac_part.qfp_par_status != '1' then
         raise_application_error(-20000, 'Start Loader - Fact Part ('||par_das_code||'/'||par_fac_code||'/'||par_par_code||') is not active');
      end if;

      /*-*/
      /* Retrieve the requested dimension fact time
      /* notes - create when not found
      /* 1. When found must not be time status 2 (completed)
      /* 2. When not found create and set time status to 1 (created)
      /*-*/
      var_found := true;
      open csr_fac_time;
      fetch csr_fac_time into rcd_fac_time;
      if csr_fac_time%notfound then
         var_found := false;
      end if;
      close csr_fac_time;
      if var_found = true then
         if rcd_fac_time.qft_tim_status = '2' then
            raise_application_error(-20000, 'Start Loader - Fact Time ('||par_das_code||'/'||par_fac_code||'/'||par_tim_code||') is already completed');
         end if;
      else
         begin
            rcd_qvi_fac_time.qft_das_code := par_das_code;
            rcd_qvi_fac_time.qft_fac_code := par_fac_code;
            rcd_qvi_fac_time.qft_tim_code := par_tim_code;
            rcd_qvi_fac_time.qft_tim_status := '1';
            rcd_qvi_fac_time.qft_upd_user := user;
            rcd_qvi_fac_time.qft_upd_date := sysdate;
            insert into qvi_fac_time values rcd_qvi_fac_time;
         exception
            when dup_val_on_index then
               null;
         end;
      end if;

      /*-*/
      /* Lock the requested source header (oracle default wait behaviour - lock will hold until commit or rollback)
      /* 1. Set the load status to 1 (loading)
      /* 2. Set the load start date to sysdate
      /* 3. Set the load end date to sysdate
      /*-*/
      
      begin
         rcd_qvi_src_hedr.qsh_das_code := par_das_code;
         rcd_qvi_src_hedr.qsh_fac_code := par_fac_code;
         rcd_qvi_src_hedr.qsh_tim_code := par_tim_code;
         rcd_qvi_src_hedr.qsh_par_code := par_par_code;
         rcd_qvi_src_hedr.qsh_lod_status := '1';
         rcd_qvi_src_hedr.qsh_str_date := sysdate;
         rcd_qvi_src_hedr.qsh_end_date := sysdate;
         insert into qvi_src_hedr values rcd_qvi_src_hedr;
      exception
         when dup_val_on_index then
            update qvi_src_hedr
               set qsh_lod_status = '1',
                   qsh_str_date = sysdate,
                   qsh_end_date = sysdate
             where qsh_das_code = par_das_code
               and qsh_fac_code = par_fac_code
               and qsh_tim_code = par_tim_code
               and qsh_par_code = par_par_code;
            if sql%notfound then
               raise_application_error(-20000, 'Start Loader - Source ('||par_das_code||'/'||par_fac_code||'/'||par_tim_code||'/'||par_par_code||') does not exist');
            end if;

            /*-*/
            /* Remove the existing source data
            /*-*/
            delete from qvi_src_data
             where qsd_das_code = par_das_code
               and qsd_fac_code = par_fac_code
               and qsd_tim_code = par_tim_code
               and qsd_par_code = par_par_code;

      end;

      /*-*/
      /* Set the package variables
      /*-*/
      pvar_das_code := par_das_code;
      pvar_fac_code := par_fac_code;
      pvar_tim_code := par_tim_code;
      pvar_par_code := par_par_code;
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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Source Function - Start Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_loader;

   /**********************************************************/
   /* This procedure performs the append source data routine */
   /**********************************************************/
   procedure append_data(par_data in sys.anydata) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_qvi_src_data qvi_src_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Source loader must be started
      /*-*/
      if pvar_das_code is null then
         raise_application_error(-20000, 'Append Data - Source loader has not been started');
      end if;

      /*-*/
      /* Create the new source data
      /*-*/
      rcd_qvi_src_data.qsd_das_code := pvar_das_code;
      rcd_qvi_src_data.qsd_fac_code := pvar_fac_code;
      rcd_qvi_src_data.qsd_tim_code := pvar_tim_code;
      rcd_qvi_src_data.qsd_par_code := pvar_par_code;
      pvar_dat_seqn := pvar_dat_seqn + 1;
      rcd_qvi_src_data.qsd_dat_seqn := pvar_dat_seqn;
      rcd_qvi_src_data.qsd_dat_data := par_data;
      insert into qvi_src_data values rcd_qvi_src_data;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Source Function - Append Data - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /**************************************************************/
   /* This procedure performs the finalise source loader routine */
   /**************************************************************/
   procedure finalise_loader is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Source loader must be started
      /*-*/
      if pvar_das_code is null then
         raise_application_error(-20000, 'Append Data - Source loader has not been started');
      end if;

      /*-*/
      /* Update the source load status
      /* 1. Set the load status to 2 (loaded)
      /* 2. Set the load end date to sysdate
      /*-*/
      update qvi_src_hedr
         set qsh_lod_status = '2',
             qsh_end_date = sysdate
       where qsh_das_code = pvar_das_code
         and qsh_fac_code = pvar_fac_code
         and qsh_tim_code = pvar_tim_code
         and qsh_par_code = pvar_par_code;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Loader - Fact Part ('||pvar_das_code||'/'||pvar_fac_code||'/'||pvar_tim_code||'/'||pvar_par_code||') does not exist');
      end if;

      /*-*/
      /* Reset the package variables
      /*-*/
      pvar_das_code := null;
      pvar_fac_code := null;
      pvar_tim_code := null;
      pvar_par_code := null;

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
         pvar_par_code := null;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Source Function - Finalise Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_loader;

   /********************************************************/
   /* This procedure performs the get source table routine */
   /********************************************************/
   function get_tables(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) return qvi_src_table pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_src_hedr is
         select t01.*
           from qvi_src_hedr t01
          where t01.qsh_das_code = par_das_code
            and t01.qsh_fac_code = par_fac_code
            and t01.qsh_tim_code = par_tim_code
            and (par_par_code = '*ALL' or t01.qsh_par_code = par_par_code);
      rcd_src_hedr csr_src_hedr%rowtype;

      cursor csr_src_data is
         select t01.*
           from qvi_src_data t01
          where t01.qsd_das_code = rcd_src_hedr.qsh_das_code
            and t01.qsd_fac_code = rcd_src_hedr.qsh_fac_code
            and t01.qsd_tim_code = rcd_src_hedr.qsh_tim_code
            and t01.qsd_par_code = rcd_src_hedr.qsh_par_code
          order by t01.qsd_dat_seqn asc;
      rcd_src_data csr_src_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the selected source headers
      /*-*/
      open csr_src_hedr;
      loop
         fetch csr_src_hedr into rcd_src_hedr;
         if csr_src_hedr%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve and pipe the source data
         /*-*/
         open csr_src_data;
         loop
            fetch csr_src_data into rcd_src_data;
            if csr_src_data%notfound then
               exit;
            end if;
            pipe row(qvi_src_object(rcd_src_data.qsd_das_code,
                                    rcd_src_data.qsd_fac_code,
                                    rcd_src_data.qsd_tim_code,
                                    rcd_src_data.qsd_par_code,
                                    rcd_src_data.qsd_dat_seqn,
                                    rcd_src_data.qsd_dat_data));
         end loop;
         close csr_src_data;

      end loop;
      close csr_src_hedr;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_tables;

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
   pvar_par_code := null;
   pvar_dat_seqn := 0;

end qvi_src_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_src_function for qv_app.qvi_src_function;
