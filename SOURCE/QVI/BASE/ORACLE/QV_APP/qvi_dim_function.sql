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
    2012/04   Mal Chambeyron Add Update Sequence to finalise_loader,
                             Add Polling Flag logic to skip Event Driven "Flag File"
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure start_loader(par_dim_code in varchar2);
   procedure append_data(par_data in sys.anydata);
   procedure finalise_loader;
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

   /*-*/
   /* Private definitions
   /*-*/
   pvar_dim_code varchar2(32);
   pvar_dat_seqn number;

   /*************************************************************/
   /* This function performs the start dimension loader routine */
   /*************************************************************/
   procedure start_loader(par_dim_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_dim_status varchar2(1);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the package
      /*-*/
      pvar_dim_code := null;
      pvar_dat_seqn := 0;

      /*-*/
      /* Lock the requested dimension definition (oracle default wait behaviour - lock will hold until commit or rollback)
      /* 1. Set the load status to 1 (loading)
      /* 2. Set the load start date to sysdate
      /* 3. Set the load end date to sysdate
      /*-*/
      update qvi_dim_defn
         set qdd_lod_status = '1',
             qdd_str_date = sysdate,
             qdd_end_date = sysdate
       where qdd_dim_code = par_dim_code
       returning qdd_dim_status into var_dim_status;
      if sql%notfound then
         raise_application_error(-20000, 'Start Loader - Dimension (' || par_dim_code || ') does not exist');
      end if;
      if var_dim_status != '1' then
         raise_application_error(-20000, 'Start Loader - Dimension (' || par_dim_code || ') is not active');
      end if;

      /*-*/
      /* Remove the existing dimension data
      /*-*/
      delete from qvi_dim_data where qdd_dim_code = par_dim_code;

      /*-*/
      /* Set the package variables
      /*-*/
      pvar_dim_code := par_dim_code;
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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dimension Function - Start Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_loader;

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
      /* Dimension loader must be started
      /*-*/
      if pvar_dim_code is null then
         raise_application_error(-20000, 'Append Data - Dimension loader has not been started');
      end if;

      /*-*/
      /* Create the new dimension data
      /*-*/
      pvar_dat_seqn := pvar_dat_seqn + 1;
      rcd_qvi_dim_data.qdd_dim_code := pvar_dim_code;
      rcd_qvi_dim_data.qdd_dat_seqn := pvar_dat_seqn;
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
   /* This procedure performs the finalise dimension loader routine */
   /*****************************************************************/
   procedure finalise_loader is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_flg_string varchar2(4000);
      var_instance number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_dim_defn is
         select t01.*
           from qvi_dim_defn t01
          where t01.qdd_dim_code = pvar_dim_code;
      rcd_dim_defn csr_dim_defn%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Dimension loader must be started
      /*-*/
      if pvar_dim_code is null then
         raise_application_error(-20000, 'Finalise Loader - Dimension loader has not been started');
      end if;

      /*-*/
      /* Retrieve the dimension definition
      /*-*/
      var_found := false;
      open csr_dim_defn;
      fetch csr_dim_defn into rcd_dim_defn;
      if csr_dim_defn%found then
         var_found := true;
      end if;
      close csr_dim_defn;
      if var_found = false then
         raise_application_error(-20000, 'Finalise Loader - Dimension (' || pvar_dim_code || ') does not exist');
      end if;

      /*-*/
      /* Update the dimension load status
      /* 1. Set the load status to 2 (loaded)
      /* 2. Set the load end date to sysdate
      /*-*/
      update qvi_dim_defn
         set qdd_lod_status = '2',
             qdd_upd_seqn = qvi_update_sequence.nextval, 
             qdd_end_date = sysdate
       where qdd_dim_code = pvar_dim_code;
      if sql%notfound then
         raise_application_error(-20000, 'Finalise Loader - Dimension (' || pvar_dim_code || ') does not exist');
      end if;

      /*-*/
      /* Create the flag file interface if Poll Flag is False (0) - Qlikview
      /*-*/
      if rcd_dim_defn.qdd_pol_flag = 0 then 
         begin
            var_instance := lics_outbound_loader.create_interface(rcd_dim_defn.qdd_flg_iface,null,rcd_dim_defn.qdd_flg_mname);
            var_flg_string := pvar_dim_code;
            var_flg_string := var_flg_string||',"'||rcd_dim_defn.qdd_dim_table||'('''||pvar_dim_code||''')"';
            lics_outbound_loader.append_data(var_flg_string);
            lics_outbound_loader.finalise_interface;
         exception
            when others then
               raise_application_error(-20000, 'Finalise Loader - Flag file interface failed - ' || substr(sqlerrm, 1, 1024));
         end;
      end if;

      /*-*/
      /* Reset the package variables
      /*-*/
      pvar_dim_code := null;

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
         pvar_dim_code := null;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dimension Function - Finalise Loader - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_loader;

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
      rcd_dim_defn csr_dim_defn%rowtype;

      cursor csr_dim_data is
         select t01.*
           from qvi_dim_data t01
          where t01.qdd_dim_code = rcd_dim_defn.qdd_dim_code
          order by t01.qdd_dat_seqn asc;
      rcd_dim_data csr_dim_data%rowtype;

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
      open csr_dim_defn;
      fetch csr_dim_defn into rcd_dim_defn;
      if csr_dim_defn%found then

         /*-*/
         /* Retrieve and pipe the dimension data
         /*-*/
         open csr_dim_data;
         loop
            fetch csr_dim_data into rcd_dim_data;
            if csr_dim_data%notfound then
               exit;
            end if;
            pipe row(qvi_dim_object(rcd_dim_data.qdd_dim_code,
                                    rcd_dim_data.qdd_dat_seqn,
                                    rcd_dim_data.qdd_dat_data));
         end loop;
         close csr_dim_data;

      end if;
      close csr_dim_defn;

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
   pvar_dim_code := null;

end qvi_dim_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_dim_function for qv_app.qvi_dim_function;
