create or replace package manu_app.shiftlog_build as

  /******************************************************************************/
  /* Package Definition                                                         */
  /******************************************************************************/
  /**
  System  : MANU (Manufacturing)
  Package : shiftlog_build
  Owner   : manu_app
  Author  : Trevor Keon

  Description
  -----------
  Manufacturing - Shiftlog Build
    Build tables used by shiftlog to use most recent data from BDS.

  EXECUTE_FG_MATL
    Build data for the SITE_SHIFTLOG_FG_MATL table.  No parameters, full refresh
    only.

  YYYY/MM   Author         Description
  -------   ------         -----------
  2008/11   Trevor Keon    Created
  2009/01   Trevor Keon    Changed from truncate to delete
  2009/01   Trevor Keon    Added execute_svms_matl.  TEMP!!

  *******************************************************************************/

  /*-*/
  /* Public declarations
  /*-*/
  procedure execute_fg_matl;
  procedure execute_svms_matl;

end shiftlog_build;

create or replace package body manu_app.shiftlog_build as

  /*-*/
  /* Private Constants
  /*-*/
  c_bulk_limit constant number(5) := 1000;

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /***************************************************************************/
  /* This procedure performs the refresh routine on the                      */
  /* site_shiftlog_fg_matl table                                             */
  /***************************************************************************/
  procedure execute_fg_matl is

    /*-*/
    /* Record definitions
    /*-*/
    type site_shiftlog_fg_matl_array is table of site_shiftlog_fg_matl%rowtype;
    site_shiftlog_fg_matl_data site_shiftlog_fg_matl_array;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_site_shiftlog_fg_matl is
      select distinct t01.material_code as matl_code, 
        t01.material_desc as matl_desc,
        t02.units_per_case as units_per_case, 
        t01.gross_wght as gross_wght,
        t01.dclrd_uom as gross_wght_uom
      from material t01,
        (
          select t11.matl_code, 
            t11.units_per_case, 
            t11.units_per_case_date
          from material_pllt t11
          union
          select t12.matl_code, 
            t12.units_per_case, 
            t12.units_per_case_date
          from material_pllt_nc t12
        ) t02
      where t01.material_code = ltrim (t02.matl_code(+), '0')
        and t01.material_type = 'FERT'
        and t01.rsu_code is null
        and t02.units_per_case is not null
        and t01.material_code not in (select matl_code from site_mvms_pllt)
        and 
          (
            t02.units_per_case_date =
              (
                select max (units_per_case_date)
                from 
                  (
                    select matl_code, 
                      units_per_case_date
                    from material_pllt
                    union
                    select matl_code, 
                      units_per_case_date
                    from material_pllt_nc
                  ) t99
                where t99.matl_code = t02.matl_code
              )
            or t02.units_per_case_date is null
          )
        and (t02.units_per_case_date <= sysdate or t02.units_per_case_date is null)
      union all
      select t01.matl_code, 
        t01.matl_desc, 
        t01.units_per_case, 
        t01.gross_wght, 
        t01.gross_wght_uom
      from site_mvms_pllt t01;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin  
    
    /*-*/
    /* Remove existing data
    /*-*/  
    delete
    from site_shiftlog_fg_matl;
   
    /*-*/
    /* Insert most recent data
    /*-*/           
    open csr_site_shiftlog_fg_matl;
    loop
      fetch csr_site_shiftlog_fg_matl bulk collect into site_shiftlog_fg_matl_data limit c_bulk_limit;
              
      forall i in 1..site_shiftlog_fg_matl_data.count
        insert into site_shiftlog_fg_matl values site_shiftlog_fg_matl_data(i);
              
      exit when csr_site_shiftlog_fg_matl%notfound;
    end loop;
    close csr_site_shiftlog_fg_matl;
  
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
      raise_application_error(-20000, 'shiftlog_build - EXECUTE_FG_MATL ' || ' - ' || substr(SQLERRM, 1, 1024));

  /*-------------*/
  /* End routine */
  /*-------------*/
  end execute_fg_matl;

  /***************************************************************************/
  /* This procedure performs the refresh routine on the material_svms table  */
  /***************************************************************************/
  procedure execute_svms_matl is

    /*-*/
    /* Record definitions
    /*-*/
    type svms_matl_array is table of material_svms%rowtype;
    svms_matl_data svms_matl_array;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_svms_matl is
      select t01.material, t01.units_per_case, t02.material_desc, t02.gross_wght, t02.dclrd_uom, t02.dclrd_wght 
      from
        (
          select distinct t01.material, (t01.qty / t01.batch_qty) * (t02.qty / t02.batch_qty) as units_per_case
          from bom t01,
            bom t02
          where t01.sub_matl = t02.material
            and t01.material in 
            (
              select ltrim(sap_material_code, '0')
              from bds_material_plant_mfanz 
              where 
                (
                  bds_material_desc_en like '%SVMS%'
                  or ltrim(sap_material_code, '0') in ('10063500','10063502','10066274','10066273','10063503','10063501','10063505','10066276',
                    '10066275','10071780','10074623','10074622','10074620','10074621')
                )  
                and plant_code in ('NZ01','NZ11')
                and material_type = 'FERT'
                and plant_specific_status = '20'
                and mars_traded_unit_flag = 'X'  
            )
            and t01.alternate = get_alternate(t01.material) 
            and t01.eff_start_date = get_alternate_date(t01.material)
            and t01.uom = 'EA' 
            and length(t01.sub_matl) = 8
            and length(t02.sub_matl) = 8
        ) t01,
        material t02
      where t01.material = t02.material_code;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin  
    
    /*-*/
    /* Remove existing data
    /*-*/  
    delete
    from material_svms;
   
    /*-*/
    /* Insert most recent data
    /*-*/           
    open csr_svms_matl;
    loop
      fetch csr_svms_matl bulk collect into svms_matl_data limit c_bulk_limit;
              
      forall i in 1..svms_matl_data.count
        insert into material_svms values svms_matl_data(i);
              
      exit when csr_svms_matl%notfound;
    end loop;
    close csr_svms_matl;
  
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
      raise_application_error(-20000, 'shiftlog_build - EXECUTE_SVMS_MATL ' || ' - ' || substr(SQLERRM, 1, 1024));

  /*-------------*/
  /* End routine */
  /*-------------*/
  end execute_svms_matl;

end shiftlog_build;

/**/
/* Authority 
/**/
grant execute on manu_app.shiftlog_build to lics_app;
grant execute on manu_app.shiftlog_build to bds_app;
grant execute on manu_app.shiftlog_build to appsupport;

/**/
/* Synonym 
/**/
create or replace public synonym shiftlog_build for manu_app.shiftlog_build;