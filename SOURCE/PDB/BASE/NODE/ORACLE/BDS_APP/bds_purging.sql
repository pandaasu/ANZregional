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
   procedure purge_ladpdb14;
   procedure purge_ladpdb15;

   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'bds_purging';
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
      /* Purge the LADPDB14 (stock balance) 
      /*-*/
      purge_ladpdb14;

      /*-*/
      /* Purge the LADPDB15 (stock in transit) 
      /*-*/
      purge_ladpdb15;

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
    where t01.plant_code = rcd_header.plant_code
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

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_ladpdb01;

  /******************************************************/
  /* This procedure performs the purge LADPDB14 routine */
  /******************************************************/
  procedure purge_ladpdb14 is

  /*-*/
  /* Local definitions
  /*-*/
  var_history number;
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.company_code,
      t01.plant_code,
      t01.storage_location_code,
      t01.stock_balance_date,
      t01.stock_balance_time
    from bds_stock_header t01
    where t01.msg_timestamp < to_char((sysdate - var_history),'yyyymmddhh24miss');
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.company_code,
      t01.plant_code,
      t01.storage_location_code,
      t01.stock_balance_date,
      t01.stock_balance_time
    from bds_stock_header t01
    where t01.company_code = rcd_header.company_code
      and t01.plant_code = rcd_header.plant_code
      and t01.storage_location_code = rcd_header.storage_location_code
      and t01.stock_balance_date = rcd_header.stock_balance_date
      and t01.stock_balance_time =  rcd_header.stock_balance_time
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the history days
    /*-*/
    var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'LADPDB14'));

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
        delete
        from bds_stock_detail
        where company_code = rcd_lock.company_code
          and plant_code = rcd_lock.plant_code
          and storage_location_code = rcd_lock.storage_location_code
          and stock_balance_date = rcd_lock.stock_balance_date
          and stock_balance_time =  rcd_lock.stock_balance_time;
                    
        delete
        from bds_stock_header
        where company_code = rcd_lock.company_code
          and plant_code = rcd_lock.plant_code
          and storage_location_code = rcd_lock.storage_location_code
          and stock_balance_date = rcd_lock.stock_balance_date
          and stock_balance_time =  rcd_lock.stock_balance_time;
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
  end purge_ladpdb14;

  /******************************************************/
  /* This procedure performs the purge LADPDB15 routine */
  /******************************************************/
  procedure purge_ladpdb15 is

  /*-*/
  /* Local definitions
  /*-*/
  var_history number;
  var_count number;
  var_available boolean;

  /*-*/
  /* Local cursors
  /*-*/
  cursor csr_header is
    select t01.plant_code,
      t01.detseq
    from bds_intransit_detail t01
    where t01.record_timestamp < to_char((sysdate - var_history),'yyyymmddhh24mi');
  rcd_header csr_header%rowtype;

  cursor csr_lock is
    select t01.plant_code,
      t01.detseq
    from bds_intransit_detail t01
    where t01.plant_code = rcd_header.plant_code
      and t01.detseq = rcd_header.detseq
    for update nowait;
  rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the history days
    /*-*/
    var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'LADPDB15'));

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
        delete 
        from bds_intransit_detail 
        where plant_code = rcd_lock.plant_code
          and detseq = rcd_lock.detseq;
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
  end purge_ladpdb15;

end bds_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_purging for lads_app.bds_purging;
grant execute on bds_purging to public;