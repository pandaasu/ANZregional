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

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure create_header(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2);
   procedure append_data(par_data in sys.anydata);
   procedure finalise_header();
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
   rcd_qvi_src_hedr qvi_src_hedr%rowtype;

   /***********************************************************/
   /* This function performs the create source header routine */
   /***********************************************************/
   procedure create_header(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2, par_par_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_das_name varchar2(32);
      var_fac_code varchar2(32);
      var_tim_code varchar2(32);
      var_par_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_das_defn is
         select t01.*
           from qvi_das_defn t01
          where t01.qdd_das_code = var_das_code;
      rcd_das_defn csr_das_defn%rowtype;

      cursor csr_fac_defn is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = var_das_code
                t01.qfd_fac_code = var_fac_code;
      rcd_fac_defn csr_fac_defn%rowtype;

      cursor csr_fac_time is
         select t01.*
           from qvi_fac_time t01
          where t01.qft_das_code = var_das_code
                t01.qft_fac_code = var_fac_code
                t01.qft_tim_code = var_tim_code;
      rcd_fac_time csr_fac_time%rowtype;

      cursor csr_fac_part is
         select t01.*
           from qvi_fac_part t01
          where t01.qfp_das_code = var_das_code
                t01.qfp_fac_code = var_fac_code
                t01.qfp_par_code = var_par_code;
      rcd_fac_part csr_fac_part%rowtype;

      cursor csr_src_hedr is
         select t01.*
           from qvi_src_hedr t01
          where t01.qsh_das_code = var_das_code
                t01.qsh_fac_code = var_fac_code
                t01.qsh_tim_code = var_tim_code
                t01.qsh_par_code = var_par_code;
      rcd_src_hedr csr_src_hedr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the loacl variables
      /*-*/
      var_das_code := par_das_code;
      var_fac_code := par_fac_code;
      var_tim_code := par_tim_code;
      var_par_code := par_par_code;
      
      /*-*/
      /* Re-initialise the package
      /*-*/
      var_hdr_control := null;
      rcd_lics_header.hea_header := null;

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
         raise_application_error(-20000, 'Create Source Header - Dashboard (' || var_das_code || ') does not exist');
      end if;
      if rcd_das_defn.qdd_das_status != '1' then
         raise_application_error(-20000, 'Create Source Header - Dashboard (' || var_das_code || ') is not active');
      end if;

      /*-*/
      /* Retrieve the requested fact
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
         raise_application_error(-20000, 'Create Source Header - Fact (' || var_fac_code || ') does not exist');
      end if;
      if rcd_fac_defn.qfd_fac_status != '1' then
         raise_application_error(-20000, 'Create Source Header - Fact (' || var_fac_code || ') is not active');
      end if;

      /*-*/
      /* Create the new source header
      /*-*/
      rcd_qvi_src_hedr.hea_interface := rcd_lics_interface.int_interface;
      rcd_qvi_src_hedr.hea_trc_count := 1;
      rcd_qvi_src_hedr.hea_crt_time := sysdate;
      rcd_qvi_src_hedr.hea_fil_name := var_fil_name;
      rcd_qvi_src_hedr.hea_msg_name := var_msg_name;
      rcd_qvi_src_hedr.hea_status := lics_constant.header_load_working;
      insert into qvi_src_hedr
         (hea_header,
          hea_interface,
          hea_trc_count,
          hea_crt_user,
          hea_crt_time,
          hea_fil_name,
          hea_msg_name,
          hea_status)
         values(rcd_qvi_src_hedr.hea_header,
                rcd_qvi_src_hedr.hea_interface,
                rcd_qvi_src_hedr.hea_trc_count,
                rcd_qvi_src_hedr.hea_crt_user,
                rcd_qvi_src_hedr.hea_crt_time,
                rcd_qvi_src_hedr.hea_fil_name,
                rcd_qvi_src_hedr.hea_msg_name,
                rcd_qvi_src_hedr.hea_status);

      /*-*/
      /* Set the header control variable
      /*-*/
      var_hdr_control := rcd_lics_header.hea_header;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Source Function - Create Header - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_header;

   /**********************************************************/
   /* This procedure performs the append source data routine */
   /**********************************************************/
   procedure append_data(par_data in sys.anydata) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Append Data - Interface has not been created');
      end if;

      /*-*/
      /* Create the new source data
      /*-*/
      rcd_qvi_src_data.qsd_das_code := pvar_das_code;
      rcd_qvi_src_data.qsd_fac_code := pvar_fac_code;
      rcd_qvi_src_data.qsd_tim_code := pvar_tim_code;
      rcd_qvi_src_data.qsd_par_code := pvar_par_code;
      rcd_qvi_src_data.qsd_dat_seqn := pvar_dat_seqn + 1;
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
   /* This procedure performs the finalise source header routine */
   /**************************************************************/
   procedure finalise_header is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing header must exist
      /* notes - header control must not be null
      /*-*/
      if var_hdr_control is null then
         raise_application_error(-20000, 'Finalise Interface - Interface has not been created');
      end if;

      /*-*/
      /* Re-initialise the package
      /*-*/
      var_hdr_control := null;

      /*-*/
      /* Update the source header status and time
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      rcd_lics_hdr_trace.het_end_time := sysdate;
      if rcd_lics_hdr_trace.het_status = lics_constant.header_load_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed;
      else
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed_error;
      end if;
      update lics_hdr_trace
         set het_end_time = rcd_lics_hdr_trace.het_end_time,
             het_status = rcd_lics_hdr_trace.het_status
       where het_header = rcd_lics_hdr_trace.het_header
         and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Interface - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
      end if;

      /*-*/
      /* Update the header status
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_working then
         rcd_lics_header.hea_status := lics_constant.header_load_completed;
      else
         rcd_lics_header.hea_status := lics_constant.header_load_completed_error;
      end if;
      update lics_header
         set hea_status = rcd_lics_header.hea_status
       where hea_header = rcd_lics_header.hea_header;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Interface - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Source Function - Finalise Header - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_header;

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
                t01.qsh_fac_code = par_fac_code
                t01.qsh_tim_code = par_tim_code
                (par_par_code = '*ALL' or t01.qsh_par_code = par_par_code);
      rcd_src_hedr csr_src_hedr%rowtype;

      cursor csr_qvi_src_data is
         select t01.qfd_src_data
           from qvi_src_data t01
          where t01.qsd_das_code = rcd_src_hedr.qsh_das_code
            and t01.qsd_fac_code = rcd_src_hedr.qsh_fac_code
            and t01.qsd_tim_code = rcd_src_hedr.qsh_tim_code
                t01.qsd_par_code = rcd_src_hedr.qsh_par_code;
          order by t01.qsd_dat_seqn asc;
      rcd_qvi_src_data csr_qvi_src_data%rowtype;

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
      open csr_qvi_src_hedr;
      loop
         fetch csr_qvi_src_hedr into rcd_qvi_src_hedr;
         if csr_qvi_src_hedr%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve and pipe the source data
         /*-*/
         open csr_qvi_src_data;
         loop
            fetch csr_qvi_src_data into rcd_qvi_src_data;
            if csr_qvi_src_data%notfound then
               exit;
            end if;
            pipe row(qvi_src_object(rcd_qvi_src_data.qsd_das_code,
                                    rcd_qvi_src_data.qsd_fac_code,
                                    rcd_qvi_src_data.qsd_tim_code,
                                    rcd_qvi_src_data.qsd_par_code,
                                    rcd_qvi_src_data.qsd_dat_seqn,
                                    rcd_qvi_src_data.qsd_dat_data));
         end loop;
         close csr_qvi_src_data;

      end loop;
      close csr_qvi_src_hedr;

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
   var_hdr_control := null;

end qvi_src_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_src_function for qv_app.qvi_src_function;
