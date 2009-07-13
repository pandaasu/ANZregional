create or replace package icb_app.ics_pdbicb01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
  System  : ICB
  Package : ics_pdbicb01
  Owner   : ICB_APP
  Author  : Trevor Keon

  Description
  -----------
    PDB -> ICB MATERIAL DATA

    PARAMETERS: <NONE>

  YYYY/MM   Author               Description
  -------   ------               -----------
  2009/05   Trevor Keon          Created
  2009/07   Liam Watson          Changed to fix leading space on next_prodn_date field

*******************************************************************************/

  /*-*/
  /* Public declarations
  /*-*/
  procedure execute;

end ics_pdbicb01;
/

create or replace package body icb_app.ics_pdbicb01 as

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Constants
  /*-*/
  var_interface constant varchar2(10) := 'PDBICB01.5';

/***********************************************/
/* This procedure performs the execute routine */
/***********************************************/
procedure execute is

  /*-*/
  /* Local Variables
  /*-*/
  var_instance number(15,0);

  /*-*/
  /* Local Cursors
  /*-*/
  cursor csr_material_data is
    select ltrim(t01.sap_material_code, '0') as sap_material_code,
      t01.bds_material_desc_en as bds_material_desc_en,
      to_char(t01.gross_weight,'999990.000') as gross_weight,
      t01.gross_weight_unit as gross_weight_unit,
      to_char(t02.volume,'999990.000') as volume,
      t02.volume_unit as volume_unit,
      t03.target_qty as target_qty,  
      t04.next_prodn_date as next_prodn_date,
      t05.stock_quantity as stock_quantity
    from bds_material_plant_mfanz t01,
      bds_material_uom t02,
      bds_material_pkg_instr_det t03,
      (
        select material_code, 
          min(next_prodn_date) as next_prodn_date
        from
          (
            --select latest production dates as planned in apollo
            select t01.material_code as material_code,
              min(t01.mars_week) as next_prodn_date
            from apollo_prodn_plan t01,
              mars_date t02
            where t01.mars_week = t02.mars_week
              and t02.calendar_date >= sysdate
            group by t01.material_code
            union all      
            --select all material production dates from the esched_atlas_schedule table where the mars_week is this week onwards 
            select t01.material_code, 
              min(t02.mars_week) as next_prodn_date
            from esched_atlas_schedule t01,
              mars_date t02,
              mars_date t03
            where to_char(t01.proc_order_start_dt, 'YYYY-MM-DD') = to_char(t02.calendar_date, 'YYYY-MM-DD')
              and to_char(t03.calendar_date, 'YYYY-MM-DD') = to_char(sysdate, 'YYYY-MM-DD')
              and t02.mars_week >= t03.mars_week
            group by t01.material_code
          ) t01
        group by material_code
      ) t04,
      (
        select material_code,
          sum(stock_quantity) as stock_quantity
        from bds_stock_balance t01
        where stock_type_code = 1 
          and plant_code in ('AU40','AU41','AU42')
        group by material_code
      ) t05
    where t01.plant_code = 'AU42'
      and t01.sap_material_code = t02.sap_material_code
      and t02.sap_material_code = t03.sap_material_code
      and t03.sap_material_code = t04.material_code(+)
      and t03.sap_material_code = t05.material_code(+)
      and t03.sales_organisation = '147'
      and t03.pkg_instr_start_date <= trunc (sysdate)
      and t03.pkg_instr_end_date >= trunc (sysdate)
      and t01.material_type = 'FERT'
      and (t01.mars_traded_unit_flag = 'X' or t01.mars_intrmdt_prdct_compnt_flag = 'X')
      and t01.plant_specific_status = '20'
      and t01.xplant_status = '10'
      and t02.uom_code = 'CS';
  rcd_material_data csr_material_data%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin     

    /*-*/
    /* Open cursor for output
    /*-*/
    open csr_material_data;
    loop
      fetch csr_material_data into rcd_material_data;
      exit when csr_material_data%notfound;
      
      if ( lics_outbound_loader.is_created = false ) then
        var_instance := lics_outbound_loader.create_interface(var_interface, null, var_interface);
      end if;
      
      lics_outbound_loader.append_data('HDR'
        || rpad(nvl(to_char(rcd_material_data.sap_material_code),' '),8,' ')
        || rpad(nvl(to_char(rcd_material_data.bds_material_desc_en),' '),40,' ')
        || rpad(nvl(to_char(rcd_material_data.gross_weight),' '),10,' ')
        || rpad(nvl(to_char(rcd_material_data.gross_weight_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_material_data.volume),' '),10,' ')
        || rpad(nvl(to_char(rcd_material_data.volume_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_material_data.target_qty),' '),6,' ')
        || rpad(nvl(to_char(rcd_material_data.next_prodn_date),' '),7,' ')
        || lpad(nvl(to_char(rcd_material_data.stock_quantity),' '),12,' '));

    end loop;
    close csr_material_data;

    /*-*/
    /* Finalise Interface
    /*-*/
    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
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
    /* Rollback the database
    /*-*/
    rollback;

    /*-*/
    /* Close Interface
    /*-*/
    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
      lics_outbound_loader.finalise_interface;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end execute;

end ics_pdbicb01;
/

/*-*/
/* Authority 
/*-*/
grant execute on icb_app.ics_pdbicb01 to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ics_pdbicb01 for icb_app.ics_pdbicb01;