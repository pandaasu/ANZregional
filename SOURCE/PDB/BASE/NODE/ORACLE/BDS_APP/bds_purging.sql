/******************/
/* Package Header */
/******************/
create or replace package bds_purging as

/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/**
  System  : bds 
  Package : bds_purging 
  Owner   : bds_app 
  Author  : Trevor Keon 

  DESCRIPTION 
  ----------- 
  Business Data Store - Purging 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/05   Trevor Keon    Created 
  2008/07   Trevor Keon    Added recipe_purge into purge_ladpdb01 procedure
  2008/09   Trevor Keon    Added purging to LADPDB03 and LADPDB10
  2008/10   Trevor Keon    Added purging to LADPDB02 and LADPDB12
  2008/10   Trevor Keon    Removed purging for LADPDB14 and LADPDB15

*******************************************************************************/ 

   /*-*/
   /* Public declarations 
   /*-*/
   procedure execute;

end bds_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_ladpdb01;
   procedure purge_ladpdb02;
   procedure purge_ladpdb03_10;
   procedure purge_ladpdb12;

   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'BDS_PURGING';
   cnt_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the LADPDB01 (process order) 
      /*-*/
      purge_ladpdb01;
      
      /*-*/
      /* Purge the LADPDB02 (materials) 
      /*-*/
      purge_ladpdb02;      
      
      /*-*/
      /* Purge the LADPDB03 and LADPDB10 (customer addresses and sales area) 
      /*-*/
      purge_ladpdb03_10; 

      /*-*/
      /* Purge the LADPDB12 (vendors) 
      /*-*/
      purge_ladpdb12;

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
         raise_application_error(-20000, 'FATAL ERROR - Business Data Store - Purging - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

  /******************************************************/
  /* This procedure performs the purge LADPDB01 routine */
  /******************************************************/
  procedure purge_ladpdb01 is

  /*-*/
  /* Local definitions
  /*-*/
  var_tecd_history number;
  var_valid_history number;
  var_validation_history number;
  
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.proc_order
    from bds_recipe_header t01
    where (run_start_datime < sysdate - var_tecd_history and teco_status = 'YES')
      or (run_start_datime < sysdate - var_valid_history and teco_status = 'NO' and proc_order between '0' and '9')
      or (upd_datime < sysdate - var_validation_history and proc_order not between '0' and '9');
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.proc_order
    from bds_recipe_header t01
    where t01.proc_order = rcd_header.proc_order
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the history days
    /*-*/
    var_tecd_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'LADPDB01_TECD'));
    var_valid_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'LADPDB01_VALID'));
    var_validation_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'LADPDB01_VALIDATION'));

    /*-*/
    /* Retrieve the headers
    /*-*/
    var_count := 0;
    open csr_header;
    loop
      if var_count >= cnt_process_count then
        if csr_header%isopen then
          close csr_header;
        end if;
        
        commit;
      
        open csr_header;
        var_count := 0;
      end if;
      
      fetch csr_header into rcd_header;
      if csr_header%notfound then
        exit;
      end if;

      /*-*/
      /* Increment the count
      /*-*/
      var_count := var_count + 1;

      /*-*/
      /* Attempt to lock the header
      /*-*/
      var_available := true;
      begin
        open csr_lock;
        fetch csr_lock into rcd_lock;
        if csr_lock%notfound then
          var_available := false;
        end if;
        
        exception
        when others then
          var_available := false;
      end;
      
      if csr_lock%isopen then
        close csr_lock;
      end if;

      /*-*/
      /* Delete the header and related data when available
      /*-*/
      if var_available = true then
        delete from bds_recipe_src_text where proc_order = rcd_lock.proc_order;
        delete from bds_recipe_src_value where proc_order = rcd_lock.proc_order;
        delete from bds_recipe_bom where proc_order = rcd_lock.proc_order;
        delete from bds_recipe_resource where proc_order = rcd_lock.proc_order;
        delete from bds_recipe_header where proc_order = rcd_lock.proc_order;          
      end if;

    end loop;
    close csr_header;

    /*-*/
    /* Commit the database
    /*-*/
    commit;
    
    /*-*/
    /* Remove any impacted recpe table data
    /*-*/    
    recipe_purge;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_ladpdb01;
  
  /******************************************************/
  /* This procedure performs the purge LADPDB02 routine */
  /******************************************************/
  procedure purge_ladpdb02 is

  /*-*/
  /* Local definitions
  /*-*/
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.sap_material_code
    from bds_material_plant_mfanz t01
    where t01.deletion_flag is not null
       or t01.plant_deletion_indctr is not null
       or t01.vltn_deletion_indctr is not null;
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.sap_material_code
    from bds_material_plant_mfanz t01
    where t01.sap_material_code = rcd_header.sap_material_code
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the headers
    /*-*/
    var_count := 0;
    open csr_header;
    loop
      if var_count >= cnt_process_count then
        if csr_header%isopen then
          close csr_header;
        end if;
        
        commit;
        
        open csr_header;
        var_count := 0;
      end if;
      
      fetch csr_header into rcd_header;
      if csr_header%notfound then
        exit;
      end if;

      /*-*/
      /* Increment the count
      /*-*/
      var_count := var_count + 1;

      /*-*/
      /* Attempt to lock the header
      /*-*/
      var_available := true;
      begin
        open csr_lock;
        fetch csr_lock into rcd_lock;
        if csr_lock%notfound then
          var_available := false;
        end if;
        
        exception
        when others then
          var_available := false;
      end;
      
      if csr_lock%isopen then
        close csr_lock;
      end if;

      /*-*/
      /* Delete the related data when available
      /*-*/
      if var_available = true then    
        delete
        from bds_material_uom
        where sap_material_code = rcd_lock.sap_material_code;
        
        delete
        from bds_material_pkg_instr_det
        where sap_material_code = rcd_lock.sap_material_code;
        
        delete
        from bds_material_plant_mfanz
        where sap_material_code = rcd_lock.sap_material_code;        
      end if;

    end loop;
    close csr_header;

    /*-*/
    /* Commit the database
    /*-*/
    commit;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_ladpdb02;
  
  /*******************************************************************/
  /* This procedure performs the purge LADPDB02 and LADPDB10 routine */
  /*******************************************************************/
  procedure purge_ladpdb03_10 is

  /*-*/
  /* Local definitions
  /*-*/
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.customer_code
    from bds_cust_sales_area t01
    where t01.deletion_flag is not null;
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.customer_code
    from bds_cust_sales_area t01
    where t01.customer_code = rcd_header.customer_code
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the headers
    /*-*/
    var_count := 0;
    open csr_header;
    loop
      if var_count >= cnt_process_count then
        if csr_header%isopen then
          close csr_header;
        end if;
        
        commit;
        
        open csr_header;
        var_count := 0;
      end if;
      
      fetch csr_header into rcd_header;
      if csr_header%notfound then
        exit;
      end if;

      /*-*/
      /* Increment the count
      /*-*/
      var_count := var_count + 1;

      /*-*/
      /* Attempt to lock the header
      /*-*/
      var_available := true;
      begin
        open csr_lock;
        fetch csr_lock into rcd_lock;
        if csr_lock%notfound then
          var_available := false;
        end if;
        
        exception
        when others then
          var_available := false;
      end;
      
      if csr_lock%isopen then
        close csr_lock;
      end if;

      /*-*/
      /* Delete the related data when available
      /*-*/
      if var_available = true then    
        delete
        from bds_addr_customer_det
        where customer_code = rcd_lock.customer_code;
        
        delete
        from bds_cust_sales_area
        where customer_code = rcd_lock.customer_code;        
      end if;

    end loop;
    close csr_header;

    /*-*/
    /* Commit the database
    /*-*/
    commit;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_ladpdb03_10;  

  /******************************************************/
  /* This procedure performs the purge LADPDB12 routine */
  /******************************************************/
  procedure purge_ladpdb12 is

  /*-*/
  /* Local definitions
  /*-*/
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.vendor_code
    from bds_vend_comp t01
    where t01.deletion_flag is not null;
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.vendor_code
    from bds_vend_comp t01
    where t01.vendor_code = rcd_header.vendor_code
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the headers
    /*-*/
    var_count := 0;
    open csr_header;
    loop
      if var_count >= cnt_process_count then
        if csr_header%isopen then
          close csr_header;
        end if;
        
        commit;
        
        open csr_header;
        var_count := 0;
      end if;
      
      fetch csr_header into rcd_header;
      if csr_header%notfound then
        exit;
      end if;

      /*-*/
      /* Increment the count
      /*-*/
      var_count := var_count + 1;

      /*-*/
      /* Attempt to lock the header
      /*-*/
      var_available := true;
      begin
        open csr_lock;
        fetch csr_lock into rcd_lock;
        if csr_lock%notfound then
          var_available := false;
        end if;
        
        exception
        when others then
          var_available := false;
      end;
      
      if csr_lock%isopen then
        close csr_lock;
      end if;

      /*-*/
      /* Delete the related data when available
      /*-*/
      if var_available = true then    
        delete
        from bds_vend_comp
        where vendor_code = rcd_lock.vendor_code;       
      end if;

    end loop;
    close csr_header;

    /*-*/
    /* Commit the database
    /*-*/
    commit;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_ladpdb12;

end bds_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_purging for bds_app.bds_purging;
grant execute on bds_purging to public;