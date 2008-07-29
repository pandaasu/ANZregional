/******************/
/* Package Header */
/******************/
create or replace package bds_atllad19_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad19_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD19 - Vendor Master (CREMAS04)

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

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_lifnr in varchar2);

end bds_atllad19_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad19_flatten as

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
   procedure lads_lock(par_lifnr in varchar2);
   procedure bds_flatten(par_lifnr in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_lifnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_lifnr);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_lifnr);
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
         raise_application_error(-20000, 'bds_atllad19_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_lifnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_vend_header bds_vend_header%rowtype;
      rcd_bds_vend_text bds_vend_text%rowtype;
      rcd_bds_vend_bank bds_vend_bank%rowtype;
      rcd_bds_vend_comp bds_vend_comp%rowtype;
      rcd_bds_vend_comp_whtax bds_vend_comp_whtax%rowtype;
      rcd_bds_vend_comp_text bds_vend_comp_text%rowtype;
      rcd_bds_vend_comp_mars bds_vend_comp_mars%rowtype;
      rcd_bds_vend_purch bds_vend_purch%rowtype;
      rcd_bds_vend_purch_plant bds_vend_purch_plant%rowtype;
      rcd_bds_vend_purch_text bds_vend_purch_text%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ven_hdr is
         select t01.lifnr as lifnr,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.begru as begru,
                t01.brsch as brsch,
                bds_date.bds_to_date('*DATE',t01.erdat) as erdat,
                t01.ernam as ernam,
                t01.konzs as konzs,
                t01.ktokk as ktokk,
                t01.kunnr as kunnr,
                t01.lnrza as lnrza,
                t01.loevm as loevm,
                t01.name1 as name1,
                t01.name2 as name2,
                t01.name3 as name3,
                t01.name4 as name4,
                t01.sortl as sortl,
                t01.sperr as sperr,
                t01.sperm as sperm,
                t01.spras as spras,
                t01.stcd1 as stcd1,
                t01.stcd2 as stcd2,
                t01.stkza as stkza,
                t01.stkzu as stkzu,
                t01.xcpdk as xcpdk,
                t01.xzemp as xzemp,
                t01.vbund as vbund,
                t01.fiskn as fiskn,
                t01.stceg as stceg,
                t01.stkzn as stkzn,
                t01.sperq as sperq,
                t01.adrnr as adrnr,
                t01.gbort as gbort,
                bds_date.bds_to_date('*DATE',t01.gbdat) as gbdat,
                t01.sexkz as sexkz,
                t01.kraus as kraus,
                bds_date.bds_to_date('*DATE',t01.revdb) as revdb,
                t01.qssys as qssys,
                t01.ktock as ktock,
                t01.werks as werks,
                t01.ltsna as ltsna,
                t01.werkr as werkr,
                t01.plkal as plkal,
                t01.duefl as duefl,
                t01.txjcd as txjcd,
                t01.scacd as scacd,
                t01.sfrgr as sfrgr,
                t01.lzone as lzone,
                t01.dlgrp as dlgrp,
                t01.fityp as fityp,
                t01.stcdt as stcdt,
                t01.regss as regss,
                t01.actss as actss,
                t01.stcd3 as stcd3,
                t01.stcd4 as stcd4,
                t01.ipisp as ipisp,
                t01.profs as profs,
                t01.stgdl as stgdl,
                t01.emnfr as emnfr,
                t01.nodel as nodel,
                t01.lfurl as lfurl,
                t01.j_1kfrepre as j_1kfrepre,
                t01.j_1kftbus as j_1kftbus,
                t01.j_1kftind as j_1kftind,
                bds_date.bds_to_date('*DATE',t01.qssysdat) as qssysdat,
                t01.podkzb as podkzb,
                t01.fisku as fisku,
                t01.stenr as stenr,
                t01.psois as psois,
                t01.pson1 as pson1,
                t01.pson2 as pson2,
                t01.pson3 as pson3,
                t01.psovn as psovn
           from lads_ven_hdr t01
          where t01.lifnr = par_lifnr;
      rcd_lads_ven_hdr csr_lads_ven_hdr%rowtype;

      cursor csr_lads_ven_txh is
         select * from (
            select t01.lifnr as lifnr,
                   t01.txhseq as txhseq,
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
                                    order by t01.txhseq) as rnkseq
              from lads_ven_txh t01
             where t01.lifnr = rcd_lads_ven_hdr.lifnr)
         where rnkseq = 1;
      rcd_lads_ven_txh csr_lads_ven_txh%rowtype;

      cursor csr_lads_ven_txl is
         select t01.tdline as tdline
           from lads_ven_txl t01
          where t01.lifnr = rcd_lads_ven_txh.lifnr
            and t01.txhseq = rcd_lads_ven_txh.txhseq
          order by t01.txlseq asc;
      rcd_lads_ven_txl csr_lads_ven_txl%rowtype;

      cursor csr_lads_ven_bnk is
         select * from (
            select t01.lifnr as lifnr,
                   t01.bnkseq as bnkseq,
                   nvl(t01.banks,'*NONE') as banks,
                   nvl(t01.bankl,'*NONE') as bankl,
                   nvl(t01.bankn,'*NONE') as bankn,
                   nvl(t01.bkont,'*NONE') as bkont,
                   t01.bvtyp as bvtyp,
                   t01.xezer as xezer,
                   t01.banka as banka,
                   t01.ort01 as ort01,
                   t01.swift as swift,
                   t01.bgrup as bgrup,
                   t01.xpgro as xpgro,
                   t01.bnklz as bnklz,
                   t01.pskto as pskto,
                   t01.bkref as bkref,
                   t01.brnch as brnch,
                   t01.prov2 as prov2,
                   t01.stra2 as stra2,
                   t01.ort02 as ort02,
                   t01.koinh as koinh,
                   bds_date.bds_to_date('*DATE',t01.kovon) as kovon,
                   bds_date.bds_to_date('*DATE',t01.kobis) as kobis,
                   rank() over (partition by nvl(t01.banks,'*NONE'),
                                             nvl(t01.bankl,'*NONE'),
                                             nvl(t01.bankn,'*NONE'),
                                             nvl(t01.bkont,'*NONE')
                                    order by t01.bnkseq) as rnkseq
              from lads_ven_bnk t01
             where t01.lifnr = rcd_lads_ven_hdr.lifnr)
         where rnkseq = 1;
      rcd_lads_ven_bnk csr_lads_ven_bnk%rowtype;

      cursor csr_lads_ven_ccd is
         select * from (
            select t01.lifnr as lifnr,
                   t01.ccdseq as ccdseq,
                   nvl(t01.bukrs,'*NONE') as bukrs,
                   bds_date.bds_to_date('*DATE',t01.erdat) as erdat,
                   t01.ernam as ernam,
                   t01.sperr as sperr,
                   t01.loevm as loevm,
                   t01.zuawa as zuawa,
                   t01.akont as akont,
                   t01.begru as begru,
                   t01.vzskz as vzskz,
                   t01.zwels as zwels,
                   t01.xverr as xverr,
                   t01.zahls as zahls,
                   t01.zterm as zterm,
                   t01.eikto as eikto,
                   t01.zsabe as zsabe,
                   t01.fdgrv as fdgrv,
                   t01.busab as busab,
                   t01.lnrze as lnrze,
                   t01.lnrzb as lnrzb,
                   bds_date.bds_to_date('*DATE',t01.zindt) as zindt,
                   t01.zinrt as zinrt,
                   bds_date.bds_to_date('*DATE',t01.datlz) as datlz,
                   t01.xdezv as xdezv,
                   t01.webtr as webtr,
                   t01.kultg as kultg,
                   t01.reprf as reprf,
                   t01.togru as togru,
                   t01.hbkid as hbkid,
                   t01.xpore as xpore,
                   t01.qsznr as qsznr,
                   bds_date.bds_to_date('*DATE',t01.qszdt) as qszdt,
                   t01.qsskz as qsskz,
                   t01.blnkz as blnkz,
                   t01.mindk as mindk,
                   t01.altkn as altkn,
                   t01.zgrup as zgrup,
                   t01.mgrup as mgrup,
                   t01.qsrec as qsrec,
                   t01.qsbgr as qsbgr,
                   t01.qland as qland,
                   t01.xedip as xedip,
                   t01.frgrp as frgrp,
                   t01.tlfxs as tlfxs,
                   t01.intad as intad,
                   t01.guzte as guzte,
                   t01.gricd as gricd,
                   t01.gridt as gridt,
                   t01.xausz as xausz,
                   bds_date.bds_to_date('*DATE',t01.cerdt) as cerdt,
                   t01.togrr as togrr,
                   t01.pernr as pernr,
                   t01.nodel as nodel,
                   t01.tlfns as tlfns,
                   t01.gmvkzk as gmvkzk,
                   rank() over (partition by nvl(t01.bukrs,'*NONE')
                                    order by t01.ccdseq) as rnkseq
              from lads_ven_ccd t01
             where t01.lifnr = rcd_lads_ven_hdr.lifnr)
         where rnkseq = 1;
      rcd_lads_ven_ccd csr_lads_ven_ccd%rowtype;

      cursor csr_lads_ven_wtx is
         select * from (
            select t01.lifnr as lifnr,
                   t01.ccdseq as ccdseq,
                   t01.wtxseq as wtxseq,
                   nvl(t01.witht,'*NONE') as witht,
                   t01.wt_subjct as wt_subjct,
                   t01.qsrec as qsrec,
                   t01.wt_wtstcd as wt_wtstcd,
                   nvl(t01.wt_withcd,'*NONE') as wt_withcd,
                   t01.wt_exnr as wt_exnr,
                   t01.wt_exrt as wt_exrt,
                   bds_date.bds_to_date('*START_DATE',t01.wt_exdf) as wt_exdf,
                   bds_date.bds_to_date('*END_DATE',t01.wt_exdt) as wt_exdt,
                   t01.wt_wtexrs as wt_wtexrs,
                   rank() over (partition by nvl(t01.witht,'*NONE'),
                                             nvl(t01.wt_withcd,'*NONE'),
                                             t01.wt_exdf,
                                             t01.wt_exdt
                                    order by t01.wtxseq) as rnkseq
              from lads_ven_wtx t01
             where t01.lifnr = rcd_lads_ven_ccd.lifnr
               and t01.ccdseq = rcd_lads_ven_ccd.ccdseq)
         where rnkseq = 1;
      rcd_lads_ven_wtx csr_lads_ven_wtx%rowtype;

      cursor csr_lads_ven_ctx is
         select * from (
            select t01.lifnr as lifnr,
                   t01.ccdseq as ccdseq,
                   t01.ctxseq as ctxseq,
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
                                    order by t01.ctxseq) as rnkseq
              from lads_ven_ctx t01
             where t01.lifnr = rcd_lads_ven_ccd.lifnr
               and t01.ccdseq = rcd_lads_ven_ccd.ccdseq)
         where rnkseq = 1;
      rcd_lads_ven_ctx csr_lads_ven_ctx%rowtype;

      cursor csr_lads_ven_ctd is
         select t01.tdline as tdline
           from lads_ven_ctd t01
          where t01.lifnr = rcd_lads_ven_ctx.lifnr
            and t01.ccdseq = rcd_lads_ven_ctx.ccdseq
            and t01.ctxseq = rcd_lads_ven_ctx.ctxseq
          order by t01.ctdseq asc;
      rcd_lads_ven_ctd csr_lads_ven_ctd%rowtype;

      cursor csr_lads_ven_zcc is
         select * from (
            select t01.lifnr as lifnr,
                   t01.ccdseq as ccdseq,
                   t01.zccseq as zccseq,
                   t01.zpytadv as zpytadv,
                   rank() over (partition by t01.ccdseq
                                    order by t01.zccseq) as rnkseq
              from lads_ven_zcc t01
             where t01.lifnr = rcd_lads_ven_ccd.lifnr
               and t01.ccdseq = rcd_lads_ven_ccd.ccdseq)
         where rnkseq = 1;
      rcd_lads_ven_zcc csr_lads_ven_zcc%rowtype;

      cursor csr_lads_ven_poh is
         select * from (
            select t01.lifnr as lifnr,
                   t01.pohseq as pohseq,
                   nvl(t01.ekorg,'*NONE') as ekorg,
                   bds_date.bds_to_date('*DATE',t01.erdat) as erdat,
                   t01.ernam as ernam,
                   t01.sperm as sperm,
                   t01.loevm as loevm,
                   t01.lfabc as lfabc,
                   t01.waers as waers,
                   t01.verkf as verkf,
                   t01.telf1 as telf1,
                   t01.minbw as minbw,
                   t01.zterm as zterm,
                   t01.inco1 as inco1,
                   t01.inco2 as inco2,
                   t01.webre as webre,
                   t01.kzabs as kzabs,
                   t01.kalsk as kalsk,
                   t01.kzaut as kzaut,
                   t01.expvz as expvz,
                   t01.zolla as zolla,
                   t01.meprf as meprf,
                   t01.ekgrp as ekgrp,
                   t01.bolre as bolre,
                   t01.umsae as umsae,
                   t01.xersy as xersy,
                   t01.plifz as plifz,
                   t01.mrppp as mrppp,
                   t01.lfrhy as lfrhy,
                   t01.liefr as liefr,
                   t01.libes as libes,
                   t01.lipre as lipre,
                   t01.liser as liser,
                   t01.boind as boind,
                   t01.prfre as prfre,
                   t01.nrgew as nrgew,
                   t01.blind as blind,
                   t01.kzret as kzret,
                   t01.skrit as skrit,
                   t01.bstae as bstae,
                   t01.rdprf as rdprf,
                   t01.megru as megru,
                   t01.vensl as vensl,
                   t01.bopnr as bopnr,
                   t01.xersr as xersr,
                   t01.eikto as eikto,
                   t01.paprf as paprf,
                   t01.agrel as agrel,
                   t01.xnbwy as xnbwy,
                   t01.vsbed as vsbed,
                   t01.lebre as lebre,
                   t01.minbw2 as minbw2,
                   rank() over (partition by nvl(t01.ekorg,'*NONE')
                                    order by t01.pohseq) as rnkseq
              from lads_ven_poh t01
             where t01.lifnr = rcd_lads_ven_hdr.lifnr)
         where rnkseq = 1;
      rcd_lads_ven_poh csr_lads_ven_poh%rowtype;

      cursor csr_lads_ven_pom is
         select * from (
            select t01.lifnr as lifnr,
                   t01.pohseq as pohseq,
                   t01.pomseq as pomseq,
                   nvl(t01.ltsnr,'*NONE') as ltsnr,
                   nvl(t01.werks,'*NONE') as werks,
                   bds_date.bds_to_date('*DATE',t01.erdat) as erdat,
                   t01.ernam as ernam,
                   t01.sperm as sperm,
                   t01.loevm as loevm,
                   t01.lfabc as lfabc,
                   t01.waers as waers,
                   t01.verkf as verkf,
                   t01.telf1 as telf1,
                   t01.minbw as minbw,
                   t01.zterm as zterm,
                   t01.inco1 as inco1,
                   t01.inco2 as inco2,
                   t01.webre as webre,
                   t01.kzabs as kzabs,
                   t01.kalsk as kalsk,
                   t01.kzaut as kzaut,
                   t01.expvz as expvz,
                   t01.zolla as zolla,
                   t01.meprf as meprf,
                   t01.ekgrp as ekgrp,
                   t01.bolre as bolre,
                   t01.umsae as umsae,
                   t01.xersy as xersy,
                   t01.plifz as plifz,
                   t01.mrppp as mrppp,
                   t01.lfrhy as lfrhy,
                   t01.liefr as liefr,
                   t01.libes as libes,
                   t01.lipre as lipre,
                   t01.liser as liser,
                   t01.dispo as dispo,
                   t01.bstae as bstae,
                   t01.rdprf as rdprf,
                   t01.megru as megru,
                   t01.bopnr as bopnr,
                   t01.xersr as xersr,
                   t01.abueb as abueb,
                   t01.paprf as paprf,
                   t01.xnbwy as xnbwy,
                   t01.lebre as lebre,
                   t01.minbw2 as minbw2,
                   rank() over (partition by nvl(t01.ltsnr,'*NONE'),
                                             nvl(t01.werks,'*NONE')
                                    order by t01.pomseq) as rnkseq
              from lads_ven_pom t01
             where t01.lifnr = rcd_lads_ven_poh.lifnr
               and t01.pohseq = rcd_lads_ven_poh.pohseq)
         where rnkseq = 1;
      rcd_lads_ven_pom csr_lads_ven_pom%rowtype;

      cursor csr_lads_ven_ptx is
         select * from (
            select t01.lifnr as lifnr,
                   t01.pohseq as pohseq,
                   t01.ptxseq as ptxseq,
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
                                    order by t01.ptxseq) as rnkseq
              from lads_ven_ptx t01
             where t01.lifnr = rcd_lads_ven_poh.lifnr
               and t01.pohseq = rcd_lads_ven_poh.pohseq)
         where rnkseq = 1;
      rcd_lads_ven_ptx csr_lads_ven_ptx%rowtype;

      cursor csr_lads_ven_ptd is
         select t01.tdline as tdline
           from lads_ven_ptd t01
          where t01.lifnr = rcd_lads_ven_ptx.lifnr
            and t01.pohseq = rcd_lads_ven_ptx.pohseq
            and t01.ptxseq = rcd_lads_ven_ptx.ptxseq
          order by t01.ptdseq asc;
      rcd_lads_ven_ptd csr_lads_ven_ptd%rowtype;

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
      delete from bds_vend_text where vendor_code = par_lifnr;
      delete from bds_vend_bank where vendor_code = par_lifnr;
      delete from bds_vend_comp where vendor_code = par_lifnr;
      delete from bds_vend_comp_whtax where vendor_code = par_lifnr;
      delete from bds_vend_comp_text where vendor_code = par_lifnr;
      delete from bds_vend_comp_mars where vendor_code = par_lifnr;
      delete from bds_vend_purch where vendor_code = par_lifnr;
      delete from bds_vend_purch_plant where vendor_code = par_lifnr;
      delete from bds_vend_purch_text where vendor_code = par_lifnr;

      /*-*/
      /* Retrieve the LADS header
      /*-*/
      open csr_lads_ven_hdr;
      fetch csr_lads_ven_hdr into rcd_lads_ven_hdr;
      if csr_lads_ven_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_ven_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_vend_header.vendor_code := rcd_lads_ven_hdr.lifnr;
      rcd_bds_vend_header.sap_idoc_name := rcd_lads_ven_hdr.idoc_name;
      rcd_bds_vend_header.sap_idoc_number := rcd_lads_ven_hdr.idoc_number;
      rcd_bds_vend_header.sap_idoc_timestamp := rcd_lads_ven_hdr.idoc_timestamp;
      rcd_bds_vend_header.bds_lads_date := rcd_lads_ven_hdr.lads_date;
      rcd_bds_vend_header.bds_lads_status := rcd_lads_ven_hdr.lads_status;
      rcd_bds_vend_header.auth_group_code := rcd_lads_ven_hdr.begru;
      rcd_bds_vend_header.industry_code := rcd_lads_ven_hdr.brsch;
      rcd_bds_vend_header.create_date := rcd_lads_ven_hdr.erdat;
      rcd_bds_vend_header.create_user := rcd_lads_ven_hdr.ernam;
      rcd_bds_vend_header.group_key := rcd_lads_ven_hdr.konzs;
      rcd_bds_vend_header.account_group_code := rcd_lads_ven_hdr.ktokk;
      rcd_bds_vend_header.customer_code := rcd_lads_ven_hdr.kunnr;
      rcd_bds_vend_header.account_number := rcd_lads_ven_hdr.lnrza;
      rcd_bds_vend_header.deletion_flag := rcd_lads_ven_hdr.loevm;
      rcd_bds_vend_header.vendor_name_01 := rcd_lads_ven_hdr.name1;
      rcd_bds_vend_header.vendor_name_02 := rcd_lads_ven_hdr.name2;
      rcd_bds_vend_header.vendor_name_03 := rcd_lads_ven_hdr.name3;
      rcd_bds_vend_header.vendor_name_04 := rcd_lads_ven_hdr.name4;
      rcd_bds_vend_header.sort_value := rcd_lads_ven_hdr.sortl;
      rcd_bds_vend_header.posting_block_flag := rcd_lads_ven_hdr.sperr;
      rcd_bds_vend_header.purchasing_block_flag := rcd_lads_ven_hdr.sperm;
      rcd_bds_vend_header.language_key := rcd_lads_ven_hdr.spras;
      rcd_bds_vend_header.tax_number_01 := rcd_lads_ven_hdr.stcd1;
      rcd_bds_vend_header.tax_number_02 := rcd_lads_ven_hdr.stcd2;
      rcd_bds_vend_header.tax_equalization_flag := rcd_lads_ven_hdr.stkza;
      rcd_bds_vend_header.vat_flag := rcd_lads_ven_hdr.stkzu;
      rcd_bds_vend_header.one_time_flag := rcd_lads_ven_hdr.xcpdk;
      rcd_bds_vend_header.alternative_payee_flag := rcd_lads_ven_hdr.xzemp;
      rcd_bds_vend_header.trading_partner_company_code := rcd_lads_ven_hdr.vbund;
      rcd_bds_vend_header.fiscal_account_number := rcd_lads_ven_hdr.fiskn;
      rcd_bds_vend_header.vat_registration_number := rcd_lads_ven_hdr.stceg;
      rcd_bds_vend_header.natural_person := rcd_lads_ven_hdr.stkzn;
      rcd_bds_vend_header.function_block := rcd_lads_ven_hdr.sperq;
      rcd_bds_vend_header.address_code := rcd_lads_ven_hdr.adrnr;
      rcd_bds_vend_header.withhold_tax_birth_place := rcd_lads_ven_hdr.gbort;
      rcd_bds_vend_header.withhold_tax_birth_date := rcd_lads_ven_hdr.gbdat;
      rcd_bds_vend_header.withhold_tax_sex := rcd_lads_ven_hdr.sexkz;
      rcd_bds_vend_header.credit_information_number := rcd_lads_ven_hdr.kraus;
      rcd_bds_vend_header.last_review_date := rcd_lads_ven_hdr.revdb;
      rcd_bds_vend_header.qm_system := rcd_lads_ven_hdr.qssys;
      rcd_bds_vend_header.one_time_account_group := rcd_lads_ven_hdr.ktock;
      rcd_bds_vend_header.plant_code := rcd_lads_ven_hdr.werks;
      rcd_bds_vend_header.sub_range_flag := rcd_lads_ven_hdr.ltsna;
      rcd_bds_vend_header.plant_level_flag := rcd_lads_ven_hdr.werkr;
      rcd_bds_vend_header.factory_calendar := rcd_lads_ven_hdr.plkal;
      rcd_bds_vend_header.data_transfer_status := rcd_lads_ven_hdr.duefl;
      rcd_bds_vend_header.tax_jurisdiction_code := rcd_lads_ven_hdr.txjcd;
      rcd_bds_vend_header.std_carrier_access_code := rcd_lads_ven_hdr.scacd;
      rcd_bds_vend_header.forward_agent_freight_group := rcd_lads_ven_hdr.sfrgr;
      rcd_bds_vend_header.delivery_transport_zone := rcd_lads_ven_hdr.lzone;
      rcd_bds_vend_header.service_agent_procedure_group := rcd_lads_ven_hdr.dlgrp;
      rcd_bds_vend_header.tax_type := rcd_lads_ven_hdr.fityp;
      rcd_bds_vend_header.tax_number_type := rcd_lads_ven_hdr.stcdt;
      rcd_bds_vend_header.social_insurance_flag := rcd_lads_ven_hdr.regss;
      rcd_bds_vend_header.social_insurance_acivity_code := rcd_lads_ven_hdr.actss;
      rcd_bds_vend_header.tax_number_03 := rcd_lads_ven_hdr.stcd3;
      rcd_bds_vend_header.tax_number_04 := rcd_lads_ven_hdr.stcd4;
      rcd_bds_vend_header.tax_split := rcd_lads_ven_hdr.ipisp;
      rcd_bds_vend_header.profession := rcd_lads_ven_hdr.profs;
      rcd_bds_vend_header.statistics_group := rcd_lads_ven_hdr.stgdl;
      rcd_bds_vend_header.external_manu_code := rcd_lads_ven_hdr.emnfr;
      rcd_bds_vend_header.deletion_block_flag := rcd_lads_ven_hdr.nodel;
      rcd_bds_vend_header.url_code := rcd_lads_ven_hdr.lfurl;
      rcd_bds_vend_header.representative_name := rcd_lads_ven_hdr.j_1kfrepre;
      rcd_bds_vend_header.business_type := rcd_lads_ven_hdr.j_1kftbus;
      rcd_bds_vend_header.industry_type := rcd_lads_ven_hdr.j_1kftind;
      rcd_bds_vend_header.certification_valid_date := rcd_lads_ven_hdr.qssysdat;
      rcd_bds_vend_header.proof_of_delivery_flag := rcd_lads_ven_hdr.podkzb;
      rcd_bds_vend_header.tax_office_account_number := rcd_lads_ven_hdr.fisku;
      rcd_bds_vend_header.tax_office_tax_number := rcd_lads_ven_hdr.stenr;
      rcd_bds_vend_header.subledger_account_procedure := rcd_lads_ven_hdr.psois;
      rcd_bds_vend_header.person_01 := rcd_lads_ven_hdr.pson1;
      rcd_bds_vend_header.person_02 := rcd_lads_ven_hdr.pson2;
      rcd_bds_vend_header.person_03 := rcd_lads_ven_hdr.pson3;
      rcd_bds_vend_header.person_first_name := rcd_lads_ven_hdr.psovn;

      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_vend_header
         set sap_idoc_name = rcd_bds_vend_header.sap_idoc_name,
             sap_idoc_number = rcd_bds_vend_header.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_vend_header.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_vend_header.bds_lads_date,
             bds_lads_status = rcd_bds_vend_header.bds_lads_status,
             auth_group_code = rcd_bds_vend_header.auth_group_code,
             industry_code = rcd_bds_vend_header.industry_code,
             create_date = rcd_bds_vend_header.create_date,
             create_user = rcd_bds_vend_header.create_user,
             group_key = rcd_bds_vend_header.group_key,
             account_group_code = rcd_bds_vend_header.account_group_code,
             customer_code = rcd_bds_vend_header.customer_code,
             account_number = rcd_bds_vend_header.account_number,
             deletion_flag = rcd_bds_vend_header.deletion_flag,
             vendor_name_01 = rcd_bds_vend_header.vendor_name_01,
             vendor_name_02 = rcd_bds_vend_header.vendor_name_02,
             vendor_name_03 = rcd_bds_vend_header.vendor_name_03,
             vendor_name_04 = rcd_bds_vend_header.vendor_name_04,
             sort_value = rcd_bds_vend_header.sort_value,
             posting_block_flag = rcd_bds_vend_header.posting_block_flag,
             purchasing_block_flag = rcd_bds_vend_header.purchasing_block_flag,
             language_key = rcd_bds_vend_header.language_key,
             tax_number_01 = rcd_bds_vend_header.tax_number_01,
             tax_number_02 = rcd_bds_vend_header.tax_number_02,
             tax_equalization_flag = rcd_bds_vend_header.tax_equalization_flag,
             vat_flag = rcd_bds_vend_header.vat_flag,
             one_time_flag = rcd_bds_vend_header.one_time_flag,
             alternative_payee_flag = rcd_bds_vend_header.alternative_payee_flag,
             trading_partner_company_code = rcd_bds_vend_header.trading_partner_company_code,
             fiscal_account_number = rcd_bds_vend_header.fiscal_account_number,
             vat_registration_number = rcd_bds_vend_header.vat_registration_number,
             natural_person = rcd_bds_vend_header.natural_person,
             function_block = rcd_bds_vend_header.function_block,
             address_code = rcd_bds_vend_header.address_code,
             withhold_tax_birth_place = rcd_bds_vend_header.withhold_tax_birth_place,
             withhold_tax_birth_date = rcd_bds_vend_header.withhold_tax_birth_date,
             withhold_tax_sex = rcd_bds_vend_header.withhold_tax_sex,
             credit_information_number = rcd_bds_vend_header.credit_information_number,
             last_review_date = rcd_bds_vend_header.last_review_date,
             qm_system = rcd_bds_vend_header.qm_system,
             one_time_account_group = rcd_bds_vend_header.one_time_account_group,
             plant_code = rcd_bds_vend_header.plant_code,
             sub_range_flag = rcd_bds_vend_header.sub_range_flag,
             plant_level_flag = rcd_bds_vend_header.plant_level_flag,
             factory_calendar = rcd_bds_vend_header.factory_calendar,
             data_transfer_status = rcd_bds_vend_header.data_transfer_status,
             tax_jurisdiction_code = rcd_bds_vend_header.tax_jurisdiction_code,
             std_carrier_access_code = rcd_bds_vend_header.std_carrier_access_code,
             forward_agent_freight_group = rcd_bds_vend_header.forward_agent_freight_group,
             delivery_transport_zone = rcd_bds_vend_header.delivery_transport_zone,
             service_agent_procedure_group = rcd_bds_vend_header.service_agent_procedure_group,
             tax_type = rcd_bds_vend_header.tax_type,
             tax_number_type = rcd_bds_vend_header.tax_number_type,
             social_insurance_flag = rcd_bds_vend_header.social_insurance_flag,
             social_insurance_acivity_code = rcd_bds_vend_header.social_insurance_acivity_code,
             tax_number_03 = rcd_bds_vend_header.tax_number_03,
             tax_number_04 = rcd_bds_vend_header.tax_number_04,
             tax_split = rcd_bds_vend_header.tax_split,
             profession = rcd_bds_vend_header.profession,
             statistics_group = rcd_bds_vend_header.statistics_group,
             external_manu_code = rcd_bds_vend_header.external_manu_code,
             deletion_block_flag = rcd_bds_vend_header.deletion_block_flag,
             url_code = rcd_bds_vend_header.url_code,
             representative_name = rcd_bds_vend_header.representative_name,
             business_type = rcd_bds_vend_header.business_type,
             industry_type = rcd_bds_vend_header.industry_type,
             certification_valid_date = rcd_bds_vend_header.certification_valid_date,
             proof_of_delivery_flag = rcd_bds_vend_header.proof_of_delivery_flag,
             tax_office_account_number = rcd_bds_vend_header.tax_office_account_number,
             tax_office_tax_number = rcd_bds_vend_header.tax_office_tax_number,
             subledger_account_procedure = rcd_bds_vend_header.subledger_account_procedure,
             person_01 = rcd_bds_vend_header.person_01,
             person_02 = rcd_bds_vend_header.person_02,
             person_03 = rcd_bds_vend_header.person_03,
             person_first_name = rcd_bds_vend_header.person_first_name
         where vendor_code = rcd_bds_vend_header.vendor_code;
      if sql%notfound then
         insert into bds_vend_header
            (vendor_code,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             auth_group_code,
             industry_code,
             create_date,
             create_user,
             group_key,
             account_group_code,
             customer_code,
             account_number,
             deletion_flag,
             vendor_name_01,
             vendor_name_02,
             vendor_name_03,
             vendor_name_04,
             sort_value,
             posting_block_flag,
             purchasing_block_flag,
             language_key,
             tax_number_01,
             tax_number_02,
             tax_equalization_flag,
             vat_flag,
             one_time_flag,
             alternative_payee_flag,
             trading_partner_company_code,
             fiscal_account_number,
             vat_registration_number,
             natural_person,
             function_block,
             address_code,
             withhold_tax_birth_place,
             withhold_tax_birth_date,
             withhold_tax_sex,
             credit_information_number,
             last_review_date,
             qm_system,
             one_time_account_group,
             plant_code,
             sub_range_flag,
             plant_level_flag,
             factory_calendar,
             data_transfer_status,
             tax_jurisdiction_code,
             std_carrier_access_code,
             forward_agent_freight_group,
             delivery_transport_zone,
             service_agent_procedure_group,
             tax_type,
             tax_number_type,
             social_insurance_flag,
             social_insurance_acivity_code,
             tax_number_03,
             tax_number_04,
             tax_split,
             profession,
             statistics_group,
             external_manu_code,
             deletion_block_flag,
             url_code,
             representative_name,
             business_type,
             industry_type,
             certification_valid_date,
             proof_of_delivery_flag,
             tax_office_account_number,
             tax_office_tax_number,
             subledger_account_procedure,
             person_01,
             person_02,
             person_03,
             person_first_name)
             values(rcd_bds_vend_header.vendor_code,
                    rcd_bds_vend_header.sap_idoc_name,
                    rcd_bds_vend_header.sap_idoc_number,
                    rcd_bds_vend_header.sap_idoc_timestamp,
                    rcd_bds_vend_header.bds_lads_date,
                    rcd_bds_vend_header.bds_lads_status,
                    rcd_bds_vend_header.auth_group_code,
                    rcd_bds_vend_header.industry_code,
                    rcd_bds_vend_header.create_date,
                    rcd_bds_vend_header.create_user,
                    rcd_bds_vend_header.group_key,
                    rcd_bds_vend_header.account_group_code,
                    rcd_bds_vend_header.customer_code,
                    rcd_bds_vend_header.account_number,
                    rcd_bds_vend_header.deletion_flag,
                    rcd_bds_vend_header.vendor_name_01,
                    rcd_bds_vend_header.vendor_name_02,
                    rcd_bds_vend_header.vendor_name_03,
                    rcd_bds_vend_header.vendor_name_04,
                    rcd_bds_vend_header.sort_value,
                    rcd_bds_vend_header.posting_block_flag,
                    rcd_bds_vend_header.purchasing_block_flag,
                    rcd_bds_vend_header.language_key,
                    rcd_bds_vend_header.tax_number_01,
                    rcd_bds_vend_header.tax_number_02,
                    rcd_bds_vend_header.tax_equalization_flag,
                    rcd_bds_vend_header.vat_flag,
                    rcd_bds_vend_header.one_time_flag,
                    rcd_bds_vend_header.alternative_payee_flag,
                    rcd_bds_vend_header.trading_partner_company_code,
                    rcd_bds_vend_header.fiscal_account_number,
                    rcd_bds_vend_header.vat_registration_number,
                    rcd_bds_vend_header.natural_person,
                    rcd_bds_vend_header.function_block,
                    rcd_bds_vend_header.address_code,
                    rcd_bds_vend_header.withhold_tax_birth_place,
                    rcd_bds_vend_header.withhold_tax_birth_date,
                    rcd_bds_vend_header.withhold_tax_sex,
                    rcd_bds_vend_header.credit_information_number,
                    rcd_bds_vend_header.last_review_date,
                    rcd_bds_vend_header.qm_system,
                    rcd_bds_vend_header.one_time_account_group,
                    rcd_bds_vend_header.plant_code,
                    rcd_bds_vend_header.sub_range_flag,
                    rcd_bds_vend_header.plant_level_flag,
                    rcd_bds_vend_header.factory_calendar,
                    rcd_bds_vend_header.data_transfer_status,
                    rcd_bds_vend_header.tax_jurisdiction_code,
                    rcd_bds_vend_header.std_carrier_access_code,
                    rcd_bds_vend_header.forward_agent_freight_group,
                    rcd_bds_vend_header.delivery_transport_zone,
                    rcd_bds_vend_header.service_agent_procedure_group,
                    rcd_bds_vend_header.tax_type,
                    rcd_bds_vend_header.tax_number_type,
                    rcd_bds_vend_header.social_insurance_flag,
                    rcd_bds_vend_header.social_insurance_acivity_code,
                    rcd_bds_vend_header.tax_number_03,
                    rcd_bds_vend_header.tax_number_04,
                    rcd_bds_vend_header.tax_split,
                    rcd_bds_vend_header.profession,
                    rcd_bds_vend_header.statistics_group,
                    rcd_bds_vend_header.external_manu_code,
                    rcd_bds_vend_header.deletion_block_flag,
                    rcd_bds_vend_header.url_code,
                    rcd_bds_vend_header.representative_name,
                    rcd_bds_vend_header.business_type,
                    rcd_bds_vend_header.industry_type,
                    rcd_bds_vend_header.certification_valid_date,
                    rcd_bds_vend_header.proof_of_delivery_flag,
                    rcd_bds_vend_header.tax_office_account_number,
                    rcd_bds_vend_header.tax_office_tax_number,
                    rcd_bds_vend_header.subledger_account_procedure,
                    rcd_bds_vend_header.person_01,
                    rcd_bds_vend_header.person_02,
                    rcd_bds_vend_header.person_03,
                    rcd_bds_vend_header.person_first_name);
      end if;

      /*-*/
      /* Process the LADS vendor text
      /*-*/
      open csr_lads_ven_txh;
      loop
         fetch csr_lads_ven_txh into rcd_lads_ven_txh;
         if csr_lads_ven_txh%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_vend_text.vendor_code := rcd_lads_ven_txh.lifnr;
         rcd_bds_vend_text.text_object := rcd_lads_ven_txh.tdobject;
         rcd_bds_vend_text.text_name := rcd_lads_ven_txh.tdname;
         rcd_bds_vend_text.text_id := rcd_lads_ven_txh.tdid;
         rcd_bds_vend_text.text_language := rcd_lads_ven_txh.tdspras;
         rcd_bds_vend_text.text_type := rcd_lads_ven_txh.tdtexttype;
         rcd_bds_vend_text.text_language_iso := rcd_lads_ven_txh.tdsprasiso;
         rcd_bds_vend_text.text_line := null;
         
         /*-*/
         /* Retrieve the LADS vendor text line
         /*-*/
         open csr_lads_ven_txl;
         loop
            fetch csr_lads_ven_txl into rcd_lads_ven_txl;
            if csr_lads_ven_txl%notfound or
               (length(rcd_bds_vend_text.text_line) + length(rcd_lads_ven_txl.tdline)) > 2000 then
               exit;
            end if;
            rcd_bds_vend_text.text_line := rcd_bds_vend_text.text_line||' '||rcd_lads_ven_txl.tdline;
         end loop;
         close csr_lads_ven_txl;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_vend_text
            (vendor_code,
             text_object,
             text_name,
             text_id,
             text_language,
             text_type,
             text_language_iso,
             text_line)
             values(rcd_bds_vend_text.vendor_code,
                    rcd_bds_vend_text.text_object,
                    rcd_bds_vend_text.text_name,
                    rcd_bds_vend_text.text_id,
                    rcd_bds_vend_text.text_language,
                    rcd_bds_vend_text.text_type,
                    rcd_bds_vend_text.text_language_iso,
                    rcd_bds_vend_text.text_line);

      end loop;
      close csr_lads_ven_txh;

      /*-*/
      /* Process the LADS vendor bank
      /*-*/
      open csr_lads_ven_bnk;
      loop
         fetch csr_lads_ven_bnk into rcd_lads_ven_bnk;
         if csr_lads_ven_bnk%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_vend_bank.vendor_code := rcd_lads_ven_bnk.lifnr;
         rcd_bds_vend_bank.bank_country_key := rcd_lads_ven_bnk.banks;
         rcd_bds_vend_bank.bank_number := rcd_lads_ven_bnk.bankl;
         rcd_bds_vend_bank.bank_account_number := rcd_lads_ven_bnk.bankn;
         rcd_bds_vend_bank.bank_control_key := rcd_lads_ven_bnk.bkont;
         rcd_bds_vend_bank.partner_bank_type := rcd_lads_ven_bnk.bvtyp;
         rcd_bds_vend_bank.collection_auth_flag := rcd_lads_ven_bnk.xezer;
         rcd_bds_vend_bank.bank_name := rcd_lads_ven_bnk.banka;
         rcd_bds_vend_bank.location := rcd_lads_ven_bnk.ort01;
         rcd_bds_vend_bank.swift_code := rcd_lads_ven_bnk.swift;
         rcd_bds_vend_bank.bank_group := rcd_lads_ven_bnk.bgrup;
         rcd_bds_vend_bank.checkbox := rcd_lads_ven_bnk.xpgro;
         rcd_bds_vend_bank.bank_number_bnklz := rcd_lads_ven_bnk.bnklz;
         rcd_bds_vend_bank.po_current_account_number := rcd_lads_ven_bnk.pskto;
         rcd_bds_vend_bank.bank_detail_reference := rcd_lads_ven_bnk.bkref;
         rcd_bds_vend_bank.bank_branch := rcd_lads_ven_bnk.brnch;
         rcd_bds_vend_bank.region := rcd_lads_ven_bnk.prov2;
         rcd_bds_vend_bank.address_street := rcd_lads_ven_bnk.stra2;
         rcd_bds_vend_bank.address_city := rcd_lads_ven_bnk.ort02;
         rcd_bds_vend_bank.account_holder_name := rcd_lads_ven_bnk.koinh;
         rcd_bds_vend_bank.batch_input_date_kovon := rcd_lads_ven_bnk.kovon;
         rcd_bds_vend_bank.batch_input_date_kobis := rcd_lads_ven_bnk.kobis;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_vend_bank
            (vendor_code,
             bank_country_key,
             bank_number,
             bank_account_number,
             bank_control_key,
             partner_bank_type,
             collection_auth_flag,
             bank_name,
             location,
             swift_code,
             bank_group,
             checkbox,
             bank_number_bnklz,
             po_current_account_number,
             bank_detail_reference,
             bank_branch,
             region,
             address_street,
             address_city,
             account_holder_name,
             batch_input_date_kovon,
             batch_input_date_kobis)
             values(rcd_bds_vend_bank.vendor_code,
                    rcd_bds_vend_bank.bank_country_key,
                    rcd_bds_vend_bank.bank_number,
                    rcd_bds_vend_bank.bank_account_number,
                    rcd_bds_vend_bank.bank_control_key,
                    rcd_bds_vend_bank.partner_bank_type,
                    rcd_bds_vend_bank.collection_auth_flag,
                    rcd_bds_vend_bank.bank_name,
                    rcd_bds_vend_bank.location,
                    rcd_bds_vend_bank.swift_code,
                    rcd_bds_vend_bank.bank_group,
                    rcd_bds_vend_bank.checkbox,
                    rcd_bds_vend_bank.bank_number_bnklz,
                    rcd_bds_vend_bank.po_current_account_number,
                    rcd_bds_vend_bank.bank_detail_reference,
                    rcd_bds_vend_bank.bank_branch,
                    rcd_bds_vend_bank.region,
                    rcd_bds_vend_bank.address_street,
                    rcd_bds_vend_bank.address_city,
                    rcd_bds_vend_bank.account_holder_name,
                    rcd_bds_vend_bank.batch_input_date_kovon,
                    rcd_bds_vend_bank.batch_input_date_kobis);

      end loop;
      close csr_lads_ven_bnk;

      /*-*/
      /* Process the LADS vendor company
      /*-*/
      open csr_lads_ven_ccd;
      loop
         fetch csr_lads_ven_ccd into rcd_lads_ven_ccd;
         if csr_lads_ven_ccd%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_vend_comp.vendor_code := rcd_lads_ven_ccd.lifnr;
         rcd_bds_vend_comp.company_code := rcd_lads_ven_ccd.bukrs;
         rcd_bds_vend_comp.create_date := rcd_lads_ven_ccd.erdat;
         rcd_bds_vend_comp.create_user := rcd_lads_ven_ccd.ernam;
         rcd_bds_vend_comp.posting_block_flag := rcd_lads_ven_ccd.sperr;
         rcd_bds_vend_comp.deletion_flag := rcd_lads_ven_ccd.loevm;
         rcd_bds_vend_comp.assignment_sort_key := rcd_lads_ven_ccd.zuawa;
         rcd_bds_vend_comp.reconciliation_account := rcd_lads_ven_ccd.akont;
         rcd_bds_vend_comp.authorisation_group := rcd_lads_ven_ccd.begru;
         rcd_bds_vend_comp.interest_calc_ind := rcd_lads_ven_ccd.vzskz;
         rcd_bds_vend_comp.payment_method := rcd_lads_ven_ccd.zwels;
         rcd_bds_vend_comp.clearing_flag := rcd_lads_ven_ccd.xverr;
         rcd_bds_vend_comp.payment_block_flag := rcd_lads_ven_ccd.zahls;
         rcd_bds_vend_comp.payment_terms := rcd_lads_ven_ccd.zterm;
         rcd_bds_vend_comp.shipper_account := rcd_lads_ven_ccd.eikto;
         rcd_bds_vend_comp.vendor_clerk := rcd_lads_ven_ccd.zsabe;
         rcd_bds_vend_comp.planning_group := rcd_lads_ven_ccd.fdgrv;
         rcd_bds_vend_comp.account_clerk_code := rcd_lads_ven_ccd.busab;
         rcd_bds_vend_comp.head_office_account := rcd_lads_ven_ccd.lnrze;
         rcd_bds_vend_comp.alternative_payee_account := rcd_lads_ven_ccd.lnrzb;
         rcd_bds_vend_comp.interest_calc_key_date := rcd_lads_ven_ccd.zindt;
         rcd_bds_vend_comp.interest_calc_freq := rcd_lads_ven_ccd.zinrt;
         rcd_bds_vend_comp.nterest_calc_run_date := rcd_lads_ven_ccd.datlz;
         rcd_bds_vend_comp.local_process_flag := rcd_lads_ven_ccd.xdezv;
         rcd_bds_vend_comp.bill_of_exchange_limit := rcd_lads_ven_ccd.webtr;
         rcd_bds_vend_comp.probable_check_paid_time := rcd_lads_ven_ccd.kultg;
         rcd_bds_vend_comp.inv_crd_check_flag := rcd_lads_ven_ccd.reprf;
         rcd_bds_vend_comp.tolerance_group_code := rcd_lads_ven_ccd.togru;
         rcd_bds_vend_comp.house_bank_key := rcd_lads_ven_ccd.hbkid;
         rcd_bds_vend_comp.pay_item_separate_flag := rcd_lads_ven_ccd.xpore;
         rcd_bds_vend_comp.withhold_tax_certificate := rcd_lads_ven_ccd.qsznr;
         rcd_bds_vend_comp.withhold_tax_valid_date := rcd_lads_ven_ccd.qszdt;
         rcd_bds_vend_comp.withhold_tax_code := rcd_lads_ven_ccd.qsskz;
         rcd_bds_vend_comp.subsidy_flag := rcd_lads_ven_ccd.blnkz;
         rcd_bds_vend_comp.minority_indicator := rcd_lads_ven_ccd.mindk;
         rcd_bds_vend_comp.previous_record_number := rcd_lads_ven_ccd.altkn;
         rcd_bds_vend_comp.payment_grouping_code := rcd_lads_ven_ccd.zgrup;
         rcd_bds_vend_comp.dunning_notice_group_code := rcd_lads_ven_ccd.mgrup;
         rcd_bds_vend_comp.recipient_type := rcd_lads_ven_ccd.qsrec;
         rcd_bds_vend_comp.withhold_tax_exemption := rcd_lads_ven_ccd.qsbgr;
         rcd_bds_vend_comp.withhold_tax_country := rcd_lads_ven_ccd.qland;
         rcd_bds_vend_comp.edi_payment_advice := rcd_lads_ven_ccd.xedip;
         rcd_bds_vend_comp.release_approval_group := rcd_lads_ven_ccd.frgrp;
         rcd_bds_vend_comp.accounting_fax := rcd_lads_ven_ccd.tlfxs;
         rcd_bds_vend_comp.accounting_url := rcd_lads_ven_ccd.intad;
         rcd_bds_vend_comp.credit_payment_terms := rcd_lads_ven_ccd.guzte;
         rcd_bds_vend_comp.income_tax_activity_code := rcd_lads_ven_ccd.gricd;
         rcd_bds_vend_comp.employ_tax_distbn_type := rcd_lads_ven_ccd.gridt;
         rcd_bds_vend_comp.periodic_account_statement := rcd_lads_ven_ccd.xausz;
         rcd_bds_vend_comp.certification_date := rcd_lads_ven_ccd.cerdt;
         rcd_bds_vend_comp.invoice_tolerance_group := rcd_lads_ven_ccd.togrr;
         rcd_bds_vend_comp.personnel_number := rcd_lads_ven_ccd.pernr;
         rcd_bds_vend_comp.deletion_block_flag := rcd_lads_ven_ccd.nodel;
         rcd_bds_vend_comp.accounting_phone := rcd_lads_ven_ccd.tlfns;
         rcd_bds_vend_comp.execution_flag := rcd_lads_ven_ccd.gmvkzk;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_vend_comp
            (vendor_code,
             company_code,
             create_date,
             create_user,
             posting_block_flag,
             deletion_flag,
             assignment_sort_key,
             reconciliation_account,
             authorisation_group,
             interest_calc_ind,
             payment_method,
             clearing_flag,
             payment_block_flag,
             payment_terms,
             shipper_account,
             vendor_clerk,
             planning_group,
             account_clerk_code,
             head_office_account,
             alternative_payee_account,
             interest_calc_key_date,
             interest_calc_freq,
             nterest_calc_run_date,
             local_process_flag,
             bill_of_exchange_limit,
             probable_check_paid_time,
             inv_crd_check_flag,
             tolerance_group_code,
             house_bank_key,
             pay_item_separate_flag,
             withhold_tax_certificate,
             withhold_tax_valid_date,
             withhold_tax_code,
             subsidy_flag,
             minority_indicator,
             previous_record_number,
             payment_grouping_code,
             dunning_notice_group_code,
             recipient_type,
             withhold_tax_exemption,
             withhold_tax_country,
             edi_payment_advice,
             release_approval_group,
             accounting_fax,
             accounting_url,
             credit_payment_terms,
             income_tax_activity_code,
             employ_tax_distbn_type,
             periodic_account_statement,
             certification_date,
             invoice_tolerance_group,
             personnel_number,
             deletion_block_flag,
             accounting_phone,
             execution_flag,
             vendor_name_01,
             vendor_name_02,
             vendor_name_03,
             vendor_name_04)
             values(rcd_bds_vend_comp.vendor_code,
                    rcd_bds_vend_comp.company_code,
                    rcd_bds_vend_comp.create_date,
                    rcd_bds_vend_comp.create_user,
                    rcd_bds_vend_comp.posting_block_flag,
                    rcd_bds_vend_comp.deletion_flag,
                    rcd_bds_vend_comp.assignment_sort_key,
                    rcd_bds_vend_comp.reconciliation_account,
                    rcd_bds_vend_comp.authorisation_group,
                    rcd_bds_vend_comp.interest_calc_ind,
                    rcd_bds_vend_comp.payment_method,
                    rcd_bds_vend_comp.clearing_flag,
                    rcd_bds_vend_comp.payment_block_flag,
                    rcd_bds_vend_comp.payment_terms,
                    rcd_bds_vend_comp.shipper_account,
                    rcd_bds_vend_comp.vendor_clerk,
                    rcd_bds_vend_comp.planning_group,
                    rcd_bds_vend_comp.account_clerk_code,
                    rcd_bds_vend_comp.head_office_account,
                    rcd_bds_vend_comp.alternative_payee_account,
                    rcd_bds_vend_comp.interest_calc_key_date,
                    rcd_bds_vend_comp.interest_calc_freq,
                    rcd_bds_vend_comp.nterest_calc_run_date,
                    rcd_bds_vend_comp.local_process_flag,
                    rcd_bds_vend_comp.bill_of_exchange_limit,
                    rcd_bds_vend_comp.probable_check_paid_time,
                    rcd_bds_vend_comp.inv_crd_check_flag,
                    rcd_bds_vend_comp.tolerance_group_code,
                    rcd_bds_vend_comp.house_bank_key,
                    rcd_bds_vend_comp.pay_item_separate_flag,
                    rcd_bds_vend_comp.withhold_tax_certificate,
                    rcd_bds_vend_comp.withhold_tax_valid_date,
                    rcd_bds_vend_comp.withhold_tax_code,
                    rcd_bds_vend_comp.subsidy_flag,
                    rcd_bds_vend_comp.minority_indicator,
                    rcd_bds_vend_comp.previous_record_number,
                    rcd_bds_vend_comp.payment_grouping_code,
                    rcd_bds_vend_comp.dunning_notice_group_code,
                    rcd_bds_vend_comp.recipient_type,
                    rcd_bds_vend_comp.withhold_tax_exemption,
                    rcd_bds_vend_comp.withhold_tax_country,
                    rcd_bds_vend_comp.edi_payment_advice,
                    rcd_bds_vend_comp.release_approval_group,
                    rcd_bds_vend_comp.accounting_fax,
                    rcd_bds_vend_comp.accounting_url,
                    rcd_bds_vend_comp.credit_payment_terms,
                    rcd_bds_vend_comp.income_tax_activity_code,
                    rcd_bds_vend_comp.employ_tax_distbn_type,
                    rcd_bds_vend_comp.periodic_account_statement,
                    rcd_bds_vend_comp.certification_date,
                    rcd_bds_vend_comp.invoice_tolerance_group,
                    rcd_bds_vend_comp.personnel_number,
                    rcd_bds_vend_comp.deletion_block_flag,
                    rcd_bds_vend_comp.accounting_phone,
                    rcd_bds_vend_comp.execution_flag,
                    rcd_bds_vend_header.vendor_name_01,
                    rcd_bds_vend_header.vendor_name_02,
                    rcd_bds_vend_header.vendor_name_03,
                    rcd_bds_vend_header.vendor_name_04);

         /*-*/
         /* Process the LADS vendor company withholding tax
         /*-*/
         open csr_lads_ven_wtx;
         loop
            fetch csr_lads_ven_wtx into rcd_lads_ven_wtx;
            if csr_lads_ven_wtx%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_vend_comp_whtax.vendor_code := rcd_lads_ven_ccd.lifnr;
            rcd_bds_vend_comp_whtax.company_code := rcd_lads_ven_ccd.bukrs;
            rcd_bds_vend_comp_whtax.withhold_tax_type := rcd_lads_ven_wtx.witht;
            rcd_bds_vend_comp_whtax.withhold_tax_flag := rcd_lads_ven_wtx.wt_subjct;
            rcd_bds_vend_comp_whtax.withhold_tax_recipient_type := rcd_lads_ven_wtx.qsrec;
            rcd_bds_vend_comp_whtax.withhold_tax_identification := rcd_lads_ven_wtx.wt_wtstcd;
            rcd_bds_vend_comp_whtax.withhold_tax_code := rcd_lads_ven_wtx.wt_withcd;
            rcd_bds_vend_comp_whtax.withhold_tax_exemption := rcd_lads_ven_wtx.wt_exnr;
            rcd_bds_vend_comp_whtax.withhold_tax_rate := rcd_lads_ven_wtx.wt_exrt;
            rcd_bds_vend_comp_whtax.withhold_tax_from_date := rcd_lads_ven_wtx.wt_exdf;
            rcd_bds_vend_comp_whtax.withhold_tax_to_date := rcd_lads_ven_wtx.wt_exdt;
            rcd_bds_vend_comp_whtax.withhold_tax_exemption_reason := rcd_lads_ven_wtx.wt_wtexrs;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_vend_comp_whtax
               (vendor_code,
                company_code,
                withhold_tax_type,
                withhold_tax_code,
                withhold_tax_from_date,
                withhold_tax_to_date,
                withhold_tax_flag,
                withhold_tax_recipient_type,
                withhold_tax_identification,
                withhold_tax_exemption,
                withhold_tax_rate,
                withhold_tax_exemption_reason)
                values(rcd_bds_vend_comp_whtax.vendor_code,
                       rcd_bds_vend_comp_whtax.company_code,
                       rcd_bds_vend_comp_whtax.withhold_tax_type,
                       rcd_bds_vend_comp_whtax.withhold_tax_code,
                       rcd_bds_vend_comp_whtax.withhold_tax_from_date,
                       rcd_bds_vend_comp_whtax.withhold_tax_to_date,
                       rcd_bds_vend_comp_whtax.withhold_tax_flag,
                       rcd_bds_vend_comp_whtax.withhold_tax_recipient_type,
                       rcd_bds_vend_comp_whtax.withhold_tax_identification,
                       rcd_bds_vend_comp_whtax.withhold_tax_exemption,
                       rcd_bds_vend_comp_whtax.withhold_tax_rate,
                       rcd_bds_vend_comp_whtax.withhold_tax_exemption_reason);

         end loop;
         close csr_lads_ven_wtx;

         /*-*/
         /* Process the LADS vendor company text
         /*-*/
         open csr_lads_ven_ctx;
         loop
            fetch csr_lads_ven_ctx into rcd_lads_ven_ctx;
            if csr_lads_ven_ctx%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_vend_comp_text.vendor_code := rcd_lads_ven_ccd.lifnr;
            rcd_bds_vend_comp_text.company_code := rcd_lads_ven_ccd.bukrs;
            rcd_bds_vend_comp_text.text_object := rcd_lads_ven_ctx.tdobject;
            rcd_bds_vend_comp_text.text_name := rcd_lads_ven_ctx.tdname;
            rcd_bds_vend_comp_text.text_id := rcd_lads_ven_ctx.tdid;
            rcd_bds_vend_comp_text.text_language := rcd_lads_ven_ctx.tdspras;
            rcd_bds_vend_comp_text.text_type := rcd_lads_ven_ctx.tdtexttype;
            rcd_bds_vend_comp_text.text_language_iso := rcd_lads_ven_ctx.tdsprasiso;
            rcd_bds_vend_comp_text.text_line := null;
         
            /*-*/
            /* Retrieve the LADS vendor company text line
            /*-*/
            open csr_lads_ven_ctd;
            loop
               fetch csr_lads_ven_ctd into rcd_lads_ven_ctd;
               if csr_lads_ven_ctd%notfound or
                  (length(rcd_bds_vend_comp_text.text_line) + length(rcd_lads_ven_ctd.tdline)) > 2000 then
                  exit;
               end if;
               rcd_bds_vend_comp_text.text_line := rcd_bds_vend_comp_text.text_line||' '||rcd_lads_ven_ctd.tdline;
            end loop;
            close csr_lads_ven_ctd;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_vend_comp_text
               (vendor_code,
                company_code,
                text_object,
                text_name,
                text_id,
                text_language,
                text_type,
                text_language_iso,
                text_line)
                values(rcd_bds_vend_comp_text.vendor_code,
                       rcd_bds_vend_comp_text.company_code,
                       rcd_bds_vend_comp_text.text_object,
                       rcd_bds_vend_comp_text.text_name,
                       rcd_bds_vend_comp_text.text_id,
                       rcd_bds_vend_comp_text.text_language,
                       rcd_bds_vend_comp_text.text_type,
                       rcd_bds_vend_comp_text.text_language_iso,
                       rcd_bds_vend_comp_text.text_line);

         end loop;
         close csr_lads_ven_ctx;

         /*-*/
         /* Process the LADS vendor company mars data
         /*-*/
         open csr_lads_ven_zcc;
         loop
            fetch csr_lads_ven_zcc into rcd_lads_ven_zcc;
            if csr_lads_ven_zcc%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_vend_comp_mars.vendor_code := rcd_lads_ven_ccd.lifnr;
            rcd_bds_vend_comp_mars.company_code := rcd_lads_ven_ccd.bukrs;
            rcd_bds_vend_comp_mars.transmission_medium := rcd_lads_ven_zcc.zpytadv;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_vend_comp_mars
               (vendor_code,
                company_code,
                transmission_medium)
                values(rcd_bds_vend_comp_mars.vendor_code,
                       rcd_bds_vend_comp_mars.company_code,
                       rcd_bds_vend_comp_mars.transmission_medium);

         end loop;
         close csr_lads_ven_zcc;

      end loop;
      close csr_lads_ven_ccd;

      /*-*/
      /* Process the LADS vendor purchasing
      /*-*/
      open csr_lads_ven_poh;
      loop
         fetch csr_lads_ven_poh into rcd_lads_ven_poh;
         if csr_lads_ven_poh%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_vend_purch.vendor_code := rcd_lads_ven_poh.lifnr;
         rcd_bds_vend_purch.purch_org_code := rcd_lads_ven_poh.ekorg;
         rcd_bds_vend_purch.create_date := rcd_lads_ven_poh.erdat;
         rcd_bds_vend_purch.create_user := rcd_lads_ven_poh.ernam;
         rcd_bds_vend_purch.purchase_block_flag := rcd_lads_ven_poh.sperm;
         rcd_bds_vend_purch.deletion_flag := rcd_lads_ven_poh.loevm;
         rcd_bds_vend_purch.abc_flag := rcd_lads_ven_poh.lfabc;
         rcd_bds_vend_purch.purch_ord_currency := rcd_lads_ven_poh.waers;
         rcd_bds_vend_purch.vendor_salesperson := rcd_lads_ven_poh.verkf;
         rcd_bds_vend_purch.vendor_phone := rcd_lads_ven_poh.telf1;
         rcd_bds_vend_purch.order_value_minimum := rcd_lads_ven_poh.minbw;
         rcd_bds_vend_purch.payment_terms := rcd_lads_ven_poh.zterm;
         rcd_bds_vend_purch.inter_company_terms_01 := rcd_lads_ven_poh.inco1;
         rcd_bds_vend_purch.inter_company_terms_02 := rcd_lads_ven_poh.inco2;
         rcd_bds_vend_purch.invoice_verify_flag := rcd_lads_ven_poh.webre;
         rcd_bds_vend_purch.order_acknowledgment_flag := rcd_lads_ven_poh.kzabs;
         rcd_bds_vend_purch.calc_schema_group := rcd_lads_ven_poh.kalsk;
         rcd_bds_vend_purch.purch_order_auto_gen_flag := rcd_lads_ven_poh.kzaut;
         rcd_bds_vend_purch.foreign_transport_mode := rcd_lads_ven_poh.expvz;
         rcd_bds_vend_purch.foreign_custom_office := rcd_lads_ven_poh.zolla;
         rcd_bds_vend_purch.price_date_category := rcd_lads_ven_poh.meprf;
         rcd_bds_vend_purch.purch_group_code := rcd_lads_ven_poh.ekgrp;
         rcd_bds_vend_purch.subsequent_settlement_flag := rcd_lads_ven_poh.bolre;
         rcd_bds_vend_purch.business_volumes_flag := rcd_lads_ven_poh.umsae;
         rcd_bds_vend_purch.ers_flag := rcd_lads_ven_poh.xersy;
         rcd_bds_vend_purch.planned_delivery_days := rcd_lads_ven_poh.plifz;
         rcd_bds_vend_purch.planning_calendar := rcd_lads_ven_poh.mrppp;
         rcd_bds_vend_purch.planning_cyle := rcd_lads_ven_poh.lfrhy;
         rcd_bds_vend_purch.delivery_cycle := rcd_lads_ven_poh.liefr;
         rcd_bds_vend_purch.vendor_order_entry_flag := rcd_lads_ven_poh.libes;
         rcd_bds_vend_purch.vendor_price_marking := rcd_lads_ven_poh.lipre;
         rcd_bds_vend_purch.rack_jobbing := rcd_lads_ven_poh.liser;
         rcd_bds_vend_purch.ssindex_compilation_flag := rcd_lads_ven_poh.boind;
         rcd_bds_vend_purch.vendor_hierarchy_flag := rcd_lads_ven_poh.prfre;
         rcd_bds_vend_purch.discount_in_kind_flag := rcd_lads_ven_poh.nrgew;
         rcd_bds_vend_purch.poindex_compilation_flag := rcd_lads_ven_poh.blind;
         rcd_bds_vend_purch.returns_flag := rcd_lads_ven_poh.kzret;
         rcd_bds_vend_purch.material_sort_criteria := rcd_lads_ven_poh.skrit;
         rcd_bds_vend_purch.confirm_control_key := rcd_lads_ven_poh.bstae;
         rcd_bds_vend_purch.rounding_profile := rcd_lads_ven_poh.rdprf;
         rcd_bds_vend_purch.uom_group := rcd_lads_ven_poh.megru;
         rcd_bds_vend_purch.vendor_service_level := rcd_lads_ven_poh.vensl;
         rcd_bds_vend_purch.restriction_profile := rcd_lads_ven_poh.bopnr;
         rcd_bds_vend_purch.auto_eval_receipt_flag := rcd_lads_ven_poh.xersr;
         rcd_bds_vend_purch.vendor_mars_account := rcd_lads_ven_poh.eikto;
         rcd_bds_vend_purch.idoc_profile := rcd_lads_ven_poh.paprf;
         rcd_bds_vend_purch.agency_business_flag := rcd_lads_ven_poh.agrel;
         rcd_bds_vend_purch.revaluation_flag := rcd_lads_ven_poh.xnbwy;
         rcd_bds_vend_purch.ship_conditions := rcd_lads_ven_poh.vsbed;
         rcd_bds_vend_purch.service_invoice_verify_flag := rcd_lads_ven_poh.lebre;
         rcd_bds_vend_purch.minimum_order_value := rcd_lads_ven_poh.minbw2;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_vend_purch
            (vendor_code,
             purch_org_code,
             create_date,
             create_user,
             purchase_block_flag,
             deletion_flag,
             abc_flag,
             purch_ord_currency,
             vendor_salesperson,
             vendor_phone,
             order_value_minimum,
             payment_terms,
             inter_company_terms_01,
             inter_company_terms_02,
             invoice_verify_flag,
             order_acknowledgment_flag,
             calc_schema_group,
             purch_order_auto_gen_flag,
             foreign_transport_mode,
             foreign_custom_office,
             price_date_category,
             purch_group_code,
             subsequent_settlement_flag,
             business_volumes_flag,
             ers_flag,
             planned_delivery_days,
             planning_calendar,
             planning_cyle,
             delivery_cycle,
             vendor_order_entry_flag,
             vendor_price_marking,
             rack_jobbing,
             ssindex_compilation_flag,
             vendor_hierarchy_flag,
             discount_in_kind_flag,
             poindex_compilation_flag,
             returns_flag,
             material_sort_criteria,
             confirm_control_key,
             rounding_profile,
             uom_group,
             vendor_service_level,
             restriction_profile,
             auto_eval_receipt_flag,
             vendor_mars_account,
             idoc_profile,
             agency_business_flag,
             revaluation_flag,
             ship_conditions,
             service_invoice_verify_flag,
             minimum_order_value)
             values(rcd_bds_vend_purch.vendor_code,
                    rcd_bds_vend_purch.purch_org_code,
                    rcd_bds_vend_purch.create_date,
                    rcd_bds_vend_purch.create_user,
                    rcd_bds_vend_purch.purchase_block_flag,
                    rcd_bds_vend_purch.deletion_flag,
                    rcd_bds_vend_purch.abc_flag,
                    rcd_bds_vend_purch.purch_ord_currency,
                    rcd_bds_vend_purch.vendor_salesperson,
                    rcd_bds_vend_purch.vendor_phone,
                    rcd_bds_vend_purch.order_value_minimum,
                    rcd_bds_vend_purch.payment_terms,
                    rcd_bds_vend_purch.inter_company_terms_01,
                    rcd_bds_vend_purch.inter_company_terms_02,
                    rcd_bds_vend_purch.invoice_verify_flag,
                    rcd_bds_vend_purch.order_acknowledgment_flag,
                    rcd_bds_vend_purch.calc_schema_group,
                    rcd_bds_vend_purch.purch_order_auto_gen_flag,
                    rcd_bds_vend_purch.foreign_transport_mode,
                    rcd_bds_vend_purch.foreign_custom_office,
                    rcd_bds_vend_purch.price_date_category,
                    rcd_bds_vend_purch.purch_group_code,
                    rcd_bds_vend_purch.subsequent_settlement_flag,
                    rcd_bds_vend_purch.business_volumes_flag,
                    rcd_bds_vend_purch.ers_flag,
                    rcd_bds_vend_purch.planned_delivery_days,
                    rcd_bds_vend_purch.planning_calendar,
                    rcd_bds_vend_purch.planning_cyle,
                    rcd_bds_vend_purch.delivery_cycle,
                    rcd_bds_vend_purch.vendor_order_entry_flag,
                    rcd_bds_vend_purch.vendor_price_marking,
                    rcd_bds_vend_purch.rack_jobbing,
                    rcd_bds_vend_purch.ssindex_compilation_flag,
                    rcd_bds_vend_purch.vendor_hierarchy_flag,
                    rcd_bds_vend_purch.discount_in_kind_flag,
                    rcd_bds_vend_purch.poindex_compilation_flag,
                    rcd_bds_vend_purch.returns_flag,
                    rcd_bds_vend_purch.material_sort_criteria,
                    rcd_bds_vend_purch.confirm_control_key,
                    rcd_bds_vend_purch.rounding_profile,
                    rcd_bds_vend_purch.uom_group,
                    rcd_bds_vend_purch.vendor_service_level,
                    rcd_bds_vend_purch.restriction_profile,
                    rcd_bds_vend_purch.auto_eval_receipt_flag,
                    rcd_bds_vend_purch.vendor_mars_account,
                    rcd_bds_vend_purch.idoc_profile,
                    rcd_bds_vend_purch.agency_business_flag,
                    rcd_bds_vend_purch.revaluation_flag,
                    rcd_bds_vend_purch.ship_conditions,
                    rcd_bds_vend_purch.service_invoice_verify_flag,
                    rcd_bds_vend_purch.minimum_order_value);

         /*-*/
         /* Process the LADS vendor purchasing plant
         /*-*/
         open csr_lads_ven_pom;
         loop
            fetch csr_lads_ven_pom into rcd_lads_ven_pom;
            if csr_lads_ven_pom%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_vend_purch_plant.vendor_code := rcd_lads_ven_poh.lifnr;
            rcd_bds_vend_purch_plant.purch_org_code := rcd_lads_ven_poh.ekorg;
            rcd_bds_vend_purch_plant.purch_org_sub_code := rcd_lads_ven_pom.ltsnr;
            rcd_bds_vend_purch_plant.plant_code := rcd_lads_ven_pom.werks;
            rcd_bds_vend_purch_plant.create_date := rcd_lads_ven_pom.erdat;
            rcd_bds_vend_purch_plant.create_user := rcd_lads_ven_pom.ernam;
            rcd_bds_vend_purch_plant.purchase_block_flag := rcd_lads_ven_pom.sperm;
            rcd_bds_vend_purch_plant.deletion_flag := rcd_lads_ven_pom.loevm;
            rcd_bds_vend_purch_plant.abc_flag := rcd_lads_ven_pom.lfabc;
            rcd_bds_vend_purch_plant.purch_ord_currency := rcd_lads_ven_pom.waers;
            rcd_bds_vend_purch_plant.vendor_salesperson := rcd_lads_ven_pom.verkf;
            rcd_bds_vend_purch_plant.vendor_phone := rcd_lads_ven_pom.telf1;
            rcd_bds_vend_purch_plant.order_value_minimum := rcd_lads_ven_pom.minbw;
            rcd_bds_vend_purch_plant.payment_terms := rcd_lads_ven_pom.zterm;
            rcd_bds_vend_purch_plant.inter_company_terms_01 := rcd_lads_ven_pom.inco1;
            rcd_bds_vend_purch_plant.inter_company_terms_02 := rcd_lads_ven_pom.inco2;
            rcd_bds_vend_purch_plant.invoice_verify_flag := rcd_lads_ven_pom.webre;
            rcd_bds_vend_purch_plant.order_acknowledgment_flag := rcd_lads_ven_pom.kzabs;
            rcd_bds_vend_purch_plant.calc_schema_group := rcd_lads_ven_pom.kalsk;
            rcd_bds_vend_purch_plant.purch_order_auto_gen_flag := rcd_lads_ven_pom.kzaut;
            rcd_bds_vend_purch_plant.foreign_transport_mode := rcd_lads_ven_pom.expvz;
            rcd_bds_vend_purch_plant.foreign_custom_office := rcd_lads_ven_pom.zolla;
            rcd_bds_vend_purch_plant.price_date_category := rcd_lads_ven_pom.meprf;
            rcd_bds_vend_purch_plant.purch_group_code := rcd_lads_ven_pom.ekgrp;
            rcd_bds_vend_purch_plant.subsequent_settlement_flag := rcd_lads_ven_pom.bolre;
            rcd_bds_vend_purch_plant.business_volumes_flag := rcd_lads_ven_pom.umsae;
            rcd_bds_vend_purch_plant.ers_flag := rcd_lads_ven_pom.xersy;
            rcd_bds_vend_purch_plant.planned_delivery_days := rcd_lads_ven_pom.plifz;
            rcd_bds_vend_purch_plant.planning_calendar := rcd_lads_ven_pom.mrppp;
            rcd_bds_vend_purch_plant.planning_cyle := rcd_lads_ven_pom.lfrhy;
            rcd_bds_vend_purch_plant.delivery_cycle := rcd_lads_ven_pom.liefr;
            rcd_bds_vend_purch_plant.vendor_order_entry_flag := rcd_lads_ven_pom.libes;
            rcd_bds_vend_purch_plant.vendor_price_marking := rcd_lads_ven_pom.lipre;
            rcd_bds_vend_purch_plant.rack_jobbing := rcd_lads_ven_pom.liser;
            rcd_bds_vend_purch_plant.mrp_controller := rcd_lads_ven_pom.dispo;
            rcd_bds_vend_purch_plant.confirm_control_key := rcd_lads_ven_pom.bstae;
            rcd_bds_vend_purch_plant.rounding_profile := rcd_lads_ven_pom.rdprf;
            rcd_bds_vend_purch_plant.uom_group := rcd_lads_ven_pom.megru;
            rcd_bds_vend_purch_plant.restriction_profile := rcd_lads_ven_pom.bopnr;
            rcd_bds_vend_purch_plant.auto_eval_receipt_flag := rcd_lads_ven_pom.xersr;
            rcd_bds_vend_purch_plant.release_creation_profile := rcd_lads_ven_pom.abueb;
            rcd_bds_vend_purch_plant.idoc_profile := rcd_lads_ven_pom.paprf;
            rcd_bds_vend_purch_plant.revaluation_flag := rcd_lads_ven_pom.xnbwy;
            rcd_bds_vend_purch_plant.service_invoice_verify_flag := rcd_lads_ven_pom.lebre;
            rcd_bds_vend_purch_plant.minimum_order_value := rcd_lads_ven_pom.minbw2;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_vend_purch_plant
               (vendor_code,
                purch_org_code,
                purch_org_sub_code,
                plant_code,
                create_date,
                create_user,
                purchase_block_flag,
                deletion_flag,
                abc_flag,
                purch_ord_currency,
                vendor_salesperson,
                vendor_phone,
                order_value_minimum,
                payment_terms,
                inter_company_terms_01,
                inter_company_terms_02,
                invoice_verify_flag,
                order_acknowledgment_flag,
                calc_schema_group,
                purch_order_auto_gen_flag,
                foreign_transport_mode,
                foreign_custom_office,
                price_date_category,
                purch_group_code,
                subsequent_settlement_flag,
                business_volumes_flag,
                ers_flag,
                planned_delivery_days,
                planning_calendar,
                planning_cyle,
                delivery_cycle,
                vendor_order_entry_flag,
                vendor_price_marking,
                rack_jobbing,
                mrp_controller,
                confirm_control_key,
                rounding_profile,
                uom_group,
                restriction_profile,
                auto_eval_receipt_flag,
                release_creation_profile,
                idoc_profile,
                revaluation_flag,
                service_invoice_verify_flag,
                minimum_order_value)
                values(rcd_bds_vend_purch_plant.vendor_code,
                       rcd_bds_vend_purch_plant.purch_org_code,
                       rcd_bds_vend_purch_plant.purch_org_sub_code,
                       rcd_bds_vend_purch_plant.plant_code,
                       rcd_bds_vend_purch_plant.create_date,
                       rcd_bds_vend_purch_plant.create_user,
                       rcd_bds_vend_purch_plant.purchase_block_flag,
                       rcd_bds_vend_purch_plant.deletion_flag,
                       rcd_bds_vend_purch_plant.abc_flag,
                       rcd_bds_vend_purch_plant.purch_ord_currency,
                       rcd_bds_vend_purch_plant.vendor_salesperson,
                       rcd_bds_vend_purch_plant.vendor_phone,
                       rcd_bds_vend_purch_plant.order_value_minimum,
                       rcd_bds_vend_purch_plant.payment_terms,
                       rcd_bds_vend_purch_plant.inter_company_terms_01,
                       rcd_bds_vend_purch_plant.inter_company_terms_02,
                       rcd_bds_vend_purch_plant.invoice_verify_flag,
                       rcd_bds_vend_purch_plant.order_acknowledgment_flag,
                       rcd_bds_vend_purch_plant.calc_schema_group,
                       rcd_bds_vend_purch_plant.purch_order_auto_gen_flag,
                       rcd_bds_vend_purch_plant.foreign_transport_mode,
                       rcd_bds_vend_purch_plant.foreign_custom_office,
                       rcd_bds_vend_purch_plant.price_date_category,
                       rcd_bds_vend_purch_plant.purch_group_code,
                       rcd_bds_vend_purch_plant.subsequent_settlement_flag,
                       rcd_bds_vend_purch_plant.business_volumes_flag,
                       rcd_bds_vend_purch_plant.ers_flag,
                       rcd_bds_vend_purch_plant.planned_delivery_days,
                       rcd_bds_vend_purch_plant.planning_calendar,
                       rcd_bds_vend_purch_plant.planning_cyle,
                       rcd_bds_vend_purch_plant.delivery_cycle,
                       rcd_bds_vend_purch_plant.vendor_order_entry_flag,
                       rcd_bds_vend_purch_plant.vendor_price_marking,
                       rcd_bds_vend_purch_plant.rack_jobbing,
                       rcd_bds_vend_purch_plant.mrp_controller,
                       rcd_bds_vend_purch_plant.confirm_control_key,
                       rcd_bds_vend_purch_plant.rounding_profile,
                       rcd_bds_vend_purch_plant.uom_group,
                       rcd_bds_vend_purch_plant.restriction_profile,
                       rcd_bds_vend_purch_plant.auto_eval_receipt_flag,
                       rcd_bds_vend_purch_plant.release_creation_profile,
                       rcd_bds_vend_purch_plant.idoc_profile,
                       rcd_bds_vend_purch_plant.revaluation_flag,
                       rcd_bds_vend_purch_plant.service_invoice_verify_flag,
                       rcd_bds_vend_purch_plant.minimum_order_value);

         end loop;
         close csr_lads_ven_pom;

         /*-*/
         /* Process the LADS vendor purchasing text
         /*-*/
         open csr_lads_ven_ptx;
         loop
            fetch csr_lads_ven_ptx into rcd_lads_ven_ptx;
            if csr_lads_ven_ptx%notfound then
               exit;
            end if;

            /*-*/
            /* Set the BDS child values
            /*-*/
            rcd_bds_vend_purch_text.vendor_code := rcd_lads_ven_poh.lifnr;
            rcd_bds_vend_purch_text.purch_org_code := rcd_lads_ven_poh.ekorg;
            rcd_bds_vend_purch_text.text_object := rcd_lads_ven_ptx.tdobject;
            rcd_bds_vend_purch_text.text_name := rcd_lads_ven_ptx.tdname;
            rcd_bds_vend_purch_text.text_id := rcd_lads_ven_ptx.tdid;
            rcd_bds_vend_purch_text.text_language := rcd_lads_ven_ptx.tdspras;
            rcd_bds_vend_purch_text.text_type := rcd_lads_ven_ptx.tdtexttype;
            rcd_bds_vend_purch_text.text_language_iso := rcd_lads_ven_ptx.tdsprasiso;
            rcd_bds_vend_purch_text.text_line := null;
         
            /*-*/
            /* Retrieve the LADS vendor purchasing text line
            /*-*/
            open csr_lads_ven_ptd;
            loop
               fetch csr_lads_ven_ptd into rcd_lads_ven_ptd;
               if csr_lads_ven_ptd%notfound or
                  (length(rcd_bds_vend_purch_text.text_line) + length(rcd_lads_ven_ptd.tdline)) > 2000 then
                  exit;
               end if;
               rcd_bds_vend_purch_text.text_line := rcd_bds_vend_purch_text.text_line||' '||rcd_lads_ven_ptd.tdline;
            end loop;
            close csr_lads_ven_ptd;

            /*-*/
            /* Insert the child row
            /*-*/
            insert into bds_vend_purch_text
               (vendor_code,
                purch_org_code,
                text_object,
                text_name,
                text_id,
                text_language,
                text_type,
                text_language_iso,
                text_line)
                values(rcd_bds_vend_purch_text.vendor_code,
                       rcd_bds_vend_purch_text.purch_org_code,
                       rcd_bds_vend_purch_text.text_object,
                       rcd_bds_vend_purch_text.text_name,
                       rcd_bds_vend_purch_text.text_id,
                       rcd_bds_vend_purch_text.text_language,
                       rcd_bds_vend_purch_text.text_type,
                       rcd_bds_vend_purch_text.text_language_iso,
                       rcd_bds_vend_purch_text.text_line);

         end loop;
         close csr_lads_ven_ptx;

      end loop;
      close csr_lads_ven_poh;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_ven_hdr
         set lads_flattened = var_flattened
         where lifnr = par_lifnr;

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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'LIFNR: ' || par_lifnr || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_lifnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_ven_hdr t01
          where t01.lifnr = par_lifnr
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
         bds_flatten(rcd_lock.lifnr);

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
         select t01.lifnr
           from lads_ven_hdr t01
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

         lads_lock(rcd_flatten.lifnr);

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
      bds_table.truncate('bds_vend_purch_text');
      bds_table.truncate('bds_vend_purch_plant');
      bds_table.truncate('bds_vend_purch');
      bds_table.truncate('bds_vend_comp_mars');
      bds_table.truncate('bds_vend_comp_text');
      bds_table.truncate('bds_vend_comp');
      bds_table.truncate('bds_vend_comp_whtax');
      bds_table.truncate('bds_vend_bank');
      bds_table.truncate('bds_vend_text');
      bds_table.truncate('bds_vend_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_ven_hdr
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

end bds_atllad19_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad19_flatten for bds_app.bds_atllad19_flatten;
grant execute on bds_atllad19_flatten to lics_app;
grant execute on bds_atllad19_flatten to lads_app;