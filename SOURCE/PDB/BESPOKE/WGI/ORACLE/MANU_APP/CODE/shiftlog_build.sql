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

  *******************************************************************************/

  /*-*/
  /* Public declarations
  /*-*/
  procedure execute_fg_matl;

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