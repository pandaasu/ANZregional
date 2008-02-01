/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_intransit_contnr_hdr
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Intransit Container Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_intransit_contnr_hdr
   (handling_unit_id,
    sap_company_code,
    contnr_num,
    whse_estd_arrival_date,
    port_estd_arrival_date,
    sap_forwarding_agent_code,
    vessel_desc,
    voyage_num,
    sap_vendor_code,
    purch_order_num,
    sap_prv_handling_unit_sts_code,
    sap_handling_unit_sts_code,
    contnr_creatn_date,
    idoc_creatn_date,
    idoc_creatn_time) as 
   select t01.exidv,
          t01.bukrs,
          t01.exidv2,
          lads_to_date(t01.slfdt,'yyyymmdd'),
          lads_to_date(t01.eindt,'yyyymmdd'),
          t01.zfwrd,
          t01.exti1,
          t01.signi,
          lads_trim_code(t01.lifnr),
          t01.ebeln,
          t01.prvstat,
          case when t01.zhustat = '1' and t01.datum != (select max(datum) as max_date from lads_icb_mfj_hdr) then '5'
               when t01.zhustat in ('2','3') and t01.datum != (select max(datum) as max_date from lads_icb_mfj_hdr) then '4'
               else t01.zhustat end,
          lads_to_date(t01.hudat,'yyyymmdd'),
          lads_to_date(t01.datum,'yyyymmdd'),
          uzeit
     from lads_icb_mfj_hdr t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_intransit_contnr_hdr to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_intransit_contnr_hdr for lads.ods_intransit_contnr_hdr;

