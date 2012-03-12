/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_dim_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_dim_function
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Dimension Functions

    This package contain the dimension data functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure create_header(par_dim_code in varchar2);
   procedure append_data(par_data in sys.anydata);
   procedure finalise_header();
   function get_table(par_dim_code in varchar2) return qvi_dim_table pipelined;

end qvi_dim_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_dim_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**************************************************************/
   /* This function performs the create dimension header routine */
   /**************************************************************/
   procedure create_header(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_das_name varchar2(32);
      var_fac_code varchar2(32);
      var_tim_code varchar2(32);

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

      cursor csr_fac_hedr is
         select t01.*
           from qvi_fac_hedr t01
          where t01.qfh_das_code = var_das_code
                t01.qfh_fac_code = var_fac_code
                t01.qfh_tim_code = var_tim_code;
      rcd_fac_hedr csr_fac_hedr%rowtype;

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
         raise_application_error(-20000, 'Create Fact Header - Dashboard (' || var_das_code || ') does not exist');
      end if;
      if rcd_das_defn.qdd_das_status != '1' then
         raise_application_error(-20000, 'Create Fact Header - Dashboard (' || var_das_code || ') is not active');
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
         raise_application_error(-20000, 'Create Fact Header - Fact (' || var_fac_code || ') does not exist');
      end if;
      if rcd_fac_defn.qfd_fac_status != '1' then
         raise_application_error(-20000, 'Create Fact Header - Fact (' || var_fac_code || ') is not active');
      end if;

      /*-*/
      /* Create the new fact header
      /*-*/
      rcd_qvi_fac_hedr.hea_interface := rcd_lics_interface.int_interface;
      rcd_qvi_fac_hedr.hea_trc_count := 1;
      rcd_qvi_fac_hedr.hea_crt_time := sysdate;
      rcd_qvi_fac_hedr.hea_fil_name := var_fil_name;
      rcd_qvi_fac_hedr.hea_msg_name := var_msg_name;
      rcd_qvi_fac_hedr.hea_status := lics_constant.header_load_working;
      insert into qvi_fac_hedr
         (hea_header,
          hea_interface,
          hea_trc_count,
          hea_crt_user,
          hea_crt_time,
          hea_fil_name,
          hea_msg_name,
          hea_status)
         values(rcd_qvi_fac_hedr.hea_header,
                rcd_qvi_fac_hedr.hea_interface,
                rcd_qvi_fac_hedr.hea_trc_count,
                rcd_qvi_fac_hedr.hea_crt_user,
                rcd_qvi_fac_hedr.hea_crt_time,
                rcd_qvi_fac_hedr.hea_fil_name,
                rcd_qvi_fac_hedr.hea_msg_name,
                rcd_qvi_fac_hedr.hea_status);

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dimension Function - Create Header - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_header;

   /*************************************************************/
   /* This procedure performs the append dimension data routine */
   /*************************************************************/
   procedure append_data(par_data in sys.anydata) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_qvi_dim_data qvi_dim_data%rowtype;

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
      /* Create the new dimension data
      /*-*/
      rcd_qvi_dim_data.qdd_dim_code := pvar_dim_code;
      rcd_qvi_dim_data.qdd_dat_seqn := pvar_dat_seqn + 1;
      rcd_qvi_dim_data.qdd_dat_data := par_data;
      insert into qvi_dim_data values rcd_qvi_dim_data;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dimension Function - Append Data - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /*****************************************************************/
   /* This procedure performs the finalise dimension header routine */
   /*****************************************************************/
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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dimension Function - Finalise Header - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_header;

   /***********************************************************/
   /* This procedure performs the get dimension table routine */
   /***********************************************************/
   function get_table(par_dim_code in varchar2) return qvi_dim_table pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_dim_defn is
         select t01.*
           from qvi_dim_defn t01
          where t01.qdd_dim_code = par_dim_code;
      rcd_dim_defn csr_dim_defnr%rowtype;

      cursor csr_qvi_dim_data is
         select t01.*
           from qvi_dim_data t01
          where t01.qdd_dim_code = rcd_dim_defn.qdd_dim_code;
          order by t01.qdd_dat_seqn asc;
      rcd_qvi_dim_data csr_qvi_dim_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the selected dimension definition
      /*-*/
      open csr_qvi_dim_defn;
      fetch csr_qvi_dim_defn into rcd_qvi_dim_defn;
      if csr_qvi_dim_defn%found then

         /*-*/
         /* Retrieve and pipe the dimension data
         /*-*/
         open csr_qvi_dim_data;
         loop
            fetch csr_qvi_dim_data into rcd_qvi_dim_data;
            if csr_qvi_dim_data%notfound then
               exit;
            end if;
            pipe row(qvi_dim_object(rcd_qvi_dim_data.qdd_dim_code,
                                    rcd_qvi_dim_data.qdd_dat_seqn,
                                    rcd_qvi_dim_data.qdd_dat_data));
         end loop;
         close csr_qvi_dim_data;

      end if;
      close csr_qvi_dim_defn;

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
   var_hdr_control := null;

end qvi_dim_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_dim_function for qv_app.qvi_dim_function;
