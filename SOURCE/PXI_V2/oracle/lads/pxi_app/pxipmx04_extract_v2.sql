prompt :: Compile Package [pxipmx04_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx04_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX04_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Customer Hierarchy - PX Interface 301 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 2013-07-28    Chris Horn            Created.
 2013-08-20    Chris Horn            Cleaned Up Code.
 2013-08-28    Chris Horn            Made generic for OZ.
 2014-02-25    Mal Chambeyron        Pipeline, Simplify, Tune
 2014-03-06    Mal Chambeyron        Filter Out Demand Planning Nodes for New Zealand
 2014-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix
 2014-03-24    Mal Chambeyron        Set Hierarchy Division Code to Leaf Division Code for Level 06 Customers Only
 2014-03-25    Mal Chambeyron        Modify to facilitate reference by [pxipmx03_extract_v2], add [division_code] to [rt_output]

*******************************************************************************/

  ------------------------------------------------------------------------------
  -- execute : Create Customer Hierarchy Interface File
  procedure execute(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  );

  ------------------------------------------------------------------------------
  -- pt_cust_hier_flat : Convienience Function to View Flattened Customer Hierarhcy

  type rt_cust_hier_flat is record (
    header_date varchar2(8 char),
    header_seq number,
    min_detail_seq number,
    max_detail_seq number,
    min_hier_level varchar2(2 char),
    max_hier_level varchar2(2 char),
    item_count number,
    cust_code varchar2(10 char),
    sales_org_code varchar2(4 char),
    distbn_chnl_code varchar2(2 char),
    division_code varchar2(2 char),
    sort_level varchar2(10 char),
    hier_level varchar2(2 char),
    start_date varchar2(8 char),
    end_date varchar2(8 char),
    cust_name varchar2(40 char),
    priority number,
    cust_code_01 varchar2(10 char),
    sales_org_code_01 varchar2(4 char),
    distbn_chnl_code_01 varchar2(2 char),
    division_code_01 varchar2(2 char),
    sort_level_01 varchar2(10 char),
    hier_level_01 varchar2(2 char),
    start_date_01 varchar2(8 char),
    end_date_01 varchar2(8 char),
    cust_name_01 varchar2(40 char),
    cust_code_02 varchar2(10 char),
    sales_org_code_02 varchar2(4 char),
    distbn_chnl_code_02 varchar2(2 char),
    division_code_02 varchar2(2 char),
    sort_level_02 varchar2(10 char),
    hier_level_02 varchar2(2 char),
    start_date_02 varchar2(8 char),
    end_date_02 varchar2(8 char),
    cust_name_02 varchar2(40 char),
    cust_code_03 varchar2(10 char),
    sales_org_code_03 varchar2(4 char),
    distbn_chnl_code_03 varchar2(2 char),
    division_code_03 varchar2(2 char),
    sort_level_03 varchar2(10 char),
    hier_level_03 varchar2(2 char),
    start_date_03 varchar2(8 char),
    end_date_03 varchar2(8 char),
    cust_name_03 varchar2(40 char),
    cust_code_04 varchar2(10 char),
    sales_org_code_04 varchar2(4 char),
    distbn_chnl_code_04 varchar2(2 char),
    division_code_04 varchar2(2 char),
    sort_level_04 varchar2(10 char),
    hier_level_04 varchar2(2 char),
    start_date_04 varchar2(8 char),
    end_date_04 varchar2(8 char),
    cust_name_04 varchar2(40 char),
    cust_code_05 varchar2(10 char),
    sales_org_code_05 varchar2(4 char),
    distbn_chnl_code_05 varchar2(2 char),
    division_code_05 varchar2(2 char),
    sort_level_05 varchar2(10 char),
    hier_level_05 varchar2(2 char),
    start_date_05 varchar2(8 char),
    end_date_05 varchar2(8 char),
    cust_name_05 varchar2(40 char),
    cust_code_06 varchar2(10 char),
    sales_org_code_06 varchar2(4 char),
    distbn_chnl_code_06 varchar2(2 char),
    division_code_06 varchar2(2 char),
    sort_level_06 varchar2(10 char),
    hier_level_06 varchar2(2 char),
    start_date_06 varchar2(8 char),
    end_date_06 varchar2(8 char),
    cust_name_06 varchar2(40 char),
    cust_header_order_block_flag varchar2(2 char),
    cust_header_deletion_flag varchar2(1 char),
    sales_area_order_block_flag varchar2(2 char),
    sales_area_deletion_flag varchar2(1 char),
    last_billing_yyyypp varchar2(6 char)
  );

  type tt_cust_hier_flat is table of rt_cust_hier_flat;

  function pt_cust_hier_flat_raw (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined;

  function pt_cust_hier_flat (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined;

  function pt_cust_hier_flat_no_refresh (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined;

  ------------------------------------------------------------------------------
  -- pt_output : Output

  type rt_output is record (
    output_record                   varchar2(4000 char),
    cust_level                      number(2,0),
    cust_code                       varchar2(10 char),
    cust_name                       varchar2(40 char),
    division_code                   varchar2(2 char),
    parent_cust_code                varchar2(10 char)
  );

  type tt_output is table of rt_output;

  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined;

end pxipmx04_extract_v2;
/

create or replace package body pxi_app.pxipmx04_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX04_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX04';

  type tt_cust_hier_flat_array is table of rt_cust_hier_flat index by pls_integer;
  ptv_cust_hier_flat_array tt_cust_hier_flat_array;

/*******************************************************************************
  NAME: PT_CUST_HIER_FLAT_RAW                                             PUBLIC
*******************************************************************************/
  function pt_cust_hier_flat_raw (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined is

  begin

    for rv_row in (

      -- Flatten Customer Hierarchy
      select header_date,
        header_seq,
        --
        min(detail_seq) min_detail_seq,
        max(detail_seq) max_detail_seq,
        min(hier_level) min_hier_level,
        max(hier_level) max_hier_level,
        count(1) item_count,
        -- leaf node
        max(decode(detail_seq, 1, cust_code, null)) cust_code,
        max(decode(detail_seq, 1, sales_org_code, null)) sales_org_code,
        max(decode(detail_seq, 1, distbn_chnl_code, null)) distbn_chnl_code,
        max(decode(detail_seq, 1, division_code, null)) division_code,
        max(decode(detail_seq, 1, sort_level, null)) sort_level,
        max(decode(detail_seq, 1, hier_level, null)) hier_level,
        max(decode(detail_seq, 1, start_date, null)) start_date,
        max(decode(detail_seq, 1, end_date, null)) end_date,
        max(decode(detail_seq, 1, cust_name, null)) cust_name,
        min(priority) priority,
        -- level 01
        max(decode(hier_level, '01', cust_code, null)) cust_code_01,
        max(decode(hier_level, '01', sales_org_code, null)) sales_org_code_01,
        max(decode(hier_level, '01', distbn_chnl_code, null)) distbn_chnl_code_01,
        max(decode(hier_level, '01', division_code, null)) division_code_01,
        max(decode(hier_level, '01', sort_level, null)) sort_level_01,
        max(decode(hier_level, '01', hier_level, null)) hier_level_01,
        max(decode(hier_level, '01', start_date, null)) start_date_01,
        max(decode(hier_level, '01', end_date, null)) end_date_01,
        max(decode(hier_level, '01', cust_name, null)) cust_name_01,
        -- level 02
        max(decode(hier_level, '02', cust_code, null)) cust_code_02,
        max(decode(hier_level, '02', sales_org_code, null)) sales_org_code_02,
        max(decode(hier_level, '02', distbn_chnl_code, null)) distbn_chnl_code_02,
        max(decode(hier_level, '02', division_code, null)) division_code_02,
        max(decode(hier_level, '02', sort_level, null)) sort_level_02,
        max(decode(hier_level, '02', hier_level, null)) hier_level_02,
        max(decode(hier_level, '02', start_date, null)) start_date_02,
        max(decode(hier_level, '02', end_date, null)) end_date_02,
        max(decode(hier_level, '02', cust_name, null)) cust_name_02,
        -- level 03
        max(decode(hier_level, '03', cust_code, null)) cust_code_03,
        max(decode(hier_level, '03', sales_org_code, null)) sales_org_code_03,
        max(decode(hier_level, '03', distbn_chnl_code, null)) distbn_chnl_code_03,
        max(decode(hier_level, '03', division_code, null)) division_code_03,
        max(decode(hier_level, '03', sort_level, null)) sort_level_03,
        max(decode(hier_level, '03', hier_level, null)) hier_level_03,
        max(decode(hier_level, '03', start_date, null)) start_date_03,
        max(decode(hier_level, '03', end_date, null)) end_date_03,
        max(decode(hier_level, '03', cust_name, null)) cust_name_03,
        -- level 04
        max(decode(hier_level, '04', cust_code, null)) cust_code_04,
        max(decode(hier_level, '04', sales_org_code, null)) sales_org_code_04,
        max(decode(hier_level, '04', distbn_chnl_code, null)) distbn_chnl_code_04,
        max(decode(hier_level, '04', division_code, null)) division_code_04,
        max(decode(hier_level, '04', sort_level, null)) sort_level_04,
        max(decode(hier_level, '04', hier_level, null)) hier_level_04,
        max(decode(hier_level, '04', start_date, null)) start_date_04,
        max(decode(hier_level, '04', end_date, null)) end_date_04,
        max(decode(hier_level, '04', cust_name, null)) cust_name_04,
        -- level 05
        max(decode(hier_level, '05', cust_code, null)) cust_code_05,
        max(decode(hier_level, '05', sales_org_code, null)) sales_org_code_05,
        max(decode(hier_level, '05', distbn_chnl_code, null)) distbn_chnl_code_05,
        max(decode(hier_level, '05', division_code, null)) division_code_05,
        max(decode(hier_level, '05', sort_level, null)) sort_level_05,
        max(decode(hier_level, '05', hier_level, null)) hier_level_05,
        max(decode(hier_level, '05', start_date, null)) start_date_05,
        max(decode(hier_level, '05', end_date, null)) end_date_05,
        max(decode(hier_level, '05', cust_name, null)) cust_name_05,
        -- level 06
        max(decode(hier_level, '06', cust_code, null)) cust_code_06,
        max(decode(hier_level, '06', sales_org_code, null)) sales_org_code_06,
        max(decode(hier_level, '06', distbn_chnl_code, null)) distbn_chnl_code_06,
        max(decode(hier_level, '06', division_code, null)) division_code_06,
        max(decode(hier_level, '06', sort_level, null)) sort_level_06,
        max(decode(hier_level, '06', hier_level, null)) hier_level_06,
        max(decode(hier_level, '06', start_date, null)) start_date_06,
        max(decode(hier_level, '06', end_date, null)) end_date_06,
        max(decode(hier_level, '06', cust_name, null)) cust_name_06,
        -- If you need extra 'levels' .. simply replicate the block above ..
        --
        max(nvl(cust_header_order_block_flag, 0)) cust_header_order_block_flag,
        max(nvl(cust_header_deletion_flag, 0)) cust_header_deletion_flag,
        max(nvl(sales_area_order_block_flag, 0)) sales_area_order_block_flag,
        max(nvl(sales_area_deletion_flag, 0)) sales_area_deletion_flag,
        max(nvl(last_billing_yyyypp, 0)) last_billing_yyyypp
        --
      from (
        select
          cust_hier.header_date,
          cust_hier.header_seq,
          cust_hier.detail_seq,
          cust_hier.cust_code,
          cust_hier.sales_org_code,
          cust_hier.distbn_chnl_code,
          cust_hier.division_code,
          cust_hier.sort_level,
          cust_hier.hier_level,
          cust_hier.start_date,
          cust_hier.end_date,
          cust_name.cust_name,
          extract_criteria.priority,
          cust_header.order_block_flag cust_header_order_block_flag,
          cust_header.deletion_flag cust_header_deletion_flag,
          cust_sales_area.order_block_flag sales_area_order_block_flag,
          cust_sales_area.deletion_flag sales_area_deletion_flag,
          last_billing.last_billing_yyyypp
        from
          (
            select
              cust_hier_detail.hdrdat header_date,
              cust_hier_detail.hdrseq header_seq,
              cust_hier_detail.detseq detail_seq,
              cust_hier_detail.kunnr cust_code,
              cust_hier_detail.vkorg sales_org_code,
              cust_hier_detail.vtweg distbn_chnl_code,
              cust_hier_detail.spart division_code,
              cust_hier_detail.sortl sort_level,
              cust_hier_detail.hielv hier_level,
              nvl(cust_hier_detail.datab,'00000000') start_date,
              nvl(cust_hier_detail.datbi,'99999999') end_date
            from lads_hie_cus_det cust_hier_detail,
              (
                select hdrdat header_date,
                  hdrseq header_seq
                from lads_hie_cus_hdr
                where hdrdat = (select max(hdrdat) from lads_hie_cus_hdr)
                and idoc_name = 'Z_CUSTOMER_HIERARCHY'
                and hityp = 'A'
                and lads_status = 1
                and to_char(i_eff_date,'YYYYMMDD') between nvl(datab,'00000000') and nvl(datbi,'99999999')
              ) cust_hier_header
            where cust_hier_detail.hdrdat = cust_hier_header.header_date
            and cust_hier_detail.hdrseq = cust_hier_header.header_seq
            and to_char(i_eff_date,'YYYYMMDD') between nvl(cust_hier_detail.datab,'00000000') and nvl(cust_hier_detail.datbi,'99999999')
          ) cust_hier,
          (
            select
              customer_code cust_code,
              order_block_flag,
              deletion_flag,
              demand_plan_group_code
            from bds_cust_header
          ) cust_header,
          (
            select customer_code cust_code,
              name cust_name
            from bds_addr_customer
            where address_version = '*NONE' -- Filter .. Main / English Customer Name
          ) cust_name,
          (
            select customer_code cust_code,
              sales_org_code,
              distbn_chnl_code,
              division_code,
              order_block_flag,
              deletion_flag
            from bds_cust_sales_area
          ) cust_sales_area,
          (
            select sold_to_cust_code cust_code,
              max(billing_yyyypp) last_billing_yyyypp
            from sale_cdw_gsv
            group by sold_to_cust_code
          ) last_billing,
          (
            select
              promax_company,
              promax_division,
              customer_division,
              distribution_channel,
              priority
            from pxi.pmx_extract_criteria
            where promax_company = i_promax_company
            and promax_division = i_promax_division
            and required_for_cust = 'YES'
          ) extract_criteria
        -- Join : cust_hier > cust_header
        where cust_hier.cust_code = cust_header.cust_code(+)
        -- Join : cust_hier > cust_name
        and cust_hier.cust_code = cust_name.cust_code(+)
        -- Join : cust_hier > cust_sales_area
        and cust_hier.cust_code = cust_sales_area.cust_code(+)
        and cust_hier.sales_org_code = cust_sales_area.sales_org_code(+)
        and cust_hier.distbn_chnl_code = cust_sales_area.distbn_chnl_code(+)
        and cust_hier.division_code = cust_sales_area.division_code(+)
        -- Join : cust_hier > last_billing
        and cust_hier.cust_code = last_billing.cust_code(+)
        -- Join : cust_hier > extract_criteria
        and cust_hier.sales_org_code = extract_criteria.promax_company
        and cust_hier.division_code = extract_criteria.customer_division
        and cust_hier.distbn_chnl_code = extract_criteria.distribution_channel
        -- Filter : keep customers without order_block_flag and deletion_flag, or have sales
        and ((cust_header.order_block_flag is null
            and cust_header.deletion_flag is null
            and cust_sales_area.order_block_flag is null
            and cust_sales_area.deletion_flag is null)
          or last_billing.cust_code is not null)
        -- Filter Out Demand Planning Nodes for New Zealand
        and (
            i_promax_company <> pxi_common.fc_new_zealand
            or
            (i_promax_company = pxi_common.fc_new_zealand and cust_header.demand_plan_group_code is null)
         )

      )
      group by header_date,
        header_seq

    )
    loop

      -- Set Hierarchy Division Code to Leaf Division Code for Level 06 Customers Only
      if rv_row.division_code_06 is not null then 
        rv_row.division_code_05 := rv_row.division_code_06; 
        rv_row.division_code_04 := rv_row.division_code_06; 
        rv_row.division_code_03 := rv_row.division_code_06; 
        rv_row.division_code_02 := rv_row.division_code_06; 
        rv_row.division_code_01 := rv_row.division_code_06;
      else
        rv_row.division_code_06 := '00'; 
        rv_row.division_code_05 := '00'; 
        rv_row.division_code_04 := '00'; 
        rv_row.division_code_03 := '00'; 
        rv_row.division_code_02 := '00'; 
        rv_row.division_code_01 := '00';
      end if;
    
      -- Find lowest level, WHERE hier_level and detail_seq are out of sync ..
      if rv_row.cust_code is null then
        rv_row.cust_code := nvl(rv_row.cust_code_06,nvl(rv_row.cust_code_05,nvl(rv_row.cust_code_04,nvl(rv_row.cust_code_03,nvl(rv_row.cust_code_02,rv_row.cust_code_01)))));
        rv_row.sales_org_code := nvl(rv_row.sales_org_code_06,nvl(rv_row.sales_org_code_05,nvl(rv_row.sales_org_code_04,nvl(rv_row.sales_org_code_03,nvl(rv_row.sales_org_code_02,rv_row.sales_org_code_01)))));
        rv_row.distbn_chnl_code := nvl(rv_row.distbn_chnl_code_06,nvl(rv_row.distbn_chnl_code_05,nvl(rv_row.distbn_chnl_code_04,nvl(rv_row.distbn_chnl_code_03,nvl(rv_row.distbn_chnl_code_02,rv_row.distbn_chnl_code_01)))));
        rv_row.division_code := nvl(rv_row.division_code_06,nvl(rv_row.division_code_05,nvl(rv_row.division_code_04,nvl(rv_row.division_code_03,nvl(rv_row.division_code_02,rv_row.division_code_01)))));
        rv_row.sort_level := nvl(rv_row.sort_level_06,nvl(rv_row.sort_level_05,nvl(rv_row.sort_level_04,nvl(rv_row.sort_level_03,nvl(rv_row.sort_level_02,rv_row.sort_level_01)))));
        rv_row.hier_level := nvl(rv_row.hier_level_06,nvl(rv_row.hier_level_05,nvl(rv_row.hier_level_04,nvl(rv_row.hier_level_03,nvl(rv_row.hier_level_02,rv_row.hier_level_01)))));
        rv_row.start_date := nvl(rv_row.start_date_06,nvl(rv_row.start_date_05,nvl(rv_row.start_date_04,nvl(rv_row.start_date_03,nvl(rv_row.start_date_02,rv_row.start_date_01)))));
        rv_row.end_date := nvl(rv_row.end_date_06,nvl(rv_row.end_date_05,nvl(rv_row.end_date_04,nvl(rv_row.end_date_03,nvl(rv_row.end_date_02,rv_row.end_date_01)))));
        rv_row.cust_name := nvl(rv_row.cust_name_06,nvl(rv_row.cust_name_05,nvl(rv_row.cust_name_04,nvl(rv_row.cust_name_03,nvl(rv_row.cust_name_02,rv_row.cust_name_01)))));
      end if;

      pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_CUST_HIER_FLAT_RAW');

  end pt_cust_hier_flat_raw;

/*******************************************************************************
  NAME: refresh_cust_hier_flat                                            PUBLIC
*******************************************************************************/
  procedure refresh_cust_hier_flat (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) is

    v_cust_code varchar2(10 char);

  begin

    v_cust_code := '*NULL'; -- Initalise to impossible value

    ptv_cust_hier_flat_array.delete;

    for rv_row in ( -- This loop needed to ensure that "Fixed" nodes are treated appropriately

      select *
      from table(pt_cust_hier_flat_raw(i_promax_company, i_promax_division, i_eff_date))
      order by cust_code, priority

    )
    loop

      if v_cust_code != rv_row.cust_code then -- Filter First Customer by Priority
        v_cust_code := rv_row.cust_code;
        ptv_cust_hier_flat_array(ptv_cust_hier_flat_array.count+1) := rv_row;
      end if;

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'REFRESH_CUST_HIER_FLAT');

  end refresh_cust_hier_flat;

/*******************************************************************************
  NAME: PT_CUST_HIER_FLAT (from ARRAY)                                    PUBLIC
*******************************************************************************/
  function pt_cust_hier_flat (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined is

  begin

    refresh_cust_hier_flat(i_promax_company, i_promax_division, i_eff_date);

    for i in 1 .. ptv_cust_hier_flat_array.count loop
        pipe row(ptv_cust_hier_flat_array(i));
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_CUST_HIER_FLAT');

  end pt_cust_hier_flat;

/*******************************************************************************
  NAME: PT_CUST_HIER_FLAT_NO_REFRESH (from ARRAY)                         PUBLIC
*******************************************************************************/
  function pt_cust_hier_flat_no_refresh (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_hier_flat pipelined is

  begin

    for i in 1 .. ptv_cust_hier_flat_array.count loop
        pipe row(ptv_cust_hier_flat_array(i));
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_CUST_HIER_FLAT_NO_REFRESH');

  end pt_cust_hier_flat_no_refresh;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
*******************************************************************************/
  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined is

  begin

    refresh_cust_hier_flat(i_promax_company, i_promax_division, i_eff_date);

    for rv_row in (

      select
        pxi_common.char_format('record_type', '301001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '301001' -> ICRecordType
        pxi_common.char_format('promax_company', i_promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
        pxi_common.char_format('promax_division', i_promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
        pxi_common.char_format('cust_code', cust_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- cust_code -> CustomerNumber
        pxi_common.char_format('cust_name', cust_name, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- cust_name -> CustomerDescription
        pxi_common.char_format('division_code', division_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- division_code -> CustomerSalesOrg
        pxi_common.char_format('parent_cust_code', parent_cust_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) -- parent_cust_code -> ParentCustomerNumber
        as output_record,
        cust_level,
        cust_code,
        cust_name,
        division_code,
        parent_cust_code
      from (

        select 
          cust_level,
          cust_code,
          max(cust_name) as cust_name,
          case max(division_code) when '00' then '56' else max(division_code) end as division_code,
          max(parent_cust_code) as parent_cust_code
        from (  
          
          -- Customer Nodes (Level 06)
          
          select distinct 
            6 as cust_level, 
            cust_code_06 as cust_code, 
            cust_name_06 as cust_name, 
            division_code_06 as division_code, 
            cust_code_05 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_06 is not null
          
          -- Hierarchy Nodes (Levels 01-05) .. Without Children
          
          union all
          
          select distinct 1 as cust_level, 
            cust_code_01 as cust_code, 
            cust_name_01 as cust_name, 
            '00' as division_code,
            -- division_code_01 as division_code, 
            null as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_01 in (
            select cust_code_01 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_01 is not null
            having max(case when cust_code_02 is not null then 1 else 0 end) = 0 -- Without Children
            group by cust_code_01
          )
          
          union all
          
          select distinct 2 as cust_level, 
            cust_code_02 as cust_code, 
            cust_name_02 as cust_name, 
            '00' as division_code,
            -- division_code_02 as division_code, 
            cust_code_01 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_02 in (
            select cust_code_02 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_02 is not null
            having max(case when cust_code_03 is not null then 1 else 0 end) = 0 -- Without Children
            group by cust_code_02
          )
          
          union all
          
          select distinct 3 as cust_level, 
            cust_code_03 as cust_code, 
            cust_name_03 as cust_name, 
            '00' as division_code,
            -- division_code_03 as division_code, 
            cust_code_02 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_03 in (
            select cust_code_03 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_03 is not null
            having max(case when cust_code_04 is not null then 1 else 0 end) = 0 -- Without Children
            group by cust_code_03
          )
          
          union all
          
          select distinct 4 as cust_level, 
            cust_code_04 as cust_code, 
            cust_name_04 as cust_name, 
            '00' as division_code,
            -- division_code_04 as division_code, 
            cust_code_03 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_04 in (
            select cust_code_04 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_04 is not null
            having max(case when cust_code_05 is not null then 1 else 0 end) = 0 -- Without Children
            group by cust_code_04
          )
          
          union all
          
          select distinct 5 as cust_level, 
            cust_code_05 as cust_code, 
            cust_name_05 as cust_name, 
            '00' as division_code,
            -- division_code_05 as division_code, 
            cust_code_04 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_05 in (
            select cust_code_05 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_05 is not null
            having max(case when cust_code_06 is not null then 1 else 0 end) = 0 -- Without Children
            group by cust_code_05
          )
          
          -- Hierarchy Nodes (Levels 01-05) .. With Children
          
          union all
          
          select distinct 1 as cust_level, 
            cust_code_01 as cust_code, 
            cust_name_01 as cust_name, 
            division_code_01 as division_code, 
            null as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_01 in (
            select cust_code_01 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_01 is not null
            having max(case when cust_code_02 is not null then 1 else 0 end) = 1 -- With Children
            group by cust_code_01
          )
          
          union all
          
          select distinct 2 as cust_level, 
            cust_code_02 as cust_code, 
            cust_name_02 as cust_name, 
            division_code_02 as division_code, 
            cust_code_01 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_02 in (
            select cust_code_02 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_02 is not null
            having max(case when cust_code_03 is not null then 1 else 0 end) = 1 -- With Children
            group by cust_code_02
          )
          
          union all
          
          select distinct 3 as cust_level, 
            cust_code_03 as cust_code, 
            cust_name_03 as cust_name, 
            division_code_03 as division_code, 
            cust_code_02 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_03 in (
            select cust_code_03 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_03 is not null
            having max(case when cust_code_04 is not null then 1 else 0 end) = 1 -- With Children
            group by cust_code_03
          )
          
          union all
          
          select distinct 4 as cust_level, 
            cust_code_04 as cust_code, 
            cust_name_04 as cust_name, 
            division_code_04 as division_code, 
            cust_code_03 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_04 in (
            select cust_code_04 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_04 is not null
            having max(case when cust_code_05 is not null then 1 else 0 end) = 1 -- With Children
            group by cust_code_04
          )
          
          union all
          
          select distinct 5 as cust_level, 
            cust_code_05 as cust_code, 
            cust_name_05 as cust_name, 
            division_code_05 as division_code, 
            cust_code_04 as parent_cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date))
          where cust_code_05 in (
            select cust_code_05 
            from table(pxipmx04_extract_v2.pt_cust_hier_flat_no_refresh(i_promax_company,i_promax_division,i_eff_date)) 
            where cust_code_05 is not null
            having max(case when cust_code_06 is not null then 1 else 0 end) = 1 -- With Children
            group by cust_code_05
          )
        
        )
        group by 
          cust_level,
          cust_code
        order by
          cust_level,
          cust_code

      )

    )
    loop

        pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_OUTPUT');

  end pt_output;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) is

    v_interface_name_with_suffix varchar2(64 char);
    v_instance number(15,0);

  begin

    -- Set interface name (including Suffix)
    v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.promax_interface_suffix(i_promax_company,i_promax_division);

    -- request lock (on interface)
    begin
      lics_locking.request(v_interface_name_with_suffix);
    exception
      when others then
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE',substr('Unable to obtain interface lock ['||v_interface_name_with_suffix||'] - '||sqlerrm, 1, 4000));
    end;

    for rv_row in (

      select output_record
      from table(pt_output(i_promax_company,i_promax_division,i_eff_date))

    )
    loop

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(v_interface_name_with_suffix);
      end if;

      -- Append Data
      lics_outbound_loader.append_data(rv_row.output_record);

    end loop;

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

    -- Release lock (on interface)
    lics_locking.release(v_interface_name_with_suffix);

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx04_extract_v2;
/

grant execute on pxi_app.pxipmx04_extract_v2 to lics_app, fflu_app, site_app;
