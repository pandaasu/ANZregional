prompt :: Compile Package [pxipmx01_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx01_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX01_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Product Data - PX Interface 302 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 2013-07-24    Chris Horn            Created.
 2013-07-27    Mal Chambeyron        Formatted SQL Output.
 2013-08-21    Chris Horn            Cleaned Up Code.
 2013-08-27    Chris Horn            Updated logic.
 2013-08-29    Chris Horn            Fixed a bug in the RSU determination logic.
 2013-11-04	   Jonathan Girling      Updated logic.
 2014-01-06    Mal Chambeyron        Revise logic to utilise pipeline, to
                                     facilitate debug and imporve performance
 2013-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of product data.

             It defaults to all available live promax companies and divisions
             and just current data as of yesterday.  If null is supplied as
             the creation date then historial information will be supplied
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.
  1.3   2013-08-27 Chris Horn           Implemented New Product Logic.
  1.4   2013-09-12 Chris Horn           Changed the deleted status to 4.
  1.5   2013-11-04 Jonathan Girling     Updated pmx_matl_tdu_to_rsu insert statement
                                        to include bom_status 5 in query.
                                        Updated xdstrbtn_chain_status check to
                                        allow status 40.
  1.6   2014-01-06 Mal Chambeyron       Revise logic to utilise pipeline, to
                                        facilitate debug and imporve performance

*******************************************************************************/

  procedure execute (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  );

  ------------------------------------------------------------------------------
  -- pt_zrep : ZREP

  type rt_zrep is record (
    promax_company                  pxi.pmx_extract_criteria.promax_company%type,
    promax_division                 pxi.pmx_extract_criteria.promax_division%type,
    sales_org                       bds_material_dstrbtn_chain.sales_organisation%type,
    dstrbtn_channel                 bds_material_dstrbtn_chain.dstrbtn_channel%type,
    dstrbtn_chain_status            bds_material_dstrbtn_chain.dstrbtn_chain_status%type,
    xdstrbtn_chain_status           bds_material_hdr.xdstrbtn_chain_status%type,
    zrep_matl_code                  bds_material_hdr.sap_material_code%type,
    zrep_matl_desc                  bds_material_hdr.bds_material_desc_en%type,
    moe_code                        bds_material_moe.moe_code%type,
    moe_start_date                  bds_material_moe.start_date%type,
    moe_end_date                    bds_material_moe.end_date%type
  );

  type tt_zrep is table of rt_zrep;

  function pt_zrep (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
  ) return tt_zrep pipelined;

  ------------------------------------------------------------------------------
  -- pt_zrep_to_tdu : ZREP to TDU

  type rt_zrep_to_tdu is record (
    accss_seq                       mfanz_matl_dtrmntn_promax_vw.accss_seq%type,
    accss_level                     mfanz_matl_dtrmntn_promax_vw.accss_level%type,
    sales_org                       mfanz_matl_dtrmntn_promax_vw.sales_org%type,
    dstrbtn_channel                 mfanz_matl_dtrmntn_promax_vw.distbn_chnl%type,
    cust_code                       mfanz_matl_dtrmntn_promax_vw.cust_code%type,
    zrep_matl_code                  mfanz_matl_dtrmntn_promax_vw.matl_code%type,
    start_date                      mfanz_matl_dtrmntn_promax_vw.start_date%type,
    end_date                        mfanz_matl_dtrmntn_promax_vw.end_date%type,
    tdu_matl_code                   mfanz_matl_dtrmntn_promax_vw.subst_matl_code%type
  );

  type tt_zrep_to_tdu is table of rt_zrep_to_tdu;

  function pt_zrep_to_tdu (
    i_eff_date in date
  ) return tt_zrep_to_tdu pipelined;

  ------------------------------------------------------------------------------
  -- pt_tdu_to_rsu : TDU to RSU

  type rt_tdu_to_rsu is record (
    tdu_matl_code                   bds_material_bom_all.parent_material_code%type,
    rsu_matl_code                   bds_material_bom_all.child_material_code%type,
    rsu_matl_desc                   bds_material_hdr.bds_material_desc_en%type,
    rsu_ean                         bds_material_bom_all.child_ian%type,
    rsu_uom                         bds_material_bom_all.child_base_uom%type,
    rsus_per_tdu                    bds_material_bom_all.child_per_parent%type,
    rsu_length                      bds_material_hdr.length%type,
    rsu_width                       bds_material_hdr.width%type,
    rsu_height                      bds_material_hdr.height%type
  );

  type tt_tdu_to_rsu is table of rt_tdu_to_rsu;

  function pt_tdu_to_rsu (
    i_eff_date in date
  ) return tt_tdu_to_rsu pipelined;

  ------------------------------------------------------------------------------
  -- pt_tdu : TDU

  type rt_tdu is record (
    tdu_matl_code                   bds_material_hdr.sap_material_code%type,
    tdu_matl_desc                   bds_material_hdr.bds_material_desc_en%type,
    tdu_ean                         bds_material_hdr.interntl_article_no%type,
    tdu_uom                         bds_material_hdr.base_uom%type,
    tdu_net_weight                  bds_material_hdr.net_weight%type,
    tdu_length                      bds_material_hdr.length%type,
    tdu_width                       bds_material_hdr.width%type,
    tdu_height                      bds_material_hdr.height%type
  );

  type tt_tdu is table of rt_tdu;

  function pt_tdu return tt_tdu pipelined;

  ------------------------------------------------------------------------------
  -- pt_zrep_tdu_rsu : ZREP TDU RSU

  type rt_zrep_tdu_rsu is record (
    promax_company                  pxi.pmx_extract_criteria.promax_company%type,
    promax_division                 pxi.pmx_extract_criteria.promax_division%type,
    sales_org                       bds_material_dstrbtn_chain.sales_organisation%type,
    dstrbtn_channel                 bds_material_dstrbtn_chain.dstrbtn_channel%type,
    dstrbtn_chain_status            bds_material_dstrbtn_chain.dstrbtn_chain_status%type,
    xdstrbtn_chain_status           bds_material_hdr.xdstrbtn_chain_status%type,
    zrep_matl_code                  bds_material_hdr.sap_material_code%type,
    zrep_matl_desc                  bds_material_hdr.bds_material_desc_en%type,
    moe_code                        bds_material_moe.moe_code%type,
    moe_start_date                  bds_material_moe.start_date%type,
    moe_end_date                    bds_material_moe.end_date%type,
    tdu_accss_seq                   mfanz_matl_dtrmntn_promax_vw.accss_seq%type,
    tdu_accss_level                 mfanz_matl_dtrmntn_promax_vw.accss_level%type,
    tdu_sales_org                   mfanz_matl_dtrmntn_promax_vw.sales_org%type,
    tdu_dstrbtn_channel             mfanz_matl_dtrmntn_promax_vw.distbn_chnl%type,
    tdu_cust_code                   mfanz_matl_dtrmntn_promax_vw.cust_code%type,
    -- tdu_zrep_matl_code              mfanz_matl_dtrmntn_promax_vw.matl_code%type,
    tdu_start_date                  mfanz_matl_dtrmntn_promax_vw.start_date%type,
    tdu_end_date                    mfanz_matl_dtrmntn_promax_vw.end_date%type,
    tdu_matl_code                   mfanz_matl_dtrmntn_promax_vw.subst_matl_code%type,
    -- tdu_matl_code                   bds_material_hdr.sap_material_code%type,
    tdu_matl_desc                   bds_material_hdr.bds_material_desc_en%type,
    tdu_ean                         bds_material_hdr.interntl_article_no%type,
    tdu_uom                         bds_material_hdr.base_uom%type,
    tdu_net_weight                  bds_material_hdr.net_weight%type,
    tdu_length                      bds_material_hdr.length%type,
    tdu_width                       bds_material_hdr.width%type,
    tdu_height                      bds_material_hdr.height%type,
    -- tdu_matl_code                   bds_material_bom_all.parent_material_code%type,
    rsu_matl_code                   bds_material_bom_all.child_material_code%type,
    rsu_matl_desc                   bds_material_hdr.bds_material_desc_en%type,
    rsu_ean                         bds_material_bom_all.child_ian%type,
    rsu_uom                         bds_material_bom_all.child_base_uom%type,
    rsus_per_tdu                    bds_material_bom_all.child_per_parent%type,
    rsu_length                      bds_material_hdr.length%type,
    rsu_width                       bds_material_hdr.width%type,
    rsu_height                      bds_material_hdr.height%type,
    hist_xdstrbtn_chain_status      pmx_matl_hist.xdstrbtn_chain_status%type,
    hist_dstrbtn_chain_status       pmx_matl_hist.dstrbtn_chain_status%type,
    hist_change_date                pmx_matl_hist.change_date%type,
    hist_last_extracted             pmx_matl_hist.last_extracted%type
  );

  type tt_zrep_tdu_rsu is table of rt_zrep_tdu_rsu;

  function pt_zrep_tdu_rsu (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_zrep_tdu_rsu pipelined;

  ------------------------------------------------------------------------------
  -- pt_output : Output

  type rt_output is record (
    row_data                        varchar2(4000 char),
    promax_company                  pxi.pmx_extract_criteria.promax_company%type,
    promax_division                 pxi.pmx_extract_criteria.promax_division%type,
    dstrbtn_chain_status            bds_material_dstrbtn_chain.dstrbtn_chain_status%type,
    xdstrbtn_chain_status           bds_material_hdr.xdstrbtn_chain_status%type,
    zrep_matl_code                  bds_material_hdr.sap_material_code%type,
    tdu_accss_level                 mfanz_matl_dtrmntn_promax_vw.accss_level%type,
    hist_xdstrbtn_chain_status      pmx_matl_hist.xdstrbtn_chain_status%type,
    hist_dstrbtn_chain_status       pmx_matl_hist.dstrbtn_chain_status%type,
    hist_change_date                pmx_matl_hist.change_date%type,
    hist_last_extracted             pmx_matl_hist.last_extracted%type
  );

  type tt_output is table of rt_output;

  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined;

end pxipmx01_extract_v2;
/

create or replace package body pxi_app.pxipmx01_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX01_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX01';
  pc_days_to_send_deletions constant number(5) := 10; -- Days

/*******************************************************************************
  NAME: PT_ZREP                                                          PUBLIC
*******************************************************************************/
  function pt_zrep (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
  ) return tt_zrep pipelined is

  begin

    for rv_row in (

      select
        i_promax_company as promax_company,
        i_promax_division as promax_div,
        matl_dstrbtn_chain.sales_org,
        matl_dstrbtn_chain.dstrbtn_channel,
        matl_dstrbtn_chain.dstrbtn_chain_status,
        matl_hdr.xdstrbtn_chain_status,
        matl_hdr.matl_code as zrep_matl_code,
        matl_hdr.matl_desc as zrep_matl_desc,
        matl_moe.moe_code,
        matl_moe.start_date as moe_start_date,
        matl_moe.end_date as moe_end_date
      from
        --
        (
          select
            sap_material_code as matl_code,
            bds_material_desc_en as matl_desc,
            material_division as matl_div,
            xdstrbtn_chain_status
          from bds_material_hdr
          where material_type = 'ZREP'
          and mars_traded_unit_flag = 'X'
          and deletion_flag is null -- Not deleted
          and bds_lads_status = 1 -- LADS valid
          and (
            i_promax_company = pxi_common.fc_new_zealand
            or (i_promax_company = pxi_common.fc_australia and material_division = i_promax_division)
          )
        ) matl_hdr,
        --
        (
          select sap_material_code as matl_code,
            sales_organisation as sales_org,
            dstrbtn_channel,
            dstrbtn_chain_status
          from bds_material_dstrbtn_chain
          where dstrbtn_channel not in ('98', '99') -- Not sold as [98] Raw or [99] Affiliate
          and sales_organisation = i_promax_company
          and dstrbtn_channel in ( -- Distribution channel required for product
            select distinct distribution_channel
            from pxi.pmx_extract_criteria
            where promax_company = i_promax_company
            and promax_division = i_promax_division
            and required_for_prod = 'YES'
          )
        ) matl_dstrbtn_chain,
        --
        (
          select sap_material_code as matl_code,
            moe_code,
            start_date,
            end_date
          from bds_material_moe
          where usage_code = 'SEL'
          and moe_code in ( -- Selling MOE required for product
            select distinct selling_moe
            from pxi.pmx_extract_criteria
            where promax_company = i_promax_company
            and promax_division = i_promax_division
            and required_for_prod = 'YES'
          )
        ) matl_moe
        --
      where matl_hdr.matl_code = matl_dstrbtn_chain.matl_code
      and matl_hdr.matl_code = matl_moe.matl_code

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ZREP');

  end pt_zrep;

/*******************************************************************************
  NAME: PT_ZREP_TO_TDU                                                   PUBLIC
*******************************************************************************/
  function pt_zrep_to_tdu (
    i_eff_date in date
  ) return tt_zrep_to_tdu pipelined is

  begin

    for rv_row in (

      select
        accss_seq,
        accss_level,
        sales_org,
        distbn_chnl as dstrbtn_channel,
        cust_code,
        matl_code as zrep_matl_code,
        start_date,
        end_date,
        subst_matl_code as tdu_matl_code
      from mfanz_matl_dtrmntn_promax_vw
      -- TDU lookup using ZREP/Sales Org/Distribution Channel -> Exclude the Customer permutations
      where accss_seq = 'Z001' -- Atlas Promotional Account
      and accss_level in (1, 2) and cust_code is null -- [1] ZREP/Sales Org, [2] ZREP/Sales Org/Distribution Channel -> Customer will ALWAYS be null
      and to_char(i_eff_date,'YYYYMMDD') between start_date and end_date -- Effective

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ZREP_TO_TDU');

  end pt_zrep_to_tdu;

/*******************************************************************************
  NAME: PT_TDU_TO_RSU                                                    PUBLIC
*******************************************************************************/
  function pt_tdu_to_rsu (
    i_eff_date in date
  ) return tt_tdu_to_rsu pipelined is

  begin

    for rv_row in (

      -- Add TDU to RSU BOMS
      select
        latest_bom.tdu_matl_code,
        latest_bom.rsu_matl_code,
        matl_hdr.bds_material_desc_en as rsu_matl_desc,
        latest_bom.rsu_ean,
        latest_bom.rsu_uom,
        latest_bom.rsus_per_tdu,
        matl_hdr.length as rsu_length,
        matl_hdr.width as rsu_width,
        matl_hdr.height as rsu_height
      from bds_material_hdr matl_hdr,
        (
          select parent_material_code as tdu_matl_code,
            child_material_code as rsu_matl_code,
            child_ian as rsu_ean,
            child_base_uom as rsu_uom,
            child_per_parent as rsus_per_tdu
          from bds_material_bom_all
          where (bom_plant, bom_alternative, bom_usage, bom_status, child_rsu_flag, parent_material_code, bom_eff_date) in (
            select bom_plant,
              bom_alternative,
              bom_usage,
              bom_status,
              child_rsu_flag,
              parent_material_code,
              max(bom_eff_date)
            from bds_material_bom_all
            where bom_plant = '*NONE' and bom_alternative = '01' -- When BOM Plant is [*NONE], BOM Alternative MUST be [01]
            and bom_usage = '5' -- [5] Sales and Distribution
            and bom_status in (1, 5, 7) -- [1] Production, [5] Forecast, [7] Obsolete
            and child_rsu_flag = 'X' -- Where Child is a RSU
            and bom_eff_date <= i_eff_date
            group by bom_plant,
              bom_alternative,
              bom_usage,
              bom_status,
              child_rsu_flag,
              parent_material_code
          )
        ) latest_bom
      where matl_hdr.sap_material_code = latest_bom.rsu_matl_code

      union

      -- Add where TDU is RSU
      select
        sap_material_code as tdu_matl_code,
        sap_material_code as rsu_matl_code,
        bds_material_desc_en as rsu_matl_desc,
        interntl_article_no as rsu_ean,
        base_uom as rsu_uom,
        1 as rsus_per_tdu,
        length as rsu_length,
        width as rsu_width,
        height as rsu_height
      from bds_material_hdr
      where mars_traded_unit_flag = 'X'
      and mars_retail_sales_unit_flag = 'X'

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_TDU_TO_RSU');

  end pt_tdu_to_rsu;

/*******************************************************************************
  NAME: PT_TDU                                                           PUBLIC
*******************************************************************************/
  function pt_tdu return tt_tdu pipelined is

  begin

    for rv_row in (

      select
        sap_material_code as tdu_matl_code,
        bds_material_desc_en as tdu_matl_desc,
        interntl_article_no as tdu_ean,
        base_uom as tdu_uom,
        (case gross_weight_unit when 'GRM' then net_weight/1000 else net_weight end) as tdu_net_weight,
        length as tdu_length,
        width as tdu_width,
        height as tdu_height
      from bds_material_hdr
      where material_type = 'FERT' -- FERT
      and mars_traded_unit_flag = 'X' -- Traded unit
      and deletion_flag is null -- Not deleted
      and bds_lads_status = 1 -- LADS complete
      -- Note: We do not care if there are no current TDU's available for distribution.
      --    -> NO Cross Distribution Chain Status = '10' Filter is included here.

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_TDU');

  end pt_tdu;

/*******************************************************************************
  NAME: PT_ZREP_TDU_RSU                                                  PUBLIC
*******************************************************************************/
  function pt_zrep_tdu_rsu (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_zrep_tdu_rsu pipelined is

  begin

    for rv_row in (

      select
        matl_zrep.promax_company,
        matl_zrep.promax_division,
        matl_zrep.sales_org,
        matl_zrep.dstrbtn_channel,
        matl_zrep.dstrbtn_chain_status,
        matl_zrep.xdstrbtn_chain_status,
        matl_zrep.zrep_matl_code,
        matl_zrep.zrep_matl_desc,
        matl_zrep.moe_code,
        matl_zrep.moe_start_date,
        matl_zrep.moe_end_date,
        matl_zrep_to_tdu.accss_seq as tdu_accss_seq,
        matl_zrep_to_tdu.accss_level as tdu_accss_level,
        matl_zrep_to_tdu.sales_org as tdu_sales_org,
        matl_zrep_to_tdu.dstrbtn_channel as tdu_dstrbtn_channel,
        matl_zrep_to_tdu.cust_code as tdu_cust_code,
        matl_zrep_to_tdu.start_date as tdu_start_date,
        matl_zrep_to_tdu.end_date as tdu_end_date,
        matl_zrep_to_tdu.tdu_matl_code as tdu_matl_code,
        matl_tdu.tdu_matl_desc,
        matl_tdu.tdu_ean,
        matl_tdu.tdu_uom,
        matl_tdu.tdu_net_weight,
        matl_tdu.tdu_length,
        matl_tdu.tdu_width,
        matl_tdu.tdu_height,
        matl_rsu.rsu_matl_code,
        matl_rsu.rsu_matl_desc,
        matl_rsu.rsu_ean,
        matl_rsu.rsu_uom,
        matl_rsu.rsus_per_tdu,
        matl_rsu.rsu_length,
        matl_rsu.rsu_width,
        matl_rsu.rsu_height,
        pmx_matl_hist.xdstrbtn_chain_status as hist_xdstrbtn_chain_status,
        pmx_matl_hist.dstrbtn_chain_status as hist_dstrbtn_chain_status,
        pmx_matl_hist.change_date as hist_change_date,
        pmx_matl_hist.last_extracted as hist_last_extracted
      from table(pxipmx01_extract_v2.pt_zrep(i_promax_company, i_promax_division)) matl_zrep,
        table(pxipmx01_extract_v2.pt_zrep_to_tdu(i_eff_date)) matl_zrep_to_tdu,
        table(pxipmx01_extract_v2.pt_tdu) matl_tdu,
        table(pxipmx01_extract_v2.pt_tdu_to_rsu(i_eff_date)) matl_rsu,
        pmx_matl_hist
      -- Material ZREP -> TDU
      --   Join on ZREP/Sales Org/Distribution Channel ..
      --   Where Sales Org/Distribution Channel of NULL is treated as a Wild Card
      --   and Lowest (Most Specific) Access Level is Chosen in the Next Step .. ??? SHOULD SELECT at THIS STEP ONCE LOGIC is CONFIRMED ???
      where matl_zrep.zrep_matl_code = matl_zrep_to_tdu.zrep_matl_code(+)
      and (matl_zrep.sales_org = matl_zrep_to_tdu.sales_org or matl_zrep_to_tdu.sales_org is null)
      and (matl_zrep.dstrbtn_channel = matl_zrep_to_tdu.dstrbtn_channel or matl_zrep_to_tdu.dstrbtn_channel is null)
      -- Material TDU
      and matl_zrep_to_tdu.tdu_matl_code = matl_tdu.tdu_matl_code(+)
      -- Material RSU
      and matl_zrep_to_tdu.tdu_matl_code = matl_rsu.tdu_matl_code(+)
      -- Promax Material History
      and matl_zrep.promax_company = pmx_matl_hist.cmpny_code(+)
      and matl_zrep.promax_division = pmx_matl_hist.div_code(+)
      and matl_zrep.zrep_matl_code = pmx_matl_hist.zrep_matl_code(+)

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ZREP_TDU_RSU');

  end pt_zrep_tdu_rsu;

/*******************************************************************************
  NAME: PT_OUTPUT                                                        PUBLIC
*******************************************************************************/
  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined is

    rv_previous rt_output;

  begin

    rv_previous.zrep_matl_code := '[null]';

    for rv_row in (

      select
        pxi_common.char_format('302001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '302001' -> RecordType
        pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
        pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
        pxi_common.char_format(zrep_matl_code, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- zrep_matl_code -> ProductItemNumber
        pxi_common.char_format(zrep_matl_desc, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- zrep_matl_desc -> Description
        pxi_common.char_format(case when dstrbtn_chain_status != '99' and xdstrbtn_chain_status in ('10', '40') then 1 else 4 end, 2, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- product_status -> Status
        pxi_common.char_format(zrep_matl_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) || -- zrep_matl_code -> ShortName
        pxi_common.char_format(rsu_ean, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- rsu_ean -> APN
        pxi_common.char_format(tdu_ean, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tdu_ean -> TUN
        pxi_common.char_format(rsu_uom, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rsu_uom -> UOM
        pxi_common.char_format(tdu_uom, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tdu_uom -> SellableUOM
        pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.fc_is_nullable) || -- rsus_per_tdu -> UnitsPerCase
        pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.fc_is_nullable) || -- rsus_per_tdu -> BaseUnitsPerSellable
        pxi_common.char_format('0', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '0' -> Type
        pxi_common.numb_format(tdu_net_weight, '9999999990.000', pxi_common.fc_is_nullable) || -- tdu_net_weight -> ShipperNetWeightKG
        pxi_common.numb_format(tdu_height, '9999999990', pxi_common.fc_is_nullable) || -- tdu_height -> CaseHeight
        pxi_common.numb_format(tdu_width, '9999999990', pxi_common.fc_is_nullable) || -- tdu_width -> CaseWidth
        pxi_common.numb_format(tdu_length, '9999999990', pxi_common.fc_is_nullable) || -- tdu_length -> CaseLength
        pxi_common.numb_format(rsu_height, '9999999990', pxi_common.fc_is_nullable) || -- rsu_height -> UnitHeight
        pxi_common.numb_format(rsu_width, '9999999990', pxi_common.fc_is_nullable) || -- rsu_width -> UnitWidth
        pxi_common.numb_format(rsu_length, '9999999990', pxi_common.fc_is_nullable) -- rsu_length -> UnitLength
        as row_data,
        --
        promax_company,
        promax_division,
        dstrbtn_chain_status,
        xdstrbtn_chain_status,
        zrep_matl_code,
        tdu_accss_level,
        hist_xdstrbtn_chain_status,
        hist_dstrbtn_chain_status,
        hist_change_date,
        hist_last_extracted
      from table(pxipmx01_extract_v2.pt_zrep_tdu_rsu(i_promax_company, i_promax_division, i_eff_date))
      where rsu_ean is not null -- Only include ZREPs with valid RSU
      order by zrep_matl_code,
        tdu_accss_level desc

    )
    loop

      -- Select the Lowest (Most Specific) TDU Access Level for a given ZREP/Company/Division
      -- Note : Only need to test ZREP .. as Company/Division are preselected
      if rv_row.zrep_matl_code <> rv_previous.zrep_matl_code then

        rv_previous.zrep_matl_code := rv_row.zrep_matl_code;

        -- Include Active or Recently Active Products (ZREP/TDU/RSU) in interface
        -- Where ..
        --    Distribution Chain Status .. [99] Retired
        --    Cross Distribution Chain Stauts .. [10] Active, [40] Development
        if ((rv_row.dstrbtn_chain_status != '99' and rv_row.xdstrbtn_chain_status in ('10', '40')) -- Active
          or (rv_row.hist_dstrbtn_chain_status != '99' and rv_row.hist_xdstrbtn_chain_status in ('10', '40')) -- Recently Active .. Last Extract was Active
          or (rv_row.hist_change_date is not null and rv_row.hist_change_date > sysdate - pc_days_to_send_deletions)) then -- Recently Active .. Status changed within last few days

          pipe row(rv_row);

        end if;

      end if;

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_OUTPUT');

  end pt_output;

/*******************************************************************************
  NAME: EXECUTE                                                           PUBLIC
*******************************************************************************/
   procedure execute (
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_eff_date in date
   ) is

     v_instance number(15,0);

   begin

    for rv_row in (

      select
        row_data,
        --
        promax_company,
        promax_division,
        dstrbtn_chain_status,
        xdstrbtn_chain_status,
        zrep_matl_code,
        hist_xdstrbtn_chain_status,
        hist_dstrbtn_chain_status,
        hist_change_date,
        hist_last_extracted
      from table(pxipmx01_extract_v2.pt_output(i_promax_company, i_promax_division, i_eff_date))

    )
    loop

      -- Update product history
      update pmx_matl_hist
      set last_extracted = sysdate,
        change_date =
          case
            when (dstrbtn_chain_status <> rv_row.dstrbtn_chain_status or xdstrbtn_chain_status <> rv_row.xdstrbtn_chain_status)
            then sysdate
            else rv_row.hist_change_date
          end,
        xdstrbtn_chain_status = rv_row.xdstrbtn_chain_status,
        dstrbtn_chain_status = rv_row.dstrbtn_chain_status
      where cmpny_code = rv_row.promax_company
      and div_code = rv_row.promax_division
      and zrep_matl_code = rv_row.zrep_matl_code;

      -- If no update was performed, add product history
      if sql%rowcount = 0 then
        insert into pmx_matl_hist (cmpny_code, div_code, zrep_matl_code, xdstrbtn_chain_status, dstrbtn_chain_status, change_date, last_extracted)
        values (rv_row.promax_company, rv_row.promax_division, rv_row.zrep_matl_code, rv_row.xdstrbtn_chain_status, rv_row.dstrbtn_chain_status, sysdate, sysdate);
      end if;

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_promax_company,i_promax_division));
      end if;

      -- Append interface data
      lics_outbound_loader.append_data(rv_row.row_data);

    end loop;

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

    -- Commit changes to product history extract table
    commit;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx01_extract_v2;
/

grant execute on pxi_app.pxipmx01_extract_v2 to lics_app, fflu_app, site_app;
