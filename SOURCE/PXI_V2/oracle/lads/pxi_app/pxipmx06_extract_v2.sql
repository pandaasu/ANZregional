prompt :: Compile Package [pxipmx06_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx06_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
  System  : LADS
  Package : PXIPMX06_EXTRACT_V2
  Owner   : PXI_APP
  Author  : Chris Horn and Mal Chambeyron

  Description
  -----------
  LADS (Outbound) -> Promax PX - Price Data - PX Interface 330

  This interface creates an extract of up to the next 3 list prices for a
  Company / Division / Material.

  The interface output can be displayed using the Pipeline funciton [pt_output],
  while the outbound interface itself is produced by the [execute] function.

  Pipeline functions were employed to increase performance over DB links,
  and to facilitate support / debug.

  Notes :

    [pt_list_price_hdr] Restricts Access Sequence Sales Organisation / Material
      -> Customer will ALWAYS be NULL !!! Customer left in should it ever be
      required

    [pt_output] List price is also dimensioned by Distribution Channel, however
      it is not used - Theoretically could create "apparent" pricing duplicates
      across distribution channels ..

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-07-24  Chris Horn            Created.
  2013-07-27  Mal Chambeyron        Formatted SQL Output
  2013-08-21  Chris Horn            Cleaned Up Code.
  2013-08-28  Chris Horn            Made Generic for OZ.
  2014-01-17  Mal Chambeyron        Rewrote with pipeline for performance
                                    over DB links
  2014-01-20  Mal Chambeyron        Add interface suffix
  2014-01-21  Mal Chambeyron        Added Field Names on Format Functions
  2013-03-12  Mal Chambeyron        Remove DEFAULTS,
                                    Replace [pxi_common.promax_config]
                                    Use Suffix

*******************************************************************************/

/*******************************************************************************
  NAME: PT_LIST_PRICE_HDR                                                 PUBLIC
  PURPOSE: Pipeline of List Price Header for Company,
           with End Date >= Effective Date.
*******************************************************************************/
  type rt_list_price_hdr is record (
    sales_org                       lads_prc_lst_hdr.vkorg%type,
    cust_code                       lads_prc_lst_hdr.kunnr%type,
    matl_code                       lads_prc_lst_hdr.matnr%type,
    start_date                      date,
    end_date                        date,
    vakey                           lads_prc_lst_hdr.vakey%type,
    kschl                           lads_prc_lst_hdr.kschl%type,
    knumh                           lads_prc_lst_hdr.knumh%type
  );

  type tt_list_price_hdr is table of rt_list_price_hdr;

  function pt_list_price_hdr (
    i_promax_company in pxi_common.st_company,
    i_eff_date in date
  ) return tt_list_price_hdr pipelined;

/*******************************************************************************
  NAME: PT_LIST_PRICE_DTL                                                 PUBLIC
  PURPOSE: Pipeline of List Price Detail
*******************************************************************************/
  type rt_list_price_dtl is record (
    currency                        lads_prc_lst_det.konwa%type,
    list_price                      lads_prc_lst_det.kbetr%type,
    start_date                      date,
    vakey                           lads_prc_lst_det.vakey%type,
    kschl                           lads_prc_lst_det.kschl%type,
    knumh                           lads_prc_lst_det.knumh%type
  );

  type tt_list_price_dtl is table of rt_list_price_dtl;

  function pt_list_price_dtl return tt_list_price_dtl pipelined;

/*******************************************************************************
  NAME: PT_MATL_DIV_CODE                                                  PUBLIC
  PURPOSE: Pipeline of Materials with their Divisions.
*******************************************************************************/
  type rt_matl_div_code is record (
    matl_code                       mfanz_matl.matl_code%type,
    div_code                        mfanz_matl.dvsn%type
  );

  type tt_matl_div_code is table of rt_matl_div_code;

  function pt_matl_div_code return tt_matl_div_code pipelined;

/*******************************************************************************
  NAME: PT_MATL_TRADE_SCTR                                                PUBLIC
  PURPOSE: Pipeline of Materials with their Trade Sectors.
*******************************************************************************/
  type rt_matl_trade_sctr is record (
    matl_code                       mfanz_fg_matl_clssfctn.matl_code%type,
    trade_sctr_code                 mfanz_fg_matl_clssfctn.trade_sctr_code%type
  );

  type tt_matl_trade_sctr is table of rt_matl_trade_sctr;

  function pt_matl_trade_sctr return tt_matl_trade_sctr pipelined;

/*******************************************************************************
  NAME: PT_MATL_DSTRBTN_CHNL                                              PUBLIC
  PURPOSE: Pipeline of Materials with their Sales Org, Distribution Channel.
*******************************************************************************/
  type rt_matl_dstrbtn_chnl is record (
    matl_code                       mfanz_matl_by_sales_area.matl_code%type,
    sales_org                       mfanz_matl_by_sales_area.sales_org%type,
    dstrbtn_chnl                    mfanz_matl_by_sales_area.dstrbtn_chnl%type
  );

  type tt_matl_dstrbtn_chnl is table of rt_matl_dstrbtn_chnl;

  function pt_matl_dstrbtn_chnl (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
  ) return tt_matl_dstrbtn_chnl pipelined;

/*******************************************************************************
  NAME: PT_LIST_PRICE                                                     PUBLIC
  PURPOSE: Pipeline of List Prices for Company / Division
           with End Date >= Effective Date.
*******************************************************************************/
  type rt_list_price is record (
    sales_org                       lads_prc_lst_hdr.vkorg%type,
    div_code                        mfanz_matl.dvsn%type,
    dstrbtn_chnl                    mfanz_matl_by_sales_area.dstrbtn_chnl%type,
    cust_code                       lads_prc_lst_hdr.kunnr%type,
    matl_code                       lads_prc_lst_hdr.matnr%type,
    start_date                      date,
    end_date                        date,
    currency                        lads_prc_lst_det.konwa%type,
    list_price                      lads_prc_lst_det.kbetr%type
  );

  type tt_list_price is table of rt_list_price;

  function pt_list_price (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_list_price pipelined;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
  PURPOSE: Pipeline of up to the next 3 List Prices for
           Company / Division / Effective Date.
           Interface Output Format is in the [output_record] field.
*******************************************************************************/
  type rt_output is record (
    output_record                   varchar2(4000 char),
    --
    sales_org                       lads_prc_lst_hdr.vkorg%type,
    div_code                        mfanz_matl.dvsn%type,
    dstrbtn_chnl                    mfanz_matl_by_sales_area.dstrbtn_chnl%type,
    cust_code                       lads_prc_lst_hdr.kunnr%type,
    matl_code                       lads_prc_lst_hdr.matnr%type,
    start_date                      date,
    end_date                        date,
    currency                        lads_prc_lst_det.konwa%type,
    list_price                      lads_prc_lst_det.kbetr%type,
    rank_seq                        number
  );

  type tt_output is table of rt_output;

  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined;

/*******************************************************************************
  NAME: EXECUTE                                                           PUBLIC
  PURPOSE: Creates the outbound interface using [output_record] from [pt_output]
*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_eff_date in date
   );

end pxipmx06_extract_v2;
/

create or replace package body pxi_app.pxipmx06_extract_v2 as
/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX06_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX06';

/*******************************************************************************
  NAME: PT_LIST_PRICE_HDR                                                 PUBLIC
*******************************************************************************/
  function pt_list_price_hdr (
    i_promax_company in pxi_common.st_company,
    i_eff_date in date
  ) return tt_list_price_hdr pipelined is

  begin

    for rv_row in (

      select vkorg as sales_org,
        kunnr as cust_code,
        matnr as matl_code,
        to_date(datab, 'YYYYMMDD') as start_date,
        to_date(datbi, 'YYYYMMDD') as end_date,
        vakey,
        kschl,
        knumh
      from lads_prc_lst_hdr
      where matnr is not null -- Material code
      and kotabnr = 812 -- 812 refers to the Access Sequence Sales Organisation / Material -> Customer will be NULL !!!
      and kschl in ('ZN00', 'ZR05')
      and i_eff_date <= to_date(datbi, 'YYYYMMDD') -- Effective date less than end date
      and vkorg = i_promax_company

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_LIST_PRICE_HDR');

  end pt_list_price_hdr;

/*******************************************************************************
  NAME: PT_LIST_PRICE_DTL                                                 PUBLIC
*******************************************************************************/
  function pt_list_price_dtl return tt_list_price_dtl pipelined is

  begin

    for rv_row in (

      select
        konwa as currency,
        kbetr as list_price,
        to_date(datab, 'YYYYMMDD') as start_date,
        vakey,
        kschl,
        knumh
      from lads_prc_lst_det a
      where kbetr is not null -- price is not null
      and kschl in ('ZN00', 'ZR05')
      and kmein = 'EA'
      and loevm_ko is null -- If this is marked 'X' it means the condition is no longer active

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_LIST_PRICE_DTL');

  end pt_list_price_dtl;

/*******************************************************************************
  NAME: PT_MATL_DIV_CODE                                                  PUBLIC
*******************************************************************************/
  function pt_matl_div_code return tt_matl_div_code pipelined is

  begin

    for rv_row in (

      select matl_code,
        dvsn as div_code
      from mfanz_matl
      where matl_type = 'ZREP'
      and trdd_unit = 'X'

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_MATL_DIV_CODE');

  end pt_matl_div_code;

/*******************************************************************************
  NAME: PT_MATL_TRADE_SCTR                                                PUBLIC
*******************************************************************************/
  function pt_matl_trade_sctr return tt_matl_trade_sctr pipelined is

  begin

    for rv_row in (

      select matl_code,
        trade_sctr_code
      from mfanz_fg_matl_clssfctn

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_MATL_TRADE_SCTR');

  end pt_matl_trade_sctr;

/*******************************************************************************
  NAME: PT_MATL_DSTRBTN_CHNL                                              PUBLIC
*******************************************************************************/
  function pt_matl_dstrbtn_chnl (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
  ) return tt_matl_dstrbtn_chnl pipelined is

  begin

    for rv_row in (

      select matl_code,
        sales_org,
        dstrbtn_chnl
      from mfanz_matl_by_sales_area
      where dstrbtn_chnl in (
        select distribution_channel
        from pxi.pmx_extract_criteria
        where promax_company = i_promax_company
        and promax_division = i_promax_division
        and required_for_price = 'YES'
      )

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_MATL_DSTRBTN_CHNL');

  end pt_matl_dstrbtn_chnl;

/*******************************************************************************
  NAME: PT_LIST_PRICE                                                     PUBLIC
*******************************************************************************/
  function pt_list_price (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_list_price pipelined is

  begin

    for rv_row in (

      select
        price_list_hdr.sales_org,
        matl_div_code.div_code,
        matl_dstrbtn_chnl.dstrbtn_chnl,
        price_list_hdr.cust_code,
        ltrim(price_list_hdr.matl_code, 0) as matl_code,
        price_list_hdr.start_date,
        price_list_hdr.end_date,
        price_list_dtl.currency,
        case
          when price_list_hdr.sales_org = pxi_common.fc_australia
          and matl_dstrbtn_chnl.dstrbtn_chnl = '12'
          and matl_trade_sctr.trade_sctr_code = '01' then
            price_list_dtl.list_price * 1.03
          else
            price_list_dtl.list_price
        end as list_price
      from table(pxipmx06_extract_v2.pt_list_price_hdr(i_promax_company, i_eff_date)) price_list_hdr,
        table(pxipmx06_extract_v2.pt_list_price_dtl) price_list_dtl,
        table(pxipmx06_extract_v2.pt_matl_div_code) matl_div_code,
        table(pxipmx06_extract_v2.pt_matl_trade_sctr) matl_trade_sctr,
        table(pxipmx06_extract_v2.pt_matl_dstrbtn_chnl(i_promax_company, i_promax_division)) matl_dstrbtn_chnl,
        (
          select promax_company,
            promax_division,
            distribution_channel
          from pxi.pmx_extract_criteria
          where promax_company = i_promax_company
          and promax_division = i_promax_division
          and required_for_price = 'YES'
        ) extract_criteria
      -- price_list_hdr > price_list_dtl
      where price_list_hdr.vakey = price_list_dtl.vakey
      and price_list_hdr.start_date = price_list_dtl.start_date
      and price_list_hdr.kschl = price_list_dtl.kschl
      and price_list_hdr.knumh = price_list_dtl.knumh
      -- price_list_hdr > matl_dstrbtn_chnl
      and price_list_hdr.matl_code = matl_dstrbtn_chnl.matl_code
      and price_list_hdr.sales_org = matl_dstrbtn_chnl.sales_org
      -- price_list_hdr > matl_trade_sctr
      and price_list_hdr.matl_code = matl_trade_sctr.matl_code
      -- price_list_hdr > matl_div_code
      and price_list_hdr.matl_code = matl_div_code.matl_code
      --  price_list_hdr, matl_dstrbtn_chnl, matl_div_code > extract_criteria
      and price_list_hdr.sales_org = extract_criteria.promax_company
      and matl_dstrbtn_chnl.dstrbtn_chnl = extract_criteria.distribution_channel
      and (
        (price_list_hdr.sales_org = pxi_common.fc_australia and matl_div_code.div_code = extract_criteria.promax_division)
        or (price_list_hdr.sales_org = pxi_common.fc_new_zealand)
      )

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_LIST_PRICE');

  end pt_list_price;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
*******************************************************************************/
  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined is

  begin

    for rv_row in (

      select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
        pxi_common.char_format('Record Type', '330002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '330002' -> RecordType
        pxi_common.char_format('Promax Company', sales_org, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
        pxi_common.char_format('Promax Division', case sales_org when pxi_common.gc_new_zealand then pxi_common.gc_new_zealand else div_code end, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
        pxi_common.char_format('Customer Code', 'DIV_1', 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- CONSTANT 'DIV_1' -> CustomerCode
        pxi_common.char_format('Material Code', matl_code, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- matl_code -> MaterialCode
        pxi_common.date_format('Start Date', start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- start_date -> StartDate
        pxi_common.date_format('End Date', end_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- end_date -> EndDate
        pxi_common.numb_format('List Price', list_price, '999999990.00', pxi_common.fc_is_not_nullable) || -- list_price -> ListPrice
        pxi_common.char_format('Currency', currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- currency -> Currency
        as output_record,
        ------------------------------------------------------------------------
        sales_org,
        div_code,
        dstrbtn_chnl, -- Dimension not used above -- Theoretically could create "apparent" pricing duplicates across distribution channels ..
        cust_code, -- ALWAYS NULL .. see [pt_list_price_hdr]
        matl_code,
        start_date,
        end_date,
        currency,
        list_price,
        rank_seq
      from (
        select
          sales_org,
          div_code,
          dstrbtn_chnl,
          cust_code,
          matl_code,
          start_date,
          end_date,
          currency,
          list_price,
          rank_seq
        from (
          select
            sales_org,
            div_code,
            dstrbtn_chnl,
            cust_code,
            matl_code,
            start_date,
            end_date,
            currency,
            list_price,
            rank () over ( partition by
              sales_org,
              div_code,
              dstrbtn_chnl,
              cust_code,
              matl_code,
              currency
              order by start_date
            ) as rank_seq
          from table(pxipmx06_extract_v2.pt_list_price(i_promax_company, i_promax_division, i_eff_date)) list_price
        )
        where rank_seq <= 3 -- the first 3 list prices, per start_date
        order by
          sales_org,
          div_code,
          dstrbtn_chnl,
          cust_code,
          matl_code,
          currency,
          start_date
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
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_eff_date in date
   ) is

     v_instance number(15,0);

   begin

    for rv_row in (

      select output_record
      from table(pxipmx06_extract_v2.pt_output(i_promax_company, i_promax_division, i_eff_date))

    )
    loop

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_promax_company,i_promax_division));
      end if;

      -- Append interface data
      lics_outbound_loader.append_data(rv_row.output_record);

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
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx06_extract_v2;
/

grant execute on pxi_app.pxipmx06_extract_v2 to lics_app, fflu_app, site_app;
