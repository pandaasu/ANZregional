create or replace package bds_app.bds_bom_build as

  /******************************************************************************/
  /* Package Definition                                                         */
  /******************************************************************************/
  /**
  System  : BDS (Business Data Store)
  Package : bds_bom_build
  Owner   : bds_app
  Author  : Trevor Keon

  Description
  -----------
  Business Data Store - BOM Build
    Build the BOM data into a table suitable for the plant database to use.

  PARAMETERS
    1. PAR_ACTION [MANDATORY]
      *DOCUMENT            - implements locks/commits internally
      *REFRESH             - process all BDS BOM records

  YYYY/MM   Author         Description
  -------   ------         -----------
  2008/10   Trevor Keon    Created

  *******************************************************************************/

  /*-*/
  /* Public declarations
  /*-*/
  procedure execute(par_action in varchar2, par_bom_material_code in varchar2 default null, par_bom_alternative in varchar2 default null, par_bom_plant in varchar2 default null);

end bds_bom_build;

create or replace package body bds_app.bds_bom_build as

  /*-*/
  /* Private Constants
  /*-*/
  c_bulk_limit constant number(5) := 1000;

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  snapshot_exception exception;
  pragma exception_init(application_exception, -20000);
  pragma exception_init(snapshot_exception, -1555);

  /*-*/
  /* Private declarations
  /*-*/
  procedure bds_lock(par_bom_material_code in varchar2, par_bom_alternative in varchar2, par_bom_plant in varchar2);
  procedure bds_build(par_bom_material_code in varchar2, par_bom_alternative in varchar2, par_bom_plant in varchar2);
  procedure bds_refresh;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_action in varchar2, par_bom_material_code in varchar2 default null, par_bom_alternative in varchar2 default null, par_bom_plant in varchar2 default null) is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
  
    /*-*/
    /* Only build for plant codes relevant to the plant
    /*-*/
    if ( par_bom_plant is null or par_bom_plant in ('AU40','AU42','AU45','AU82','AU83','AU84','AU85','AU86','AU87','AU88','AU89', 'AU90') ) then    
      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_lock(par_bom_material_code, par_bom_alternative, par_bom_plant);
        when '*REFRESH' then bds_refresh;
        else raise_application_error(-20000, 'Action parameter must be *DOCUMENT or *REFRESH');
      end case;
    
    end if;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

    /**/
    /* Exception trap
    /**/
    when others then

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise_application_error(-20000, 'bds_bom_build - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

  /*-------------*/
  /* End routine */
  /*-------------*/
  end execute;

  /***************************************************/
  /* This procedure perfroms the BDS Build routine */
  /***************************************************/
  procedure bds_build(par_bom_material_code in varchar2, par_bom_alternative in varchar2, par_bom_plant in varchar2) is

    /*-*/
    /* BDS record definitions
    /*-*/
    rcd_bds_bom_all bds_bom_all%rowtype;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_bds_bom_det is
      select t01.bom_material_code, 
        t01.bom_alternative, 
        t01.bom_plant,
        t01.bom_number, 
        t01.bom_msg_function, 
        t01.bom_usage,
        case
          when count = 1 and t02.bom_eff_from_date is not null
            then t02.bom_eff_from_date
          when count = 1 and t02.bom_eff_from_date is null
            then t01.bom_eff_from_date
          when count > 1 and t02.bom_eff_from_date is null
            then null
          when count > 1 and t02.bom_eff_from_date is not null
            then t02.bom_eff_from_date
        end as bom_eff_from_date,
        t01.bom_eff_to_date, 
        t01.bom_base_qty, 
        t01.bom_base_uom,
        t01.bom_status, 
        t01.item_sequence, 
        t01.item_number,
        t01.item_msg_function, 
        t01.item_material_code, 
        t01.item_category,
        t01.item_base_qty, 
        t01.item_base_uom, 
        t01.item_eff_from_date,
        t01.item_eff_to_date
      from bds_bom_det t01,
        bds_refrnc_hdr_altrnt t02,
        (
          select bom_material_code, 
            bom_plant, 
            count(*) as count
          from 
          (
            select distinct bom_material_code, 
              bom_plant,
              bom_alternative
            from bds_bom_det
          )
          group by bom_material_code, bom_plant
        ) t03
      where t01.bom_material_code = ltrim (t02.bom_material_code(+), ' 0')
        and t01.bom_alternative = ltrim (t02.bom_alternative(+), ' 0')
        and t01.bom_plant = t02.bom_plant(+)
        and t01.bom_usage = t02.bom_usage(+)
        and t01.bom_material_code = t03.bom_material_code
        and t01.bom_plant = t03.bom_plant
        and t01.bom_material_code = par_bom_material_code
        and t01.bom_alternative = par_bom_alternative
        and t01.bom_plant = par_bom_plant;
    rcd_bds_bom_det csr_bds_bom_det%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Perform BDS Flattening Logic
    /* **note** - assumes that a lock is held in a parent procedure
    /*          - assumes commit/rollback will be issued in a parent procedure
    /*-*/

    /*-*/
    /* Delete the BDS table child data
    /*-*/
    delete 
    from bds_bom_all
    where bom_material_code = par_bom_material_code
      and bom_alternative = par_bom_alternative
      and bom_plant = par_bom_plant;

    /*-*/
    /* Retrieve the LADS stock balance header
    /*-*/
    open csr_bds_bom_det;
    loop

      fetch csr_bds_bom_det into rcd_bds_bom_det;
      exit when csr_bds_bom_det%notfound;    

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_bom_all.bom_material_code := rcd_bds_bom_det.bom_material_code;
      rcd_bds_bom_all.bom_alternative := rcd_bds_bom_det.bom_alternative;
      rcd_bds_bom_all.bom_plant := rcd_bds_bom_det.bom_plant;
      rcd_bds_bom_all.bom_number := rcd_bds_bom_det.bom_number;
      rcd_bds_bom_all.bom_msg_function := rcd_bds_bom_det.bom_msg_function;
      rcd_bds_bom_all.bom_usage := rcd_bds_bom_det.bom_usage;
      rcd_bds_bom_all.bom_eff_from_date := rcd_bds_bom_det.bom_eff_from_date;
      rcd_bds_bom_all.bom_eff_to_date := rcd_bds_bom_det.bom_eff_to_date;
      rcd_bds_bom_all.bom_base_qty := rcd_bds_bom_det.bom_base_qty;
      rcd_bds_bom_all.bom_base_uom := rcd_bds_bom_det.bom_base_uom;
      rcd_bds_bom_all.bom_status := rcd_bds_bom_det.bom_status;
      rcd_bds_bom_all.item_sequence := rcd_bds_bom_det.item_sequence;
      rcd_bds_bom_all.item_number := rcd_bds_bom_det.item_number;
      rcd_bds_bom_all.item_msg_function := rcd_bds_bom_det.item_msg_function;
      rcd_bds_bom_all.item_material_code := rcd_bds_bom_det.item_material_code;
      rcd_bds_bom_all.item_category := rcd_bds_bom_det.item_category;
      rcd_bds_bom_all.item_base_qty := rcd_bds_bom_det.item_base_qty;
      rcd_bds_bom_all.item_base_uom := rcd_bds_bom_det.item_base_uom;
      rcd_bds_bom_all.item_eff_from_date := rcd_bds_bom_det.item_eff_from_date;
      rcd_bds_bom_all.item_eff_to_date := rcd_bds_bom_det.item_eff_to_date;
            
      insert into bds_bom_all
      (
        bom_material_code, 
        bom_alternative, 
        bom_plant,
        bom_number, 
        bom_msg_function, 
        bom_usage,
        bom_eff_from_date,
        bom_eff_to_date, 
        bom_base_qty, 
        bom_base_uom,
        bom_status, 
        item_sequence, 
        item_number,
        item_msg_function, 
        item_material_code, 
        item_category,
        item_base_qty, 
        item_base_uom, 
        item_eff_from_date,
        item_eff_to_date        
      )
      values
      (
        rcd_bds_bom_all.bom_material_code, 
        rcd_bds_bom_all.bom_alternative, 
        rcd_bds_bom_all.bom_plant,
        rcd_bds_bom_all.bom_number, 
        rcd_bds_bom_all.bom_msg_function, 
        rcd_bds_bom_all.bom_usage,
        rcd_bds_bom_all.bom_eff_from_date,
        rcd_bds_bom_all.bom_eff_to_date, 
        rcd_bds_bom_all.bom_base_qty, 
        rcd_bds_bom_all.bom_base_uom,
        rcd_bds_bom_all.bom_status, 
        rcd_bds_bom_all.item_sequence, 
        rcd_bds_bom_all.item_number,
        rcd_bds_bom_all.item_msg_function, 
        rcd_bds_bom_all.item_material_code, 
        rcd_bds_bom_all.item_category,
        rcd_bds_bom_all.item_base_qty, 
        rcd_bds_bom_all.item_base_uom, 
        rcd_bds_bom_all.item_eff_from_date,
        rcd_bds_bom_all.item_eff_to_date        
      ); 
    
    end loop;
    close csr_bds_bom_det;  

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

    /**/
    /* Exception trap
    /**/
    when others then

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise_application_error(-20000, 'BDS_FLATTEN - ' || 'Material: ' || par_bom_material_code || ' Alternate: ' || par_bom_alternative || ' Plant: ' || par_bom_plant || ' - ' || substr(SQLERRM, 1, 1024));

  /*-------------*/
  /* End routine */
  /*-------------*/ 
  end bds_build;

  /*******************************************************************************/
  /* This procedure performs the lock routine                                    */
  /*   notes - acquires a lock on the BDS header record                          */
  /*         - issues commit to release lock                                     */
  /*         - used when manually executing flattening                           */
  /*******************************************************************************/
  procedure bds_lock(par_bom_material_code in varchar2, par_bom_alternative in varchar2, par_bom_plant in varchar2) is

    /*-*/
    /* Local definitions
    /*-*/
    var_available boolean;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_lock is
      select t01.*
      from bds_bom_det t01
      where t01.bom_material_code = par_bom_material_code
        and t01.bom_alternative = par_bom_alternative
        and t01.bom_plant = par_bom_plant
      for update nowait;
    rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Attempt to lock the header row
    /* notes - must still exist
    /*         must not be locked
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
    /*-*/
    if csr_lock%isopen then
      close csr_lock;
    end if;
    /*-*/
    if (var_available) then

      /*-*/
      /* Build
      /*-*/
      bds_build(rcd_lock.bom_material_code, rcd_lock.bom_alternative, rcd_lock.bom_plant);

      /*-*/
      /* Commit
      /*-*/
      commit;

    else
      rollback;
    end if;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

    /**/
    /* Exception trap
    /**/
    when others then

      /*-*/
      /* Rollback database
      /*-*/
      rollback;

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end bds_lock;

  /******************************************************************************************/
  /* This procedure performs the refresh routine                                            */
  /*   notes - processes all BDS records
  /******************************************************************************************/
  procedure bds_refresh is

    /*-*/
    /* BDS record definitions
    /*-*/
    type bds_bom_array is table of bds_bom_all%rowtype;
    bds_bom_data bds_bom_array;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_bds_bom_det is
      select t01.bom_material_code, 
        t01.bom_alternative, 
        t01.bom_plant,
        t01.bom_number, 
        t01.bom_msg_function, 
        t01.bom_usage,
        case
          when count = 1 and t02.bom_eff_from_date is not null
            then t02.bom_eff_from_date
          when count = 1 and t02.bom_eff_from_date is null
            then t01.bom_eff_from_date
          when count > 1 and t02.bom_eff_from_date is null
            then null
          when count > 1 and t02.bom_eff_from_date is not null
            then t02.bom_eff_from_date
        end as bom_eff_from_date,
        t01.bom_eff_to_date, 
        t01.bom_base_qty, 
        t01.bom_base_uom,
        t01.bom_status, 
        t01.item_sequence, 
        t01.item_number,
        t01.item_msg_function, 
        t01.item_material_code, 
        t01.item_category,
        t01.item_base_qty, 
        t01.item_base_uom, 
        t01.item_eff_from_date,
        t01.item_eff_to_date
      from bds_bom_det t01,
        bds_refrnc_hdr_altrnt t02,
        (
          select bom_material_code, 
            bom_plant, 
            count(*) as count
          from 
          (
            select distinct bom_material_code, 
              bom_plant,
              bom_alternative
            from bds_bom_det
          )
          group by bom_material_code, bom_plant
        ) t03
      where t01.bom_material_code = ltrim (t02.bom_material_code(+), ' 0')
        and t01.bom_alternative = ltrim (t02.bom_alternative(+), ' 0')
        and t01.bom_plant = t02.bom_plant(+)
        and t01.bom_usage = t02.bom_usage(+)
        and t01.bom_material_code = t03.bom_material_code
        and t01.bom_plant = t03.bom_plant
        and t01.bom_plant in ('AU40','AU42','AU45','AU82','AU83','AU84','AU85','AU86','AU87','AU88','AU89', 'AU90');

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin  
    
    bds_table.truncate('bds_bom_all');
          
    open csr_bds_bom_det;
    loop
      fetch csr_bds_bom_det bulk collect into bds_bom_data limit c_bulk_limit;
              
      forall i in 1..bds_bom_data.count
        insert into bds_bom_all values bds_bom_data(i);
              
      exit when csr_bds_bom_det%notfound;
    end loop;
    close csr_bds_bom_det;
  
    commit;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

    /**/
    /* Exception trap
    /**/
    when others then

      /*-*/
      /* Rollback database
      /*-*/
      rollback;

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end bds_refresh;

end bds_bom_build;