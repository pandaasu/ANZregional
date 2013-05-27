
set define off;

-- Create Entity Access Package
create or replace package dds_app.quo_act_dtl_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : quo
  Owner   : dds_app
  Package : quo_act_dtl_pkg
  Author  : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Container Package to Provide Custom Views for Activities

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-27  Mal Chambeyron        Created
  2013-05-20  Tom Docherty			Restricted data to active customers and products returned for dist_check_view_at_date,
  		"			"				sos_psd_view_at_date, sos_spc_view_at_date, off_view_at_date

*******************************************************************************/

  -- Public : Type : Customer > Terrirory > Position > Rep ---------------------
  type quo_cust_to_rep_rec is record (
    source_id number(4,0),
    report_date date,
    --
    cust_id number(10,0),
    cust_batch_id number(15,0),
    cust_terr_id number(10,0),
    cust_terr_batch_id number(15,0),
    terr_id number(10,0),
    terr_batch_id number(15,0),
    pos_terr_id number(10,0),
    pos_terr_batch_id number(15,0),
    is_primary_terr number(1,0),
    pos_id number(10,0),
    pos_batch_id number(15,0),
    rep_id number(10,0),
    rep_batch_id number(15,0)
  );

  type quo_cust_to_rep_type is table of quo_cust_to_rep_rec;

  -- Public : Type : Distribution Check ----------------------------------------
  type quo_dist_check_rec is record (
    source_id number(4,0),
    report_date date,
    --
    act_id number(10,0),
    act_dtl_id number(10,0),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    prod_id number(10,0),
    prod_batch_id number(15,0),
    --
    is_ranged number(1,0),
    is_tag_missing number(1,0)
  );

  type quo_dist_check_type is table of quo_dist_check_rec;

  -- Public : Type : Off Location ----------------------------------------------
  type quo_off_rec is record (
    source_id number(4,0),
    report_date date,
    --
    act_id number(10,0),
    act_dtl_id number(10,0),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    prod_id number(10,0),
    prod_batch_id number(15,0),
    --
    no_ach_this_call number(18,4)
  );

  type quo_off_type is table of quo_off_rec;

  -- Public : Type : Share of Shelf, PSD ---------------------------------------
  type quo_sos_psd_rec is record (
    source_id number(4,0),
    report_date date,
    --
    act_id number(10,0),
    act_dtl_id number(10,0),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    prod_hier_id number(10,0),
    prod_hier_batch_id number(15,0),
    --
    sos_mars_shelves number(18,4),
    sos_nestle_shelves number(18,4),
    sos_private_label_shelves number(18,4),
    sos_other_label_shelves number(18,4)
  );

  type quo_sos_psd_type is table of quo_sos_psd_rec;

  -- Public : Type : Share of Shelf, Specialist --------------------------------
  type quo_sos_spc_rec is record (
    source_id number(4,0),
    report_date date,
    --
    act_id number(10,0),
    act_dtl_id number(10,0),
    cust_id number(10,0),
    cust_batch_id number(15,0),
    prod_hier_id number(10,0),
    prod_hier_batch_id number(15,0),
    --
    sos_advance_modules number(18,4),
    sos_eukanuba_modules number(18,4),
    sos_hills_modules number(18,4),
    sos_royalcanine_modules number(18,4),
    sos_proplan_modules number(18,4),
    sos_nutro_modules number(18,4),
    sos_other_natural_modules number(18,4),
    sos_mars_core_modules number(18,4),
    sos_other_modules number(18,4)
  );

  type quo_sos_spc_type is table of quo_sos_spc_rec;

  -- Public : Functions --------------------------------------------------------
  function cust_terr_pos_rep_view_at_date(p_source_id in number, p_at_date in date) return quo_cust_to_rep_type pipelined;

  function dist_check_view_at_date(p_source_id in number, p_at_date in date) return quo_dist_check_type pipelined;
  function off_view_at_date(p_source_id in number, p_at_date in date) return quo_off_type pipelined;
  function sos_psd_view_at_date(p_source_id in number, p_at_date in date) return quo_sos_psd_type pipelined;
  function sos_spc_view_at_date(p_source_id in number, p_at_date in date) return quo_sos_spc_type pipelined;

end quo_act_dtl_pkg;
/

create or replace package body dds_app.quo_act_dtl_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'quo_act_dtl_pkg';

  /*****************************************************************************
  ** Function : Customer > Terrirory > Position > Rep, as at Date
  *****************************************************************************/
  function cust_terr_pos_rep_view_at_date(p_source_id in number, p_at_date in date) return quo_cust_to_rep_type pipelined is

  begin

    for l_entity in (
    
      select cust.q4x_source_id source_id,
        sysdate report_date,
        cust.id cust_id,
        cust.q4x_batch_id cust_batch_id,
        cust_terr.id cust_terr_id,
        cust_terr.q4x_batch_id cust_terr_batch_id,
        terr.id terr_id,
        terr.q4x_batch_id terr_batch_id,
        pos_terr.id pos_terr_id,
        pos_terr.q4x_batch_id pos_terr_batch_id,
        pos_terr.is_primary_terr,
        pos.id pos_id,
        pos.q4x_batch_id pos_batch_id,
        rep.id rep_id,
        rep.q4x_batch_id rep_batch_id
      from table(quo_cust_pkg.view_at_date(p_source_id,p_at_date)) cust,
        table(quo_cust_terr_pkg.view_at_date(p_source_id,p_at_date)) cust_terr,
        table(quo_terr_pkg.view_at_date(p_source_id,p_at_date)) terr,
        table(quo_pos_terr_pkg.view_at_date(p_source_id,p_at_date)) pos_terr,
        table(quo_pos_pkg.view_at_date(p_source_id,p_at_date)) pos,
        table(quo_rep_pkg.view_at_date(p_source_id,p_at_date)) rep
      where cust.id = cust_terr.cust_id  
      and cust_terr.terr_id = terr.id  
      and terr.id = pos_terr.terr_id
      and pos_terr.pos_id = pos.id
      and pos.id = rep.pos_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_terr_pos_rep_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_terr_pos_rep_view_at_date;
  
  /*****************************************************************************
  ** Function : Distribution Check, as at Date
  *****************************************************************************/
  function dist_check_view_at_date(p_source_id in number, p_at_date in date) return quo_dist_check_type pipelined is

  begin

    for l_entity in (
    
      select latest_act_dtl.source_id,
        p_at_date report_date,
        --
        latest_act_dtl.act_id,
        latest_act_dtl.act_dtl_id,
        latest_act_dtl.cust_id,
        cust.q4x_batch_id cust_batch_id,
        latest_act_dtl.prod_id,
        prod.q4x_batch_id prod_batch_id,
        --
        latest_act_dtl.is_ranged,
        latest_act_dtl.is_tag_missing
        --
      from 
        (
          select latest_act_dtl.q4x_source_id source_id,
            p_at_date report_date,
            --
            act_dtl.act_id,
            latest_act_dtl.act_dtl_id,
            latest_act_dtl.cust_id,
            latest_act_dtl.prod_id,
            --
            act_dtl.is_ranged,
            act_dtl.is_tag_missing
            --
          from table(quo_act_dtl_dist_check_pkg.view_current(p_source_id)) act_dtl,
            (
              select act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_id,
                max(act_dtl.id) act_dtl_id
              from table(quo_act_dtl_dist_check_pkg.view_current(p_source_id)) act_dtl,
                table(quo_act_hdr_pkg.view_current(p_source_id)) act_hdr,
                table(quo_callcard_pkg.view_current(p_source_id)) callcard
              -- act_hdr date
              where act_dtl.q4x_source_id = p_source_id
              and act_hdr.start_date <= p_at_date
              -- act_dtl > act_hdr
              and act_dtl.q4x_source_id = act_hdr.q4x_source_id
              and act_dtl.act_id = act_hdr.id
              -- act_hdr > callcard
              and act_dtl.q4x_source_id = callcard.q4x_source_id
              and act_hdr.callcard_id = callcard.id
              --
              group by act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_id
            ) latest_act_dtl -- per cust / prod
          where act_dtl.q4x_source_id = latest_act_dtl.q4x_source_id
          and act_dtl.id = latest_act_dtl.act_dtl_id
        ) latest_act_dtl,
        table(quo_cust_pkg.view_at_date(p_source_id,p_at_date)) cust,
        table(quo_prod_pkg.view_at_date(p_source_id,p_at_date)) prod
      where latest_act_dtl.cust_id = cust.id
      and latest_act_dtl.prod_id = prod.id
	  and cust.is_active = 1
	  and prod.is_active = 1

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.dist_check_view_at_date] : '||SQLERRM, 1, 4000));

  end dist_check_view_at_date;

  /*****************************************************************************
  ** Function : Off Location, as at Date
  *****************************************************************************/
  function off_view_at_date(p_source_id in number, p_at_date in date) return quo_off_type pipelined is

  begin

    for l_entity in (
    
      select latest_act_dtl.source_id,
        sysdate report_date,
        --
        latest_act_dtl.act_id,
        latest_act_dtl.act_dtl_id,
        latest_act_dtl.cust_id,
        cust.q4x_batch_id cust_batch_id,
        latest_act_dtl.prod_id,
        prod.q4x_batch_id prod_batch_id,
        --
        latest_act_dtl.no_ach_this_call
        --
      from 
        (
          select latest_act_dtl.q4x_source_id source_id,
            sysdate report_date,
            --
            act_dtl.act_id,
            latest_act_dtl.act_dtl_id,
            latest_act_dtl.cust_id,
            latest_act_dtl.prod_id,
            --
            act_dtl.no_ach_this_call
            --
          from table(quo_act_dtl_off_pkg.view_current(p_source_id)) act_dtl,
            (
              select act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_id,
                max(act_dtl.id) act_dtl_id
              from table(quo_act_dtl_off_pkg.view_current(p_source_id)) act_dtl,
                table(quo_act_hdr_pkg.view_current(p_source_id)) act_hdr,
                table(quo_callcard_pkg.view_current(p_source_id)) callcard
              -- act_hdr date
              where act_dtl.q4x_source_id = p_source_id
              and act_hdr.start_date <= p_at_date
              -- act_dtl > act_hdr
              and act_dtl.q4x_source_id = act_hdr.q4x_source_id
              and act_dtl.act_id = act_hdr.id
              -- act_hdr > callcard
              and act_dtl.q4x_source_id = callcard.q4x_source_id
              and act_hdr.callcard_id = callcard.id
              --
              group by act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_id
            ) latest_act_dtl -- per cust / prod
          where act_dtl.q4x_source_id = latest_act_dtl.q4x_source_id
          and act_dtl.id = latest_act_dtl.act_dtl_id
        ) latest_act_dtl,
        table(quo_cust_pkg.view_at_date(p_source_id,p_at_date)) cust,
        table(quo_prod_pkg.view_at_date(p_source_id,p_at_date)) prod
      where latest_act_dtl.cust_id = cust.id
      and latest_act_dtl.prod_id = prod.id
	  and cust.is_active = 1
	  and prod.is_active = 1

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.off_view_at_date] : '||SQLERRM, 1, 4000));

  end off_view_at_date;

  /*****************************************************************************
  ** Function : Share of Shelf PSD, as at Date
  *****************************************************************************/
  function sos_psd_view_at_date(p_source_id in number, p_at_date in date) return quo_sos_psd_type pipelined is

  begin

    for l_entity in (
    
      select latest_act_dtl.source_id,
        sysdate report_date,
        --
        latest_act_dtl.act_id,
        latest_act_dtl.act_dtl_id,
        latest_act_dtl.cust_id,
        cust.q4x_batch_id cust_batch_id,
        latest_act_dtl.prod_hier_id,
        prod_hier.q4x_batch_id prod_hier_batch_id,
        --
        latest_act_dtl.sos_mars_shelves,
        latest_act_dtl.sos_nestle_shelves,
        latest_act_dtl.sos_private_label_shelves,
        latest_act_dtl.sos_other_label_shelves
        --
      from 
        (
          select latest_act_dtl.q4x_source_id source_id,
            sysdate report_date,
            --
            act_dtl.act_id,
            latest_act_dtl.act_dtl_id,
            latest_act_dtl.cust_id,
            latest_act_dtl.prod_hier_id,
            --
            act_dtl.sos_mars_shelves,
            act_dtl.sos_nestle_shelves,
            act_dtl.sos_private_label_shelves,
            act_dtl.sos_other_label_shelves
            --
          from table(quo_act_dtl_sos_psd_pkg.view_current(p_source_id)) act_dtl,
            (
              select act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_hier_id,
                max(act_dtl.id) act_dtl_id
              from table(quo_act_dtl_sos_psd_pkg.view_current(p_source_id)) act_dtl,
                table(quo_act_hdr_pkg.view_current(p_source_id)) act_hdr,
                table(quo_callcard_pkg.view_current(p_source_id)) callcard
              -- act_hdr date
              where act_dtl.q4x_source_id = p_source_id
              and act_hdr.start_date <= p_at_date
              -- act_dtl > act_hdr
              and act_dtl.q4x_source_id = act_hdr.q4x_source_id
              and act_dtl.act_id = act_hdr.id
              -- act_hdr > callcard
              and act_dtl.q4x_source_id = callcard.q4x_source_id
              and act_hdr.callcard_id = callcard.id
              --
              group by act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_hier_id
            ) latest_act_dtl -- per cust / prod
          where act_dtl.q4x_source_id = latest_act_dtl.q4x_source_id
          and act_dtl.id = latest_act_dtl.act_dtl_id
        ) latest_act_dtl,
        table(quo_cust_pkg.view_at_date(p_source_id,p_at_date)) cust,
        table(quo_hier_pkg.view_at_date(p_source_id,p_at_date)) prod_hier
      where latest_act_dtl.cust_id = cust.id
      and latest_act_dtl.prod_hier_id = prod_hier.id
	  and cust.is_active = 1
	  and prod_hier.is_active = 1

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.sos_psd_view_at_date] : '||SQLERRM, 1, 4000));

  end sos_psd_view_at_date;

  /*****************************************************************************
  ** Function : Share of Shelf Specialist, as at Date
  *****************************************************************************/
  function sos_spc_view_at_date(p_source_id in number, p_at_date in date) return quo_sos_spc_type pipelined is

  begin

    for l_entity in (
    
      select latest_act_dtl.source_id,
        sysdate report_date,
        --
        latest_act_dtl.act_id,
        latest_act_dtl.act_dtl_id,
        latest_act_dtl.cust_id,
        cust.q4x_batch_id cust_batch_id,
        latest_act_dtl.prod_hier_id,
        prod_hier.q4x_batch_id prod_hier_batch_id,
        --
        latest_act_dtl.sos_advance_modules,
        latest_act_dtl.sos_eukanuba_modules,
        latest_act_dtl.sos_hills_modules,
        latest_act_dtl.sos_royalcanine_modules,
        latest_act_dtl.sos_proplan_modules,
        latest_act_dtl.sos_nutro_modules,
        latest_act_dtl.sos_other_natural_modules,
        latest_act_dtl.sos_mars_core_modules,
        latest_act_dtl.sos_other_modules
        --
      from 
        (
          select latest_act_dtl.q4x_source_id source_id,
            sysdate report_date,
            --
            act_dtl.act_id,
            latest_act_dtl.act_dtl_id,
            latest_act_dtl.cust_id,
            latest_act_dtl.prod_hier_id,
            --
            act_dtl.sos_advance_modules,
            act_dtl.sos_eukanuba_modules,
            act_dtl.sos_hills_modules,
            act_dtl.sos_royalcanine_modules,
            act_dtl.sos_proplan_modules,
            act_dtl.sos_nutro_modules,
            act_dtl.sos_other_natural_modules,
            act_dtl.sos_mars_core_modules,
            act_dtl.sos_other_modules
            --
          from table(quo_act_dtl_sos_spc_pkg.view_current(p_source_id)) act_dtl,
            (
              select act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_hier_id,
                max(act_dtl.id) act_dtl_id
              from table(quo_act_dtl_sos_spc_pkg.view_current(p_source_id)) act_dtl,
                table(quo_act_hdr_pkg.view_current(p_source_id)) act_hdr,
                table(quo_callcard_pkg.view_current(p_source_id)) callcard
              -- act_hdr date
              where act_dtl.q4x_source_id = p_source_id
              and act_hdr.start_date <= p_at_date
              -- act_dtl > act_hdr
              and act_dtl.q4x_source_id = act_hdr.q4x_source_id
              and act_dtl.act_id = act_hdr.id
              -- act_hdr > callcard
              and act_dtl.q4x_source_id = callcard.q4x_source_id
              and act_hdr.callcard_id = callcard.id
              --
              group by act_dtl.q4x_source_id,
                callcard.cust_id,
                act_dtl.prod_hier_id
            ) latest_act_dtl -- per cust / prod
          where act_dtl.q4x_source_id = latest_act_dtl.q4x_source_id
          and act_dtl.id = latest_act_dtl.act_dtl_id
        ) latest_act_dtl,
        table(quo_cust_pkg.view_at_date(p_source_id,p_at_date)) cust,
        table(quo_hier_pkg.view_at_date(p_source_id,p_at_date)) prod_hier
      where latest_act_dtl.cust_id = cust.id
      and latest_act_dtl.prod_hier_id = prod_hier.id
	  and cust.is_active = 1
	  and prod_hier.is_active = 1

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.sos_spc_view_at_date] : '||SQLERRM, 1, 4000));

  end sos_spc_view_at_date;
  
end quo_act_dtl_pkg;
/

-- Synonyms
create or replace public synonym quo_act_dtl_pkg for dds_app.quo_act_dtl_pkg;

-- Grants
grant execute on dds_app.quo_act_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
