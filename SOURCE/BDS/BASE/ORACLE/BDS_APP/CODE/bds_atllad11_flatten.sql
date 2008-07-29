/******************/
/* Package Header */
/******************/
create or replace package bds_atllad11_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad11_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD11 - Customer Master (DEBMAS05)

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

    NOTES
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created
    2007/08   Steve Gregan   Atlas 3.2.1 upgrade (SAD)

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_kunnr in varchar2);

end bds_atllad11_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad11_flatten as

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
   procedure lads_lock(par_kunnr in varchar2);
   procedure bds_flatten(par_kunnr in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_kunnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_kunnr);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_kunnr);
        when '*REFRESH' then bds_refresh;
        when '*REBUILD' then bds_rebuild;
        else raise_application_error(-20000, 'Action parameter must be *DOCUMENT, *DOCUMENT_OVERRIDE, *REFRESH or *REBUILD');
      end case;

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
         raise_application_error(-20000, 'bds_atllad11_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_kunnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;
      var_text varchar2(4000);

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_cust_header bds_cust_header%rowtype;
      rcd_bds_cust_text bds_cust_text%rowtype;
      rcd_bds_cust_contact bds_cust_contact%rowtype;
      rcd_bds_cust_bank bds_cust_bank%rowtype;
      rcd_bds_cust_unlpnt bds_cust_unlpnt%rowtype;
      rcd_bds_cust_vat bds_cust_vat%rowtype;
      rcd_bds_cust_sales_area bds_cust_sales_area%rowtype;
      rcd_bds_cust_sales_area_vmityp bds_cust_sales_area_vmityp%rowtype;
      rcd_bds_cust_sales_area_vmifct bds_cust_sales_area_vmifct%rowtype;
      rcd_bds_cust_sales_area_pnrfun bds_cust_sales_area_pnrfun%rowtype;
      rcd_bds_cust_sales_area_taxind bds_cust_sales_area_taxind%rowtype;
      rcd_bds_cust_sales_area_licse bds_cust_sales_area_licse%rowtype;
      rcd_bds_cust_sales_area_text bds_cust_sales_area_text%rowtype;
      rcd_bds_cust_comp bds_cust_comp%rowtype;
      rcd_bds_cust_comp_whtax bds_cust_comp_whtax%rowtype;
      rcd_bds_cust_comp_text bds_cust_comp_text%rowtype;
      rcd_bds_cust_plant bds_cust_plant%rowtype;
      rcd_bds_cust_plant_rcvpnt bds_cust_plant_rcvpnt%rowtype;
      rcd_bds_cust_plant_dept bds_cust_plant_dept%rowtype;
      rcd_bds_cust_plant_vomd bds_cust_plant_vomd%rowtype;
      rcd_bds_cust_plant_vomd_except bds_cust_plant_vomd_except%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_cus_hdr is
         select t01.kunnr as kunnr,
                t01.aufsd as aufsd,
                t01.begru as begru,
                t01.brsch as brsch,
                t01.faksd as faksd,
                t01.fiskn as fiskn,
                t01.knrza as knrza,
                t01.konzs as konzs,
                t01.ktokd as ktokd,
                t01.kukla as kukla,
                t01.lifnr as lifnr,
                t01.lifsd as lifsd,
                t01.loevm as loevm,
                t01.sperr as sperr,
                t01.stcd1 as stcd1,
                t01.stcd2 as stcd2,
                t01.stkza as stkza,
                t01.stkzu as stkzu,
                t01.xzemp as xzemp,
                t01.vbund as vbund,
                t01.stceg as stceg,
                t01.gform as gform,
                t01.umjah as umjah,
                t01.uwaer as uwaer,
                t01.katr2 as katr2,
                t01.katr3 as katr3,
                t01.katr4 as katr4,
                t01.katr5 as katr5,
                t01.katr6 as katr6,
                t01.katr7 as katr7,
                t01.katr8 as katr8,
                t01.katr9 as katr9,
                t01.katr10 as katr10,
                t01.stkzn as stkzn,
                t01.umsa1 as umsa1,
                t01.periv as periv,
                t01.ktocd as ktocd,
                t01.fityp as fityp,
                t01.stcdt as stcdt,
                t01.stcd3 as stcd3,
                t01.stcd4 as stcd4,
                t01.cassd as cassd,
                t01.kdkg1 as kdkg1,
                t01.kdkg2 as kdkg2,
                t01.kdkg3 as kdkg3,
                t01.kdkg4 as kdkg4,
                t01.kdkg5 as kdkg5,
                t01.nodel as nodel,
                t01.xsub2 as xsub2,
                t01.werks as werks,
                t01.zzcustom01 as zzcustom01,
                t01.zzkatr13 as zzkatr13,
                t01.zzkatr14 as zzkatr14,
                t01.j_1kfrepre as j_1kfrepre,
                t01.j_1kftbus as j_1kftbus,
                t01.j_1kftind as j_1kftind,
                t01.psois as psois,
                t01.katr1 as katr1,
                t01.zzcuststat as zzcuststat,
                t01.zzretstore as zzretstore,
                t01.locco as locco,
                t01.zzdemplan as zzdemplan,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status
           from lads_cus_hdr t01
          where t01.kunnr = par_kunnr;
      rcd_lads_cus_hdr csr_lads_cus_hdr%rowtype;

      cursor csr_lads_cus_hth is
         select * from (
            select t01.kunnr as kunnr,
                   t01.hthseq as hthseq,
                   nvl(t01.tdobject,'*NONE') as tdobject,
                   nvl(t01.tdname,'*NONE') as tdname,
                   nvl(t01.tdid,'*NONE') as tdid,
                   nvl(t01.tdspras,'*NONE') as tdspras,
                   nvl(t01.tdtexttype,'*NONE') as tdtexttype,
                   t01.tdsprasiso as tdsprasiso,
                   rank() over (partition by nvl(t01.tdobject,'*NONE'),
                                             nvl(t01.tdname,'*NONE'),
                                             nvl(t01.tdid,'*NONE'),
                                             nvl(t01.tdspras,'*NONE'),
                                             nvl(t01.tdtexttype,'*NONE')
                                    order by t01.hthseq) as rnkseq
              from lads_cus_hth t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_hth csr_lads_cus_hth%rowtype;

      cursor csr_lads_cus_htd is
         select t01.tdline as tdline
           from lads_cus_htd t01
          where t01.kunnr = rcd_lads_cus_hth.kunnr
            and t01.hthseq = rcd_lads_cus_hth.hthseq
          order by t01.htdseq asc;
      rcd_lads_cus_htd csr_lads_cus_htd%rowtype;

      cursor csr_lads_cus_cnt is
         select * from (
            select t01.kunnr as kunnr,
                   t01.cntseq as cntseq,
                   nvl(t01.parnr,999999999) as parnr,
                   t01.namev as namev,
                   t01.name1 as name1,
                   t01.abtpa as abtpa,
                   t01.abtnr as abtnr,
                   t01.uepar as uepar,
                   t01.telf1 as telf1,
                   t01.anred as anred,
                   t01.pafkt as pafkt,
                   t01.sortl as sortl,
                   t01.zz_tel_extens as zz_tel_extens,
                   t01.zz_fax_number as zz_fax_number,
                   t01.zz_fax_extens as zz_fax_extens,
                   rank() over (partition by nvl(t01.parnr,999999999)
                                    order by t01.cntseq) as rnkseq
              from lads_cus_cnt t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_cnt csr_lads_cus_cnt%rowtype;

      cursor csr_lads_cus_bnk is
         select * from (
            select t01.kunnr as kunnr,
                   t01.bnkseq as bnkseq,
                   nvl(t01.banks,'*NONE') as banks,
                   nvl(t01.bankl,'*NONE') as bankl,
                   nvl(t01.bankn,'*NONE') as bankn,
                   nvl(t01.bkont,'*NONE') as bkont,
                   t01.bvtyp as bvtyp,
                   t01.xezer as xezer,
                   t01.bkref as bkref,
                   t01.banka as banka,
                   t01.stras as stras,
                   t01.ort01 as ort01,
                   t01.swift as swift,
                   t01.bgrup as bgrup,
                   t01.xpgro as xpgro,
                   t01.bnklz as bnklz,
                   t01.pskto as pskto,
                   t01.brnch as brnch,
                   t01.provz as provz,
                   t01.koinh as koinh,
                   t01.koinh_n as koinh_n,
                   bds_date.bds_to_date('*DATE',t01.kovon) as kovon,
                   bds_date.bds_to_date('*DATE',t01.kobis) as kobis,
                   rank() over (partition by nvl(t01.banks,'*NONE'),
                                             nvl(t01.bankl,'*NONE'),
                                             nvl(t01.bankn,'*NONE'),
                                             nvl(t01.bkont,'*NONE')
                                    order by t01.bnkseq) as rnkseq
              from lads_cus_bnk t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_bnk csr_lads_cus_bnk%rowtype;

      cursor csr_lads_cus_unl is
         select * from (
            select t01.kunnr as kunnr,
                   t01.unlseq as unlseq,
                   nvl(t01.ablad,'*NONE') as ablad,
                   t01.knfak as knfak,
                   t01.wanid as wanid,
                   t01.defab as defab,
                   rank() over (partition by nvl(t01.ablad,'*NONE')
                                    order by t01.unlseq) as rnkseq
              from lads_cus_unl t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_unl csr_lads_cus_unl%rowtype;

      cursor csr_lads_cus_vat is
         select * from (
            select t01.kunnr as kunnr,
                   t01.vatseq as vatseq,
                   nvl(t01.land1,'*NONE') as land1,
                   t01.stceg as stceg,
                   rank() over (partition by nvl(t01.land1,'*NONE')
                                    order by t01.vatseq) as rnkseq
              from lads_cus_vat t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_vat csr_lads_cus_vat%rowtype;

      cursor csr_lads_cus_sad is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   nvl(t01.vkorg,'*NONE') as vkorg,
                   nvl(t01.vtweg,'*NONE') as vtweg,
                   nvl(t01.spart,'*NONE') as spart,
                   t01.begru as begru,
                   t01.loevm as loevm,
                   t01.versg as versg,
                   t01.aufsd as aufsd,
                   t01.kalks as kalks,
                   t01.kdgrp as kdgrp,
                   t01.bzirk as bzirk,
                   t01.konda as konda,
                   t01.pltyp as pltyp,
                   t01.awahr as awahr,
                   t01.inco1 as inco1,
                   t01.inco2 as inco2,
                   t01.lifsd as lifsd,
                   t01.autlf as autlf,
                   t01.antlf as antlf,
                   t01.kztlf as kztlf,
                   t01.kzazu as kzazu,
                   t01.chspl as chspl,
                   t01.lprio as lprio,
                   t01.eikto as eikto,
                   t01.vsbed as vsbed,
                   t01.faksd as faksd,
                   t01.mrnkz as mrnkz,
                   t01.perfk as perfk,
                   t01.perrl as perrl,
                   t01.waers as waers,
                   t01.ktgrd as ktgrd,
                   t01.zterm as zterm,
                   t01.vwerk as vwerk,
                   t01.vkgrp as vkgrp,
                   t01.vkbur as vkbur,
                   t01.vsort as vsort,
                   t01.kvgr1 as kvgr1,
                   t01.kvgr2 as kvgr2,
                   t01.kvgr3 as kvgr3,
                   t01.kvgr4 as kvgr4,
                   t01.kvgr5 as kvgr5,
                   t01.bokre as bokre,
                   t01.kurst as kurst,
                   t01.prfre as prfre,
                   t01.klabc as klabc,
                   t01.kabss as kabss,
                   t01.kkber as kkber,
                   t01.cassd as cassd,
                   t01.rdoff as rdoff,
                   t01.agrel as agrel,
                   t01.megru as megru,
                   t01.uebto as uebto,
                   t01.untto as untto,
                   t01.uebtk as uebtk,
                   t01.pvksm as pvksm,
                   t01.podkz as podkz,
                   t01.podtg as podtg,
                   t01.blind as blind,
                   t01.zzshelfgrp as zzshelfgrp,
                   t01.zzvmicdim as zzvmicdim,
                   t01.zzcurrentflag as zzcurrentflag,
                   t01.zzfutureflag as zzfutureflag,
                   t01.zzmarketacctflag as zzmarketacctflag,
                   t01.zzcspiv,
                   t01.zzcmph,
                   t01.zzcmph_uom,
                   t01.zzhppl,
                   t01.zzhppc,
                   t01.zztmr,
                   t01.zzpppm,
                   t01.zzmpph,
                   t01.zzmpph_uom,
                   rank() over (partition by nvl(t01.vkorg,'*NONE'),
                                             nvl(t01.vtweg,'*NONE'),
                                             nvl(t01.spart,'*NONE')
                                    order by t01.sadseq) as rnkseq
              from lads_cus_sad t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_sad csr_lads_cus_sad%rowtype;

      cursor csr_lads_cus_zsd is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.zsdseq as zsdseq,
                   t01.vkorg as vkorg,
                   t01.vtweg as vtweg,
                   t01.spart as spart,
                   t01.vmict as vmict,
                   rank() over (partition by t01.sadseq
                                    order by t01.zsdseq) as rnkseq
              from lads_cus_zsd t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_zsd csr_lads_cus_zsd%rowtype;

      cursor csr_lads_cus_zsv is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.zsvseq as zsvseq,
                   t01.vkorg as vkorg,
                   t01.vtweg as vtweg,
                   t01.spart as spart,
                   t01.vmifds as vmifds,
                   rank() over (partition by t01.sadseq
                                    order by t01.zsvseq) as rnkseq
              from lads_cus_zsv t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_zsv csr_lads_cus_zsv%rowtype;

      cursor csr_lads_cus_pfr is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.pfrseq as pfrseq,
                   nvl(t01.parvw,'*NONE') as parvw,
                   nvl(t01.kunn2,'*NONE') as kunn2,
                   t01.defpa as defpa,
                   t01.knref as knref,
                   t01.parza as parza,
                   t01.zz_parvw_txt as zz_parvw_txt,
                   t01.zz_partn_nam as zz_partn_nam,
                   t01.zz_partn_nachn as zz_partn_nachn,
                   t01.zz_partn_vorna as zz_partn_vorna,
                   rank() over (partition by nvl(t01.parvw,'*NONE'),
                                             nvl(t01.kunn2,'*NONE')
                                    order by t01.pfrseq) as rnkseq
              from lads_cus_pfr t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_pfr csr_lads_cus_pfr%rowtype;

      cursor csr_lads_cus_stx is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.stxseq as stxseq,
                   nvl(t01.aland,'*NONE') as aland,
                   nvl(t01.tatyp,'*NONE') as tatyp,
                   t01.taxkd as taxkd,
                   rank() over (partition by nvl(t01.aland,'*NONE'),
                                             nvl(t01.tatyp,'*NONE')
                                    order by t01.stxseq) as rnkseq
              from lads_cus_stx t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_stx csr_lads_cus_stx%rowtype;

      cursor csr_lads_cus_lid is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.lidseq as lidseq,
                   t01.aland as aland,
                   t01.tatyp as tatyp,
                   t01.licnr as licnr,
                   bds_date.bds_to_date('*START_DATE',t01.datab) as datab,
                   bds_date.bds_to_date('*END_DATE',t01.datbi) as datbi,
                   t01.belic as belic,
                   rank() over (partition by nvl(t01.aland,'*NONE'),
                                             nvl(t01.tatyp,'*NONE'),
                                             t01.datab,
                                             t01.datbi
                                    order by t01.lidseq) as rnkseq
              from lads_cus_lid t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_lid csr_lads_cus_lid%rowtype;

      cursor csr_lads_cus_sat is
         select * from (
            select t01.kunnr as kunnr,
                   t01.sadseq as sadseq,
                   t01.satseq as satseq,
                   nvl(t01.tdobject,'*NONE') as tdobject,
                   nvl(t01.tdname,'*NONE') as tdname,
                   nvl(t01.tdid,'*NONE') as tdid,
                   nvl(t01.tdspras,'*NONE') as tdspras,
                   nvl(t01.tdtexttype,'*NONE') as tdtexttype,
                   t01.tdsprasiso as tdsprasiso,
                   rank() over (partition by nvl(t01.tdobject,'*NONE'),
                                             nvl(t01.tdname,'*NONE'),
                                             nvl(t01.tdid,'*NONE'),
                                             nvl(t01.tdspras,'*NONE'),
                                             nvl(t01.tdtexttype,'*NONE')
                                    order by t01.satseq) as rnkseq
              from lads_cus_sat t01
             where t01.kunnr = rcd_lads_cus_sad.kunnr
               and t01.sadseq = rcd_lads_cus_sad.sadseq)
         where rnkseq = 1;
      rcd_lads_cus_sat csr_lads_cus_sat%rowtype;

      cursor csr_lads_cus_std is
         select t01.tdline as tdline
           from lads_cus_std t01
          where t01.kunnr = rcd_lads_cus_sat.kunnr
            and t01.sadseq = rcd_lads_cus_sat.sadseq
            and t01.satseq = rcd_lads_cus_sat.satseq
          order by t01.stdseq asc;
      rcd_lads_cus_std csr_lads_cus_std%rowtype;

      cursor csr_lads_cus_cud is
         select * from (
            select t01.kunnr as kunnr,
                   t01.cudseq as cudseq,
                   nvl(t01.bukrs,'*NONE') as bukrs,
                   t01.sperr as sperr,
                   t01.loevm as loevm,
                   t01.zuawa as zuawa,
                   t01.busab as busab,
                   t01.akont as akont,
                   t01.begru as begru,
                   t01.knrze as knrze,
                   t01.knrzb as knrzb,
                   t01.zamim as zamim,
                   t01.zamiv as zamiv,
                   t01.zamir as zamir,
                   t01.zamib as zamib,
                   t01.zamio as zamio,
                   t01.zwels as zwels,
                   t01.xverr as xverr,
                   t01.zahls as zahls,
                   t01.zterm as zterm,
                   t01.wakon as wakon,
                   t01.vzskz as vzskz,
                   bds_date.bds_to_date('*DATE',t01.zindt) as zindt,
                   t01.zinrt as zinrt,
                   t01.eikto as eikto,
                   t01.zsabe as zsabe,
                   t01.kverm as kverm,
                   t01.fdgrv as fdgrv,
                   t01.vrbkz as vrbkz,
                   t01.vlibb as vlibb,
                   t01.vrszl as vrszl,
                   t01.vrspr as vrspr,
                   t01.vrsnr as vrsnr,
                   bds_date.bds_to_date('*DATE',t01.verdt) as verdt,
                   t01.perkz as perkz,
                   t01.xdezv as xdezv,
                   t01.xausz as xausz,
                   t01.webtr as webtr,
                   t01.remit as remit,
                   bds_date.bds_to_date('*DATE',t01.datlz) as datlz,
                   t01.xzver as xzver,
                   t01.togru as togru,
                   t01.kultg as kultg,
                   t01.hbkid as hbkid,
                   t01.xpore as xpore,
                   t01.blnkz as blnkz,
                   t01.altkn as altkn,
                   t01.zgrup as zgrup,
                   t01.urlid as urlid,
                   t01.mgrup as mgrup,
                   t01.lockb as lockb,
                   t01.uzawe as uzawe,
                   t01.ekvbd as ekvbd,
                   t01.sregl as sregl,
                   t01.xedip as xedip,
                   t01.frgrp as frgrp,
                   t01.vrsdg as vrsdg,
                   t01.tlfxs as tlfxs,
                   t01.pernr as pernr,
                   t01.intad as intad,
                   t01.guzte as guzte,
                   t01.gricd as gricd,
                   t01.gridt as gridt,
                   t01.wbrsl as wbrsl,
                   t01.nodel as nodel,
                   t01.tlfns as tlfns,
                   t01.cession_kz as cession_kz,
                   t01.gmvkzd as gmvkzd,
                   rank() over (partition by nvl(t01.bukrs,'*NONE')
                                    order by t01.cudseq) as rnkseq
              from lads_cus_cud t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_cud csr_lads_cus_cud%rowtype;

      cursor csr_lads_cus_ctx is
         select * from (
            select t01.kunnr as kunnr,
                   t01.cudseq as cudseq,
                   t01.ctxseq as ctxseq,
                   nvl(t01.witht,'*NONE') as witht,
                   nvl(t01.wt_withcd,'*NONE') as wt_withcd,
                   t01.wt_agent as wt_agent,
                   bds_date.bds_to_date('*START_DATE',t01.wt_agtdf) as wt_agtdf,
                   bds_date.bds_to_date('*END_DATE',t01.wt_agtdt) as wt_agtdt,
                   t01.wt_wtstcd as wt_wtstcd,
                   t01.bukrs as bukrs,
                   rank() over (partition by nvl(t01.witht,'*NONE'),
                                             nvl(t01.wt_withcd,'*NONE'),
                                             t01.wt_agtdf,
                                             t01.wt_agtdt
                                    order by t01.ctxseq) as rnkseq
              from lads_cus_ctx t01
             where t01.kunnr = rcd_lads_cus_cud.kunnr
               and t01.cudseq = rcd_lads_cus_cud.cudseq)
         where rnkseq = 1;
      rcd_lads_cus_ctx csr_lads_cus_ctx%rowtype;

      cursor csr_lads_cus_cte is
         select * from (
            select t01.kunnr as kunnr,
                   t01.cudseq as cudseq,
                   t01.cteseq as cteseq,
                   nvl(t01.tdobject,'*NONE') as tdobject,
                   nvl(t01.tdname,'*NONE') as tdname,
                   nvl(t01.tdid,'*NONE') as tdid,
                   nvl(t01.tdspras,'*NONE') as tdspras,
                   nvl(t01.tdtexttype,'*NONE') as tdtexttype,
                   t01.tdsprasiso as tdsprasiso,
                   rank() over (partition by nvl(t01.tdobject,'*NONE'),
                                             nvl(t01.tdname,'*NONE'),
                                             nvl(t01.tdid,'*NONE'),
                                             nvl(t01.tdspras,'*NONE'),
                                             nvl(t01.tdtexttype,'*NONE')
                                    order by t01.cteseq) as rnkseq
              from lads_cus_cte t01
             where t01.kunnr = rcd_lads_cus_cud.kunnr
               and t01.cudseq = rcd_lads_cus_cud.cudseq)
         where rnkseq = 1;
      rcd_lads_cus_cte csr_lads_cus_cte%rowtype;

      cursor csr_lads_cus_ctd is
         select t01.tdline as tdline
           from lads_cus_ctd t01
          where t01.kunnr = rcd_lads_cus_cte.kunnr
            and t01.cudseq = rcd_lads_cus_cte.cudseq
            and t01.cteseq = rcd_lads_cus_cte.cteseq
          order by t01.ctdseq asc;
      rcd_lads_cus_ctd csr_lads_cus_ctd%rowtype;

      cursor csr_lads_cus_plm is
         select * from (
            select t01.kunnr as kunnr,
                   t01.plmseq as plmseq,
                   nvl(t01.locnr,'*NONE') as locnr,
                   bds_date.bds_to_date('*DATE',t01.eroed) as eroed,
                   bds_date.bds_to_date('*DATE',t01.schld) as schld,
                   bds_date.bds_to_date('*DATE',t01.spdab) as spdab,
                   bds_date.bds_to_date('*DATE',t01.spdbi) as spdbi,
                   t01.autob as autob,
                   t01.kopro as kopro,
                   t01.layvr as layvr,
                   t01.flvar as flvar,
                   t01.stfak as stfak,
                   t01.wanid as wanid,
                   t01.verfl as verfl,
                   t01.verfe as verfe,
                   t01.spgr1 as spgr1,
                   t01.inpro as inpro,
                   t01.ekoar as ekoar,
                   t01.kzlik as kzlik,
                   t01.betrp as betrp,
                   bds_date.bds_to_date('*DATE',t01.erdat) as erdat,
                   t01.ernam as ernam,
                   t01.nlmatfb as nlmatfb,
                   t01.bwwrk as bwwrk,
                   t01.bwvko as bwvko,
                   t01.bwvtw as bwvtw,
                   t01.bbpro as bbpro,
                   t01.vkbur_wrk as vkbur_wrk,
                   t01.vlfkz as vlfkz,
                   t01.lstfl as lstfl,
                   t01.ligrd as ligrd,
                   t01.vkorg as vkorg,
                   t01.vtweg as vtweg,
                   t01.desroi as desroi,
                   t01.timinc as timinc,
                   t01.posws as posws,
                   t01.ssopt_pro as ssopt_pro,
                   t01.wbpro as wbpro,
                   rank() over (partition by nvl(t01.locnr,'*NONE')
                                    order by t01.plmseq) as rnkseq
              from lads_cus_plm t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_plm csr_lads_cus_plm%rowtype;

      cursor csr_lads_cus_prp is
         select * from (
            select t01.kunnr as kunnr,
                   t01.prpseq as prpseq,
                   nvl(t01.locnr,'*NONE') as locnr,
                   nvl(t01.empst,'*NONE') as empst,
                   t01.kunn2 as kunn2,
                   t01.ablad as ablad,
                   rank() over (partition by nvl(t01.locnr,'*NONE'),
                                             nvl(t01.empst,'*NONE')
                                    order by t01.prpseq) as rnkseq
              from lads_cus_prp t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_prp csr_lads_cus_prp%rowtype;

      cursor csr_lads_cus_pdp is
         select * from (
            select t01.kunnr as kunnr,
                   t01.pdpseq as pdpseq,
                   nvl(t01.locnr,'*NONE') as locnr,
                   nvl(t01.abtnr,'*NONE') as abtnr,
                   t01.empst as empst,
                   t01.verfl as verfl,
                   t01.verfe as verfe,
                   t01.layvr as layvr,
                   t01.flvar as flvar,
                   rank() over (partition by nvl(t01.locnr,'*NONE'),
                                             nvl(t01.abtnr,'*NONE')
                                    order by t01.pdpseq) as rnkseq
              from lads_cus_pdp t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_pdp csr_lads_cus_pdp%rowtype;

      cursor csr_lads_cus_mgv is
         select * from (
            select t01.kunnr as kunnr,
                   t01.mgvseq as mgvseq,
                   nvl(t01.locnr,'*NONE') as locnr,
                   nvl(t01.matkl,'*NONE') as matkl,
                   nvl(t01.wwgpa,'*NONE') as wwgpa,
                   t01.kedet as kedet,
                   rank() over (partition by nvl(t01.locnr,'*NONE'),
                                             nvl(t01.matkl,'*NONE'),
                                             nvl(t01.wwgpa,'*NONE')
                                    order by t01.mgvseq) as rnkseq
              from lads_cus_mgv t01
             where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_mgv csr_lads_cus_mgv%rowtype;

      cursor csr_lads_cus_mge is
         select * from (
            select t01.kunnr as kunnr,
                   t01.mgeseq as mgeseq,
                   nvl(t01.locnr,'*NONE') as locnr,
                   nvl(t01.matnr,'*NONE') as matnr,
                   nvl(t01.wmatn,'*NONE') as wmatn,
                   nvl(t01.matkl,'*NONE') as matkl,
                   rank() over (partition by nvl(t01.locnr,'*NONE'),
                                             nvl(t01.matnr,'*NONE'),
                                             nvl(t01.wmatn,'*NONE'),
                                             nvl(t01.matkl,'*NONE')
                                    order by t01.mgeseq) as rnkseq
              from lads_cus_mge t01
            where t01.kunnr = rcd_lads_cus_hdr.kunnr)
         where rnkseq = 1;
      rcd_lads_cus_mge csr_lads_cus_mge%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_excluded := false;
      var_flattened := '1';

      /*-*/
      /* Perform BDS Flattening Logic
      /* **note** - assumes that a lock is held in a parent procedure
      /*          - assumes commit/rollback will be issued in a parent procedure
      /*-*/

      /*-*/
      /* Delete the BDS table child data
      /*-*/
      delete from bds_cust_text where customer_code = par_kunnr;
      delete from bds_cust_contact where customer_code = par_kunnr;
      delete from bds_cust_bank where customer_code = par_kunnr;
      delete from bds_cust_unlpnt where customer_code = par_kunnr;
      delete from bds_cust_vat where customer_code = par_kunnr;
      delete from bds_cust_sales_area where customer_code = par_kunnr;
      delete from bds_cust_sales_area_vmityp where customer_code = par_kunnr;
      delete from bds_cust_sales_area_vmifct where customer_code = par_kunnr;
      delete from bds_cust_sales_area_pnrfun where customer_code = par_kunnr;
      delete from bds_cust_sales_area_taxind where customer_code = par_kunnr;
      delete from bds_cust_sales_area_licse where customer_code = par_kunnr;
      delete from bds_cust_sales_area_text where customer_code = par_kunnr;
      delete from bds_cust_comp where customer_code = par_kunnr;
      delete from bds_cust_comp_whtax where customer_code = par_kunnr;
      delete from bds_cust_comp_text where customer_code = par_kunnr;
      delete from bds_cust_plant where customer_code = par_kunnr;
      delete from bds_cust_plant_rcvpnt where customer_code = par_kunnr;
      delete from bds_cust_plant_dept where customer_code = par_kunnr;
      delete from bds_cust_plant_vomd where customer_code = par_kunnr;
      delete from bds_cust_plant_vomd_except where customer_code = par_kunnr;

      /*-*/
      /* Retrieve the LADS header
      /*-*/
      open csr_lads_cus_hdr;
      fetch csr_lads_cus_hdr into rcd_lads_cus_hdr;
      if csr_lads_cus_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_cus_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_cust_header.customer_code := rcd_lads_cus_hdr.kunnr;
      rcd_bds_cust_header.sap_idoc_name := rcd_lads_cus_hdr.idoc_name;
      rcd_bds_cust_header.sap_idoc_number := rcd_lads_cus_hdr.idoc_number;
      rcd_bds_cust_header.sap_idoc_timestamp := rcd_lads_cus_hdr.idoc_timestamp;
      rcd_bds_cust_header.bds_lads_date := rcd_lads_cus_hdr.lads_date;
      rcd_bds_cust_header.bds_lads_status := rcd_lads_cus_hdr.lads_status;
      rcd_bds_cust_header.order_block_flag := rcd_lads_cus_hdr.aufsd;
      rcd_bds_cust_header.auth_group_code := rcd_lads_cus_hdr.begru;
      rcd_bds_cust_header.industry_code := rcd_lads_cus_hdr.brsch;
      rcd_bds_cust_header.billing_block_flag := rcd_lads_cus_hdr.faksd;
      rcd_bds_cust_header.fiscal_address_account := rcd_lads_cus_hdr.fiskn;
      rcd_bds_cust_header.alternative_payer_account := rcd_lads_cus_hdr.knrza;
      rcd_bds_cust_header.group_key := rcd_lads_cus_hdr.konzs;
      rcd_bds_cust_header.account_group_code := rcd_lads_cus_hdr.ktokd;
      rcd_bds_cust_header.classification_code := rcd_lads_cus_hdr.kukla;
      rcd_bds_cust_header.vendor_code := rcd_lads_cus_hdr.lifnr;
      rcd_bds_cust_header.delivery_block_flag := rcd_lads_cus_hdr.lifsd;
      rcd_bds_cust_header.deletion_flag := rcd_lads_cus_hdr.loevm;
      rcd_bds_cust_header.posting_block_flag := rcd_lads_cus_hdr.sperr;
      rcd_bds_cust_header.tax_number_01 := rcd_lads_cus_hdr.stcd1;
      rcd_bds_cust_header.tax_number_02 := rcd_lads_cus_hdr.stcd2;
      rcd_bds_cust_header.tax_equalization_flag := rcd_lads_cus_hdr.stkza;
      rcd_bds_cust_header.vat_flag := rcd_lads_cus_hdr.stkzu;
      rcd_bds_cust_header.alternative_payee_flag := rcd_lads_cus_hdr.xzemp;
      rcd_bds_cust_header.trading_partner_company_code := rcd_lads_cus_hdr.vbund;
      rcd_bds_cust_header.vat_registration_number := rcd_lads_cus_hdr.stceg;
      rcd_bds_cust_header.legal_status := rcd_lads_cus_hdr.gform;
      rcd_bds_cust_header.sales_year := rcd_lads_cus_hdr.umjah;
      rcd_bds_cust_header.sales_currency_code := rcd_lads_cus_hdr.uwaer;
      rcd_bds_cust_header.sales_point_type := rcd_lads_cus_hdr.katr2;
      rcd_bds_cust_header.combine_invoice_list_code := rcd_lads_cus_hdr.katr3;
      rcd_bds_cust_header.attribute_04 := rcd_lads_cus_hdr.katr4;
      rcd_bds_cust_header.attribute_05 := rcd_lads_cus_hdr.katr5;
      rcd_bds_cust_header.attribute_06 := rcd_lads_cus_hdr.katr6;
      rcd_bds_cust_header.attribute_07 := rcd_lads_cus_hdr.katr7;
      rcd_bds_cust_header.attribute_08 := rcd_lads_cus_hdr.katr8;
      rcd_bds_cust_header.attribute_09 := rcd_lads_cus_hdr.katr9;
      rcd_bds_cust_header.attribute_10 := rcd_lads_cus_hdr.katr10;
      rcd_bds_cust_header.natural_person := rcd_lads_cus_hdr.stkzn;
      rcd_bds_cust_header.char_field_umsa1 := rcd_lads_cus_hdr.umsa1;
      rcd_bds_cust_header.fiscal_year_variant := rcd_lads_cus_hdr.periv;
      rcd_bds_cust_header.one_time_account_group := rcd_lads_cus_hdr.ktocd;
      rcd_bds_cust_header.tax_type := rcd_lads_cus_hdr.fityp;
      rcd_bds_cust_header.tax_number_type := rcd_lads_cus_hdr.stcdt;
      rcd_bds_cust_header.tax_number_03 := rcd_lads_cus_hdr.stcd3;
      rcd_bds_cust_header.tax_number_04 := rcd_lads_cus_hdr.stcd4;
      rcd_bds_cust_header.sales_block_flag := rcd_lads_cus_hdr.cassd;
      rcd_bds_cust_header.cndtn_grp_01 := rcd_lads_cus_hdr.kdkg1;
      rcd_bds_cust_header.cndtn_grp_02 := rcd_lads_cus_hdr.kdkg2;
      rcd_bds_cust_header.cndtn_grp_03 := rcd_lads_cus_hdr.kdkg3;
      rcd_bds_cust_header.cndtn_grp_04 := rcd_lads_cus_hdr.kdkg4;
      rcd_bds_cust_header.cndtn_grp_05 := rcd_lads_cus_hdr.kdkg5;
      rcd_bds_cust_header.deletion_block_flag := rcd_lads_cus_hdr.nodel;
      rcd_bds_cust_header.stc_customer_group := rcd_lads_cus_hdr.xsub2;
      rcd_bds_cust_header.plant_code := rcd_lads_cus_hdr.werks;
      rcd_bds_cust_header.char_field_zzcustom01 := rcd_lads_cus_hdr.zzcustom01;
      rcd_bds_cust_header.custom_attr_13 := rcd_lads_cus_hdr.zzkatr13;
      rcd_bds_cust_header.custom_attr_14 := rcd_lads_cus_hdr.zzkatr14;
      rcd_bds_cust_header.representative_name := rcd_lads_cus_hdr.j_1kfrepre;
      rcd_bds_cust_header.business_type := rcd_lads_cus_hdr.j_1kftbus;
      rcd_bds_cust_header.industry_type := rcd_lads_cus_hdr.j_1kftind;
      rcd_bds_cust_header.subledger_acct_procedure := rcd_lads_cus_hdr.psois;
      rcd_bds_cust_header.region_code := rcd_lads_cus_hdr.katr1;
      rcd_bds_cust_header.status_code := rcd_lads_cus_hdr.zzcuststat;
      rcd_bds_cust_header.retail_store_number := rcd_lads_cus_hdr.zzretstore;
      rcd_bds_cust_header.location_code := rcd_lads_cus_hdr.locco;
      rcd_bds_cust_header.demand_plan_group_code := rcd_lads_cus_hdr.zzdemplan;

      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_cust_header
         set sap_idoc_name = rcd_bds_cust_header.sap_idoc_name,
             sap_idoc_number = rcd_bds_cust_header.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_cust_header.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_cust_header.bds_lads_date,
             bds_lads_status = rcd_bds_cust_header.bds_lads_status,
             order_block_flag = rcd_bds_cust_header.order_block_flag,
             auth_group_code = rcd_bds_cust_header.auth_group_code,
             industry_code = rcd_bds_cust_header.industry_code,
             billing_block_flag = rcd_bds_cust_header.billing_block_flag,
             fiscal_address_account = rcd_bds_cust_header.fiscal_address_account,
             alternative_payer_account = rcd_bds_cust_header.alternative_payer_account,
             group_key = rcd_bds_cust_header.group_key,
             account_group_code = rcd_bds_cust_header.account_group_code,
             classification_code = rcd_bds_cust_header.classification_code,
             vendor_code = rcd_bds_cust_header.vendor_code,
             delivery_block_flag = rcd_bds_cust_header.delivery_block_flag,
             deletion_flag = rcd_bds_cust_header.deletion_flag,
             posting_block_flag = rcd_bds_cust_header.posting_block_flag,
             tax_number_01 = rcd_bds_cust_header.tax_number_01,
             tax_number_02 = rcd_bds_cust_header.tax_number_02,
             tax_equalization_flag = rcd_bds_cust_header.tax_equalization_flag,
             vat_flag = rcd_bds_cust_header.vat_flag,
             alternative_payee_flag = rcd_bds_cust_header.alternative_payee_flag,
             trading_partner_company_code = rcd_bds_cust_header.trading_partner_company_code,
             vat_registration_number = rcd_bds_cust_header.vat_registration_number,
             legal_status = rcd_bds_cust_header.legal_status,
             sales_year = rcd_bds_cust_header.sales_year,
             sales_currency_code = rcd_bds_cust_header.sales_currency_code,
             sales_point_type = rcd_bds_cust_header.sales_point_type,
             combine_invoice_list_code = rcd_bds_cust_header.combine_invoice_list_code,
             attribute_04 = rcd_bds_cust_header.attribute_04,
             attribute_05 = rcd_bds_cust_header.attribute_05,
             attribute_06 = rcd_bds_cust_header.attribute_06,
             attribute_07 = rcd_bds_cust_header.attribute_07,
             attribute_08 = rcd_bds_cust_header.attribute_08,
             attribute_09 = rcd_bds_cust_header.attribute_09,
             attribute_10 = rcd_bds_cust_header.attribute_10,
             natural_person = rcd_bds_cust_header.natural_person,
             char_field_umsa1 = rcd_bds_cust_header.char_field_umsa1,
             fiscal_year_variant = rcd_bds_cust_header.fiscal_year_variant,
             one_time_account_group = rcd_bds_cust_header.one_time_account_group,
             tax_type = rcd_bds_cust_header.tax_type,
             tax_number_type = rcd_bds_cust_header.tax_number_type,
             tax_number_03 = rcd_bds_cust_header.tax_number_03,
             tax_number_04 = rcd_bds_cust_header.tax_number_04,
             sales_block_flag = rcd_bds_cust_header.sales_block_flag,
             cndtn_grp_01 = rcd_bds_cust_header.cndtn_grp_01,
             cndtn_grp_02 = rcd_bds_cust_header.cndtn_grp_02,
             cndtn_grp_03 = rcd_bds_cust_header.cndtn_grp_03,
             cndtn_grp_04 = rcd_bds_cust_header.cndtn_grp_04,
             cndtn_grp_05 = rcd_bds_cust_header.cndtn_grp_05,
             deletion_block_flag = rcd_bds_cust_header.deletion_block_flag,
             stc_customer_group = rcd_bds_cust_header.stc_customer_group,
             plant_code = rcd_bds_cust_header.plant_code,
             char_field_zzcustom01 = rcd_bds_cust_header.char_field_zzcustom01,
             custom_attr_13 = rcd_bds_cust_header.custom_attr_13,
             custom_attr_14 = rcd_bds_cust_header.custom_attr_14,
             representative_name = rcd_bds_cust_header.representative_name,
             business_type = rcd_bds_cust_header.business_type,
             industry_type = rcd_bds_cust_header.industry_type,
             subledger_acct_procedure = rcd_bds_cust_header.subledger_acct_procedure,
             region_code = rcd_bds_cust_header.region_code,
             status_code = rcd_bds_cust_header.status_code,
             retail_store_number = rcd_bds_cust_header.retail_store_number,
             location_code = rcd_bds_cust_header.location_code,
             demand_plan_group_code = rcd_bds_cust_header.demand_plan_group_code
         where customer_code = rcd_bds_cust_header.customer_code;
      if sql%notfound then
         insert into bds_cust_header
            (customer_code,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             order_block_flag,
             auth_group_code,
             industry_code,
             billing_block_flag,
             fiscal_address_account,
             alternative_payer_account,
             group_key,
             account_group_code,
             classification_code,
             vendor_code,
             delivery_block_flag,
             deletion_flag,
             posting_block_flag,
             tax_number_01,
             tax_number_02,
             tax_equalization_flag,
             vat_flag,
             alternative_payee_flag,
             trading_partner_company_code,
             vat_registration_number,
             legal_status,
             sales_year,
             sales_currency_code,
             sales_point_type,
             combine_invoice_list_code,
             attribute_04,
             attribute_05,
             attribute_06,
             attribute_07,
             attribute_08,
             attribute_09,
             attribute_10,
             natural_person,
             char_field_umsa1,
             fiscal_year_variant,
             one_time_account_group,
             tax_type,
             tax_number_type,
             tax_number_03,
             tax_number_04,
             sales_block_flag,
             cndtn_grp_01,
             cndtn_grp_02,
             cndtn_grp_03,
             cndtn_grp_04,
             cndtn_grp_05,
             deletion_block_flag,
             stc_customer_group,
             plant_code,
             char_field_zzcustom01,
             custom_attr_13,
             custom_attr_14,
             representative_name,
             business_type,
             industry_type,
             subledger_acct_procedure,
             region_code,
             status_code,
             retail_store_number,
             location_code,
             demand_plan_group_code)
             values(rcd_bds_cust_header.customer_code,
                    rcd_bds_cust_header.sap_idoc_name,
                    rcd_bds_cust_header.sap_idoc_number,
                    rcd_bds_cust_header.sap_idoc_timestamp,
                    rcd_bds_cust_header.bds_lads_date,
                    rcd_bds_cust_header.bds_lads_status,
                    rcd_bds_cust_header.order_block_flag,
                    rcd_bds_cust_header.auth_group_code,
                    rcd_bds_cust_header.industry_code,
                    rcd_bds_cust_header.billing_block_flag,
                    rcd_bds_cust_header.fiscal_address_account,
                    rcd_bds_cust_header.alternative_payer_account,
                    rcd_bds_cust_header.group_key,
                    rcd_bds_cust_header.account_group_code,
                    rcd_bds_cust_header.classification_code,
                    rcd_bds_cust_header.vendor_code,
                    rcd_bds_cust_header.delivery_block_flag,
                    rcd_bds_cust_header.deletion_flag,
                    rcd_bds_cust_header.posting_block_flag,
                    rcd_bds_cust_header.tax_number_01,
                    rcd_bds_cust_header.tax_number_02,
                    rcd_bds_cust_header.tax_equalization_flag,
                    rcd_bds_cust_header.vat_flag,
                    rcd_bds_cust_header.alternative_payee_flag,
                    rcd_bds_cust_header.trading_partner_company_code,
                    rcd_bds_cust_header.vat_registration_number,
                    rcd_bds_cust_header.legal_status,
                    rcd_bds_cust_header.sales_year,
                    rcd_bds_cust_header.sales_currency_code,
                    rcd_bds_cust_header.sales_point_type,
                    rcd_bds_cust_header.combine_invoice_list_code,
                    rcd_bds_cust_header.attribute_04,
                    rcd_bds_cust_header.attribute_05,
                    rcd_bds_cust_header.attribute_06,
                    rcd_bds_cust_header.attribute_07,
                    rcd_bds_cust_header.attribute_08,
                    rcd_bds_cust_header.attribute_09,
                    rcd_bds_cust_header.attribute_10,
                    rcd_bds_cust_header.natural_person,
                    rcd_bds_cust_header.char_field_umsa1,
                    rcd_bds_cust_header.fiscal_year_variant,
                    rcd_bds_cust_header.one_time_account_group,
                    rcd_bds_cust_header.tax_type,
                    rcd_bds_cust_header.tax_number_type,
                    rcd_bds_cust_header.tax_number_03,
                    rcd_bds_cust_header.tax_number_04,
                    rcd_bds_cust_header.sales_block_flag,
                    rcd_bds_cust_header.cndtn_grp_01,
                    rcd_bds_cust_header.cndtn_grp_02,
                    rcd_bds_cust_header.cndtn_grp_03,
                    rcd_bds_cust_header.cndtn_grp_04,
                    rcd_bds_cust_header.cndtn_grp_05,
                    rcd_bds_cust_header.deletion_block_flag,
                    rcd_bds_cust_header.stc_customer_group,
                    rcd_bds_cust_header.plant_code,
                    rcd_bds_cust_header.char_field_zzcustom01,
                    rcd_bds_cust_header.custom_attr_13,
                    rcd_bds_cust_header.custom_attr_14,
                    rcd_bds_cust_header.representative_name,
                    rcd_bds_cust_header.business_type,
                    rcd_bds_cust_header.industry_type,
                    rcd_bds_cust_header.subledger_acct_procedure,
                    rcd_bds_cust_header.region_code,
                    rcd_bds_cust_header.status_code,
                    rcd_bds_cust_header.retail_store_number,
                    rcd_bds_cust_header.location_code,
                    rcd_bds_cust_header.demand_plan_group_code);
      end if;

      /*-*/
      /* Process the LADS customer text
      /*-*/
      open csr_lads_cus_hth;
      loop
         fetch csr_lads_cus_hth into rcd_lads_cus_hth;
         if csr_lads_cus_hth%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_text.customer_code := rcd_lads_cus_hth.kunnr;
         rcd_bds_cust_text.text_object := rcd_lads_cus_hth.tdobject;
         rcd_bds_cust_text.text_name := rcd_lads_cus_hth.tdname;
         rcd_bds_cust_text.text_id := rcd_lads_cus_hth.tdid;
         rcd_bds_cust_text.text_language := rcd_lads_cus_hth.tdspras;
         rcd_bds_cust_text.text_type := rcd_lads_cus_hth.tdtexttype;
         rcd_bds_cust_text.text_language_iso := rcd_lads_cus_hth.tdsprasiso;
         rcd_bds_cust_text.text_line := null;
         
         /*-*/
         /* Retrieve the LADS customer text line
         /*-*/
         open csr_lads_cus_htd;
         loop
            fetch csr_lads_cus_htd into rcd_lads_cus_htd;
            if csr_lads_cus_htd%notfound or
               (length(rcd_bds_cust_text.text_line) + length(rcd_lads_cus_htd.tdline)) > 2000 then
               exit;
            end if;
            rcd_bds_cust_text.text_line := rcd_bds_cust_text.text_line||' '||rcd_lads_cus_htd.tdline;
         end loop;
         close csr_lads_cus_htd;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_text
            (customer_code,
             text_object,
             text_name,
             text_id,
             text_language,
             text_type,
             text_language_iso,
             text_line)
             values(rcd_bds_cust_text.customer_code,
                    rcd_bds_cust_text.text_object,
                    rcd_bds_cust_text.text_name,
                    rcd_bds_cust_text.text_id,
                    rcd_bds_cust_text.text_language,
                    rcd_bds_cust_text.text_type,
                    rcd_bds_cust_text.text_language_iso,
                    rcd_bds_cust_text.text_line);

      end loop;
      close csr_lads_cus_hth;

      /*-*/
      /* Process the LADS customer contact
      /*-*/
      open csr_lads_cus_cnt;
      loop
         fetch csr_lads_cus_cnt into rcd_lads_cus_cnt;
         if csr_lads_cus_cnt%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_contact.customer_code := rcd_lads_cus_cnt.kunnr;
         rcd_bds_cust_contact.contact_number := rcd_lads_cus_cnt.parnr;
         rcd_bds_cust_contact.first_name := rcd_lads_cus_cnt.namev;
         rcd_bds_cust_contact.last_name := rcd_lads_cus_cnt.name1;
         rcd_bds_cust_contact.cust_department := rcd_lads_cus_cnt.abtpa;
         rcd_bds_cust_contact.department := rcd_lads_cus_cnt.abtnr;
         rcd_bds_cust_contact.higher_partner := rcd_lads_cus_cnt.uepar;
         rcd_bds_cust_contact.phone_number := rcd_lads_cus_cnt.telf1;
         rcd_bds_cust_contact.salutation := rcd_lads_cus_cnt.anred;
         rcd_bds_cust_contact.person_function := rcd_lads_cus_cnt.pafkt;
         rcd_bds_cust_contact.sort_field := rcd_lads_cus_cnt.sortl;
         rcd_bds_cust_contact.phone_extension := rcd_lads_cus_cnt.zz_tel_extens;
         rcd_bds_cust_contact.fax_number := rcd_lads_cus_cnt.zz_fax_number;
         rcd_bds_cust_contact.faz_extension := rcd_lads_cus_cnt.zz_fax_extens;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_contact
            (customer_code,
             contact_number,
             first_name,
             last_name,
             cust_department,
             department,
             higher_partner,
             phone_number,
             salutation,
             person_function,
             sort_field,
             phone_extension,
             fax_number,
             faz_extension)
             values(rcd_bds_cust_contact.customer_code,
                    rcd_bds_cust_contact.contact_number,
                    rcd_bds_cust_contact.first_name,
                    rcd_bds_cust_contact.last_name,
                    rcd_bds_cust_contact.cust_department,
                    rcd_bds_cust_contact.department,
                    rcd_bds_cust_contact.higher_partner,
                    rcd_bds_cust_contact.phone_number,
                    rcd_bds_cust_contact.salutation,
                    rcd_bds_cust_contact.person_function,
                    rcd_bds_cust_contact.sort_field,
                    rcd_bds_cust_contact.phone_extension,
                    rcd_bds_cust_contact.fax_number,
                    rcd_bds_cust_contact.faz_extension);

      end loop;
      close csr_lads_cus_cnt;

      /*-*/
      /* Process the LADS customer bank
      /*-*/
      open csr_lads_cus_bnk;
      loop
         fetch csr_lads_cus_bnk into rcd_lads_cus_bnk;
         if csr_lads_cus_bnk%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_bank.customer_code := rcd_lads_cus_bnk.kunnr;
         rcd_bds_cust_bank.bank_country_key := rcd_lads_cus_bnk.banks;
         rcd_bds_cust_bank.bank_number := rcd_lads_cus_bnk.bankl;
         rcd_bds_cust_bank.bank_account_number := rcd_lads_cus_bnk.bankn;
         rcd_bds_cust_bank.bank_control_key := rcd_lads_cus_bnk.bkont;
         rcd_bds_cust_bank.partner_bank_type := rcd_lads_cus_bnk.bvtyp;
         rcd_bds_cust_bank.collection_auth_flag := rcd_lads_cus_bnk.xezer;
         rcd_bds_cust_bank.bank_detail_reference := rcd_lads_cus_bnk.bkref;
         rcd_bds_cust_bank.bank_name := rcd_lads_cus_bnk.banka;
         rcd_bds_cust_bank.address_street := rcd_lads_cus_bnk.stras;
         rcd_bds_cust_bank.address_city := rcd_lads_cus_bnk.ort01;
         rcd_bds_cust_bank.swift_code := rcd_lads_cus_bnk.swift;
         rcd_bds_cust_bank.bank_group := rcd_lads_cus_bnk.bgrup;
         rcd_bds_cust_bank.po_current_account_flag := rcd_lads_cus_bnk.xpgro;
         rcd_bds_cust_bank.bank_number_bnklz := rcd_lads_cus_bnk.bnklz;
         rcd_bds_cust_bank.po_current_account_number := rcd_lads_cus_bnk.pskto;
         rcd_bds_cust_bank.bank_branch := rcd_lads_cus_bnk.brnch;
         rcd_bds_cust_bank.region := rcd_lads_cus_bnk.provz;
         rcd_bds_cust_bank.account_holder_name := rcd_lads_cus_bnk.koinh;
         rcd_bds_cust_bank.account_holder_name_long := rcd_lads_cus_bnk.koinh_n;
         rcd_bds_cust_bank.batch_input_date_kovon := rcd_lads_cus_bnk.kovon;
         rcd_bds_cust_bank.batch_input_date_kobis := rcd_lads_cus_bnk.kobis;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_bank
            (customer_code,
             bank_country_key,
             bank_number,
             bank_account_number,
             bank_control_key,
             partner_bank_type,
             collection_auth_flag,
             bank_detail_reference,
             bank_name,
             address_street,
             address_city,
             swift_code,
             bank_group,
             po_current_account_flag,
             bank_number_bnklz,
             po_current_account_number,
             bank_branch,
             region,
             account_holder_name,
             account_holder_name_long,
             batch_input_date_kovon,
             batch_input_date_kobis)
             values(rcd_bds_cust_bank.customer_code,
                    rcd_bds_cust_bank.bank_country_key,
                    rcd_bds_cust_bank.bank_number,
                    rcd_bds_cust_bank.bank_account_number,
                    rcd_bds_cust_bank.bank_control_key,
                    rcd_bds_cust_bank.partner_bank_type,
                    rcd_bds_cust_bank.collection_auth_flag,
                    rcd_bds_cust_bank.bank_detail_reference,
                    rcd_bds_cust_bank.bank_name,
                    rcd_bds_cust_bank.address_street,
                    rcd_bds_cust_bank.address_city,
                    rcd_bds_cust_bank.swift_code,
                    rcd_bds_cust_bank.bank_group,
                    rcd_bds_cust_bank.po_current_account_flag,
                    rcd_bds_cust_bank.bank_number_bnklz,
                    rcd_bds_cust_bank.po_current_account_number,
                    rcd_bds_cust_bank.bank_branch,
                    rcd_bds_cust_bank.region,
                    rcd_bds_cust_bank.account_holder_name,
                    rcd_bds_cust_bank.account_holder_name_long,
                    rcd_bds_cust_bank.batch_input_date_kovon,
                    rcd_bds_cust_bank.batch_input_date_kobis);

      end loop;
      close csr_lads_cus_bnk;

      /*-*/
      /* Process the LADS customer unloading point
      /*-*/
      open csr_lads_cus_unl;
      loop
         fetch csr_lads_cus_unl into rcd_lads_cus_unl;
         if csr_lads_cus_unl%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_unlpnt.customer_code := rcd_lads_cus_unl.kunnr;
         rcd_bds_cust_unlpnt.unloading_point := rcd_lads_cus_unl.ablad;
         rcd_bds_cust_unlpnt.factory_calendar := rcd_lads_cus_unl.knfak;
         rcd_bds_cust_unlpnt.goods_receiving_code := rcd_lads_cus_unl.wanid;
         rcd_bds_cust_unlpnt.default_unloading_point_flag := rcd_lads_cus_unl.defab;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_unlpnt
            (customer_code,
             unloading_point,
             factory_calendar,
             goods_receiving_code,
             default_unloading_point_flag)
             values(rcd_bds_cust_unlpnt.customer_code,
                    rcd_bds_cust_unlpnt.unloading_point,
                    rcd_bds_cust_unlpnt.factory_calendar,
                    rcd_bds_cust_unlpnt.goods_receiving_code,
                    rcd_bds_cust_unlpnt.default_unloading_point_flag);

      end loop;
      close csr_lads_cus_unl;

      /*-*/
      /* Process the LADS customer value added tax
      /*-*/
      open csr_lads_cus_vat;
      loop
         fetch csr_lads_cus_vat into rcd_lads_cus_vat;
         if csr_lads_cus_vat%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_vat.customer_code := rcd_lads_cus_vat.kunnr;
         rcd_bds_cust_vat.country_code := rcd_lads_cus_vat.land1;
         rcd_bds_cust_vat.vat_registration_number := rcd_lads_cus_vat.stceg;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_vat
            (customer_code,
             country_code,
             vat_registration_number)
             values(rcd_bds_cust_vat.customer_code,
                    rcd_bds_cust_vat.country_code,
                    rcd_bds_cust_vat.vat_registration_number);

      end loop;
      close csr_lads_cus_vat;

      /*-*/
      /* Process the LADS customer sales area
      /*-*/
      open csr_lads_cus_sad;
      loop
         fetch csr_lads_cus_sad into rcd_lads_cus_sad;
         if csr_lads_cus_sad%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_sales_area.customer_code := rcd_lads_cus_sad.kunnr;
         rcd_bds_cust_sales_area.sales_org_code := rcd_lads_cus_sad.vkorg;
         rcd_bds_cust_sales_area.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
         rcd_bds_cust_sales_area.division_code := rcd_lads_cus_sad.spart;
         rcd_bds_cust_sales_area.auth_group_code := rcd_lads_cus_sad.begru;
         rcd_bds_cust_sales_area.deletion_flag := rcd_lads_cus_sad.loevm;
         rcd_bds_cust_sales_area.statistics_group := rcd_lads_cus_sad.versg;
         rcd_bds_cust_sales_area.order_block_flag := rcd_lads_cus_sad.aufsd;
         rcd_bds_cust_sales_area.pricing_procedure := rcd_lads_cus_sad.kalks;
         rcd_bds_cust_sales_area.group_code := rcd_lads_cus_sad.kdgrp;
         rcd_bds_cust_sales_area.sales_district := rcd_lads_cus_sad.bzirk;
         rcd_bds_cust_sales_area.price_group := rcd_lads_cus_sad.konda;
         rcd_bds_cust_sales_area.price_list_type := rcd_lads_cus_sad.pltyp;
         rcd_bds_cust_sales_area.order_probability := rcd_lads_cus_sad.awahr;
         rcd_bds_cust_sales_area.inter_company_terms_01 := rcd_lads_cus_sad.inco1;
         rcd_bds_cust_sales_area.inter_company_terms_02 := rcd_lads_cus_sad.inco2;
         rcd_bds_cust_sales_area.delivery_block_flag := rcd_lads_cus_sad.lifsd;
         rcd_bds_cust_sales_area.order_complete_delivery_flag := rcd_lads_cus_sad.autlf;
         rcd_bds_cust_sales_area.partial_item_delivery_max := rcd_lads_cus_sad.antlf;
         rcd_bds_cust_sales_area.partial_item_delivery_flag := rcd_lads_cus_sad.kztlf;
         rcd_bds_cust_sales_area.order_combination_flag := rcd_lads_cus_sad.kzazu;
         rcd_bds_cust_sales_area.split_batch_flag := rcd_lads_cus_sad.chspl;
         rcd_bds_cust_sales_area.delivery_priority := rcd_lads_cus_sad.lprio;
         rcd_bds_cust_sales_area.shipper_account_number := rcd_lads_cus_sad.eikto;
         rcd_bds_cust_sales_area.ship_conditions := rcd_lads_cus_sad.vsbed;
         rcd_bds_cust_sales_area.billing_block_flag := rcd_lads_cus_sad.faksd;
         rcd_bds_cust_sales_area.manual_invoice_flag := rcd_lads_cus_sad.mrnkz;
         rcd_bds_cust_sales_area.invoice_dates := rcd_lads_cus_sad.perfk;
         rcd_bds_cust_sales_area.invoice_list_schedule := rcd_lads_cus_sad.perrl;
         rcd_bds_cust_sales_area.currency_code := rcd_lads_cus_sad.waers;
         rcd_bds_cust_sales_area.account_assign_group := rcd_lads_cus_sad.ktgrd;
         rcd_bds_cust_sales_area.payment_terms_key := rcd_lads_cus_sad.zterm;
         rcd_bds_cust_sales_area.delivery_plant_code := rcd_lads_cus_sad.vwerk;
         rcd_bds_cust_sales_area.sales_group_code := rcd_lads_cus_sad.vkgrp;
         rcd_bds_cust_sales_area.sales_office_code := rcd_lads_cus_sad.vkbur;
         rcd_bds_cust_sales_area.item_proposal := rcd_lads_cus_sad.vsort;
         rcd_bds_cust_sales_area.invoice_combination := rcd_lads_cus_sad.kvgr1;
         rcd_bds_cust_sales_area.price_band_expected := rcd_lads_cus_sad.kvgr2;
         rcd_bds_cust_sales_area.accept_int_pallet := rcd_lads_cus_sad.kvgr3;
         rcd_bds_cust_sales_area.price_band_guaranteed := rcd_lads_cus_sad.kvgr4;
         rcd_bds_cust_sales_area.back_order_flag := rcd_lads_cus_sad.kvgr5;
         rcd_bds_cust_sales_area.rebate_flag := rcd_lads_cus_sad.bokre;
         rcd_bds_cust_sales_area.exchange_rate_type := rcd_lads_cus_sad.kurst;
         rcd_bds_cust_sales_area.price_determination_id := rcd_lads_cus_sad.prfre;
         rcd_bds_cust_sales_area.abc_classification := rcd_lads_cus_sad.klabc;
         rcd_bds_cust_sales_area.payment_guarantee_proc := rcd_lads_cus_sad.kabss;
         rcd_bds_cust_sales_area.credit_control_area := rcd_lads_cus_sad.kkber;
         rcd_bds_cust_sales_area.sales_block_flag := rcd_lads_cus_sad.cassd;
         rcd_bds_cust_sales_area.rounding_off := rcd_lads_cus_sad.rdoff;
         rcd_bds_cust_sales_area.agency_business_flag := rcd_lads_cus_sad.agrel;
         rcd_bds_cust_sales_area.uom_group := rcd_lads_cus_sad.megru;
         rcd_bds_cust_sales_area.over_delivery_tolerance := rcd_lads_cus_sad.uebto;
         rcd_bds_cust_sales_area.under_delivery_tolerance := rcd_lads_cus_sad.untto;
         rcd_bds_cust_sales_area.unlimited_over_delivery := rcd_lads_cus_sad.uebtk;
         rcd_bds_cust_sales_area.product_proposal_proc := rcd_lads_cus_sad.pvksm;
         rcd_bds_cust_sales_area.pod_processing := rcd_lads_cus_sad.podkz;
         rcd_bds_cust_sales_area.pod_confirm_timeframe := rcd_lads_cus_sad.podtg;
         rcd_bds_cust_sales_area.po_index_compilation := rcd_lads_cus_sad.blind;
         rcd_bds_cust_sales_area.batch_search_strategy := rcd_lads_cus_sad.zzshelfgrp;
         rcd_bds_cust_sales_area.vmi_input_method := rcd_lads_cus_sad.zzvmicdim;
         rcd_bds_cust_sales_area.current_planning_flag := rcd_lads_cus_sad.zzcurrentflag;
         rcd_bds_cust_sales_area.future_planning_flag := rcd_lads_cus_sad.zzfutureflag;
         rcd_bds_cust_sales_area.market_account_flag := rcd_lads_cus_sad.zzmarketacctflag;
         rcd_bds_cust_sales_area.cust_pack_instr_validation := rcd_lads_cus_sad.zzcspiv;
         rcd_bds_cust_sales_area.cust_pallet_max_height := rcd_lads_cus_sad.zzcmph;
         rcd_bds_cust_sales_area.cust_pallet_max_height_uom := rcd_lads_cus_sad.zzcmph_uom;
         rcd_bds_cust_sales_area.layer_homogeneous_pick_pallet := rcd_lads_cus_sad.zzhppl;
         rcd_bds_cust_sales_area.case_homogeneous_pick_pallet := rcd_lads_cus_sad.zzhppc;
         rcd_bds_cust_sales_area.transport_modules_flag := rcd_lads_cus_sad.zztmr;
         rcd_bds_cust_sales_area.pick_pallet_pack_material := rcd_lads_cus_sad.zzpppm;
         rcd_bds_cust_sales_area.pick_pallet_max_height := rcd_lads_cus_sad.zzmpph;
         rcd_bds_cust_sales_area.pick_pallet_max_height_uom := rcd_lads_cus_sad.zzmpph_uom;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_sales_area
            (customer_code,
             sales_org_code,
             distbn_chnl_code,
             division_code,
             auth_group_code,
             deletion_flag,
             statistics_group,
             order_block_flag,
             pricing_procedure,
             group_code,
             sales_district,
             price_group,
             price_list_type,
             order_probability,
             inter_company_terms_01,
             inter_company_terms_02,
             delivery_block_flag,
             order_complete_delivery_flag,
             partial_item_delivery_max,
             partial_item_delivery_flag,
             order_combination_flag,
             split_batch_flag,
             delivery_priority,
             shipper_account_number,
             ship_conditions,
             billing_block_flag,
             manual_invoice_flag,
             invoice_dates,
             invoice_list_schedule,
             currency_code,
             account_assign_group,
             payment_terms_key,
             delivery_plant_code,
             sales_group_code,
             sales_office_code,
             item_proposal,
             invoice_combination,
             price_band_expected,
             accept_int_pallet,
             price_band_guaranteed,
             back_order_flag,
             rebate_flag,
             exchange_rate_type,
             price_determination_id,
             abc_classification,
             payment_guarantee_proc,
             credit_control_area,
             sales_block_flag,
             rounding_off,
             agency_business_flag,
             uom_group,
             over_delivery_tolerance,
             under_delivery_tolerance,
             unlimited_over_delivery,
             product_proposal_proc,
             pod_processing,
             pod_confirm_timeframe,
             po_index_compilation,
             batch_search_strategy,
             vmi_input_method,
             current_planning_flag,
             future_planning_flag,
             market_account_flag,
             cust_pack_instr_validation,
             cust_pallet_max_height,
             cust_pallet_max_height_uom,
             layer_homogeneous_pick_pallet,
             case_homogeneous_pick_pallet,
             transport_modules_flag,
             pick_pallet_pack_material,
             pick_pallet_max_height,
             pick_pallet_max_height_uom)
             values(rcd_bds_cust_sales_area.customer_code,
                    rcd_bds_cust_sales_area.sales_org_code,
                    rcd_bds_cust_sales_area.distbn_chnl_code,
                    rcd_bds_cust_sales_area.division_code,
                    rcd_bds_cust_sales_area.auth_group_code,
                    rcd_bds_cust_sales_area.deletion_flag,
                    rcd_bds_cust_sales_area.statistics_group,
                    rcd_bds_cust_sales_area.order_block_flag,
                    rcd_bds_cust_sales_area.pricing_procedure,
                    rcd_bds_cust_sales_area.group_code,
                    rcd_bds_cust_sales_area.sales_district,
                    rcd_bds_cust_sales_area.price_group,
                    rcd_bds_cust_sales_area.price_list_type,
                    rcd_bds_cust_sales_area.order_probability,
                    rcd_bds_cust_sales_area.inter_company_terms_01,
                    rcd_bds_cust_sales_area.inter_company_terms_02,
                    rcd_bds_cust_sales_area.delivery_block_flag,
                    rcd_bds_cust_sales_area.order_complete_delivery_flag,
                    rcd_bds_cust_sales_area.partial_item_delivery_max,
                    rcd_bds_cust_sales_area.partial_item_delivery_flag,
                    rcd_bds_cust_sales_area.order_combination_flag,
                    rcd_bds_cust_sales_area.split_batch_flag,
                    rcd_bds_cust_sales_area.delivery_priority,
                    rcd_bds_cust_sales_area.shipper_account_number,
                    rcd_bds_cust_sales_area.ship_conditions,
                    rcd_bds_cust_sales_area.billing_block_flag,
                    rcd_bds_cust_sales_area.manual_invoice_flag,
                    rcd_bds_cust_sales_area.invoice_dates,
                    rcd_bds_cust_sales_area.invoice_list_schedule,
                    rcd_bds_cust_sales_area.currency_code,
                    rcd_bds_cust_sales_area.account_assign_group,
                    rcd_bds_cust_sales_area.payment_terms_key,
                    rcd_bds_cust_sales_area.delivery_plant_code,
                    rcd_bds_cust_sales_area.sales_group_code,
                    rcd_bds_cust_sales_area.sales_office_code,
                    rcd_bds_cust_sales_area.item_proposal,
                    rcd_bds_cust_sales_area.invoice_combination,
                    rcd_bds_cust_sales_area.price_band_expected,
                    rcd_bds_cust_sales_area.accept_int_pallet,
                    rcd_bds_cust_sales_area.price_band_guaranteed,
                    rcd_bds_cust_sales_area.back_order_flag,
                    rcd_bds_cust_sales_area.rebate_flag,
                    rcd_bds_cust_sales_area.exchange_rate_type,
                    rcd_bds_cust_sales_area.price_determination_id,
                    rcd_bds_cust_sales_area.abc_classification,
                    rcd_bds_cust_sales_area.payment_guarantee_proc,
                    rcd_bds_cust_sales_area.credit_control_area,
                    rcd_bds_cust_sales_area.sales_block_flag,
                    rcd_bds_cust_sales_area.rounding_off,
                    rcd_bds_cust_sales_area.agency_business_flag,
                    rcd_bds_cust_sales_area.uom_group,
                    rcd_bds_cust_sales_area.over_delivery_tolerance,
                    rcd_bds_cust_sales_area.under_delivery_tolerance,
                    rcd_bds_cust_sales_area.unlimited_over_delivery,
                    rcd_bds_cust_sales_area.product_proposal_proc,
                    rcd_bds_cust_sales_area.pod_processing,
                    rcd_bds_cust_sales_area.pod_confirm_timeframe,
                    rcd_bds_cust_sales_area.po_index_compilation,
                    rcd_bds_cust_sales_area.batch_search_strategy,
                    rcd_bds_cust_sales_area.vmi_input_method,
                    rcd_bds_cust_sales_area.current_planning_flag,
                    rcd_bds_cust_sales_area.future_planning_flag,
                    rcd_bds_cust_sales_area.market_account_flag,
                    rcd_bds_cust_sales_area.cust_pack_instr_validation,
                    rcd_bds_cust_sales_area.cust_pallet_max_height,
                    rcd_bds_cust_sales_area.cust_pallet_max_height_uom,
                    rcd_bds_cust_sales_area.layer_homogeneous_pick_pallet,
                    rcd_bds_cust_sales_area.case_homogeneous_pick_pallet,
                    rcd_bds_cust_sales_area.transport_modules_flag,
                    rcd_bds_cust_sales_area.pick_pallet_pack_material,
                    rcd_bds_cust_sales_area.pick_pallet_max_height,
                    rcd_bds_cust_sales_area.pick_pallet_max_height_uom);

         /*-*/
         /* Process the LADS customer sales area vmi type
         /*-*/
         open csr_lads_cus_zsd;
         loop
            fetch csr_lads_cus_zsd into rcd_lads_cus_zsd;
            if csr_lads_cus_zsd%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_vmityp.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_vmityp.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_vmityp.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_vmityp.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_vmityp.vmi_customer_type := rcd_lads_cus_zsd.vmict;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_vmityp
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                vmi_customer_type)
                values(rcd_bds_cust_sales_area_vmityp.customer_code,
                       rcd_bds_cust_sales_area_vmityp.sales_org_code,
                       rcd_bds_cust_sales_area_vmityp.distbn_chnl_code,
                       rcd_bds_cust_sales_area_vmityp.division_code,
                       rcd_bds_cust_sales_area_vmityp.vmi_customer_type);

         end loop;
         close csr_lads_cus_zsd;

         /*-*/
         /* Process the LADS customer sales area vmi forecast
         /*-*/
         open csr_lads_cus_zsv;
         loop
            fetch csr_lads_cus_zsv into rcd_lads_cus_zsv;
            if csr_lads_cus_zsv%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_vmifct.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_vmifct.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_vmifct.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_vmifct.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_vmifct.vmi_fcst_data_source := rcd_lads_cus_zsv.vmifds;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_vmifct
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                vmi_fcst_data_source)
                values(rcd_bds_cust_sales_area_vmifct.customer_code,
                       rcd_bds_cust_sales_area_vmifct.sales_org_code,
                       rcd_bds_cust_sales_area_vmifct.distbn_chnl_code,
                       rcd_bds_cust_sales_area_vmifct.division_code,
                       rcd_bds_cust_sales_area_vmifct.vmi_fcst_data_source);

         end loop;
         close csr_lads_cus_zsv;

         /*-*/
         /* Process the LADS customer sales area partner function
         /*-*/
         open csr_lads_cus_pfr;
         loop
            fetch csr_lads_cus_pfr into rcd_lads_cus_pfr;
            if csr_lads_cus_pfr%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_pnrfun.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_pnrfun.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_pnrfun.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_pnrfun.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_pnrfun.partner_funcn_code := rcd_lads_cus_pfr.parvw;
            rcd_bds_cust_sales_area_pnrfun.partner_cust_code := rcd_lads_cus_pfr.kunn2;
            rcd_bds_cust_sales_area_pnrfun.default_partner_flag := rcd_lads_cus_pfr.defpa;
            rcd_bds_cust_sales_area_pnrfun.partner_description := rcd_lads_cus_pfr.knref;
            rcd_bds_cust_sales_area_pnrfun.partner_counter := rcd_lads_cus_pfr.parza;
            rcd_bds_cust_sales_area_pnrfun.partner_text := rcd_lads_cus_pfr.zz_parvw_txt;
            rcd_bds_cust_sales_area_pnrfun.partner_name := rcd_lads_cus_pfr.zz_partn_nam;
            rcd_bds_cust_sales_area_pnrfun.partner_last_name := rcd_lads_cus_pfr.zz_partn_nachn;
            rcd_bds_cust_sales_area_pnrfun.partner_first_name := rcd_lads_cus_pfr.zz_partn_vorna;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_pnrfun
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                partner_funcn_code,
                partner_cust_code,
                default_partner_flag,
                partner_description,
                partner_counter,
                partner_text,
                partner_name,
                partner_last_name,
                partner_first_name)
                values(rcd_bds_cust_sales_area_pnrfun.customer_code,
                       rcd_bds_cust_sales_area_pnrfun.sales_org_code,
                       rcd_bds_cust_sales_area_pnrfun.distbn_chnl_code,
                       rcd_bds_cust_sales_area_pnrfun.division_code,
                       rcd_bds_cust_sales_area_pnrfun.partner_funcn_code,
                       rcd_bds_cust_sales_area_pnrfun.partner_cust_code,
                       rcd_bds_cust_sales_area_pnrfun.default_partner_flag,
                       rcd_bds_cust_sales_area_pnrfun.partner_description,
                       rcd_bds_cust_sales_area_pnrfun.partner_counter,
                       rcd_bds_cust_sales_area_pnrfun.partner_text,
                       rcd_bds_cust_sales_area_pnrfun.partner_name,
                       rcd_bds_cust_sales_area_pnrfun.partner_last_name,
                       rcd_bds_cust_sales_area_pnrfun.partner_first_name);

         end loop;
         close csr_lads_cus_pfr;

         /*-*/
         /* Process the LADS customer sales area tax indicator
         /*-*/
         open csr_lads_cus_stx;
         loop
            fetch csr_lads_cus_stx into rcd_lads_cus_stx;
            if csr_lads_cus_stx%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_taxind.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_taxind.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_taxind.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_taxind.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_taxind.departure_country := rcd_lads_cus_stx.aland;
            rcd_bds_cust_sales_area_taxind.tax_category_code := rcd_lads_cus_stx.tatyp;
            rcd_bds_cust_sales_area_taxind.tax_classification_code := rcd_lads_cus_stx.taxkd;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_taxind
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                departure_country,
                tax_category_code,
                tax_classification_code)
                values(rcd_bds_cust_sales_area_taxind.customer_code,
                       rcd_bds_cust_sales_area_taxind.sales_org_code,
                       rcd_bds_cust_sales_area_taxind.distbn_chnl_code,
                       rcd_bds_cust_sales_area_taxind.division_code,
                       rcd_bds_cust_sales_area_taxind.departure_country,
                       rcd_bds_cust_sales_area_taxind.tax_category_code,
                       rcd_bds_cust_sales_area_taxind.tax_classification_code);

         end loop;
         close csr_lads_cus_stx;

         /*-*/
         /* Process the LADS customer sales area license
         /*-*/
         open csr_lads_cus_lid;
         loop
            fetch csr_lads_cus_lid into rcd_lads_cus_lid;
            if csr_lads_cus_lid%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_licse.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_licse.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_licse.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_licse.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_licse.departure_country := rcd_lads_cus_lid.aland;
            rcd_bds_cust_sales_area_licse.tax_category_code := rcd_lads_cus_lid.tatyp;
            rcd_bds_cust_sales_area_licse.valid_from_date := rcd_lads_cus_lid.datab;
            rcd_bds_cust_sales_area_licse.valid_to_date := rcd_lads_cus_lid.datbi;
            rcd_bds_cust_sales_area_licse.license_number := rcd_lads_cus_lid.licnr;
            rcd_bds_cust_sales_area_licse.license_confirm_flag := rcd_lads_cus_lid.belic;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_licse
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                departure_country,
                tax_category_code,
                valid_from_date,
                valid_to_date,
                license_number,
                license_confirm_flag)
                values(rcd_bds_cust_sales_area_licse.customer_code,
                       rcd_bds_cust_sales_area_licse.sales_org_code,
                       rcd_bds_cust_sales_area_licse.distbn_chnl_code,
                       rcd_bds_cust_sales_area_licse.division_code,
                       rcd_bds_cust_sales_area_licse.departure_country,
                       rcd_bds_cust_sales_area_licse.tax_category_code,
                       rcd_bds_cust_sales_area_licse.valid_from_date,
                       rcd_bds_cust_sales_area_licse.valid_to_date,
                       rcd_bds_cust_sales_area_licse.license_number,
                       rcd_bds_cust_sales_area_licse.license_confirm_flag);

         end loop;
         close csr_lads_cus_lid;

         /*-*/
         /* Process the LADS customer sales area text
         /*-*/
         open csr_lads_cus_sat;
         loop
            fetch csr_lads_cus_sat into rcd_lads_cus_sat;
            if csr_lads_cus_sat%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_sales_area_text.customer_code := rcd_lads_cus_sad.kunnr;
            rcd_bds_cust_sales_area_text.sales_org_code := rcd_lads_cus_sad.vkorg;
            rcd_bds_cust_sales_area_text.distbn_chnl_code := rcd_lads_cus_sad.vtweg;
            rcd_bds_cust_sales_area_text.division_code := rcd_lads_cus_sad.spart;
            rcd_bds_cust_sales_area_text.text_object := rcd_lads_cus_sat.tdobject;
            rcd_bds_cust_sales_area_text.text_name := rcd_lads_cus_sat.tdname;
            rcd_bds_cust_sales_area_text.text_id := rcd_lads_cus_sat.tdid;
            rcd_bds_cust_sales_area_text.text_language := rcd_lads_cus_sat.tdspras;
            rcd_bds_cust_sales_area_text.text_type := rcd_lads_cus_sat.tdtexttype;
            rcd_bds_cust_sales_area_text.text_language_iso := rcd_lads_cus_sat.tdsprasiso;
            rcd_bds_cust_sales_area_text.text_line := null;
         
            /*-*/
            /* Retrieve the LADS customer sales area text line
            /*-*/
            open csr_lads_cus_std;
            loop
               fetch csr_lads_cus_std into rcd_lads_cus_std;
               if csr_lads_cus_std%notfound or
                  (length(rcd_bds_cust_sales_area_text.text_line) + length(rcd_lads_cus_std.tdline)) > 2000 then
                  exit;
               end if;
               rcd_bds_cust_sales_area_text.text_line := rcd_bds_cust_sales_area_text.text_line||' '||rcd_lads_cus_std.tdline;
            end loop;
            close csr_lads_cus_std;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_sales_area_text
               (customer_code,
                sales_org_code,
                distbn_chnl_code,
                division_code,
                text_object,
                text_name,
                text_id,
                text_language,
                text_type,
                text_language_iso,
                text_line)
                values(rcd_bds_cust_sales_area_text.customer_code,
                       rcd_bds_cust_sales_area_text.sales_org_code,
                       rcd_bds_cust_sales_area_text.distbn_chnl_code,
                       rcd_bds_cust_sales_area_text.division_code,
                       rcd_bds_cust_sales_area_text.text_object,
                       rcd_bds_cust_sales_area_text.text_name,
                       rcd_bds_cust_sales_area_text.text_id,
                       rcd_bds_cust_sales_area_text.text_language,
                       rcd_bds_cust_sales_area_text.text_type,
                       rcd_bds_cust_sales_area_text.text_language_iso,
                       rcd_bds_cust_sales_area_text.text_line);

            end loop;
            close csr_lads_cus_sat;

      end loop;
      close csr_lads_cus_sad;

      /*-*/
      /* Process the LADS customer company
      /*-*/
      open csr_lads_cus_cud;
      loop
         fetch csr_lads_cus_cud into rcd_lads_cus_cud;
         if csr_lads_cus_cud%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_comp.customer_code := rcd_lads_cus_cud.kunnr;
         rcd_bds_cust_comp.company_code := rcd_lads_cus_cud.bukrs;
         rcd_bds_cust_comp.posting_block_flag := rcd_lads_cus_cud.sperr;
         rcd_bds_cust_comp.deletion_flag := rcd_lads_cus_cud.loevm;
         rcd_bds_cust_comp.assignment_sort_key := rcd_lads_cus_cud.zuawa;
         rcd_bds_cust_comp.account_clerk_code := rcd_lads_cus_cud.busab;
         rcd_bds_cust_comp.reconciliation_account := rcd_lads_cus_cud.akont;
         rcd_bds_cust_comp.auth_group_code := rcd_lads_cus_cud.begru;
         rcd_bds_cust_comp.head_office_account_number := rcd_lads_cus_cud.knrze;
         rcd_bds_cust_comp.alt_payer_account_number := rcd_lads_cus_cud.knrzb;
         rcd_bds_cust_comp.cust_payment_notice_ci_flag := rcd_lads_cus_cud.zamim;
         rcd_bds_cust_comp.sales_payment_notice_flag := rcd_lads_cus_cud.zamiv;
         rcd_bds_cust_comp.legal_payment_notice_flag := rcd_lads_cus_cud.zamir;
         rcd_bds_cust_comp.account_payment_notice_flag := rcd_lads_cus_cud.zamib;
         rcd_bds_cust_comp.cust_payment_notice_woci_flag := rcd_lads_cus_cud.zamio;
         rcd_bds_cust_comp.payment_method_code := rcd_lads_cus_cud.zwels;
         rcd_bds_cust_comp.cust_vend_clearing_flag := rcd_lads_cus_cud.xverr;
         rcd_bds_cust_comp.payment_block_flag := rcd_lads_cus_cud.zahls;
         rcd_bds_cust_comp.payment_terms_code := rcd_lads_cus_cud.zterm;
         rcd_bds_cust_comp.payment_terms_boec_flag := rcd_lads_cus_cud.wakon;
         rcd_bds_cust_comp.interest_calc_code := rcd_lads_cus_cud.vzskz;
         rcd_bds_cust_comp.interest_calc_last_date := rcd_lads_cus_cud.zindt;
         rcd_bds_cust_comp.interest_calc_freq := rcd_lads_cus_cud.zinrt;
         rcd_bds_cust_comp.cust_mars_account := rcd_lads_cus_cud.eikto;
         rcd_bds_cust_comp.cust_user := rcd_lads_cus_cud.zsabe;
         rcd_bds_cust_comp.cust_memo := rcd_lads_cus_cud.kverm;
         rcd_bds_cust_comp.planning_group_code := rcd_lads_cus_cud.fdgrv;
         rcd_bds_cust_comp.export_cred_insur_inst_nbr := rcd_lads_cus_cud.vrbkz;
         rcd_bds_cust_comp.insured_amount := rcd_lads_cus_cud.vlibb;
         rcd_bds_cust_comp.insurance_laed_months := rcd_lads_cus_cud.vrszl;
         rcd_bds_cust_comp.deductable_percent_rate := rcd_lads_cus_cud.vrspr;
         rcd_bds_cust_comp.insurance_number := rcd_lads_cus_cud.vrsnr;
         rcd_bds_cust_comp.insurance_valid_date := rcd_lads_cus_cud.verdt;
         rcd_bds_cust_comp.collective_inv_variant := rcd_lads_cus_cud.perkz;
         rcd_bds_cust_comp.local_processing_flag := rcd_lads_cus_cud.xdezv;
         rcd_bds_cust_comp.periodic_statements_flag := rcd_lads_cus_cud.xausz;
         rcd_bds_cust_comp.bill_of_exch_limit := rcd_lads_cus_cud.webtr;
         rcd_bds_cust_comp.next_payee := rcd_lads_cus_cud.remit;
         rcd_bds_cust_comp.interest_calc_run_date := rcd_lads_cus_cud.datlz;
         rcd_bds_cust_comp.record_pay_history_flag := rcd_lads_cus_cud.xzver;
         rcd_bds_cust_comp.tolerance_group_code := rcd_lads_cus_cud.togru;
         rcd_bds_cust_comp.probable_payment_time := rcd_lads_cus_cud.kultg;
         rcd_bds_cust_comp.house_bank_key := rcd_lads_cus_cud.hbkid;
         rcd_bds_cust_comp.pay_items_separately := rcd_lads_cus_cud.xpore;
         rcd_bds_cust_comp.reduction_rate_subsidy := rcd_lads_cus_cud.blnkz;
         rcd_bds_cust_comp.prev_master_record := rcd_lads_cus_cud.altkn;
         rcd_bds_cust_comp.payment_grouping_code := rcd_lads_cus_cud.zgrup;
         rcd_bds_cust_comp.known_leave_key := rcd_lads_cus_cud.urlid;
         rcd_bds_cust_comp.dunning_notice_group_code := rcd_lads_cus_cud.mgrup;
         rcd_bds_cust_comp.payment_lockbox := rcd_lads_cus_cud.lockb;
         rcd_bds_cust_comp.payment_method_supplement := rcd_lads_cus_cud.uzawe;
         rcd_bds_cust_comp.buying_group_account_number := rcd_lads_cus_cud.ekvbd;
         rcd_bds_cust_comp.payment_advice_select_rule := rcd_lads_cus_cud.sregl;
         rcd_bds_cust_comp.edi_payments_flag := rcd_lads_cus_cud.xedip;
         rcd_bds_cust_comp.release_approval_group_code := rcd_lads_cus_cud.frgrp;
         rcd_bds_cust_comp.convert_version_reason_code := rcd_lads_cus_cud.vrsdg;
         rcd_bds_cust_comp.cust_vend_fax := rcd_lads_cus_cud.tlfxs;
         rcd_bds_cust_comp.cust_vend_phone := rcd_lads_cus_cud.pernr;
         rcd_bds_cust_comp.cust_vend_email := rcd_lads_cus_cud.intad;
         rcd_bds_cust_comp.credit_memo_payment_terms := rcd_lads_cus_cud.guzte;
         rcd_bds_cust_comp.gross_income_tax_activity := rcd_lads_cus_cud.gricd;
         rcd_bds_cust_comp.employ_tax_distbn_type := rcd_lads_cus_cud.gridt;
         rcd_bds_cust_comp.value_adjust_key := rcd_lads_cus_cud.wbrsl;
         rcd_bds_cust_comp.deletion_block_flag := rcd_lads_cus_cud.nodel;
         rcd_bds_cust_comp.partner_phone := rcd_lads_cus_cud.tlfns;
         rcd_bds_cust_comp.receivable_pledging_flag := rcd_lads_cus_cud.cession_kz;
         rcd_bds_cust_comp.debt_enforecement_flag := rcd_lads_cus_cud.gmvkzd;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_comp
            (customer_code,
             company_code,
             posting_block_flag,
             deletion_flag,
             assignment_sort_key,
             account_clerk_code,
             reconciliation_account,
             auth_group_code,
             head_office_account_number,
             alt_payer_account_number,
             cust_payment_notice_ci_flag,
             sales_payment_notice_flag,
             legal_payment_notice_flag,
             account_payment_notice_flag,
             cust_payment_notice_woci_flag,
             payment_method_code,
             cust_vend_clearing_flag,
             payment_block_flag,
             payment_terms_code,
             payment_terms_boec_flag,
             interest_calc_code,
             interest_calc_last_date,
             interest_calc_freq,
             cust_mars_account,
             cust_user,
             cust_memo,
             planning_group_code,
             export_cred_insur_inst_nbr,
             insured_amount,
             insurance_laed_months,
             deductable_percent_rate,
             insurance_number,
             insurance_valid_date,
             collective_inv_variant,
             local_processing_flag,
             periodic_statements_flag,
             bill_of_exch_limit,
             next_payee,
             interest_calc_run_date,
             record_pay_history_flag,
             tolerance_group_code,
             probable_payment_time,
             house_bank_key,
             pay_items_separately,
             reduction_rate_subsidy,
             prev_master_record,
             payment_grouping_code,
             known_leave_key,
             dunning_notice_group_code,
             payment_lockbox,
             payment_method_supplement,
             buying_group_account_number,
             payment_advice_select_rule,
             edi_payments_flag,
             release_approval_group_code,
             convert_version_reason_code,
             cust_vend_fax,
             cust_vend_phone,
             cust_vend_email,
             credit_memo_payment_terms,
             gross_income_tax_activity,
             employ_tax_distbn_type,
             value_adjust_key,
             deletion_block_flag,
             partner_phone,
             receivable_pledging_flag,
             debt_enforecement_flag)
             values(rcd_bds_cust_comp.customer_code,
                    rcd_bds_cust_comp.company_code,
                    rcd_bds_cust_comp.posting_block_flag,
                    rcd_bds_cust_comp.deletion_flag,
                    rcd_bds_cust_comp.assignment_sort_key,
                    rcd_bds_cust_comp.account_clerk_code,
                    rcd_bds_cust_comp.reconciliation_account,
                    rcd_bds_cust_comp.auth_group_code,
                    rcd_bds_cust_comp.head_office_account_number,
                    rcd_bds_cust_comp.alt_payer_account_number,
                    rcd_bds_cust_comp.cust_payment_notice_ci_flag,
                    rcd_bds_cust_comp.sales_payment_notice_flag,
                    rcd_bds_cust_comp.legal_payment_notice_flag,
                    rcd_bds_cust_comp.account_payment_notice_flag,
                    rcd_bds_cust_comp.cust_payment_notice_woci_flag,
                    rcd_bds_cust_comp.payment_method_code,
                    rcd_bds_cust_comp.cust_vend_clearing_flag,
                    rcd_bds_cust_comp.payment_block_flag,
                    rcd_bds_cust_comp.payment_terms_code,
                    rcd_bds_cust_comp.payment_terms_boec_flag,
                    rcd_bds_cust_comp.interest_calc_code,
                    rcd_bds_cust_comp.interest_calc_last_date,
                    rcd_bds_cust_comp.interest_calc_freq,
                    rcd_bds_cust_comp.cust_mars_account,
                    rcd_bds_cust_comp.cust_user,
                    rcd_bds_cust_comp.cust_memo,
                    rcd_bds_cust_comp.planning_group_code,
                    rcd_bds_cust_comp.export_cred_insur_inst_nbr,
                    rcd_bds_cust_comp.insured_amount,
                    rcd_bds_cust_comp.insurance_laed_months,
                    rcd_bds_cust_comp.deductable_percent_rate,
                    rcd_bds_cust_comp.insurance_number,
                    rcd_bds_cust_comp.insurance_valid_date,
                    rcd_bds_cust_comp.collective_inv_variant,
                    rcd_bds_cust_comp.local_processing_flag,
                    rcd_bds_cust_comp.periodic_statements_flag,
                    rcd_bds_cust_comp.bill_of_exch_limit,
                    rcd_bds_cust_comp.next_payee,
                    rcd_bds_cust_comp.interest_calc_run_date,
                    rcd_bds_cust_comp.record_pay_history_flag,
                    rcd_bds_cust_comp.tolerance_group_code,
                    rcd_bds_cust_comp.probable_payment_time,
                    rcd_bds_cust_comp.house_bank_key,
                    rcd_bds_cust_comp.pay_items_separately,
                    rcd_bds_cust_comp.reduction_rate_subsidy,
                    rcd_bds_cust_comp.prev_master_record,
                    rcd_bds_cust_comp.payment_grouping_code,
                    rcd_bds_cust_comp.known_leave_key,
                    rcd_bds_cust_comp.dunning_notice_group_code,
                    rcd_bds_cust_comp.payment_lockbox,
                    rcd_bds_cust_comp.payment_method_supplement,
                    rcd_bds_cust_comp.buying_group_account_number,
                    rcd_bds_cust_comp.payment_advice_select_rule,
                    rcd_bds_cust_comp.edi_payments_flag,
                    rcd_bds_cust_comp.release_approval_group_code,
                    rcd_bds_cust_comp.convert_version_reason_code,
                    rcd_bds_cust_comp.cust_vend_fax,
                    rcd_bds_cust_comp.cust_vend_phone,
                    rcd_bds_cust_comp.cust_vend_email,
                    rcd_bds_cust_comp.credit_memo_payment_terms,
                    rcd_bds_cust_comp.gross_income_tax_activity,
                    rcd_bds_cust_comp.employ_tax_distbn_type,
                    rcd_bds_cust_comp.value_adjust_key,
                    rcd_bds_cust_comp.deletion_block_flag,
                    rcd_bds_cust_comp.partner_phone,
                    rcd_bds_cust_comp.receivable_pledging_flag,
                    rcd_bds_cust_comp.debt_enforecement_flag);

         /*-*/
         /* Process the LADS customer company withholding tax
         /*-*/
         open csr_lads_cus_ctx;
         loop
            fetch csr_lads_cus_ctx into rcd_lads_cus_ctx;
            if csr_lads_cus_ctx%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_comp_whtax.customer_code := rcd_lads_cus_cud.kunnr;
            rcd_bds_cust_comp_whtax.company_code := rcd_lads_cus_cud.bukrs;
            rcd_bds_cust_comp_whtax.withhold_tax_type := rcd_lads_cus_ctx.witht;
            rcd_bds_cust_comp_whtax.withhold_tax_code := rcd_lads_cus_ctx.wt_withcd;
            rcd_bds_cust_comp_whtax.withhold_tax_from_date := rcd_lads_cus_ctx.wt_agtdf;
            rcd_bds_cust_comp_whtax.withhold_tax_to_date := rcd_lads_cus_ctx.wt_agtdt;
            rcd_bds_cust_comp_whtax.withhold_tax_agent := rcd_lads_cus_ctx.wt_agent;
            rcd_bds_cust_comp_whtax.withhold_tax_identification := rcd_lads_cus_ctx.wt_wtstcd;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_comp_whtax
               (customer_code,
                company_code,
                withhold_tax_type,
                withhold_tax_code,
                withhold_tax_from_date,
                withhold_tax_to_date,
                withhold_tax_agent,
                withhold_tax_identification)
                values(rcd_bds_cust_comp_whtax.customer_code,
                       rcd_bds_cust_comp_whtax.company_code,
                       rcd_bds_cust_comp_whtax.withhold_tax_type,
                       rcd_bds_cust_comp_whtax.withhold_tax_code,
                       rcd_bds_cust_comp_whtax.withhold_tax_from_date,
                       rcd_bds_cust_comp_whtax.withhold_tax_to_date,
                       rcd_bds_cust_comp_whtax.withhold_tax_agent,
                       rcd_bds_cust_comp_whtax.withhold_tax_identification);

         end loop;
         close csr_lads_cus_ctx;

         /*-*/
         /* Process the LADS customer company text
         /*-*/
         open csr_lads_cus_cte;
         loop
            fetch csr_lads_cus_cte into rcd_lads_cus_cte;
            if csr_lads_cus_cte%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_cust_comp_text.customer_code := rcd_lads_cus_cud.kunnr;
            rcd_bds_cust_comp_text.company_code := rcd_lads_cus_cud.bukrs;
            rcd_bds_cust_comp_text.text_object := rcd_lads_cus_cte.tdobject;
            rcd_bds_cust_comp_text.text_name := rcd_lads_cus_cte.tdname;
            rcd_bds_cust_comp_text.text_id := rcd_lads_cus_cte.tdid;
            rcd_bds_cust_comp_text.text_language := rcd_lads_cus_cte.tdspras;
            rcd_bds_cust_comp_text.text_type := rcd_lads_cus_cte.tdtexttype;
            rcd_bds_cust_comp_text.text_language_iso := rcd_lads_cus_cte.tdsprasiso;
            rcd_bds_cust_comp_text.text_line := null;
         
            /*-*/
            /* Retrieve the LADS customer company text line
            /*-*/
            open csr_lads_cus_ctd;
            loop
               fetch csr_lads_cus_ctd into rcd_lads_cus_ctd;
               if csr_lads_cus_ctd%notfound or
                  (length(rcd_bds_cust_comp_text.text_line) + length(rcd_lads_cus_ctd.tdline)) > 2000 then
                  exit;
               end if;
               rcd_bds_cust_comp_text.text_line := rcd_bds_cust_comp_text.text_line||' '||rcd_lads_cus_ctd.tdline;
            end loop;
            close csr_lads_cus_ctd;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_cust_comp_text
               (customer_code,
                company_code,
                text_object,
                text_name,
                text_id,
                text_language,
                text_type,
                text_language_iso,
                text_line)
                values(rcd_bds_cust_comp_text.customer_code,
                       rcd_bds_cust_comp_text.company_code,
                       rcd_bds_cust_comp_text.text_object,
                       rcd_bds_cust_comp_text.text_name,
                       rcd_bds_cust_comp_text.text_id,
                       rcd_bds_cust_comp_text.text_language,
                       rcd_bds_cust_comp_text.text_type,
                       rcd_bds_cust_comp_text.text_language_iso,
                       rcd_bds_cust_comp_text.text_line);

         end loop;
         close csr_lads_cus_cte;

      end loop;
      close csr_lads_cus_cud;

      /*-*/
      /* Process the LADS customer plant
      /*-*/
      open csr_lads_cus_plm;
      loop
         fetch csr_lads_cus_plm into rcd_lads_cus_plm;
         if csr_lads_cus_plm%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_plant.customer_code := rcd_lads_cus_plm.kunnr;
         rcd_bds_cust_plant.cust_plant := rcd_lads_cus_plm.locnr;
         rcd_bds_cust_plant.open_date := rcd_lads_cus_plm.eroed;
         rcd_bds_cust_plant.close_date := rcd_lads_cus_plm.schld;
         rcd_bds_cust_plant.block_from_date := rcd_lads_cus_plm.spdab;
         rcd_bds_cust_plant.block_to_date := rcd_lads_cus_plm.spdbi;
         rcd_bds_cust_plant.auto_purchase_order := rcd_lads_cus_plm.autob;
         rcd_bds_cust_plant.pos_outbound_profile := rcd_lads_cus_plm.kopro;
         rcd_bds_cust_plant.layout := rcd_lads_cus_plm.layvr;
         rcd_bds_cust_plant.area := rcd_lads_cus_plm.flvar;
         rcd_bds_cust_plant.calendar := rcd_lads_cus_plm.stfak;
         rcd_bds_cust_plant.goods_receive_code := rcd_lads_cus_plm.wanid;
         rcd_bds_cust_plant.sales_area_space := rcd_lads_cus_plm.verfl;
         rcd_bds_cust_plant.sales_area_space_unit := rcd_lads_cus_plm.verfe;
         rcd_bds_cust_plant.block_reason := rcd_lads_cus_plm.spgr1;
         rcd_bds_cust_plant.pos_inbound_profile := rcd_lads_cus_plm.inpro;
         rcd_bds_cust_plant.pos_outbound_cndtn_type := rcd_lads_cus_plm.ekoar;
         rcd_bds_cust_plant.assortment_list_conditions := rcd_lads_cus_plm.kzlik;
         rcd_bds_cust_plant.plant_profile := rcd_lads_cus_plm.betrp;
         rcd_bds_cust_plant.create_date := rcd_lads_cus_plm.erdat;
         rcd_bds_cust_plant.create_user := rcd_lads_cus_plm.ernam;
         rcd_bds_cust_plant.carry_out := rcd_lads_cus_plm.nlmatfb;
         rcd_bds_cust_plant.retail_price_plant := rcd_lads_cus_plm.bwwrk;
         rcd_bds_cust_plant.retail_price_sal_org := rcd_lads_cus_plm.bwvko;
         rcd_bds_cust_plant.retail_price_distbn_chnl := rcd_lads_cus_plm.bwvtw;
         rcd_bds_cust_plant.assortment_list_profile := rcd_lads_cus_plm.bbpro;
         rcd_bds_cust_plant.sales_office := rcd_lads_cus_plm.vkbur_wrk;
         rcd_bds_cust_plant.plant_category := rcd_lads_cus_plm.vlfkz;
         rcd_bds_cust_plant.list_procedure := rcd_lads_cus_plm.lstfl;
         rcd_bds_cust_plant.list_rule := rcd_lads_cus_plm.ligrd;
         rcd_bds_cust_plant.intercompany_sales_org := rcd_lads_cus_plm.vkorg;
         rcd_bds_cust_plant.intercompany_distbn_chnl := rcd_lads_cus_plm.vtweg;
         rcd_bds_cust_plant.roi_required := rcd_lads_cus_plm.desroi;
         rcd_bds_cust_plant.ale_time_increment := rcd_lads_cus_plm.timinc;
         rcd_bds_cust_plant.pos_currency := rcd_lads_cus_plm.posws;
         rcd_bds_cust_plant.space_manage_profile := rcd_lads_cus_plm.ssopt_pro;
         rcd_bds_cust_plant.vbim_profile := rcd_lads_cus_plm.wbpro;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_plant
            (customer_code,
             cust_plant,
             open_date,
             close_date,
             block_from_date,
             block_to_date,
             auto_purchase_order,
             pos_outbound_profile,
             layout,
             area,
             calendar,
             goods_receive_code,
             sales_area_space,
             sales_area_space_unit,
             block_reason,
             pos_inbound_profile,
             pos_outbound_cndtn_type,
             assortment_list_conditions,
             plant_profile,
             create_date,
             create_user,
             carry_out,
             retail_price_plant,
             retail_price_sal_org,
             retail_price_distbn_chnl,
             assortment_list_profile,
             sales_office,
             plant_category,
             list_procedure,
             list_rule,
             intercompany_sales_org,
             intercompany_distbn_chnl,
             roi_required,
             ale_time_increment,
             pos_currency,
             space_manage_profile,
             vbim_profile)
             values(rcd_bds_cust_plant.customer_code,
                    rcd_bds_cust_plant.cust_plant,
                    rcd_bds_cust_plant.open_date,
                    rcd_bds_cust_plant.close_date,
                    rcd_bds_cust_plant.block_from_date,
                    rcd_bds_cust_plant.block_to_date,
                    rcd_bds_cust_plant.auto_purchase_order,
                    rcd_bds_cust_plant.pos_outbound_profile,
                    rcd_bds_cust_plant.layout,
                    rcd_bds_cust_plant.area,
                    rcd_bds_cust_plant.calendar,
                    rcd_bds_cust_plant.goods_receive_code,
                    rcd_bds_cust_plant.sales_area_space,
                    rcd_bds_cust_plant.sales_area_space_unit,
                    rcd_bds_cust_plant.block_reason,
                    rcd_bds_cust_plant.pos_inbound_profile,
                    rcd_bds_cust_plant.pos_outbound_cndtn_type,
                    rcd_bds_cust_plant.assortment_list_conditions,
                    rcd_bds_cust_plant.plant_profile,
                    rcd_bds_cust_plant.create_date,
                    rcd_bds_cust_plant.create_user,
                    rcd_bds_cust_plant.carry_out,
                    rcd_bds_cust_plant.retail_price_plant,
                    rcd_bds_cust_plant.retail_price_sal_org,
                    rcd_bds_cust_plant.retail_price_distbn_chnl,
                    rcd_bds_cust_plant.assortment_list_profile,
                    rcd_bds_cust_plant.sales_office,
                    rcd_bds_cust_plant.plant_category,
                    rcd_bds_cust_plant.list_procedure,
                    rcd_bds_cust_plant.list_rule,
                    rcd_bds_cust_plant.intercompany_sales_org,
                    rcd_bds_cust_plant.intercompany_distbn_chnl,
                    rcd_bds_cust_plant.roi_required,
                    rcd_bds_cust_plant.ale_time_increment,
                    rcd_bds_cust_plant.pos_currency,
                    rcd_bds_cust_plant.space_manage_profile,
                    rcd_bds_cust_plant.vbim_profile);

      end loop;
      close csr_lads_cus_plm;

      /*-*/
      /* Process the LADS customer plant receiving point
      /*-*/
      open csr_lads_cus_prp;
      loop
         fetch csr_lads_cus_prp into rcd_lads_cus_prp;
         if csr_lads_cus_prp%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_plant_rcvpnt.customer_code := rcd_lads_cus_prp.kunnr;
         rcd_bds_cust_plant_rcvpnt.cust_plant := rcd_lads_cus_prp.locnr;
         rcd_bds_cust_plant_rcvpnt.receiving_point := rcd_lads_cus_prp.empst;
         rcd_bds_cust_plant_rcvpnt.partner_cust_code := rcd_lads_cus_prp.kunn2;
         rcd_bds_cust_plant_rcvpnt.unloading_point := rcd_lads_cus_prp.ablad;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_plant_rcvpnt
            (customer_code,
             cust_plant,
             receiving_point,
             partner_cust_code,
             unloading_point)
             values(rcd_bds_cust_plant_rcvpnt.customer_code,
                    rcd_bds_cust_plant_rcvpnt.cust_plant,
                    rcd_bds_cust_plant_rcvpnt.receiving_point,
                    rcd_bds_cust_plant_rcvpnt.partner_cust_code,
                    rcd_bds_cust_plant_rcvpnt.unloading_point);

      end loop;
      close csr_lads_cus_prp;

      /*-*/
      /* Process the LADS customer plant department
      /*-*/
      open csr_lads_cus_pdp;
      loop
         fetch csr_lads_cus_pdp into rcd_lads_cus_pdp;
         if csr_lads_cus_pdp%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_plant_dept.customer_code := rcd_lads_cus_pdp.kunnr;
         rcd_bds_cust_plant_dept.cust_plant := rcd_lads_cus_pdp.locnr;
         rcd_bds_cust_plant_dept.cust_department := rcd_lads_cus_pdp.abtnr;
         rcd_bds_cust_plant_dept.receive_point := rcd_lads_cus_pdp.empst;
         rcd_bds_cust_plant_dept.sales_area_space := rcd_lads_cus_pdp.verfl;
         rcd_bds_cust_plant_dept.sales_area_space_unit := rcd_lads_cus_pdp.verfe;
         rcd_bds_cust_plant_dept.layout := rcd_lads_cus_pdp.layvr;
         rcd_bds_cust_plant_dept.area := rcd_lads_cus_pdp.flvar;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_plant_dept
            (customer_code,
             cust_plant,
             cust_department,
             receive_point,
             sales_area_space,
             sales_area_space_unit,
             layout,
             area)
             values(rcd_bds_cust_plant_dept.customer_code,
                    rcd_bds_cust_plant_dept.cust_plant,
                    rcd_bds_cust_plant_dept.cust_department,
                    rcd_bds_cust_plant_dept.receive_point,
                    rcd_bds_cust_plant_dept.sales_area_space,
                    rcd_bds_cust_plant_dept.sales_area_space_unit,
                    rcd_bds_cust_plant_dept.layout,
                    rcd_bds_cust_plant_dept.area);

      end loop;
      close csr_lads_cus_pdp;

      /*-*/
      /* Process the LADS customer plant value only material determination
      /*-*/
      open csr_lads_cus_mgv;
      loop
         fetch csr_lads_cus_mgv into rcd_lads_cus_mgv;
         if csr_lads_cus_mgv%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_plant_vomd.customer_code := rcd_lads_cus_mgv.kunnr;
         rcd_bds_cust_plant_vomd.cust_plant := rcd_lads_cus_mgv.locnr;
         rcd_bds_cust_plant_vomd.material_group := rcd_lads_cus_mgv.matkl;
         rcd_bds_cust_plant_vomd.material_group_material_code := rcd_lads_cus_mgv.wwgpa;
         rcd_bds_cust_plant_vomd.inventory_manage_exception := rcd_lads_cus_mgv.kedet;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_plant_vomd
            (customer_code,
             cust_plant,
             material_group,
             material_group_material_code,
             inventory_manage_exception)
             values(rcd_bds_cust_plant_vomd.customer_code,
                    rcd_bds_cust_plant_vomd.cust_plant,
                    rcd_bds_cust_plant_vomd.material_group,
                    rcd_bds_cust_plant_vomd.material_group_material_code,
                    rcd_bds_cust_plant_vomd.inventory_manage_exception);

      end loop;
      close csr_lads_cus_mgv;

      /*-*/
      /* Process the LADS customer plant value only material determination exception
      /*-*/
      open csr_lads_cus_mge;
      loop
         fetch csr_lads_cus_mge into rcd_lads_cus_mge;
         if csr_lads_cus_mge%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_cust_plant_vomd_except.customer_code := rcd_lads_cus_mge.kunnr;
         rcd_bds_cust_plant_vomd_except.cust_plant := rcd_lads_cus_mge.locnr;
         rcd_bds_cust_plant_vomd_except.material_code := rcd_lads_cus_mge.matnr;
         rcd_bds_cust_plant_vomd_except.posting_material_code := rcd_lads_cus_mge.wmatn;
         rcd_bds_cust_plant_vomd_except.material_group_code := rcd_lads_cus_mge.matkl;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_cust_plant_vomd_except
            (customer_code,
             cust_plant,
             material_code,
             posting_material_code,
             material_group_code)
             values(rcd_bds_cust_plant_vomd_except.customer_code,
                    rcd_bds_cust_plant_vomd_except.cust_plant,
                    rcd_bds_cust_plant_vomd_except.material_code,
                    rcd_bds_cust_plant_vomd_except.posting_material_code,
                    rcd_bds_cust_plant_vomd_except.material_group_code);

      end loop;
      close csr_lads_cus_mge;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_cus_hdr
         set lads_flattened = var_flattened
         where kunnr = par_kunnr;

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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'KUNNR: ' || par_kunnr || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_flatten;

   /*******************************************************************************/
   /* This procedure performs the lock routine                                    */
   /*   notes - acquires a lock on the LADS header record                         */
   /*         - uses NOWAIT, assumes if locked, LADS load will re-call flattening */
   /*         - issues commit to release lock                                     */
   /*         - used when manually executing flattening                           */
   /*******************************************************************************/
   procedure lads_lock(par_kunnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_cus_hdr t01
          where t01.kunnr = par_kunnr
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
         /* Flatten
         /*-*/
         bds_flatten(rcd_lock.kunnr);

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
   end lads_lock;

   /******************************************************************************************/
   /* This procedure performs the refresh routine                                            */
   /*   notes - processes all LADS records with unflattened status                           */
   /******************************************************************************************/
   procedure bds_refresh is

      /*-*/
      /* Local definitions
      /*-*/
      var_open boolean;
      var_exit boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_flatten is
         select t01.kunnr
           from lads_cus_hdr t01
          where nvl(t01.lads_flattened,'0') = '0';
      rcd_flatten csr_flatten%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve document header with lads_flattened status = 0
      /* notes - cursor is reopened when snapshot to old
      /*-*/
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next document to process
         /*-*/
         loop
            if var_open = true then
               if csr_flatten%isopen then
                  close csr_flatten;
               end if;
               open csr_flatten;
               var_open := false;
            end if;
            begin
               fetch csr_flatten into rcd_flatten;
               if csr_flatten%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         /*-*/
         if var_exit = true then
            exit;
         end if;

         lads_lock(rcd_flatten.kunnr);

      end loop;
      close csr_flatten;

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

   /******************************************************************************************/
   /* This procedure performs the rebuild routine                                            */
   /*   notes - RECOMMEND stopping ICS jobs prior to execution                               */
   /*         - performs a truncate on the target BDS table                                  */
   /*         - updates all LADS records to unflattened status                               */
   /*         - calls bds_refresh procedure to drive processing                              */
   /******************************************************************************************/
   procedure bds_rebuild is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Truncate target BDS table(s)
      /*-*/
      bds_table.truncate('bds_cust_plant_vomd_except');
      bds_table.truncate('bds_cust_plant_vomd');
      bds_table.truncate('bds_cust_plant_dept');
      bds_table.truncate('bds_cust_plant_rcvpnt');
      bds_table.truncate('bds_cust_plant');
      bds_table.truncate('bds_cust_comp_text');
      bds_table.truncate('bds_cust_comp_whtax');
      bds_table.truncate('bds_cust_comp');
      bds_table.truncate('bds_cust_sales_area_text');
      bds_table.truncate('bds_cust_sales_area_licse');
      bds_table.truncate('bds_cust_sales_area_taxind');
      bds_table.truncate('bds_cust_sales_area_pnrfun');
      bds_table.truncate('bds_cust_sales_area_vmifct');
      bds_table.truncate('bds_cust_sales_area_vmityp');
      bds_table.truncate('bds_cust_sales_area');
      bds_table.truncate('bds_cust_vat');
      bds_table.truncate('bds_cust_unlpnt');
      bds_table.truncate('bds_cust_bank');
      bds_table.truncate('bds_cust_contact');
      bds_table.truncate('bds_cust_text');
      bds_table.truncate('bds_cust_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_cus_hdr
         set lads_flattened = '0';

      /*-*/
      /* Commit
      /*-*/
      commit;

      /*-*/
      /* Execute BDS_REFRESH to repopulate BDS target tables
      /*-*/
      bds_refresh;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad11_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad11_flatten for bds_app.bds_atllad11_flatten;
grant execute on bds_atllad11_flatten to lics_app;
grant execute on bds_atllad11_flatten to lads_app;