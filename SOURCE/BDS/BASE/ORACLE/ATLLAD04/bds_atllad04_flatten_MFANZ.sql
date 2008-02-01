create or replace package bds_atllad04_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad04_flatten
    Owner   : BDS_APP
    Author  : Linden Glen

    Description
    -----------
    Business Data Store - ATLLAD04 - Material Master (MATMAS) - MFANZ Version

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

      2. PAR_MATNR [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
         Field from LADS document in LADS_MAT_HDR.MATNR

    NOTES 
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2006/11   Linden Glen    Created
    2007/01   Linden Glen    Added BDS_MATERIAL_PLANT_MFANZ processing
    2007/01   Linden Glen    Changed join condition for BDS_MATERIAL_PLANT_MFANZ cursor
                             Added additional UOM fields to BDS_MATERIAL_PLANT_MFANZ cursor
    2007/02   Linden Glen    Corrected field mapping in BDS_MATERIAL_PLANT_MFANZ processing
    2007/04   Steve Gregan   Added redundant bds_material_pkg_instr_hdr columns to detail bds_material_pkg_instr_det
    2007/05   Steve Gregan   Added additional fields to BDS_MATERIAL_PLANT_MFANZ
    2007/08   Steve Gregan   Added additional fields to BDS_MATERIAL_PLANT_MFANZ

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_matnr in varchar2);

end bds_atllad04_flatten;
/


/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad04_flatten as

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
   procedure lads_lock(par_matnr in varchar2);
   procedure bds_flatten(par_matnr in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_matnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_matnr);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_matnr);
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
         raise_application_error(-20000, 'BDS_ATLLAD04_FLATTEN - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_matnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;
      var_text_line_sep varchar2(1);

      /*---------------------*/
      /* Material Data       */
      /*---------------------*/
      rcd_bds_material_hdr bds_material_hdr%rowtype;
      rcd_bds_material_tax bds_material_tax%rowtype;
      rcd_bds_material_vltn bds_material_vltn%rowtype;
      rcd_bds_material_desc bds_material_desc%rowtype;
      rcd_bds_material_text bds_material_text%rowtype;
      rcd_bds_material_text_en bds_material_text_en%rowtype;
      rcd_bds_material_regional bds_material_regional%rowtype;
      rcd_bds_material_dstrbtn_chain bds_material_dstrbtn_chain%rowtype;
      /*---------------------*/
      /* Material MOE Data   */
      /*---------------------*/
      rcd_bds_material_moe bds_material_moe%rowtype;
      rcd_bds_material_moe_grp bds_material_moe_grp%rowtype;
      /*---------------------*/
      /* Material UOM Data   */
      /*---------------------*/
      rcd_bds_material_uom bds_material_uom%rowtype;
      rcd_bds_material_uom_ean bds_material_uom_ean%rowtype;
      /*---------------------*/
      /* Material Plant Data */
      /*---------------------*/
      rcd_bds_material_plant_hdr bds_material_plant_hdr%rowtype;
      rcd_bds_material_plant_vrsn bds_material_plant_vrsn%rowtype;
      rcd_bds_material_plant_batch bds_material_plant_batch%rowtype;
      rcd_bds_material_plant_frcst bds_material_plant_forecast%rowtype;
      rcd_bds_matl_plant_unp_cnsmptn bds_material_plant_unp_cnsmptn%rowtype;
      rcd_bds_matl_plant_ttl_cnsmptn bds_material_plant_ttl_cnsmptn%rowtype;
      /*-----------------------------------*/
      /* Material Packing Instruction Data */
      /*-----------------------------------*/
      rcd_bds_material_pkg_instr_hdr bds_material_pkg_instr_hdr%rowtype;
      rcd_bds_material_pkg_instr_det bds_material_pkg_instr_det%rowtype;
      rcd_bds_material_pkg_instr_ean bds_material_pkg_instr_ean%rowtype;
      rcd_bds_material_pkg_instr_moe bds_material_pkg_instr_moe%rowtype;
      rcd_bds_material_pkg_instr_reg bds_material_pkg_instr_reg%rowtype;
      rcd_bds_matl_pkg_instr_text bds_material_pkg_instr_text%rowtype;
      /*-----------------------------------*/
      /* Material/Plant for MFANZ          */
      /*-----------------------------------*/
      rcd_bds_material_plant_mfanz bds_material_plant_mfanz%rowtype;


      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_hdr is
         select t01.matnr as matnr,
                (select max(maktx)
                 from lads_mat_mkt
                 where matnr = t01.matnr
                   and spras_iso = 'EN') as bds_material_desc_en,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.ersda as ersda,
                t01.ernam as ernam,
                t01.laeda as laeda,
                t01.aenam as aenam,
                t01.pstat as pstat,
                t01.lvorm as lvorm,
                t01.mtart as mtart,
                t01.mbrsh as mbrsh,
                t01.matkl as matkl,
                t01.bismt as bismt,
                t01.meins as meins,
                t01.bstme as bstme,
                t01.zeinr as zeinr,
                t01.zeiar as zeiar,
                t01.zeivr as zeivr,
                t01.zeifo as zeifo,
                t01.aeszn as aeszn,
                t01.blatt as blatt,
                t01.blanz as blanz,
                t01.ferth as ferth,
                t01.formt as formt,
                t01.groes as groes,
                t01.wrkst as wrkst,
                t01.normt as normt,
                t01.labor as labor,
                t01.ekwsl as ekwsl,
                t01.brgew as brgew,
                t01.ntgew as ntgew,
                t01.gewei as gewei,
                t01.volum as volum,
                t01.voleh as voleh,
                t01.behvo as behvo,
                t01.raube as raube,
                t01.tempb as tempb,
                t01.tragr as tragr,
                t01.stoff as stoff,
                t01.spart as spart,
                t01.kunnr as kunnr,
                t01.wesch as wesch,
                t01.bwvor as bwvor,
                t01.bwscl as bwscl,
                t01.saiso as saiso,
                t01.etiar as etiar,
                t01.etifo as etifo,
                t01.ean11 as ean11,
                t01.numtp as numtp,
                t01.laeng as laeng,
                t01.breit as breit,
                t01.hoehe as hoehe,
                t01.meabm as meabm,
                t01.prdha as prdha,
                t01.cadkz as cadkz,
                t01.ergew as ergew,
                t01.ergei as ergei,
                t01.ervol as ervol,
                t01.ervoe as ervoe,
                t01.gewto as gewto,
                t01.volto as volto,
                t01.vabme as vabme,
                t01.kzkfg as kzkfg,
                t01.xchpf as xchpf,
                t01.vhart as vhart,
                t01.fuelg as fuelg,
                t01.stfak as stfak,
                t01.magrv as magrv,
                t01.begru as begru,
                t01.qmpur as qmpur,
                t01.rbnrm as rbnrm,
                t01.mhdrz as mhdrz,
                t01.mhdhb as mhdhb,
                t01.mhdlp as mhdlp,
                t01.vpsta as vpsta,
                t01.extwg as extwg,
                t01.mstae as mstae,
                t01.mstav as mstav,
                t01.mstde as mstde,
                t01.mstdv as mstdv,
                t01.kzumw as kzumw,
                t01.kosch as kosch,
                t01.nrfhg as nrfhg,
                t01.mfrpn as mfrpn,
                t01.mfrnr as mfrnr,
                t01.bmatn as bmatn,
                t01.mprof as mprof,
                t01.profl as profl,
                t01.ihivi as ihivi,
                t01.iloos as iloos,
                t01.kzgvh as kzgvh,
                t01.xgchp as xgchp,
                t01.compl as compl,
                t01.kzeff as kzeff,
                t01.rdmhd as rdmhd,
                t01.iprkz as iprkz,
                t01.przus as przus,
                t01.mtpos_mara as mtpos_mara,
                t01.gewto_new as gewto_new,
                t01.volto_new as volto_new,
                t01.wrkst_new as wrkst_new,
                t01.aennr as aennr,
                t01.matfi as matfi,
                t01.cmrel as cmrel,
                t01.satnr as satnr,
                t01.sled_bbd as sled_bbd,
                t01.gtin_variant as gtin_variant,
                t01.gennr as gennr,
                t01.serlv as serlv,
                t01.rmatp as rmatp,
                t01.zzdecvolum as zzdecvolum,
                t01.zzdecvoleh as zzdecvoleh,
                t01.zzdeccount as zzdeccount,
                t01.zzdeccounit as zzdeccounit,
                t01.zzpproweight as zzpproweight,
                t01.zzpprowunit as zzpprowunit,
                t01.zzpprovolum as zzpprovolum,
                t01.zzpprovunit as zzpprovunit,
                t01.zzpprocount as zzpprocount,
                t01.zzpprocunit as zzpprocunit,
                t01.zzalpha01 as zzalpha01,
                t01.zzalpha02 as zzalpha02,
                t01.zzalpha03 as zzalpha03,
                t01.zzalpha04 as zzalpha04,
                t01.zzalpha05 as zzalpha05,
                t01.zzalpha06 as zzalpha06,
                t01.zzalpha07 as zzalpha07,
                t01.zzalpha08 as zzalpha08,
                t01.zzalpha09 as zzalpha09,
                t01.zzalpha10 as zzalpha10,
                t01.zznum01 as zznum01,
                t01.zznum02 as zznum02,
                t01.zznum03 as zznum03,
                t01.zznum04 as zznum04,
                t01.zznum05 as zznum05,
                t01.zznum06 as zznum06,
                t01.zznum07 as zznum07,
                t01.zznum08 as zznum08,
                t01.zznum09 as zznum09,
                t01.zznum10 as zznum10,
                t01.zzcheck01 as zzcheck01,
                t01.zzcheck02 as zzcheck02,
                t01.zzcheck03 as zzcheck03,
                t01.zzcheck04 as zzcheck04,
                t01.zzcheck05 as zzcheck05,
                t01.zzcheck06 as zzcheck06,
                t01.zzcheck07 as zzcheck07,
                t01.zzcheck08 as zzcheck08,
                t01.zzcheck09 as zzcheck09,
                t01.zzcheck10 as zzcheck10,
                t01.zzplan_item as zzplan_item,
                t01.zzisint as zzisint,
                t01.zzismcu as zzismcu,
                t01.zzispro as zzispro,
                t01.zzisrsu as zzisrsu,
                t01.zzissc as zzissc,
                t01.zzissfp as zzissfp,
                t01.zzistdu as zzistdu,
                t01.zzistra as zzistra,
                t01.zzstatuscode as zzstatuscode,
                t01.zzitemowner as zzitemowner,
                t01.zzchangedby as zzchangedby,
                t01.zzmattim as zzmattim,
                t01.zzrepmatnr as zzrepmatnr
         from lads_mat_hdr t01
         where t01.matnr = par_matnr;
      rcd_lads_mat_hdr  csr_lads_mat_hdr%rowtype;

      cursor csr_lads_mat_mkt is
         select nvl(t01.spras_iso,'*NONE') as spras_iso,
                max(t01.maktx) as maktx,
                max(t01.msgfn) as msgfn
         from lads_mat_mkt t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
         group by nvl(t01.spras_iso,'*NONE');
      rcd_lads_mat_mkt  csr_lads_mat_mkt%rowtype;

      cursor csr_lads_mat_moe is
         select nvl(t01.usagecode,'*NONE') as usagecode,
                nvl(t01.moe,'*NONE') as moe,
                t01.datab as datab,
                t01.dated as dated
         from lads_mat_moe t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
         group by nvl(t01.usagecode,'*NONE'), nvl(t01.moe,'*NONE'), t01.datab, t01.dated;
      rcd_lads_mat_moe  csr_lads_mat_moe%rowtype;

      cursor csr_lads_mat_txh is
         select nvl(t01.tdobject,'*NONE') as tdobject,
                nvl(t01.tdname,'*NONE') as tdname,
                nvl(t01.tdid,'*NONE') as tdid,
                nvl(t01.tdtexttype,'*NONE') as tdtexttype,
                nvl(t01.spras_iso,'*NONE') as spras_iso,
                max(t01.txhseq) as txhseq,
                max(t01.msgfn) as msgfn
         from lads_mat_txh t01
         where t01.matnr = par_matnr
         group by nvl(t01.tdobject,'*NONE'), nvl(t01.tdname,'*NONE'), nvl(t01.tdid,'*NONE'), nvl(t01.tdtexttype,'*NONE'), nvl(t01.spras_iso,'*NONE');
      rcd_lads_mat_txh  csr_lads_mat_txh%rowtype;

      cursor csr_lads_mat_text_en is
         select nvl(trim(substr(t01.tdname,19,4)),'*NONE') as sales_organisation,
                nvl(trim(substr(t01.tdname,23,2)),'*NONE') as dstrbtn_channel,
                max(t01.txhseq) as txhseq
         from lads_mat_txh t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.spras_iso = 'EN'
           and t01.tdobject = 'MVKE'
           and t01.tdtexttype = 'ASCII'
         group by t01.tdobject, t01.tdname, t01.tdid, t01.tdtexttype, t01.spras_iso;
      rcd_lads_mat_text_en  csr_lads_mat_text_en%rowtype;

      cursor csr_lads_mat_tax is
         select * from 
            (select nvl(t01.aland,'*NONE') as aland,
                    t01.msgfn as msgfn,
                    t01.taty1 as taty1,
                    t01.taxm1 as taxm1,
                    t01.taty2 as taty2,
                    t01.taxm2 as taxm2,
                    t01.taty3 as taty3,
                    t01.taxm3 as taxm3,
                    t01.taty4 as taty4,
                    t01.taxm4 as taxm4,
                    t01.taty5 as taty5,
                    t01.taxm5 as taxm5,
                    t01.taty6 as taty6,
                    t01.taxm6 as taxm6,
                    t01.taty7 as taty7,
                    t01.taxm7 as taxm7,
                    t01.taty8 as taty8,
                    t01.taxm8 as taxm8,
                    t01.taty9 as taty9,
                    t01.taxm9 as taxm9,
                    t01.taxim as taxim,
                    rank() over (partition by nvl(t01.aland,'*NONE') order by rownum) as rnkseq
             from lads_mat_tax t01
             where t01.matnr = rcd_lads_mat_hdr.matnr)
         where rnkseq = 1;
      rcd_lads_mat_tax  csr_lads_mat_tax%rowtype;

      cursor csr_lads_mat_gme is
         select nvl(t01.grouptype,'*NONE') as grouptype,
                nvl(t01.groupmoe,'*NONE') as groupmoe,
                nvl(t01.usagecode,'*NONE') as usagecode,
                t01.datab as datab,
                t01.dated as dated
         from lads_mat_gme t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
         group by nvl(t01.grouptype,'*NONE'), nvl(t01.groupmoe,'*NONE'), nvl(t01.usagecode,'*NONE'), t01.datab, t01.dated;
      rcd_lads_mat_gme  csr_lads_mat_gme%rowtype;

      cursor csr_lads_mat_mbe is
         select * from (
            select nvl(t01.bwkey,'*NONE') as bwkey,
                   nvl(t01.bwtar,'*NONE') as bwtar,
                   t01.lvorm as lvorm,
                   t01.bwprh as bwprh,
                   t01.bwph1 as bwph1,
                   t01.vjbwh as vjbwh,
                   t01.hrkft as hrkft,
                   t01.ekalr as ekalr,
                   t01.kosgr as kosgr,
                   t01.lfmon as lfmon,
                   t01.lfgja as lfgja,
                   t01.kalkl as kalkl,
                   t01.kalkz as kalkz,
                   t01.pdatl as pdatl,
                   t01.bwva2 as bwva2,
                   t01.vers2 as vers2,
                   t01.zplpr as zplpr,
                   t01.zplp1 as zplp1,
                   t01.zpld1 as zpld1,
                   t01.zplp2 as zplp2,
                   t01.zpld2 as zpld2,
                   t01.zplp3 as zplp3,
                   t01.zpld3 as zpld3,
                   t01.pprdz as pprdz,
                   t01.zkprs as zkprs,
                   t01.pdatz as pdatz,
                   t01.bwva1 as bwva1,
                   t01.vers1 as vers1,
                   t01.mlmaa as mlmaa,
                   t01.mypol as mypol,
                   t01.abwkz as abwkz,
                   t01.pstat as pstat,
                   t01.verpr as verpr,
                   t01.xlifo as xlifo,
                   t01.hkmat as hkmat,
                   t01.mtorg as mtorg,
                   t01.pprdl as pprdl,
                   t01.pprdv as pprdv,
                   t01.kaln1 as kaln1,
                   t01.kalnr as kalnr,
                   t01.vplpr as vplpr,
                   t01.vmver as vmver,
                   t01.vmvpr as vmvpr,
                   t01.vmpei as vmpei,
                   t01.vmstp as vmstp,
                   t01.vmbkl as vmbkl,
                   t01.pdatv as pdatv,
                   t01.bwva3 as bwva3,
                   t01.vers3 as vers3,
                   t01.vjver as vjver,
                   t01.vjvpr as vjvpr,
                   t01.vjpei as vjpei,
                   t01.vjstp as vjstp,
                   t01.vjbkl as vjbkl,
                   t01.vprsv as vprsv,
                   t01.mlast as mlast,
                   t01.peinh as peinh,
                   t01.ownpr as ownpr,
                   t01.qklas as qklas,
                   t01.eklas as eklas,
                   t01.msgfn as msgfn,
                   t01.stprs as stprs,
                   t01.bwpei as bwpei,
                   t01.bwprs as bwprs,
                   t01.bwps1 as bwps1,
                   t01.vjbws as vjbws,
                   t01.vvmlb as vvmlb,
                   t01.vvjlb as vvjlb,
                   t01.mtuse as mtuse,
                   t01.zkdat as zkdat,
                   t01.bklas as bklas,
                   t01.bwtty as bwtty,
                   t01.vvsal as vvsal,
                   rank() over (partition by nvl(t01.bwkey,'*NONE'), nvl(t01.bwtar,'*NONE') order by rownum) as rnkseq
            from lads_mat_mbe t01
            where t01.matnr = rcd_lads_mat_hdr.matnr)
         where rnkseq = 1;
      rcd_lads_mat_mbe  csr_lads_mat_mbe%rowtype;

      cursor csr_lads_mat_sad is
         select * from (
            select nvl(t01.vkorg,'*NONE') as vkorg,
                   nvl(t01.vtweg,'*NONE') as vtweg,
                   t01.msgfn as msgfn,
                   t01.lvorm as lvorm,
                   t01.versg as versg,
                   t01.bonus as bonus,
                   t01.provg as provg,
                   t01.sktof as sktof,
                   t01.vmsta as vmsta,
                   t01.vmstd as vmstd,
                   t01.aumng as aumng,
                   t01.lfmng as lfmng,
                   t01.efmng as efmng,
                   t01.scmng as scmng,
                   t01.schme as schme,
                   t01.vrkme as vrkme,
                   t01.mtpos as mtpos,
                   t01.dwerk as dwerk,
                   t01.prodh as prodh,
                   t01.pmatn as pmatn,
                   t01.kondm as kondm,
                   t01.ktgrm as ktgrm,
                   t01.mvgr1 as mvgr1,
                   t01.mvgr2 as mvgr2,
                   t01.mvgr3 as mvgr3,
                   t01.mvgr4 as mvgr4,
                   t01.mvgr5 as mvgr5,
                   t01.sstuf as sstuf,
                   t01.pflks as pflks,
                   t01.lstfl as lstfl,
                   t01.lstvz as lstvz,
                   t01.lstak as lstak,
                   t01.prat1 as prat1,
                   t01.prat2 as prat2,
                   t01.prat3 as prat3,
                   t01.prat4 as prat4,
                   t01.prat5 as prat5,
                   t01.prat6 as prat6,
                   t01.prat7 as prat7,
                   t01.prat8 as prat8,
                   t01.prat9 as prat9,
                   t01.prata as prata,
                   t01.vavme as vavme,
                   t01.rdprf as rdprf,
                   t01.megru as megru,
                   t01.pmatn_external as pmatn_external,
                   t01.pmatn_version as pmatn_version,
                   t01.pmatn_guid as pmatn_guid,
                   (select max(zzlogist_point) from lads_mat_zsd
                    where matnr = t01.matnr and sadseq = t01.sadseq) as zzlogist_point,
                   rank() over (partition by nvl(t01.vkorg,'*NONE'), nvl(t01.vtweg,'*NONE'), t01.sadseq order by rownum) as rnkseq
            from lads_mat_sad t01
            where t01.matnr = par_matnr)
         where rnkseq = 1;
      rcd_lads_mat_sad  csr_lads_mat_sad%rowtype;

      cursor csr_lads_mat_lcd is
         select nvl(t01.z_lcdid,'*NONE') as z_lcdid,
                nvl(t01.z_lcdnr,'*NONE') as z_lcdnr
         from lads_mat_lcd t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
         group by t01.z_lcdid, t01.z_lcdnr;
      rcd_lads_mat_lcd  csr_lads_mat_lcd%rowtype;

      cursor csr_lads_mat_uom is
         select * from (
            select nvl(t01.meinh,'*NONE') as meinh,
                   t01.uomseq as uomseq,
                   t01.msgfn as msgfn,
                   t01.umrez as umrez,
                   t01.umren as umren,
                   t01.ean11 as ean11,
                   t01.numtp as numtp,
                   t01.laeng as laeng,
                   t01.breit as breit,
                   t01.hoehe as hoehe,
                   t01.meabm as meabm,
                   t01.volum as volum,
                   t01.voleh as voleh,
                   t01.brgew as brgew,
                   t01.gewei as gewei,
                   t01.mesub as mesub,
                   t01.gtin_variant as gtin_variant,
                   t01.zzmultitdu as zzmultitdu,
                   t01.zzpcitem as zzpcitem,
                   t01.zzpclevel as zzpclevel,
                   t01.zzpreforder as zzpreforder,
                   t01.zzprefsales as zzprefsales,
                   t01.zzprefissue as zzprefissue,
                   t01.zzprefwm as zzprefwm,
                   t01.zzrefmatnr as zzrefmatnr,
                   rank() over (partition by nvl(t01.meinh,'*NONE') order by rownum) as rnkseq
            from lads_mat_uom t01
            where t01.matnr = rcd_lads_mat_hdr.matnr)
         where rnkseq = 1;
      rcd_lads_mat_uom  csr_lads_mat_uom%rowtype;

      cursor csr_lads_mat_uoe is
         select nvl(t01.lfnum,'*NONE') as lfnum,
                max(t01.msgfn) as msgfn,
                max(t01.ean11) as ean11,
                max(t01.eantp) as eantp,
                max(t01.hpean) as hpean
         from lads_mat_uoe t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.uomseq = rcd_lads_mat_uom.uomseq
         group by nvl(t01.lfnum,'*NONE');
      rcd_lads_mat_uoe  csr_lads_mat_uoe%rowtype;

      cursor csr_lads_mat_mrc is
         select * from 
         (select nvl(t01.werks,'*NONE') as werks,
                t01.msgfn as msgfn,
                t01.pstat as pstat,
                t01.lvorm as lvorm,
                t01.bwtty as bwtty,
                t01.maabc as maabc,
                t01.kzkri as kzkri,
                t01.ekgrp as ekgrp,
                t01.ausme as ausme,
                t01.dispr as dispr,
                t01.dismm as dismm,
                t01.dispo as dispo,
                t01.plifz as plifz,
                t01.webaz as webaz,
                t01.perkz as perkz,
                t01.ausss as ausss,
                t01.disls as disls,
                t01.beskz as beskz,
                t01.sobsl as sobsl,
                t01.minbe as minbe,
                t01.eisbe as eisbe,
                t01.bstmi as bstmi,
                t01.bstma as bstma,
                t01.bstfe as bstfe,
                t01.bstrf as bstrf,
                t01.mabst as mabst,
                t01.losfx as losfx,
                t01.sbdkz as sbdkz,
                t01.lagpr as lagpr,
                t01.altsl as altsl,
                t01.kzaus as kzaus,
                t01.ausdt as ausdt,
                t01.nfmat as nfmat,
                t01.kzbed as kzbed,
                t01.miskz as miskz,
                t01.fhori as fhori,
                t01.pfrei as pfrei,
                t01.ffrei as ffrei,
                t01.rgekz as rgekz,
                t01.fevor as fevor,
                t01.bearz as bearz,
                t01.ruezt as ruezt,
                t01.tranz as tranz,
                t01.basmg as basmg,
                t01.dzeit as dzeit,
                t01.maxlz as maxlz,
                t01.lzeih as lzeih,
                t01.kzpro as kzpro,
                t01.gpmkz as gpmkz,
                t01.ueeto as ueeto,
                t01.ueetk as ueetk,
                t01.uneto as uneto,
                t01.wzeit as wzeit,
                t01.atpkz as atpkz,
                t01.vzusl as vzusl,
                t01.herbl as herbl,
                t01.insmk as insmk,
                t01.ssqss as ssqss,
                t01.kzdkz as kzdkz,
                t01.umlmc as umlmc,
                t01.ladgr as ladgr,
                t01.xchpf as xchpf,
                t01.usequ as usequ,
                t01.lgrad as lgrad,
                t01.auftl as auftl,
                t01.plvar as plvar,
                t01.otype as otype,
                t01.objid as objid,
                t01.mtvfp as mtvfp,
                t01.periv as periv,
                t01.kzkfk as kzkfk,
                t01.vrvez as vrvez,
                t01.vbamg as vbamg,
                t01.vbeaz as vbeaz,
                t01.lizyk as lizyk,
                t01.bwscl as bwscl,
                t01.kautb as kautb,
                t01.kordb as kordb,
                t01.stawn as stawn,
                t01.herkl as herkl,
                t01.herkr as herkr,
                t01.expme as expme,
                t01.mtver as mtver,
                t01.prctr as prctr,
                t01.trame as trame,
                t01.mrppp as mrppp,
                t01.sauft as sauft,
                t01.fxhor as fxhor,
                t01.vrmod as vrmod,
                t01.vint1 as vint1,
                t01.vint2 as vint2,
                t01.stlal as stlal,
                t01.stlan as stlan,
                t01.plnnr as plnnr,
                t01.aplal as aplal,
                t01.losgr as losgr,
                t01.sobsk as sobsk,
                t01.frtme as frtme,
                t01.lgpro as lgpro,
                t01.disgr as disgr,
                t01.kausf as kausf,
                t01.qzgtp as qzgtp,
                t01.takzt as takzt,
                t01.rwpro as rwpro,
                t01.copam as copam,
                t01.abcin as abcin,
                t01.awsls as awsls,
                t01.sernp as sernp,
                t01.stdpd as stdpd,
                t01.sfepr as sfepr,
                t01.xmcng as xmcng,
                t01.qssys as qssys,
                t01.lfrhy as lfrhy,
                t01.rdprf as rdprf,
                t01.vrbmt as vrbmt,
                t01.vrbwk as vrbwk,
                t01.vrbdt as vrbdt,
                t01.vrbfk as vrbfk,
                t01.autru as autru,
                t01.prefe as prefe,
                t01.prenc as prenc,
                t01.preno as preno,
                t01.prend as prend,
                t01.prene as prene,
                t01.preng as preng,
                t01.itark as itark,
                t01.prfrq as prfrq,
                t01.kzkup as kzkup,
                t01.strgr as strgr,
                t01.lgfsb as lgfsb,
                t01.schgt as schgt,
                t01.ccfix as ccfix,
                t01.eprio as eprio,
                t01.qmata as qmata,
                t01.plnty as plnty,
                t01.mmsta as mmsta,
                t01.sfcpf as sfcpf,
                t01.shflg as shflg,
                t01.shzet as shzet,
                t01.mdach as mdach,
                t01.kzech as kzech,
                t01.mmstd as mmstd,
                t01.mfrgr as mfrgr,
                t01.fvidk as fvidk,
                t01.indus as indus,
                t01.mownr as mownr,
                t01.mogru as mogru,
                t01.casnr as casnr,
                t01.gpnum as gpnum,
                t01.steuc as steuc,
                t01.fabkz as fabkz,
                t01.matgr as matgr,
                t01.loggr as loggr,
                t01.vspvb as vspvb,
                t01.dplfs as dplfs,
                t01.dplpu as dplpu,
                t01.dplho as dplho,
                t01.minls as minls,
                t01.maxls as maxls,
                t01.fixls as fixls,
                t01.ltinc as ltinc,
                t01.compl as compl,
                t01.convt as convt,
                t01.fprfm as fprfm,
                t01.shpro as shpro,
                t01.fxpru as fxpru,
                t01.kzpsp as kzpsp,
                t01.ocmpf as ocmpf,
                t01.apokz as apokz,
                t01.ahdis as ahdis,
                t01.eislo as eislo,
                t01.ncost as ncost,
                t01.megru as megru,
                t01.rotation_date as rotation_date,
                t01.uchkz as uchkz,
                t01.ucmat as ucmat,
                t01.msgfn1 as msgfn1,
                t01.objty as objty,
                t01.objid1 as objid1,
                t01.zaehl as zaehl,
                t01.objty_v as objty_v,
                t01.objid_v as objid_v,
                t01.kzkbl as kzkbl,
                t01.steuf as steuf,
                t01.steuf_ref as steuf_ref,
                t01.fgru1 as fgru1,
                t01.fgru2 as fgru2,
                t01.planv as planv,
                t01.ktsch as ktsch,
                t01.ktsch_ref as ktsch_ref,
                t01.bzoffb as bzoffb,
                t01.bzoffb_ref as bzoffb_ref,
                t01.offstb as offstb,
                t01.ehoffb as ehoffb,
                t01.offstb_ref as offstb_ref,
                t01.bzoffe as bzoffe,
                t01.bzoffe_ref as bzoffe_ref,
                t01.offste as offste,
                t01.ehoffe as ehoffe,
                t01.offste_ref as offste_ref,
                t01.mgform as mgform,
                t01.mgform_ref as mgform_ref,
                t01.ewform as ewform,
                t01.ewform_ref as ewform_ref,
                t01.par01 as par01,
                t01.par02 as par02,
                t01.par03 as par03,
                t01.par04 as par04,
                t01.par05 as par05,
                t01.par06 as par06,
                t01.paru1 as paru1,
                t01.paru2 as paru2,
                t01.paru3 as paru3,
                t01.paru4 as paru4,
                t01.paru5 as paru5,
                t01.paru6 as paru6,
                t01.parv1 as parv1,
                t01.parv2 as parv2,
                t01.parv3 as parv3,
                t01.parv4 as parv4,
                t01.parv5 as parv5,
                t01.parv6 as parv6,
                t01.msgfn2 as msgfn2,
                t01.prgrp as prgrp,
                t01.prwrk as prwrk,
                t01.umref as umref,
                t01.prgrp_external as prgrp_external,
                t01.prgrp_version as prgrp_version,
                t01.prgrp_guid as prgrp_guid,
                t01.msgfn3 as msgfn3,
                t01.versp as versp,
                t01.propr as propr,
                t01.modaw as modaw,
                t01.modav as modav,
                t01.kzpar as kzpar,
                t01.opgra as opgra,
                t01.kzini as kzini,
                t01.prmod as prmod,
                t01.alpha as alpha,
                t01.beta1 as beta1,
                t01.gamma as gamma,
                t01.delta as delta,
                t01.epsil as epsil,
                t01.siggr as siggr,
                t01.perkz1 as perkz1,
                t01.prdat as prdat,
                t01.peran as peran,
                t01.perin as perin,
                t01.perio as perio,
                t01.perex as perex,
                t01.anzpr as anzpr,
                t01.fimon as fimon,
                t01.gwert as gwert,
                t01.gwer1 as gwer1,
                t01.gwer2 as gwer2,
                t01.vmgwe as vmgwe,
                t01.vmgw1 as vmgw1,
                t01.vmgw2 as vmgw2,
                t01.twert as twert,
                t01.vmtwe as vmtwe,
                t01.prmad as prmad,
                t01.vmmad as vmmad,
                t01.fsumm as fsumm,
                t01.vmfsu as vmfsu,
                t01.gewgr as gewgr,
                t01.thkof as thkof,
                t01.ausna as ausna,
                t01.proab as proab,
                rank() over (partition by nvl(t01.werks,'*NONE') order by rownum) as rnkseq
         from lads_mat_mrc t01
         where t01.matnr = rcd_lads_mat_hdr.matnr)
         where rnkseq = 1;
      rcd_lads_mat_mrc  csr_lads_mat_mrc%rowtype;

      cursor csr_lads_mat_zmc is
         select max(t01.zzmtart) as zzmtart,
                max(t01.zzmattim_pl) as zzmattim_pl,
                max(t01.zzfppsmoe) as zzfppsmoe
         from lads_mat_zmc t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks);
      rcd_lads_mat_zmc  csr_lads_mat_zmc%rowtype;

      cursor csr_lads_mat_mpm is
         select nvl(t01.ertag,'*NONE') as ertag,
                max(t01.msgfn) as msgfn,
                max(t01.prwrt) as prwrt,
                max(t01.koprw) as koprw,
                max(t01.saiin) as saiin,
                max(t01.fixkz) as fixkz,
                max(t01.exprw) as exprw,
                max(t01.antei) as antei
         from lads_mat_mpm t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks)
         group by nvl(t01.ertag,'*NONE');
      rcd_lads_mat_mpm  csr_lads_mat_mpm%rowtype;

      cursor csr_lads_mat_mpv is
         select nvl(t01.verid,'*NONE') as verid,
                max(t01.msgfn) as msgfn,
                max(t01.bdatu) as bdatu,
                max(t01.adatu) as adatu,
                max(t01.stlal) as stlal,
                max(t01.stlan) as stlan,
                max(t01.plnty) as plnty,
                max(t01.plnnr) as plnnr,
                max(t01.alnal) as alnal,
                max(t01.beskz) as beskz,
                max(t01.sobsl) as sobsl,
                max(t01.losgr) as losgr,
                max(t01.mdv01) as mdv01,
                max(t01.mdv02) as mdv02,
                max(t01.text1) as text1,
                max(t01.ewahr) as ewahr,
                max(t01.verto) as verto,
                max(t01.serkz) as serkz,
                max(t01.bstmi) as bstmi,
                max(t01.bstma) as bstma,
                max(t01.rgekz) as rgekz,
                max(t01.alort) as alort,
                max(t01.pltyg) as pltyg,
                max(t01.plnng) as plnng,
                max(t01.alnag) as alnag,
                max(t01.pltym) as pltym,
                max(t01.plnnm) as plnnm,
                max(t01.alnam) as alnam,
                max(t01.csplt) as csplt,
                max(t01.matko) as matko,
                max(t01.elpro) as elpro,
                max(t01.prvbe) as prvbe,
                max(t01.matko_external) as matko_external,
                max(t01.matko_version) as matko_version,
                max(t01.matko_guid) as matko_guid
         from lads_mat_mpv t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks)
         group by nvl(t01.verid,'*NONE');
      rcd_lads_mat_mpv  csr_lads_mat_mpv%rowtype;

      cursor csr_lads_mat_mrd is
         select nvl(t01.lgort,'*NONE') as lgort,
                max(t01.msgfn) as msgfn,
                max(t01.pstat) as pstat,
                max(t01.lvorm) as lvorm,
                max(t01.diskz) as diskz,
                max(t01.lsobs) as lsobs,
                max(t01.lminb) as lminb,
                max(t01.lbstf) as lbstf,
                max(t01.herkl) as herkl,
                max(t01.exppg) as exppg,
                max(t01.exver) as exver,
                max(t01.lgpbe) as lgpbe,
                max(t01.prctl) as prctl,
                max(t01.lwmkb) as lwmkb,
                max(t01.bskrf) as bskrf
         from lads_mat_mrd t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks)
         group by nvl(t01.lgort,'*NONE');
      rcd_lads_mat_mrd  csr_lads_mat_mrd%rowtype;

      cursor csr_lads_mat_mum is
         select nvl(t01.ertag,'*NONE') as ertag,
                max(t01.msgfn) as msgfn,
                max(t01.vbwrt) as vbwrt,
                max(t01.kovbw) as kovbw,
                max(t01.kzexi) as kzexi,
                max(t01.antei) as antei
         from lads_mat_mum t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks)
         group by nvl(t01.ertag,'*NONE');
      rcd_lads_mat_mum  csr_lads_mat_mum%rowtype;

      cursor csr_lads_mat_mvm is
         select nvl(t01.ertag,'*NONE') as ertag,
                max(t01.msgfn) as msgfn,
                max(t01.vbwrt) as vbwrt,
                max(t01.kovbw) as kovbw,
                max(t01.kzexi) as kzexi,
                max(t01.antei) as antei
         from lads_mat_mvm t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and t01.mrcseq in (select t01.mrcseq
                              from lads_mat_mrc t01
                              where t01.matnr = rcd_lads_mat_hdr.matnr
                                and nvl(t01.werks,'*NONE') = rcd_lads_mat_mrc.werks)
         group by nvl(t01.ertag,'*NONE');
      rcd_lads_mat_mvm  csr_lads_mat_mvm%rowtype;

      cursor csr_lads_mat_pkg_instr_hdr is
         select nvl(t01.kvewe,'*NONE') as kvewe,
                nvl(to_char(t01.kotabnr),'*NONE') as kotabnr,
                nvl(t01.kschl,'*NONE') as kschl,
                nvl(t01.kappl,'*NONE') as kappl,
                nvl(t01.vkorg,'*NONE') as vkorg,
                t02.datab as datab,
                t02.datbi as datbi,
                max(t02.packnr) as packnr,
                max(t01.vakey) as vakey,
                max(t02.packnr1) as packnr1,
                max(t02.packnr2) as packnr2,
                max(t02.packnr3) as packnr3,
                max(t02.packnr4) as packnr4,
                max(t03.height) as height,
                max(t03.width) as width,
                max(t03.length) as length,
                max(t03.tarewei) as tarewei,
                max(t03.loadwei) as loadwei,
                max(t03.totlwei) as totlwei,
                max(t03.tarevol) as tarevol,
                max(t03.loadvol) as loadvol,
                max(t03.totlvol) as totlvol,
                max(t03.pobjid) as pobjid,
                max(t03.stfac) as stfac,
                max(t03.chdat) as chdat,
                max(t03.unitdim) as unitdim,
                max(t03.unitwei) as unitwei,
                max(t03.unitwei_max) as unitwei_max,
                max(t03.unitvol) as unitvol,
                max(t03.unitvol_max) as unitvol_max
         from lads_mat_pch t01,
              lads_mat_pcr t02,
              lads_mat_pih t03
         where t01.matnr = t02.matnr(+)
           and t01.pchseq = t02.pchseq(+)
           and t02.matnr = t03.matnr(+)
           and t02.pchseq = t03.pchseq(+)
           and t02.pcrseq = t03.pcrseq(+)
           and t01.matnr = rcd_lads_mat_hdr.matnr
         group by nvl(t01.kvewe,'*NONE'), 
                  nvl(to_char(t01.kotabnr),'*NONE'), 
                  nvl(t01.kschl,'*NONE'), 
                  nvl(t01.kappl,'*NONE'), 
                  nvl(t01.vkorg,'*NONE'),
                  t02.datab,
                  t02.datbi;
      rcd_lads_mat_pkg_instr_hdr  csr_lads_mat_pkg_instr_hdr%rowtype;

      cursor csr_lads_mat_pid is
         select nvl(t01.detail_itemtype,'*NONE') as detail_itemtype,
                nvl(t01.component,'*NONE') as component,
                max(t01.trgqty) as trgqty,
                max(t01.minqty) as minqty,
                max(t01.rndqty) as rndqty,
                max(t01.unitqty) as unitqty,
                max(t01.indmapaco) as indmapaco
         from lads_mat_pid t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and (t01.pchseq, t01.pcrseq, t01.pihseq) in 
               (select t03.pchseq,
                       t03.pcrseq,
                       t03.pihseq
                from lads_mat_pch t01,
                     lads_mat_pcr t02,
                     lads_mat_pih t03
                where t01.matnr = t02.matnr
                  and t01.pchseq = t02.pchseq
                  and t02.matnr = t03.matnr
                  and t02.pchseq = t03.pchseq
                  and t02.pcrseq = t03.pcrseq
                  and t01.matnr = rcd_lads_mat_hdr.matnr
                  and nvl(t01.kvewe,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kvewe
                  and nvl(to_char(t01.kotabnr),'*NONE') = rcd_lads_mat_pkg_instr_hdr.kotabnr
                  and nvl(t01.kschl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kschl
                  and nvl(t01.kappl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kappl
                  and nvl(t01.vkorg,'*NONE') = rcd_lads_mat_pkg_instr_hdr.vkorg
                  and t02.datab = rcd_lads_mat_pkg_instr_hdr.datab
                  and t02.datbi = rcd_lads_mat_pkg_instr_hdr.datbi)
         group by nvl(t01.detail_itemtype,'*NONE'), 
                  nvl(t01.component,'*NONE');
      rcd_lads_mat_pid  csr_lads_mat_pid%rowtype;

      cursor csr_lads_mat_pie is
         select nvl(t01.ean11,'*NONE') as ean11,
                max(t01.eantp) as eantp,
                max(t01.hpean) as hpean
         from lads_mat_pie t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and (t01.pchseq, t01.pcrseq, t01.pihseq) in 
               (select t03.pchseq,
                       t03.pcrseq,
                       t03.pihseq
                from lads_mat_pch t01,
                     lads_mat_pcr t02,
                     lads_mat_pih t03
                where t01.matnr = t02.matnr
                  and t01.pchseq = t02.pchseq
                  and t02.matnr = t03.matnr
                  and t02.pchseq = t03.pchseq
                  and t02.pcrseq = t03.pcrseq
                  and t01.matnr = rcd_lads_mat_hdr.matnr
                  and nvl(t01.kvewe,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kvewe
                  and nvl(to_char(t01.kotabnr),'*NONE') = rcd_lads_mat_pkg_instr_hdr.kotabnr
                  and nvl(t01.kschl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kschl
                  and nvl(t01.kappl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kappl
                  and nvl(t01.vkorg,'*NONE') = rcd_lads_mat_pkg_instr_hdr.vkorg
                  and t02.datab = rcd_lads_mat_pkg_instr_hdr.datab
                  and t02.datbi = rcd_lads_mat_pkg_instr_hdr.datbi)
         group by nvl(t01.ean11,'*NONE');
      rcd_lads_mat_pie  csr_lads_mat_pie%rowtype;

      cursor csr_lads_mat_pim is
         select nvl(t01.moe,'*NONE') as moe,
                nvl(t01.usagecode,'*NONE') as usagecode,
                t01.datab as datab,
                t01.dated as dated
         from lads_mat_pim t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and (t01.pchseq, t01.pcrseq, t01.pihseq) in 
               (select t03.pchseq,
                       t03.pcrseq,
                       t03.pihseq
                from lads_mat_pch t01,
                     lads_mat_pcr t02,
                     lads_mat_pih t03
                where t01.matnr = t02.matnr
                  and t01.pchseq = t02.pchseq
                  and t02.matnr = t03.matnr
                  and t02.pchseq = t03.pchseq
                  and t02.pcrseq = t03.pcrseq
                  and t01.matnr = rcd_lads_mat_hdr.matnr
                  and nvl(t01.kvewe,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kvewe
                  and nvl(to_char(t01.kotabnr),'*NONE') = rcd_lads_mat_pkg_instr_hdr.kotabnr
                  and nvl(t01.kschl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kschl
                  and nvl(t01.kappl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kappl
                  and nvl(t01.vkorg,'*NONE') = rcd_lads_mat_pkg_instr_hdr.vkorg
                  and t02.datab = rcd_lads_mat_pkg_instr_hdr.datab
                  and t02.datbi = rcd_lads_mat_pkg_instr_hdr.datbi)
         group by nvl(t01.moe,'*NONE'), nvl(t01.usagecode,'*NONE'), t01.datab, t01.dated;
      rcd_lads_mat_pim  csr_lads_mat_pim%rowtype;

      cursor csr_lads_mat_pir is
         select nvl(t01.z_lcdid,'*NONE') as z_lcdid,
                nvl(t01.z_lcdnr,'*NONE') as z_lcdnr
         from lads_mat_pir t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and (t01.pchseq, t01.pcrseq, t01.pihseq) in 
               (select t03.pchseq,
                       t03.pcrseq,
                       t03.pihseq
                from lads_mat_pch t01,
                     lads_mat_pcr t02,
                     lads_mat_pih t03
                where t01.matnr = t02.matnr
                  and t01.pchseq = t02.pchseq
                  and t02.matnr = t03.matnr
                  and t02.pchseq = t03.pchseq
                  and t02.pcrseq = t03.pcrseq
                  and t01.matnr = rcd_lads_mat_hdr.matnr
                  and nvl(t01.kvewe,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kvewe
                  and nvl(to_char(t01.kotabnr),'*NONE') = rcd_lads_mat_pkg_instr_hdr.kotabnr
                  and nvl(t01.kschl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kschl
                  and nvl(t01.kappl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kappl
                  and nvl(t01.vkorg,'*NONE') = rcd_lads_mat_pkg_instr_hdr.vkorg
                  and t02.datab = rcd_lads_mat_pkg_instr_hdr.datab
                  and t02.datbi = rcd_lads_mat_pkg_instr_hdr.datbi)
         group by nvl(t01.z_lcdid,'*NONE'), nvl(t01.z_lcdnr,'*NONE');
      rcd_lads_mat_pir  csr_lads_mat_pir%rowtype;

      cursor csr_lads_mat_pit is
         select nvl(t01.spras,'*NONE') as spras,
                max(t01.content) as content
         from lads_mat_pit t01
         where t01.matnr = rcd_lads_mat_hdr.matnr
           and (t01.pchseq, t01.pcrseq, t01.pihseq) in 
               (select t03.pchseq,
                       t03.pcrseq,
                       t03.pihseq
                from lads_mat_pch t01,
                     lads_mat_pcr t02,
                     lads_mat_pih t03
                where t01.matnr = t02.matnr
                  and t01.pchseq = t02.pchseq
                  and t02.matnr = t03.matnr
                  and t02.pchseq = t03.pchseq
                  and t02.pcrseq = t03.pcrseq
                  and t01.matnr = rcd_lads_mat_hdr.matnr
                  and nvl(t01.kvewe,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kvewe
                  and nvl(to_char(t01.kotabnr),'*NONE') = rcd_lads_mat_pkg_instr_hdr.kotabnr
                  and nvl(t01.kschl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kschl
                  and nvl(t01.kappl,'*NONE') = rcd_lads_mat_pkg_instr_hdr.kappl
                  and nvl(t01.vkorg,'*NONE') = rcd_lads_mat_pkg_instr_hdr.vkorg
                  and t02.datab = rcd_lads_mat_pkg_instr_hdr.datab
                  and t02.datbi = rcd_lads_mat_pkg_instr_hdr.datbi)
         group by nvl(t01.spras,'*NONE');
      rcd_lads_mat_pit  csr_lads_mat_pit%rowtype;

      cursor csr_lads_material_plant_mfanz is	
         select t01.sap_material_code as sap_material_code, 
                t02.plant_code as plant_code,
                t01.mars_rprsnttv_item_code as mars_rprsnttv_item_code, 
                t01.bds_material_desc_en as bds_material_desc_en,
                t01.material_type as material_type,
                t01.material_grp as material_grp,
                t01.base_uom as base_uom,
                t01.order_unit as order_unit,
                t01.gross_weight as gross_weight,
                t01.net_weight as net_weight,
                t01.gross_weight_unit as gross_weight_unit,
                t01.length as length,
                t01.width as width,
                t01.height as height,
                t01.dimension_uom as dimension_uom,
                t01.interntl_article_no as interntl_article_no,
                t01.total_shelf_life as total_shelf_life,
                t01.mars_intrmdt_prdct_compnt_flag as mars_intrmdt_prdct_compnt_flag,
                t01.mars_merchandising_unit_flag as mars_merchandising_unit_flag,
                t01.mars_prmotional_material_flag as mars_prmotional_material_flag,
                t01.mars_retail_sales_unit_flag as mars_retail_sales_unit_flag,
                t01.mars_semi_finished_prdct_flag as mars_semi_finished_prdct_flag,
                t01.mars_rprsnttv_item_flag as mars_rprsnttv_item_flag,
                t01.mars_traded_unit_flag as mars_traded_unit_flag,
                t01.xplant_status as xplant_status,
                t01.xplant_status_valid as xplant_status_valid,
                t01.batch_mngmnt_reqrmnt_indctr as batch_mngmnt_reqrmnt_indctr,
                t02.mars_plant_material_type as mars_plant_material_type,
                t02.procurement_type as procurement_type,
                t02.special_procurement_type as special_procurement_type,
                t02.issue_storage_location as issue_storage_location,
                t02.mrp_controller as mrp_controller,
                t02.plant_specific_status_valid as plant_specific_status_valid,
                t02.deletion_indctr as deletion_indctr,
                t02.plant_specific_status as plant_specific_status,
                t02.assembly_scrap_percntg as assembly_scrap_percntg,
                t02.component_scrap_percntg as component_scrap_percntg,
                t02.backflush_indctr as backflush_indctr,
                t03.sales_text_147 as sales_text_147,
                t03.sales_text_149 as sales_text_149,
                t04.regional_code_10 as regional_code_10,
                t04.regional_code_18 as regional_code_18,
                t04.regional_code_17 as regional_code_17,
                t04.regional_code_19 as regional_code_19,
                t05.stndrd_price as stndrd_price,
                t05.price_unit as price_unit,
                t05.future_planned_price_1 as future_planned_price_1,
                t05.vltn_class as vltn_class,
                decode(t06.bds_pce_factor_from_base_uom,null,1,t06.bds_pce_factor_from_base_uom) as bds_pce_factor_from_base_uom,
                t06.mars_pce_item_code as mars_pce_item_code,
                t06.mars_pce_interntl_article_no as mars_pce_interntl_article_no,        
                t06.bds_sb_factor_from_base_uom as bds_sb_factor_from_base_uom,  
                t06.mars_sb_item_code as mars_sb_item_code,
                t02.effective_out_date,
                t02.discontinuation_indctr,
                t02.followup_material,
                t01.material_division,
                t02.mrp_type,
                t02.max_storage_prd,
                t02.max_storage_prd_unit
         from bds_material_hdr t01,
              bds_material_plant_hdr t02,
              (select sap_material_code,
                      max(case when sales_organisation = '147' then text end) as sales_text_147,
                      max(case when sales_organisation = '149' then text end) as sales_text_149
	       from bds_material_text_en
               where sales_organisation in ('147','149')
                 and dstrbtn_channel = '99'
               group by sap_material_code) t03,
              (select sap_material_code,
                      max(case when regional_code_id = '10' then regional_code end) as regional_code_10,
                      max(case when regional_code_id = '18' then regional_code end) as regional_code_18,
                      max(case when regional_code_id = '17' then regional_code end) as regional_code_17,
                      max(case when regional_code_id = '19' then regional_code end) as regional_code_19
               from bds_material_regional
               where regional_code_id in ('10', '18', '17', '19')
               group by sap_material_code) t04,
              bds_material_vltn t05,
              (select sap_material_code,
                      max(case when uom_code = 'PCE' then bds_factor_from_base_uom end) as bds_pce_factor_from_base_uom,
                      max(case when uom_code = 'PCE' then mars_pc_item_code end) as mars_pce_item_code,
                      max(case when uom_code = 'PCE' then interntl_article_no end) as mars_pce_interntl_article_no,
                      max(case when uom_code = 'SB' then bds_factor_from_base_uom end) as bds_sb_factor_from_base_uom,
                      max(case when uom_code = 'SB' then mars_pc_item_code end) as mars_sb_item_code
               from bds_material_uom
               where uom_code in ('PCE','SB')
               group by sap_material_code) t06
         where t01.sap_material_code = t02.sap_material_code
           and t01.mars_rprsnttv_item_code = t03.sap_material_code(+)
           and t01.sap_material_code = t04.sap_material_code(+)
           and t02.sap_material_code = t05.sap_material_code(+)
           and t02.plant_code = t05.vltn_area(+)
           and t01.sap_material_code = t06.sap_material_code(+)
           and t01.sap_material_code = rcd_lads_mat_hdr.matnr
           and t01.material_type IN ('ROH', 'VERP', 'NLAG', 'PIPE', 'FERT') -- all interested materials
           and t01.deletion_flag is null
           and (t02.plant_code like 'AU%' or t02.plant_code like 'NZ%') 
           and t02.deletion_indctr is null
           and t05.vltn_type(+) = '*NONE'
           and t05.deletion_indctr(+) is null;
      rcd_lads_material_plant_mfanz  csr_lads_material_plant_mfanz%rowtype;

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

      /*---------------------------------------*/
      /* DELETE BDS TABLES                     */
      /*---------------------------------------*/
      delete bds_material_plant_mfanz where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_hdr where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_det where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_ean where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_text where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_reg where sap_material_code = par_matnr;
      delete bds_material_pkg_instr_moe where sap_material_code = par_matnr;
      delete bds_material_plant_hdr where sap_material_code = par_matnr;
      delete bds_material_plant_forecast where sap_material_code = par_matnr;
      delete bds_material_plant_vrsn where sap_material_code = par_matnr;
      delete bds_material_plant_batch where sap_material_code = par_matnr;
      delete bds_material_plant_unp_cnsmptn where sap_material_code = par_matnr;
      delete bds_material_plant_ttl_cnsmptn where sap_material_code = par_matnr;
      delete bds_material_uom where sap_material_code = par_matnr;
      delete bds_material_uom_ean where sap_material_code = par_matnr;
      delete bds_material_regional where sap_material_code = par_matnr;
      delete bds_material_dstrbtn_chain where sap_material_code = par_matnr;
      delete bds_material_vltn where sap_material_code = par_matnr;
      delete bds_material_moe_grp where sap_material_code = par_matnr;
      delete bds_material_tax where sap_material_code = par_matnr;
      delete bds_material_text_en where sap_material_code = par_matnr;
      delete bds_material_text where sap_material_code = par_matnr;
      delete bds_material_moe where sap_material_code = par_matnr;
      delete bds_material_desc where sap_material_code = par_matnr;


      /*-*/
      /* Process Material header
      /*-*/
      open csr_lads_mat_hdr;
      fetch csr_lads_mat_hdr into rcd_lads_mat_hdr;
      if (csr_lads_mat_hdr%notfound) then
         raise_application_error(-20000, 'Material Header cursor not found');
      end if;
      close csr_lads_mat_hdr;

         rcd_bds_material_hdr.sap_material_code := rcd_lads_mat_hdr.matnr;
         rcd_bds_material_hdr.bds_material_desc_en := rcd_lads_mat_hdr.bds_material_desc_en;
         rcd_bds_material_hdr.sap_idoc_name := rcd_lads_mat_hdr.idoc_name;
         rcd_bds_material_hdr.sap_idoc_number := rcd_lads_mat_hdr.idoc_number;
         rcd_bds_material_hdr.sap_idoc_timestamp := rcd_lads_mat_hdr.idoc_timestamp;
         rcd_bds_material_hdr.bds_lads_date := rcd_lads_mat_hdr.lads_date;
         rcd_bds_material_hdr.bds_lads_status := rcd_lads_mat_hdr.lads_status;
         rcd_bds_material_hdr.creatn_user := rcd_lads_mat_hdr.ernam;
         rcd_bds_material_hdr.creatn_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_hdr.ersda,'yyyymmdd');
         rcd_bds_material_hdr.change_user := rcd_lads_mat_hdr.aenam;
         rcd_bds_material_hdr.change_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_hdr.laeda,'yyyymmdd');
         rcd_bds_material_hdr.maint_status := rcd_lads_mat_hdr.pstat;
         rcd_bds_material_hdr.deletion_flag := rcd_lads_mat_hdr.lvorm;
         rcd_bds_material_hdr.material_type := rcd_lads_mat_hdr.mtart;
         rcd_bds_material_hdr.industry_sector := rcd_lads_mat_hdr.mbrsh;
         rcd_bds_material_hdr.material_grp := rcd_lads_mat_hdr.matkl;
         rcd_bds_material_hdr.old_material_code := rcd_lads_mat_hdr.bismt;
         rcd_bds_material_hdr.base_uom := rcd_lads_mat_hdr.meins;
         rcd_bds_material_hdr.order_unit := rcd_lads_mat_hdr.bstme;
         rcd_bds_material_hdr.document_number := rcd_lads_mat_hdr.zeinr;
         rcd_bds_material_hdr.document_type := rcd_lads_mat_hdr.zeiar;
         rcd_bds_material_hdr.document_vrsn := rcd_lads_mat_hdr.zeivr;
         rcd_bds_material_hdr.document_page_frmt := rcd_lads_mat_hdr.zeifo;
         rcd_bds_material_hdr.document_change_no := rcd_lads_mat_hdr.aeszn;
         rcd_bds_material_hdr.document_page_no := rcd_lads_mat_hdr.blatt;
         rcd_bds_material_hdr.document_sheets_no := rcd_lads_mat_hdr.blanz;
         rcd_bds_material_hdr.inspection_memo := rcd_lads_mat_hdr.ferth;
         rcd_bds_material_hdr.prod_memo_page_frmt := rcd_lads_mat_hdr.formt;
         rcd_bds_material_hdr.material_dimension := rcd_lads_mat_hdr.groes;
         rcd_bds_material_hdr.basic_material_constituent := rcd_lads_mat_hdr.wrkst;
         rcd_bds_material_hdr.industry_stndrd_desc := rcd_lads_mat_hdr.normt;
         rcd_bds_material_hdr.design_office := rcd_lads_mat_hdr.labor;
         rcd_bds_material_hdr.purchasing_value_key := rcd_lads_mat_hdr.ekwsl;
         rcd_bds_material_hdr.gross_weight := rcd_lads_mat_hdr.brgew;
         rcd_bds_material_hdr.net_weight := rcd_lads_mat_hdr.ntgew;
         rcd_bds_material_hdr.gross_weight_unit := rcd_lads_mat_hdr.gewei;
         rcd_bds_material_hdr.volume := rcd_lads_mat_hdr.volum;
         rcd_bds_material_hdr.volume_unit := rcd_lads_mat_hdr.voleh;
         rcd_bds_material_hdr.contnr_reqrmnt := rcd_lads_mat_hdr.behvo;
         rcd_bds_material_hdr.storg_condtn := rcd_lads_mat_hdr.raube;
         rcd_bds_material_hdr.temprtr_condtn_indctr := rcd_lads_mat_hdr.tempb;
         rcd_bds_material_hdr.transprt_grp := rcd_lads_mat_hdr.tragr;
         rcd_bds_material_hdr.hazardous_material_no := rcd_lads_mat_hdr.stoff;
         rcd_bds_material_hdr.material_division := rcd_lads_mat_hdr.spart;
         rcd_bds_material_hdr.competitor := rcd_lads_mat_hdr.kunnr;
         rcd_bds_material_hdr.qty_print_slips := rcd_lads_mat_hdr.wesch;
         rcd_bds_material_hdr.procurement_rule := rcd_lads_mat_hdr.bwvor;
         rcd_bds_material_hdr.supply_src := rcd_lads_mat_hdr.bwscl;
         rcd_bds_material_hdr.season_ctgry := rcd_lads_mat_hdr.saiso;
         rcd_bds_material_hdr.label_type := rcd_lads_mat_hdr.etiar;
         rcd_bds_material_hdr.label_form := rcd_lads_mat_hdr.etifo;
         rcd_bds_material_hdr.interntl_article_no := rcd_lads_mat_hdr.ean11;
         rcd_bds_material_hdr.interntl_article_no_ctgry := rcd_lads_mat_hdr.numtp;
         rcd_bds_material_hdr.length := rcd_lads_mat_hdr.laeng;
         rcd_bds_material_hdr.width := rcd_lads_mat_hdr.breit;
         rcd_bds_material_hdr.height := rcd_lads_mat_hdr.hoehe;
         rcd_bds_material_hdr.dimension_uom := rcd_lads_mat_hdr.meabm;
         rcd_bds_material_hdr.prdct_hierachy := rcd_lads_mat_hdr.prdha;
         rcd_bds_material_hdr.cad_indictr := rcd_lads_mat_hdr.cadkz;
         rcd_bds_material_hdr.allowed_pkging_weight := rcd_lads_mat_hdr.ergew;
         rcd_bds_material_hdr.allowed_pkging_weight_unit := rcd_lads_mat_hdr.ergei;
         rcd_bds_material_hdr.allowed_pkging_volume := rcd_lads_mat_hdr.ervol;
         rcd_bds_material_hdr.allowed_pkging_volume_unit := rcd_lads_mat_hdr.ervoe;
         rcd_bds_material_hdr.hu_excess_weight_tolrnc := rcd_lads_mat_hdr.gewto;
         rcd_bds_material_hdr.hu_excess_volume_tolrnc := rcd_lads_mat_hdr.volto;
         rcd_bds_material_hdr.variable_order_unit_actv := rcd_lads_mat_hdr.vabme;
         rcd_bds_material_hdr.configurable_material := rcd_lads_mat_hdr.kzkfg;
         rcd_bds_material_hdr.batch_mngmnt_reqrmnt_indctr := rcd_lads_mat_hdr.xchpf;
         rcd_bds_material_hdr.pkging_material_type := rcd_lads_mat_hdr.vhart;
         rcd_bds_material_hdr.max_level_volume := rcd_lads_mat_hdr.fuelg;
         rcd_bds_material_hdr.stacking_fctr := rcd_lads_mat_hdr.stfak;
         rcd_bds_material_hdr.material_grp_pkging := rcd_lads_mat_hdr.magrv;
         rcd_bds_material_hdr.authrztn_grp := rcd_lads_mat_hdr.begru;
         rcd_bds_material_hdr.qm_procurement_actv := rcd_lads_mat_hdr.qmpur;
         rcd_bds_material_hdr.catalog_profile := rcd_lads_mat_hdr.rbnrm;
         rcd_bds_material_hdr.min_remaining_shelf_life := rcd_lads_mat_hdr.mhdrz;
         rcd_bds_material_hdr.total_shelf_life := rcd_lads_mat_hdr.mhdhb;
         rcd_bds_material_hdr.storg_percntg := rcd_lads_mat_hdr.mhdlp;
         rcd_bds_material_hdr.complt_maint_status := rcd_lads_mat_hdr.vpsta;
         rcd_bds_material_hdr.extrnl_material_grp := rcd_lads_mat_hdr.extwg;
         rcd_bds_material_hdr.xplant_status := rcd_lads_mat_hdr.mstae;
         rcd_bds_material_hdr.xdstrbtn_chain_status := rcd_lads_mat_hdr.mstav;
         rcd_bds_material_hdr.xplant_status_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_hdr.mstde,'yyyymmdd');
         rcd_bds_material_hdr.xdstrbtn_chain_status_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_hdr.mstdv,'yyyymmdd');
         rcd_bds_material_hdr.envrnmnt_relevant_indctr := rcd_lads_mat_hdr.kzumw;
         rcd_bds_material_hdr.prdct_alloctn_detrmntn_prcdr := rcd_lads_mat_hdr.kosch;
         rcd_bds_material_hdr.discount_in_kind := rcd_lads_mat_hdr.nrfhg;
         rcd_bds_material_hdr.manufctr_part_no := rcd_lads_mat_hdr.mfrpn;
         rcd_bds_material_hdr.manufctr_no := rcd_lads_mat_hdr.mfrnr;
         rcd_bds_material_hdr.to_material_no := rcd_lads_mat_hdr.bmatn;
         rcd_bds_material_hdr.manufctr_part_profile := rcd_lads_mat_hdr.mprof;
         rcd_bds_material_hdr.dangerous_goods_indctr := rcd_lads_mat_hdr.profl;
         rcd_bds_material_hdr.highly_vicsous_indctr := rcd_lads_mat_hdr.ihivi;
         rcd_bds_material_hdr.bulk_liqud_indctr := rcd_lads_mat_hdr.iloos;
         rcd_bds_material_hdr.closed_pkging_material := rcd_lads_mat_hdr.kzgvh;
         rcd_bds_material_hdr.apprvd_batch_rec_indctr := rcd_lads_mat_hdr.xgchp;
         rcd_bds_material_hdr.compltn_level := rcd_lads_mat_hdr.compl;
         rcd_bds_material_hdr.assign_effctvty_param := rcd_lads_mat_hdr.kzeff;
         rcd_bds_material_hdr.sled_rounding_rule := rcd_lads_mat_hdr.rdmhd;
         rcd_bds_material_hdr.prd_shelf_life_indctr := rcd_lads_mat_hdr.iprkz;
         rcd_bds_material_hdr.compostn_on_pkging := rcd_lads_mat_hdr.przus;
         rcd_bds_material_hdr.general_item_ctgry_grp := rcd_lads_mat_hdr.mtpos_mara;
         rcd_bds_material_hdr.hu_excess_weight_tolrnc_1 := rcd_lads_mat_hdr.gewto_new;
         rcd_bds_material_hdr.hu_excess_volume_tolrnc_1 := rcd_lads_mat_hdr.volto_new;
         rcd_bds_material_hdr.basic_material := rcd_lads_mat_hdr.wrkst_new;
         rcd_bds_material_hdr.change_no := rcd_lads_mat_hdr.aennr;
         rcd_bds_material_hdr.locked_indctr := rcd_lads_mat_hdr.matfi;
         rcd_bds_material_hdr.config_mngmnt_indctr := rcd_lads_mat_hdr.cmrel;
         rcd_bds_material_hdr.xplant_configurable_material := rcd_lads_mat_hdr.satnr;
         rcd_bds_material_hdr.sled_bbd := rcd_lads_mat_hdr.sled_bbd;
         rcd_bds_material_hdr.global_trade_item_variant := rcd_lads_mat_hdr.gtin_variant;
         rcd_bds_material_hdr.prepack_generic_material_no := rcd_lads_mat_hdr.gennr;
         rcd_bds_material_hdr.explicit_serial_no_level := rcd_lads_mat_hdr.serlv;
         rcd_bds_material_hdr.refrnc_material := rcd_lads_mat_hdr.rmatp;
         rcd_bds_material_hdr.mars_declrd_volume := rcd_lads_mat_hdr.zzdecvolum;
         rcd_bds_material_hdr.mars_declrd_volume_unit := rcd_lads_mat_hdr.zzdecvoleh;
         rcd_bds_material_hdr.mars_declrd_count := rcd_lads_mat_hdr.zzdeccount;
         rcd_bds_material_hdr.mars_declrd_count_uni := rcd_lads_mat_hdr.zzdeccounit;
         rcd_bds_material_hdr.mars_pre_promtd_weight := rcd_lads_mat_hdr.zzpproweight;
         rcd_bds_material_hdr.mars_pre_promtd_weight_unit := rcd_lads_mat_hdr.zzpprowunit;
         rcd_bds_material_hdr.mars_pre_promtd_volume := rcd_lads_mat_hdr.zzpprovolum;
         rcd_bds_material_hdr.mars_pre_promtd_volume_unit := rcd_lads_mat_hdr.zzpprovunit;
         rcd_bds_material_hdr.mars_pre_promtd_count := rcd_lads_mat_hdr.zzpprocount;
         rcd_bds_material_hdr.mars_pre_promtd_count_unit := rcd_lads_mat_hdr.zzpprocunit;
         rcd_bds_material_hdr.mars_zzalpha01 := rcd_lads_mat_hdr.zzalpha01;
         rcd_bds_material_hdr.mars_zzalpha02 := rcd_lads_mat_hdr.zzalpha02;
         rcd_bds_material_hdr.mars_zzalpha03 := rcd_lads_mat_hdr.zzalpha03;
         rcd_bds_material_hdr.mars_zzalpha04 := rcd_lads_mat_hdr.zzalpha04;
         rcd_bds_material_hdr.mars_zzalpha05 := rcd_lads_mat_hdr.zzalpha05;
         rcd_bds_material_hdr.mars_zzalpha06 := rcd_lads_mat_hdr.zzalpha06;
         rcd_bds_material_hdr.mars_zzalpha07 := rcd_lads_mat_hdr.zzalpha07;
         rcd_bds_material_hdr.mars_zzalpha08 := rcd_lads_mat_hdr.zzalpha08;
         rcd_bds_material_hdr.mars_zzalpha09 := rcd_lads_mat_hdr.zzalpha09;
         rcd_bds_material_hdr.mars_zzalpha10 := rcd_lads_mat_hdr.zzalpha10;
         rcd_bds_material_hdr.mars_zznum01 := rcd_lads_mat_hdr.zznum01;
         rcd_bds_material_hdr.mars_zznum02 := rcd_lads_mat_hdr.zznum02;
         rcd_bds_material_hdr.mars_zznum03 := rcd_lads_mat_hdr.zznum03;
         rcd_bds_material_hdr.mars_zznum04 := rcd_lads_mat_hdr.zznum04;
         rcd_bds_material_hdr.mars_zznum05 := rcd_lads_mat_hdr.zznum05;
         rcd_bds_material_hdr.mars_zznum06 := rcd_lads_mat_hdr.zznum06;
         rcd_bds_material_hdr.mars_zznum07 := rcd_lads_mat_hdr.zznum07;
         rcd_bds_material_hdr.mars_zznum08 := rcd_lads_mat_hdr.zznum08;
         rcd_bds_material_hdr.mars_zznum09 := rcd_lads_mat_hdr.zznum09;
         rcd_bds_material_hdr.mars_zznum10 := rcd_lads_mat_hdr.zznum10;
         rcd_bds_material_hdr.mars_zzcheck01 := rcd_lads_mat_hdr.zzcheck01;
         rcd_bds_material_hdr.mars_zzcheck02 := rcd_lads_mat_hdr.zzcheck02;
         rcd_bds_material_hdr.mars_zzcheck03 := rcd_lads_mat_hdr.zzcheck03;
         rcd_bds_material_hdr.mars_zzcheck04 := rcd_lads_mat_hdr.zzcheck04;
         rcd_bds_material_hdr.mars_zzcheck05 := rcd_lads_mat_hdr.zzcheck05;
         rcd_bds_material_hdr.mars_zzcheck06 := rcd_lads_mat_hdr.zzcheck06;
         rcd_bds_material_hdr.mars_zzcheck07 := rcd_lads_mat_hdr.zzcheck07;
         rcd_bds_material_hdr.mars_zzcheck08 := rcd_lads_mat_hdr.zzcheck08;
         rcd_bds_material_hdr.mars_zzcheck09 := rcd_lads_mat_hdr.zzcheck09;
         rcd_bds_material_hdr.mars_zzcheck10 := rcd_lads_mat_hdr.zzcheck10;
         rcd_bds_material_hdr.mars_plan_item_flag := rcd_lads_mat_hdr.zzplan_item;
         rcd_bds_material_hdr.mars_intrmdt_prdct_compnt_flag := rcd_lads_mat_hdr.zzisint;
         rcd_bds_material_hdr.mars_merchandising_unit_flag := rcd_lads_mat_hdr.zzismcu;
         rcd_bds_material_hdr.mars_prmotional_material_flag := rcd_lads_mat_hdr.zzispro;
         rcd_bds_material_hdr.mars_retail_sales_unit_flag := rcd_lads_mat_hdr.zzisrsu;
         rcd_bds_material_hdr.mars_shpping_contnr_flag := rcd_lads_mat_hdr.zzissc;
         rcd_bds_material_hdr.mars_semi_finished_prdct_flag := rcd_lads_mat_hdr.zzissfp;
         rcd_bds_material_hdr.mars_traded_unit_flag := rcd_lads_mat_hdr.zzistdu;
         rcd_bds_material_hdr.mars_rprsnttv_item_flag := rcd_lads_mat_hdr.zzistra;
         rcd_bds_material_hdr.mars_item_status_code := rcd_lads_mat_hdr.zzstatuscode;
         rcd_bds_material_hdr.mars_item_owner := rcd_lads_mat_hdr.zzitemowner;
         rcd_bds_material_hdr.mars_change_user := rcd_lads_mat_hdr.zzchangedby;
         rcd_bds_material_hdr.mars_day_lead_time := rcd_lads_mat_hdr.zzmattim;
         rcd_bds_material_hdr.mars_rprsnttv_item_code := rcd_lads_mat_hdr.zzrepmatnr;

      /*--------------------------*/
      /* UPDATE BDS_MATERIAL_HDR  */
      /*--------------------------*/
      update bds_material_hdr
         set bds_material_desc_en = rcd_bds_material_hdr.bds_material_desc_en,
             sap_idoc_name = rcd_bds_material_hdr.sap_idoc_name,
             sap_idoc_number = rcd_bds_material_hdr.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_material_hdr.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_material_hdr.bds_lads_date,
             bds_lads_status = rcd_bds_material_hdr.bds_lads_status,
             creatn_date = rcd_bds_material_hdr.creatn_date,
             creatn_user = rcd_bds_material_hdr.creatn_user,
             change_user = rcd_bds_material_hdr.change_user,
             change_date = rcd_bds_material_hdr.change_date,
             maint_status = rcd_bds_material_hdr.maint_status,
             deletion_flag = rcd_bds_material_hdr.deletion_flag,
             material_type = rcd_bds_material_hdr.material_type,
             industry_sector = rcd_bds_material_hdr.industry_sector,
             material_grp = rcd_bds_material_hdr.material_grp,
             old_material_code = rcd_bds_material_hdr.old_material_code,
             base_uom = rcd_bds_material_hdr.base_uom,
             order_unit = rcd_bds_material_hdr.order_unit,
             document_number = rcd_bds_material_hdr.document_number,
             document_type = rcd_bds_material_hdr.document_type,
             document_vrsn = rcd_bds_material_hdr.document_vrsn,
             document_page_frmt = rcd_bds_material_hdr.document_page_frmt,
             document_change_no = rcd_bds_material_hdr.document_change_no,
             document_page_no = rcd_bds_material_hdr.document_page_no,
             document_sheets_no = rcd_bds_material_hdr.document_sheets_no,
             inspection_memo = rcd_bds_material_hdr.inspection_memo,
             prod_memo_page_frmt = rcd_bds_material_hdr.prod_memo_page_frmt,
             material_dimension = rcd_bds_material_hdr.material_dimension,
             basic_material_constituent = rcd_bds_material_hdr.basic_material_constituent,
             industry_stndrd_desc = rcd_bds_material_hdr.industry_stndrd_desc,
             design_office = rcd_bds_material_hdr.design_office,
             purchasing_value_key = rcd_bds_material_hdr.purchasing_value_key,
             gross_weight = rcd_bds_material_hdr.gross_weight,
             net_weight = rcd_bds_material_hdr.net_weight,
             gross_weight_unit = rcd_bds_material_hdr.gross_weight_unit,
             volume = rcd_bds_material_hdr.volume,
             volume_unit = rcd_bds_material_hdr.volume_unit,
             contnr_reqrmnt = rcd_bds_material_hdr.contnr_reqrmnt,
             storg_condtn = rcd_bds_material_hdr.storg_condtn,
             temprtr_condtn_indctr = rcd_bds_material_hdr.temprtr_condtn_indctr,
             transprt_grp = rcd_bds_material_hdr.transprt_grp,
             hazardous_material_no = rcd_bds_material_hdr.hazardous_material_no,
             material_division = rcd_bds_material_hdr.material_division,
             competitor = rcd_bds_material_hdr.competitor,
             qty_print_slips = rcd_bds_material_hdr.qty_print_slips,
             procurement_rule = rcd_bds_material_hdr.procurement_rule,
             supply_src = rcd_bds_material_hdr.supply_src,
             season_ctgry = rcd_bds_material_hdr.season_ctgry,
             label_type = rcd_bds_material_hdr.label_type,
             label_form = rcd_bds_material_hdr.label_form,
             interntl_article_no = rcd_bds_material_hdr.interntl_article_no,
             interntl_article_no_ctgry = rcd_bds_material_hdr.interntl_article_no_ctgry,
             length = rcd_bds_material_hdr.length,
             width = rcd_bds_material_hdr.width,
             height = rcd_bds_material_hdr.height,
             dimension_uom = rcd_bds_material_hdr.dimension_uom,
             prdct_hierachy = rcd_bds_material_hdr.prdct_hierachy,
             cad_indictr = rcd_bds_material_hdr.cad_indictr,
             allowed_pkging_weight = rcd_bds_material_hdr.allowed_pkging_weight,
             allowed_pkging_weight_unit = rcd_bds_material_hdr.allowed_pkging_weight_unit,
             allowed_pkging_volume = rcd_bds_material_hdr.allowed_pkging_volume,
             allowed_pkging_volume_unit = rcd_bds_material_hdr.allowed_pkging_volume_unit,
             hu_excess_weight_tolrnc = rcd_bds_material_hdr.hu_excess_weight_tolrnc,
             hu_excess_volume_tolrnc = rcd_bds_material_hdr.hu_excess_volume_tolrnc,
             variable_order_unit_actv = rcd_bds_material_hdr.variable_order_unit_actv,
             configurable_material = rcd_bds_material_hdr.configurable_material,
             batch_mngmnt_reqrmnt_indctr = rcd_bds_material_hdr.batch_mngmnt_reqrmnt_indctr,
             pkging_material_type = rcd_bds_material_hdr.pkging_material_type,
             max_level_volume = rcd_bds_material_hdr.max_level_volume,
             stacking_fctr = rcd_bds_material_hdr.stacking_fctr,
             material_grp_pkging = rcd_bds_material_hdr.material_grp_pkging,
             authrztn_grp = rcd_bds_material_hdr.authrztn_grp,
             qm_procurement_actv = rcd_bds_material_hdr.qm_procurement_actv,
             catalog_profile = rcd_bds_material_hdr.catalog_profile,
             min_remaining_shelf_life = rcd_bds_material_hdr.min_remaining_shelf_life,
             total_shelf_life = rcd_bds_material_hdr.total_shelf_life,
             storg_percntg = rcd_bds_material_hdr.storg_percntg,
             complt_maint_status = rcd_bds_material_hdr.complt_maint_status,
             extrnl_material_grp = rcd_bds_material_hdr.extrnl_material_grp,
             xplant_status = rcd_bds_material_hdr.xplant_status,
             xdstrbtn_chain_status = rcd_bds_material_hdr.xdstrbtn_chain_status,
             xplant_status_valid = rcd_bds_material_hdr.xplant_status_valid,
             xdstrbtn_chain_status_valid = rcd_bds_material_hdr.xdstrbtn_chain_status_valid,
             envrnmnt_relevant_indctr = rcd_bds_material_hdr.envrnmnt_relevant_indctr,
             prdct_alloctn_detrmntn_prcdr = rcd_bds_material_hdr.prdct_alloctn_detrmntn_prcdr,
             discount_in_kind = rcd_bds_material_hdr.discount_in_kind,
             manufctr_part_no = rcd_bds_material_hdr.manufctr_part_no,
             manufctr_no = rcd_bds_material_hdr.manufctr_no,
             to_material_no = rcd_bds_material_hdr.to_material_no,
             manufctr_part_profile = rcd_bds_material_hdr.manufctr_part_profile,
             dangerous_goods_indctr = rcd_bds_material_hdr.dangerous_goods_indctr,
             highly_vicsous_indctr = rcd_bds_material_hdr.highly_vicsous_indctr,
             bulk_liqud_indctr = rcd_bds_material_hdr.bulk_liqud_indctr,
             closed_pkging_material = rcd_bds_material_hdr.closed_pkging_material,
             apprvd_batch_rec_indctr = rcd_bds_material_hdr.apprvd_batch_rec_indctr,
             compltn_level = rcd_bds_material_hdr.compltn_level,
             assign_effctvty_param = rcd_bds_material_hdr.assign_effctvty_param,
             sled_rounding_rule = rcd_bds_material_hdr.sled_rounding_rule,
             prd_shelf_life_indctr = rcd_bds_material_hdr.prd_shelf_life_indctr,
             compostn_on_pkging = rcd_bds_material_hdr.compostn_on_pkging,
             general_item_ctgry_grp = rcd_bds_material_hdr.general_item_ctgry_grp,
             hu_excess_weight_tolrnc_1 = rcd_bds_material_hdr.hu_excess_weight_tolrnc_1,
             hu_excess_volume_tolrnc_1 = rcd_bds_material_hdr.hu_excess_volume_tolrnc_1,
             basic_material = rcd_bds_material_hdr.basic_material,
             change_no = rcd_bds_material_hdr.change_no,
             locked_indctr = rcd_bds_material_hdr.locked_indctr,
             config_mngmnt_indctr = rcd_bds_material_hdr.config_mngmnt_indctr,
             xplant_configurable_material = rcd_bds_material_hdr.xplant_configurable_material,
             sled_bbd = rcd_bds_material_hdr.sled_bbd,
             global_trade_item_variant = rcd_bds_material_hdr.global_trade_item_variant,
             prepack_generic_material_no = rcd_bds_material_hdr.prepack_generic_material_no,
             explicit_serial_no_level = rcd_bds_material_hdr.explicit_serial_no_level,
             refrnc_material = rcd_bds_material_hdr.refrnc_material,
             mars_declrd_volume = rcd_bds_material_hdr.mars_declrd_volume,
             mars_declrd_volume_unit = rcd_bds_material_hdr.mars_declrd_volume_unit,
             mars_declrd_count = rcd_bds_material_hdr.mars_declrd_count,
             mars_declrd_count_uni = rcd_bds_material_hdr.mars_declrd_count_uni,
             mars_pre_promtd_weight = rcd_bds_material_hdr.mars_pre_promtd_weight,
             mars_pre_promtd_weight_unit = rcd_bds_material_hdr.mars_pre_promtd_weight_unit,
             mars_pre_promtd_volume = rcd_bds_material_hdr.mars_pre_promtd_volume,
             mars_pre_promtd_volume_unit = rcd_bds_material_hdr.mars_pre_promtd_volume_unit,
             mars_pre_promtd_count = rcd_bds_material_hdr.mars_pre_promtd_count,
             mars_pre_promtd_count_unit = rcd_bds_material_hdr.mars_pre_promtd_count_unit,
             mars_zzalpha01 = rcd_bds_material_hdr.mars_zzalpha01,
             mars_zzalpha02 = rcd_bds_material_hdr.mars_zzalpha02,
             mars_zzalpha03 = rcd_bds_material_hdr.mars_zzalpha03,
             mars_zzalpha04 = rcd_bds_material_hdr.mars_zzalpha04,
             mars_zzalpha05 = rcd_bds_material_hdr.mars_zzalpha05,
             mars_zzalpha06 = rcd_bds_material_hdr.mars_zzalpha06,
             mars_zzalpha07 = rcd_bds_material_hdr.mars_zzalpha07,
             mars_zzalpha08 = rcd_bds_material_hdr.mars_zzalpha08,
             mars_zzalpha09 = rcd_bds_material_hdr.mars_zzalpha09,
             mars_zzalpha10 = rcd_bds_material_hdr.mars_zzalpha10,
             mars_zznum01 = rcd_bds_material_hdr.mars_zznum01,
             mars_zznum02 = rcd_bds_material_hdr.mars_zznum02,
             mars_zznum03 = rcd_bds_material_hdr.mars_zznum03,
             mars_zznum04 = rcd_bds_material_hdr.mars_zznum04,
             mars_zznum05 = rcd_bds_material_hdr.mars_zznum05,
             mars_zznum06 = rcd_bds_material_hdr.mars_zznum06,
             mars_zznum07 = rcd_bds_material_hdr.mars_zznum07,
             mars_zznum08 = rcd_bds_material_hdr.mars_zznum08,
             mars_zznum09 = rcd_bds_material_hdr.mars_zznum09,
             mars_zznum10 = rcd_bds_material_hdr.mars_zznum10,
             mars_zzcheck01 = rcd_bds_material_hdr.mars_zzcheck01,
             mars_zzcheck02 = rcd_bds_material_hdr.mars_zzcheck02,
             mars_zzcheck03 = rcd_bds_material_hdr.mars_zzcheck03,
             mars_zzcheck04 = rcd_bds_material_hdr.mars_zzcheck04,
             mars_zzcheck05 = rcd_bds_material_hdr.mars_zzcheck05,
             mars_zzcheck06 = rcd_bds_material_hdr.mars_zzcheck06,
             mars_zzcheck07 = rcd_bds_material_hdr.mars_zzcheck07,
             mars_zzcheck08 = rcd_bds_material_hdr.mars_zzcheck08,
             mars_zzcheck09 = rcd_bds_material_hdr.mars_zzcheck09,
             mars_zzcheck10 = rcd_bds_material_hdr.mars_zzcheck10,
             mars_plan_item_flag = rcd_bds_material_hdr.mars_plan_item_flag,
             mars_intrmdt_prdct_compnt_flag = rcd_bds_material_hdr.mars_intrmdt_prdct_compnt_flag,
             mars_merchandising_unit_flag = rcd_bds_material_hdr.mars_merchandising_unit_flag,
             mars_prmotional_material_flag = rcd_bds_material_hdr.mars_prmotional_material_flag,
             mars_retail_sales_unit_flag = rcd_bds_material_hdr.mars_retail_sales_unit_flag,
             mars_shpping_contnr_flag = rcd_bds_material_hdr.mars_shpping_contnr_flag,
             mars_semi_finished_prdct_flag = rcd_bds_material_hdr.mars_semi_finished_prdct_flag,
             mars_traded_unit_flag = rcd_bds_material_hdr.mars_traded_unit_flag,
             mars_rprsnttv_item_flag = rcd_bds_material_hdr.mars_rprsnttv_item_flag,
             mars_item_status_code = rcd_bds_material_hdr.mars_item_status_code,
             mars_item_owner = rcd_bds_material_hdr.mars_item_owner,
             mars_change_user = rcd_bds_material_hdr.mars_change_user,
             mars_day_lead_time = rcd_bds_material_hdr.mars_day_lead_time,
             mars_rprsnttv_item_code = rcd_bds_material_hdr.mars_rprsnttv_item_code
      where sap_material_code = rcd_bds_material_hdr.sap_material_code;
      if (sql%notfound) then
         insert into bds_material_hdr
            (sap_material_code,
             bds_material_desc_en,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             creatn_date,
             creatn_user,
             change_user,
             change_date,
             maint_status,
             deletion_flag,
             material_type,
             industry_sector,
             material_grp,
             old_material_code,
             base_uom,
             order_unit,
             document_number,
             document_type,
             document_vrsn,
             document_page_frmt,
             document_change_no,
             document_page_no,
             document_sheets_no,
             inspection_memo,
             prod_memo_page_frmt,
             material_dimension,
             basic_material_constituent,
             industry_stndrd_desc,
             design_office,
             purchasing_value_key,
             gross_weight,
             net_weight,
             gross_weight_unit,
             volume,
             volume_unit,
             contnr_reqrmnt,
             storg_condtn,
             temprtr_condtn_indctr,
             transprt_grp,
             hazardous_material_no,
             material_division,
             competitor,
             qty_print_slips,
             procurement_rule,
             supply_src,
             season_ctgry,
             label_type,
             label_form,
             interntl_article_no,
             interntl_article_no_ctgry,
             length,
             width,
             height,
             dimension_uom,
             prdct_hierachy,
             cad_indictr,
             allowed_pkging_weight,
             allowed_pkging_weight_unit,
             allowed_pkging_volume,
             allowed_pkging_volume_unit,
             hu_excess_weight_tolrnc,
             hu_excess_volume_tolrnc,
             variable_order_unit_actv,
             configurable_material,
             batch_mngmnt_reqrmnt_indctr,
             pkging_material_type,
             max_level_volume,
             stacking_fctr,
             material_grp_pkging,
             authrztn_grp,
             qm_procurement_actv,
             catalog_profile,
             min_remaining_shelf_life,
             total_shelf_life,
             storg_percntg,
             complt_maint_status,
             extrnl_material_grp,
             xplant_status,
             xdstrbtn_chain_status,
             xplant_status_valid,
             xdstrbtn_chain_status_valid,
             envrnmnt_relevant_indctr,
             prdct_alloctn_detrmntn_prcdr,
             discount_in_kind,
             manufctr_part_no,
             manufctr_no,
             to_material_no,
             manufctr_part_profile,
             dangerous_goods_indctr,
             highly_vicsous_indctr,
             bulk_liqud_indctr,
             closed_pkging_material,
             apprvd_batch_rec_indctr,
             compltn_level,
             assign_effctvty_param,
             sled_rounding_rule,
             prd_shelf_life_indctr,
             compostn_on_pkging,
             general_item_ctgry_grp,
             hu_excess_weight_tolrnc_1,
             hu_excess_volume_tolrnc_1,
             basic_material,
             change_no,
             locked_indctr,
             config_mngmnt_indctr,
             xplant_configurable_material,
             sled_bbd,
             global_trade_item_variant,
             prepack_generic_material_no,
             explicit_serial_no_level,
             refrnc_material,
             mars_declrd_volume,
             mars_declrd_volume_unit,
             mars_declrd_count,
             mars_declrd_count_uni,
             mars_pre_promtd_weight,
             mars_pre_promtd_weight_unit,
             mars_pre_promtd_volume,
             mars_pre_promtd_volume_unit,
             mars_pre_promtd_count,
             mars_pre_promtd_count_unit,
             mars_zzalpha01,
             mars_zzalpha02,
             mars_zzalpha03,
             mars_zzalpha04,
             mars_zzalpha05,
             mars_zzalpha06,
             mars_zzalpha07,
             mars_zzalpha08,
             mars_zzalpha09,
             mars_zzalpha10,
             mars_zznum01,
             mars_zznum02,
             mars_zznum03,
             mars_zznum04,
             mars_zznum05,
             mars_zznum06,
             mars_zznum07,
             mars_zznum08,
             mars_zznum09,
             mars_zznum10,
             mars_zzcheck01,
             mars_zzcheck02,
             mars_zzcheck03,
             mars_zzcheck04,
             mars_zzcheck05,
             mars_zzcheck06,
             mars_zzcheck07,
             mars_zzcheck08,
             mars_zzcheck09,
             mars_zzcheck10,
             mars_plan_item_flag,
             mars_intrmdt_prdct_compnt_flag,
             mars_merchandising_unit_flag,
             mars_prmotional_material_flag,
             mars_retail_sales_unit_flag,
             mars_shpping_contnr_flag,
             mars_semi_finished_prdct_flag,
             mars_traded_unit_flag,
             mars_rprsnttv_item_flag,
             mars_item_status_code,
             mars_item_owner,
             mars_change_user,
             mars_day_lead_time,
             mars_rprsnttv_item_code)
          values
            (rcd_bds_material_hdr.sap_material_code,
             rcd_bds_material_hdr.bds_material_desc_en,
             rcd_bds_material_hdr.sap_idoc_name,
             rcd_bds_material_hdr.sap_idoc_number,
             rcd_bds_material_hdr.sap_idoc_timestamp,
             rcd_bds_material_hdr.bds_lads_date,
             rcd_bds_material_hdr.bds_lads_status,
             rcd_bds_material_hdr.creatn_date,
             rcd_bds_material_hdr.creatn_user,
             rcd_bds_material_hdr.change_user,
             rcd_bds_material_hdr.change_date,
             rcd_bds_material_hdr.maint_status,
             rcd_bds_material_hdr.deletion_flag,
             rcd_bds_material_hdr.material_type,
             rcd_bds_material_hdr.industry_sector,
             rcd_bds_material_hdr.material_grp,
             rcd_bds_material_hdr.old_material_code,
             rcd_bds_material_hdr.base_uom,
             rcd_bds_material_hdr.order_unit,
             rcd_bds_material_hdr.document_number,
             rcd_bds_material_hdr.document_type,
             rcd_bds_material_hdr.document_vrsn,
             rcd_bds_material_hdr.document_page_frmt,
             rcd_bds_material_hdr.document_change_no,
             rcd_bds_material_hdr.document_page_no,
             rcd_bds_material_hdr.document_sheets_no,
             rcd_bds_material_hdr.inspection_memo,
             rcd_bds_material_hdr.prod_memo_page_frmt,
             rcd_bds_material_hdr.material_dimension,
             rcd_bds_material_hdr.basic_material_constituent,
             rcd_bds_material_hdr.industry_stndrd_desc,
             rcd_bds_material_hdr.design_office,
             rcd_bds_material_hdr.purchasing_value_key,
             rcd_bds_material_hdr.gross_weight,
             rcd_bds_material_hdr.net_weight,
             rcd_bds_material_hdr.gross_weight_unit,
             rcd_bds_material_hdr.volume,
             rcd_bds_material_hdr.volume_unit,
             rcd_bds_material_hdr.contnr_reqrmnt,
             rcd_bds_material_hdr.storg_condtn,
             rcd_bds_material_hdr.temprtr_condtn_indctr,
             rcd_bds_material_hdr.transprt_grp,
             rcd_bds_material_hdr.hazardous_material_no,
             rcd_bds_material_hdr.material_division,
             rcd_bds_material_hdr.competitor,
             rcd_bds_material_hdr.qty_print_slips,
             rcd_bds_material_hdr.procurement_rule,
             rcd_bds_material_hdr.supply_src,
             rcd_bds_material_hdr.season_ctgry,
             rcd_bds_material_hdr.label_type,
             rcd_bds_material_hdr.label_form,
             rcd_bds_material_hdr.interntl_article_no,
             rcd_bds_material_hdr.interntl_article_no_ctgry,
             rcd_bds_material_hdr.length,
             rcd_bds_material_hdr.width,
             rcd_bds_material_hdr.height,
             rcd_bds_material_hdr.dimension_uom,
             rcd_bds_material_hdr.prdct_hierachy,
             rcd_bds_material_hdr.cad_indictr,
             rcd_bds_material_hdr.allowed_pkging_weight,
             rcd_bds_material_hdr.allowed_pkging_weight_unit,
             rcd_bds_material_hdr.allowed_pkging_volume,
             rcd_bds_material_hdr.allowed_pkging_volume_unit,
             rcd_bds_material_hdr.hu_excess_weight_tolrnc,
             rcd_bds_material_hdr.hu_excess_volume_tolrnc,
             rcd_bds_material_hdr.variable_order_unit_actv,
             rcd_bds_material_hdr.configurable_material,
             rcd_bds_material_hdr.batch_mngmnt_reqrmnt_indctr,
             rcd_bds_material_hdr.pkging_material_type,
             rcd_bds_material_hdr.max_level_volume,
             rcd_bds_material_hdr.stacking_fctr,
             rcd_bds_material_hdr.material_grp_pkging,
             rcd_bds_material_hdr.authrztn_grp,
             rcd_bds_material_hdr.qm_procurement_actv,
             rcd_bds_material_hdr.catalog_profile,
             rcd_bds_material_hdr.min_remaining_shelf_life,
             rcd_bds_material_hdr.total_shelf_life,
             rcd_bds_material_hdr.storg_percntg,
             rcd_bds_material_hdr.complt_maint_status,
             rcd_bds_material_hdr.extrnl_material_grp,
             rcd_bds_material_hdr.xplant_status,
             rcd_bds_material_hdr.xdstrbtn_chain_status,
             rcd_bds_material_hdr.xplant_status_valid,
             rcd_bds_material_hdr.xdstrbtn_chain_status_valid,
             rcd_bds_material_hdr.envrnmnt_relevant_indctr,
             rcd_bds_material_hdr.prdct_alloctn_detrmntn_prcdr,
             rcd_bds_material_hdr.discount_in_kind,
             rcd_bds_material_hdr.manufctr_part_no,
             rcd_bds_material_hdr.manufctr_no,
             rcd_bds_material_hdr.to_material_no,
             rcd_bds_material_hdr.manufctr_part_profile,
             rcd_bds_material_hdr.dangerous_goods_indctr,
             rcd_bds_material_hdr.highly_vicsous_indctr,
             rcd_bds_material_hdr.bulk_liqud_indctr,
             rcd_bds_material_hdr.closed_pkging_material,
             rcd_bds_material_hdr.apprvd_batch_rec_indctr,
             rcd_bds_material_hdr.compltn_level,
             rcd_bds_material_hdr.assign_effctvty_param,
             rcd_bds_material_hdr.sled_rounding_rule,
             rcd_bds_material_hdr.prd_shelf_life_indctr,
             rcd_bds_material_hdr.compostn_on_pkging,
             rcd_bds_material_hdr.general_item_ctgry_grp,
             rcd_bds_material_hdr.hu_excess_weight_tolrnc_1,
             rcd_bds_material_hdr.hu_excess_volume_tolrnc_1,
             rcd_bds_material_hdr.basic_material,
             rcd_bds_material_hdr.change_no,
             rcd_bds_material_hdr.locked_indctr,
             rcd_bds_material_hdr.config_mngmnt_indctr,
             rcd_bds_material_hdr.xplant_configurable_material,
             rcd_bds_material_hdr.sled_bbd,
             rcd_bds_material_hdr.global_trade_item_variant,
             rcd_bds_material_hdr.prepack_generic_material_no,
             rcd_bds_material_hdr.explicit_serial_no_level,
             rcd_bds_material_hdr.refrnc_material,
             rcd_bds_material_hdr.mars_declrd_volume,
             rcd_bds_material_hdr.mars_declrd_volume_unit,
             rcd_bds_material_hdr.mars_declrd_count,
             rcd_bds_material_hdr.mars_declrd_count_uni,
             rcd_bds_material_hdr.mars_pre_promtd_weight,
             rcd_bds_material_hdr.mars_pre_promtd_weight_unit,
             rcd_bds_material_hdr.mars_pre_promtd_volume,
             rcd_bds_material_hdr.mars_pre_promtd_volume_unit,
             rcd_bds_material_hdr.mars_pre_promtd_count,
             rcd_bds_material_hdr.mars_pre_promtd_count_unit,
             rcd_bds_material_hdr.mars_zzalpha01,
             rcd_bds_material_hdr.mars_zzalpha02,
             rcd_bds_material_hdr.mars_zzalpha03,
             rcd_bds_material_hdr.mars_zzalpha04,
             rcd_bds_material_hdr.mars_zzalpha05,
             rcd_bds_material_hdr.mars_zzalpha06,
             rcd_bds_material_hdr.mars_zzalpha07,
             rcd_bds_material_hdr.mars_zzalpha08,
             rcd_bds_material_hdr.mars_zzalpha09,
             rcd_bds_material_hdr.mars_zzalpha10,
             rcd_bds_material_hdr.mars_zznum01,
             rcd_bds_material_hdr.mars_zznum02,
             rcd_bds_material_hdr.mars_zznum03,
             rcd_bds_material_hdr.mars_zznum04,
             rcd_bds_material_hdr.mars_zznum05,
             rcd_bds_material_hdr.mars_zznum06,
             rcd_bds_material_hdr.mars_zznum07,
             rcd_bds_material_hdr.mars_zznum08,
             rcd_bds_material_hdr.mars_zznum09,
             rcd_bds_material_hdr.mars_zznum10,
             rcd_bds_material_hdr.mars_zzcheck01,
             rcd_bds_material_hdr.mars_zzcheck02,
             rcd_bds_material_hdr.mars_zzcheck03,
             rcd_bds_material_hdr.mars_zzcheck04,
             rcd_bds_material_hdr.mars_zzcheck05,
             rcd_bds_material_hdr.mars_zzcheck06,
             rcd_bds_material_hdr.mars_zzcheck07,
             rcd_bds_material_hdr.mars_zzcheck08,
             rcd_bds_material_hdr.mars_zzcheck09,
             rcd_bds_material_hdr.mars_zzcheck10,
             rcd_bds_material_hdr.mars_plan_item_flag,
             rcd_bds_material_hdr.mars_intrmdt_prdct_compnt_flag,
             rcd_bds_material_hdr.mars_merchandising_unit_flag,
             rcd_bds_material_hdr.mars_prmotional_material_flag,
             rcd_bds_material_hdr.mars_retail_sales_unit_flag,
             rcd_bds_material_hdr.mars_shpping_contnr_flag,
             rcd_bds_material_hdr.mars_semi_finished_prdct_flag,
             rcd_bds_material_hdr.mars_traded_unit_flag,
             rcd_bds_material_hdr.mars_rprsnttv_item_flag,
             rcd_bds_material_hdr.mars_item_status_code,
             rcd_bds_material_hdr.mars_item_owner,
             rcd_bds_material_hdr.mars_change_user,
             rcd_bds_material_hdr.mars_day_lead_time,
             rcd_bds_material_hdr.mars_rprsnttv_item_code);
      end if;

      /*-*/
      /* Process Material Description
      /*-*/
      open csr_lads_mat_mkt;
      loop
         fetch csr_lads_mat_mkt into rcd_lads_mat_mkt;
         if (csr_lads_mat_mkt%notfound) then
            exit;
         end if;

         rcd_bds_material_desc.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_desc.material_desc := rcd_lads_mat_mkt.maktx;
         rcd_bds_material_desc.desc_language := rcd_lads_mat_mkt.spras_iso;
         rcd_bds_material_desc.sap_function := rcd_lads_mat_mkt.msgfn;

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_DESC   */
         /*----------------------------*/
         insert into bds_material_desc
            (sap_material_code,
             material_desc,
             desc_language,
             sap_function)
          values 
            (rcd_bds_material_desc.sap_material_code,
             rcd_bds_material_desc.material_desc,
             rcd_bds_material_desc.desc_language,
             rcd_bds_material_desc.sap_function);

      end loop;
      close csr_lads_mat_mkt;

      /*-*/
      /* Process Material Mars Organisational Entity (MOE)
      /*-*/
      open csr_lads_mat_moe;
      loop
         fetch csr_lads_mat_moe into rcd_lads_mat_moe;
         if (csr_lads_mat_moe%notfound) then
            exit;
         end if;

         rcd_bds_material_moe.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_moe.usage_code := rcd_lads_mat_moe.usagecode;
         rcd_bds_material_moe.moe_code := rcd_lads_mat_moe.moe;
         rcd_bds_material_moe.start_date := bds_date.bds_to_date('*START_DATE',rcd_lads_mat_moe.datab,'yyyymmdd');
         rcd_bds_material_moe.end_date := bds_date.bds_to_date('*END_DATE',rcd_lads_mat_moe.dated,'yyyymmdd');

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_MOE    */
         /*----------------------------*/
         insert into bds_material_moe
            (sap_material_code,
             usage_code,
             moe_code,
             start_date,
             end_date)
          values 
            (rcd_bds_material_moe.sap_material_code,
             rcd_bds_material_moe.usage_code,
             rcd_bds_material_moe.moe_code,
             rcd_bds_material_moe.start_date,
             rcd_bds_material_moe.end_date);

      end loop;
      close csr_lads_mat_moe;

      /*-*/
      /* Process Material Text
      /*-*/
      open csr_lads_mat_txh;
      loop
         fetch csr_lads_mat_txh into rcd_lads_mat_txh;
         if (csr_lads_mat_txh%notfound) then
            exit;
         end if;

         rcd_bds_material_text.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_text.text_object := rcd_lads_mat_txh.tdobject;
         rcd_bds_material_text.text_name := rcd_lads_mat_txh.tdname;
         rcd_bds_material_text.text_id := rcd_lads_mat_txh.tdid;
         rcd_bds_material_text.text_type := rcd_lads_mat_txh.tdtexttype;
         rcd_bds_material_text.text_language := rcd_lads_mat_txh.spras_iso;
         rcd_bds_material_text.sap_function := rcd_lads_mat_txh.msgfn;
         rcd_bds_material_text.text := bds_material.join_text_lines(par_matnr, rcd_lads_mat_txh.txhseq);

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_TEXT   */
         /*----------------------------*/
         insert into bds_material_text
            (sap_material_code,
             text_object,
             text_name,
             text_id,
             text_type,
             text_language,
             text,
             sap_function)
          values 
            (rcd_bds_material_text.sap_material_code,
             rcd_bds_material_text.text_object,
             rcd_bds_material_text.text_name,
             rcd_bds_material_text.text_id,
             rcd_bds_material_text.text_type,
             rcd_bds_material_text.text_language,
             rcd_bds_material_text.text,
             rcd_bds_material_text.sap_function);

      end loop;
      close csr_lads_mat_txh;

      /*-*/
      /* Process Material Text
      /*-*/
      open csr_lads_mat_text_en;
      loop
         fetch csr_lads_mat_text_en into rcd_lads_mat_text_en;
         if (csr_lads_mat_text_en%notfound) then
            exit;
         end if;

         rcd_bds_material_text_en.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_text_en.sales_organisation := rcd_lads_mat_text_en.sales_organisation;
         rcd_bds_material_text_en.dstrbtn_channel := rcd_lads_mat_text_en.dstrbtn_channel;
         rcd_bds_material_text_en.text := bds_material.join_text_lines(par_matnr, rcd_lads_mat_text_en.txhseq);

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_TEXT_EN*/
         /*----------------------------*/
         insert into bds_material_text_en
            (sap_material_code,
             sales_organisation,
             dstrbtn_channel,
             text)
          values 
            (rcd_bds_material_text.sap_material_code,
             rcd_bds_material_text_en.sales_organisation,
             rcd_bds_material_text_en.dstrbtn_channel,
             rcd_bds_material_text_en.text);

      end loop;
      close csr_lads_mat_text_en;

      /*-*/
      /* Process Material Tax
      /*-*/
      open csr_lads_mat_tax;
      loop
         fetch csr_lads_mat_tax into rcd_lads_mat_tax;
         if (csr_lads_mat_tax%notfound) then
            exit;
         end if;

         rcd_bds_material_tax.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_tax.sap_function := rcd_lads_mat_tax.msgfn;
         rcd_bds_material_tax.departure_cntry := rcd_lads_mat_tax.aland;
         rcd_bds_material_tax.tax_ctgry_01 := rcd_lads_mat_tax.taty1;
         rcd_bds_material_tax.tax_classfctn_01 := rcd_lads_mat_tax.taxm1;
         rcd_bds_material_tax.tax_ctgry_02 := rcd_lads_mat_tax.taty2;
         rcd_bds_material_tax.tax_classfctn_02 := rcd_lads_mat_tax.taxm2;
         rcd_bds_material_tax.tax_ctgry_03 := rcd_lads_mat_tax.taty3;
         rcd_bds_material_tax.tax_classfctn_03 := rcd_lads_mat_tax.taxm3;
         rcd_bds_material_tax.tax_ctgry_04 := rcd_lads_mat_tax.taty4;
         rcd_bds_material_tax.tax_classfctn_04 := rcd_lads_mat_tax.taxm4;
         rcd_bds_material_tax.tax_ctgry_05 := rcd_lads_mat_tax.taty5;
         rcd_bds_material_tax.tax_classfctn_05 := rcd_lads_mat_tax.taxm5;
         rcd_bds_material_tax.tax_ctgry_06 := rcd_lads_mat_tax.taty6;
         rcd_bds_material_tax.tax_classfctn_06 := rcd_lads_mat_tax.taxm6;
         rcd_bds_material_tax.tax_ctgry_07 := rcd_lads_mat_tax.taty7;
         rcd_bds_material_tax.tax_classfctn_07 := rcd_lads_mat_tax.taxm7;
         rcd_bds_material_tax.tax_ctgry_08 := rcd_lads_mat_tax.taty8;
         rcd_bds_material_tax.tax_classfctn_08 := rcd_lads_mat_tax.taxm8;
         rcd_bds_material_tax.tax_ctgry_09 := rcd_lads_mat_tax.taty9;
         rcd_bds_material_tax.tax_classfctn_09 := rcd_lads_mat_tax.taxm9;
         rcd_bds_material_tax.tax_indctr := rcd_lads_mat_tax.taxim;

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_TAX    */
         /*----------------------------*/
         insert into bds_material_tax
            (sap_material_code,
             sap_function,
             departure_cntry,
             tax_ctgry_01,
             tax_classfctn_01,
             tax_ctgry_02,
             tax_classfctn_02,
             tax_ctgry_03,
             tax_classfctn_03,
             tax_ctgry_04,
             tax_classfctn_04,
             tax_ctgry_05,
             tax_classfctn_05,
             tax_ctgry_06,
             tax_classfctn_06,
             tax_ctgry_07,
             tax_classfctn_07,
             tax_ctgry_08,
             tax_classfctn_08,
             tax_ctgry_09,
             tax_classfctn_09,
             tax_indctr)
          values 
            (rcd_bds_material_tax.sap_material_code,
             rcd_bds_material_tax.sap_function,
             rcd_bds_material_tax.departure_cntry,
             rcd_bds_material_tax.tax_ctgry_01,
             rcd_bds_material_tax.tax_classfctn_01,
             rcd_bds_material_tax.tax_ctgry_02,
             rcd_bds_material_tax.tax_classfctn_02,
             rcd_bds_material_tax.tax_ctgry_03,
             rcd_bds_material_tax.tax_classfctn_03,
             rcd_bds_material_tax.tax_ctgry_04,
             rcd_bds_material_tax.tax_classfctn_04,
             rcd_bds_material_tax.tax_ctgry_05,
             rcd_bds_material_tax.tax_classfctn_05,
             rcd_bds_material_tax.tax_ctgry_06,
             rcd_bds_material_tax.tax_classfctn_06,
             rcd_bds_material_tax.tax_ctgry_07,
             rcd_bds_material_tax.tax_classfctn_07,
             rcd_bds_material_tax.tax_ctgry_08,
             rcd_bds_material_tax.tax_classfctn_08,
             rcd_bds_material_tax.tax_ctgry_09,
             rcd_bds_material_tax.tax_classfctn_09,
             rcd_bds_material_tax.tax_indctr);

      end loop;
      close csr_lads_mat_tax;

      /*-*/
      /* Process MOE Group
      /*-*/
      open csr_lads_mat_gme;
      loop
         fetch csr_lads_mat_gme into rcd_lads_mat_gme;
         if (csr_lads_mat_gme%notfound) then
            exit;
         end if;

         rcd_bds_material_moe_grp.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_moe_grp.grp_type_code := rcd_lads_mat_gme.grouptype;
         rcd_bds_material_moe_grp.grp_moe_code := rcd_lads_mat_gme.groupmoe;
         rcd_bds_material_moe_grp.usage_code := rcd_lads_mat_gme.usagecode;
         rcd_bds_material_moe_grp.start_date := bds_date.bds_to_date('*START_DATE',rcd_lads_mat_gme.datab,'yyyymmdd');
         rcd_bds_material_moe_grp.end_date := bds_date.bds_to_date('*END_DATE',rcd_lads_mat_gme.dated,'yyyymmdd');

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_MOE_GRP*/
         /*----------------------------*/
         insert into bds_material_moe_grp
            (sap_material_code,
             grp_type_code,
             grp_moe_code,
             usage_code,
             start_date,
             end_date)
          values 
            (rcd_bds_material_moe_grp.sap_material_code,
             rcd_bds_material_moe_grp.grp_type_code,
             rcd_bds_material_moe_grp.grp_moe_code,
             rcd_bds_material_moe_grp.usage_code,
             rcd_bds_material_moe_grp.start_date,
             rcd_bds_material_moe_grp.end_date);

      end loop;
      close csr_lads_mat_gme;

      /*-*/
      /* Process Material Valuation
      /*-*/
      open csr_lads_mat_mbe;
      loop
         fetch csr_lads_mat_mbe into rcd_lads_mat_mbe;
         if (csr_lads_mat_mbe%notfound) then
            exit;
         end if;

         rcd_bds_material_vltn.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_vltn.vltn_area := rcd_lads_mat_mbe.bwkey;
         rcd_bds_material_vltn.vltn_type := rcd_lads_mat_mbe.bwtar;
         rcd_bds_material_vltn.deletion_indctr := rcd_lads_mat_mbe.lvorm;
         rcd_bds_material_vltn.cmmrcl_law_level_1_price := rcd_lads_mat_mbe.bwprh;
         rcd_bds_material_vltn.cmmrcl_law_level_2_price := rcd_lads_mat_mbe.bwph1;
         rcd_bds_material_vltn.cmmrcl_law_level_3_price := rcd_lads_mat_mbe.vjbwh;
         rcd_bds_material_vltn.cost_element_sub_origin_grp := rcd_lads_mat_mbe.hrkft;
         rcd_bds_material_vltn.costed_qty_structure := rcd_lads_mat_mbe.ekalr;
         rcd_bds_material_vltn.costing_overhead_grp := rcd_lads_mat_mbe.kosgr;
         rcd_bds_material_vltn.curr_prd := rcd_lads_mat_mbe.lfmon;
         rcd_bds_material_vltn.curr_prd_fiscal_year := rcd_lads_mat_mbe.lfgja;
         rcd_bds_material_vltn.curr_prd_stndrd_cost_estimate := rcd_lads_mat_mbe.kalkl;
         rcd_bds_material_vltn.curr_prd_stndrd_cost_indctr := rcd_lads_mat_mbe.kalkz;
         rcd_bds_material_vltn.curr_stndrd_cost_fiscal_year := rcd_lads_mat_mbe.pdatl;
         rcd_bds_material_vltn.curr_stndrd_cost_vltn_vrnt := rcd_lads_mat_mbe.bwva2;
         rcd_bds_material_vltn.curr_stndrd_costing_vrsn := rcd_lads_mat_mbe.vers2;
         rcd_bds_material_vltn.future_planned_price := rcd_lads_mat_mbe.zplpr;
         rcd_bds_material_vltn.future_planned_price_1 := rcd_lads_mat_mbe.zplp1;
         rcd_bds_material_vltn.future_planned_price_1_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_mbe.zpld1,'yyyymmdd');
         rcd_bds_material_vltn.future_planned_price_2 := rcd_lads_mat_mbe.zplp2;
         rcd_bds_material_vltn.future_planned_price_2_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_mbe.zpld2,'yyyymmdd');
         rcd_bds_material_vltn.future_planned_price_3 := rcd_lads_mat_mbe.zplp3;
         rcd_bds_material_vltn.future_planned_price_3_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_mbe.zpld3,'yyyymmdd');
         rcd_bds_material_vltn.future_prd_stndrd_cost := rcd_lads_mat_mbe.pprdz;
         rcd_bds_material_vltn.future_price := rcd_lads_mat_mbe.zkprs;
         rcd_bds_material_vltn.future_stndrd_cost_fiscal_year := rcd_lads_mat_mbe.pdatz;
         rcd_bds_material_vltn.future_stndrd_cost_vltn_vrnt := rcd_lads_mat_mbe.bwva1;
         rcd_bds_material_vltn.future_stndrd_costing_vrsn := rcd_lads_mat_mbe.vers1;
         rcd_bds_material_vltn.ledger_active := rcd_lads_mat_mbe.mlmaa;
         rcd_bds_material_vltn.lifo_vltn_pool_no := rcd_lads_mat_mbe.mypol;
         rcd_bds_material_vltn.lowest_value_indctr := rcd_lads_mat_mbe.abwkz;
         rcd_bds_material_vltn.maint_status := rcd_lads_mat_mbe.pstat;
         rcd_bds_material_vltn.moving_price := rcd_lads_mat_mbe.verpr;
         rcd_bds_material_vltn.order_relevant := rcd_lads_mat_mbe.xlifo;
         rcd_bds_material_vltn.origin_1 := rcd_lads_mat_mbe.hkmat;
         rcd_bds_material_vltn.origin_2 := rcd_lads_mat_mbe.mtorg;
         rcd_bds_material_vltn.prd_curr_stndrd_cost := rcd_lads_mat_mbe.pprdl;
         rcd_bds_material_vltn.prd_prev_stndrd_cost := rcd_lads_mat_mbe.pprdv;
         rcd_bds_material_vltn.prdct_cost_estimate_1 := rcd_lads_mat_mbe.kaln1;
         rcd_bds_material_vltn.prdct_cost_estimate_2 := rcd_lads_mat_mbe.kalnr;
         rcd_bds_material_vltn.prev_planned_price := rcd_lads_mat_mbe.vplpr;
         rcd_bds_material_vltn.prev_prd_moving_price := rcd_lads_mat_mbe.vmver;
         rcd_bds_material_vltn.prev_prd_price_cntrl_indctr := rcd_lads_mat_mbe.vmvpr;
         rcd_bds_material_vltn.prev_prd_price_unit := rcd_lads_mat_mbe.vmpei;
         rcd_bds_material_vltn.prev_prd_stndrd_price := rcd_lads_mat_mbe.vmstp;
         rcd_bds_material_vltn.prev_prd_vltn_class := rcd_lads_mat_mbe.vmbkl;
         rcd_bds_material_vltn.prev_stndrd_cost_fiscal_year := rcd_lads_mat_mbe.pdatv;
         rcd_bds_material_vltn.prev_stndrd_cost_vltn_vrnt := rcd_lads_mat_mbe.bwva3;
         rcd_bds_material_vltn.prev_stndrd_costing_vrsn := rcd_lads_mat_mbe.vers3;
         rcd_bds_material_vltn.prev_year_moving_price := rcd_lads_mat_mbe.vjver;
         rcd_bds_material_vltn.prev_year_price_cntrl_indctr := rcd_lads_mat_mbe.vjvpr;
         rcd_bds_material_vltn.prev_year_price_unit := rcd_lads_mat_mbe.vjpei;
         rcd_bds_material_vltn.prev_year_stndrd_price := rcd_lads_mat_mbe.vjstp;
         rcd_bds_material_vltn.prev_year_vltn_class := rcd_lads_mat_mbe.vjbkl;
         rcd_bds_material_vltn.price_cntrl_indctr := rcd_lads_mat_mbe.vprsv;
         rcd_bds_material_vltn.price_determination_cntrl := rcd_lads_mat_mbe.mlast;
         rcd_bds_material_vltn.price_unit := rcd_lads_mat_mbe.peinh;
         rcd_bds_material_vltn.produced_inhouse := rcd_lads_mat_mbe.ownpr;
         rcd_bds_material_vltn.project_stock_vltn_class := rcd_lads_mat_mbe.qklas;
         rcd_bds_material_vltn.sales_order_stock_vltn_class := rcd_lads_mat_mbe.eklas;
         rcd_bds_material_vltn.sap_function := rcd_lads_mat_mbe.msgfn;
         rcd_bds_material_vltn.stndrd_price := rcd_lads_mat_mbe.stprs;
         rcd_bds_material_vltn.tax_cmmrcl_price_unit := rcd_lads_mat_mbe.bwpei;
         rcd_bds_material_vltn.tax_law_level_1_price := rcd_lads_mat_mbe.bwprs;
         rcd_bds_material_vltn.tax_law_level_2_price := rcd_lads_mat_mbe.bwps1;
         rcd_bds_material_vltn.tax_law_level_3_price := rcd_lads_mat_mbe.vjbws;
         rcd_bds_material_vltn.total_stock_in_prd_bfr_last := rcd_lads_mat_mbe.vvmlb;
         rcd_bds_material_vltn.total_stock_in_year_bfr_last := rcd_lads_mat_mbe.vvjlb;
         rcd_bds_material_vltn.usage := rcd_lads_mat_mbe.mtuse;
         rcd_bds_material_vltn.valid_from_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_mbe.zkdat,'yyyymmdd');
         rcd_bds_material_vltn.vltn_class := rcd_lads_mat_mbe.bklas;
         rcd_bds_material_vltn.vltn_ctgry := rcd_lads_mat_mbe.bwtty;
         rcd_bds_material_vltn.value_stock_in_prd_bfr_last := rcd_lads_mat_mbe.vvsal;

         /*------------------------------*/
         /* UPDATE BDS_MATERIAL_VLTN     */
         /*------------------------------*/
         insert into bds_material_vltn
            (sap_material_code,
             vltn_area,
             vltn_type,
             deletion_indctr,
             cmmrcl_law_level_1_price,
             cmmrcl_law_level_2_price,
             cmmrcl_law_level_3_price,
             cost_element_sub_origin_grp,
             costed_qty_structure,
             costing_overhead_grp,
             curr_prd,
             curr_prd_fiscal_year,
             curr_prd_stndrd_cost_estimate,
             curr_prd_stndrd_cost_indctr,
             curr_stndrd_cost_fiscal_year,
             curr_stndrd_cost_vltn_vrnt,
             curr_stndrd_costing_vrsn,
             future_planned_price,
             future_planned_price_1,
             future_planned_price_1_valid,
             future_planned_price_2,
             future_planned_price_2_valid,
             future_planned_price_3,
             future_planned_price_3_valid,
             future_prd_stndrd_cost,
             future_price,
             future_stndrd_cost_fiscal_year,
             future_stndrd_cost_vltn_vrnt,
             future_stndrd_costing_vrsn,
             ledger_active,
             lifo_vltn_pool_no,
             lowest_value_indctr,
             maint_status,
             moving_price,
             order_relevant,
             origin_1,
             origin_2,
             prd_curr_stndrd_cost,
             prd_prev_stndrd_cost,
             prdct_cost_estimate_1,
             prdct_cost_estimate_2,
             prev_planned_price,
             prev_prd_moving_price,
             prev_prd_price_cntrl_indctr,
             prev_prd_price_unit,
             prev_prd_stndrd_price,
             prev_prd_vltn_class,
             prev_stndrd_cost_fiscal_year,
             prev_stndrd_cost_vltn_vrnt,
             prev_stndrd_costing_vrsn,
             prev_year_moving_price,
             prev_year_price_cntrl_indctr,
             prev_year_price_unit,
             prev_year_stndrd_price,
             prev_year_vltn_class,
             price_cntrl_indctr,
             price_determination_cntrl,
             price_unit,
             produced_inhouse,
             project_stock_vltn_class,
             sales_order_stock_vltn_class,
             sap_function,
             stndrd_price,
             tax_cmmrcl_price_unit,
             tax_law_level_1_price,
             tax_law_level_2_price,
             tax_law_level_3_price,
             total_stock_in_prd_bfr_last,
             total_stock_in_year_bfr_last,
             usage,
             valid_from_date,
             vltn_class,
             vltn_ctgry,
             value_stock_in_prd_bfr_last)
          values 
            (rcd_bds_material_vltn.sap_material_code,
             rcd_bds_material_vltn.vltn_area,
             rcd_bds_material_vltn.vltn_type,
             rcd_bds_material_vltn.deletion_indctr,
             rcd_bds_material_vltn.cmmrcl_law_level_1_price,
             rcd_bds_material_vltn.cmmrcl_law_level_2_price,
             rcd_bds_material_vltn.cmmrcl_law_level_3_price,
             rcd_bds_material_vltn.cost_element_sub_origin_grp,
             rcd_bds_material_vltn.costed_qty_structure,
             rcd_bds_material_vltn.costing_overhead_grp,
             rcd_bds_material_vltn.curr_prd,
             rcd_bds_material_vltn.curr_prd_fiscal_year,
             rcd_bds_material_vltn.curr_prd_stndrd_cost_estimate,
             rcd_bds_material_vltn.curr_prd_stndrd_cost_indctr,
             rcd_bds_material_vltn.curr_stndrd_cost_fiscal_year,
             rcd_bds_material_vltn.curr_stndrd_cost_vltn_vrnt,
             rcd_bds_material_vltn.curr_stndrd_costing_vrsn,
             rcd_bds_material_vltn.future_planned_price,
             rcd_bds_material_vltn.future_planned_price_1,
             rcd_bds_material_vltn.future_planned_price_1_valid,
             rcd_bds_material_vltn.future_planned_price_2,
             rcd_bds_material_vltn.future_planned_price_2_valid,
             rcd_bds_material_vltn.future_planned_price_3,
             rcd_bds_material_vltn.future_planned_price_3_valid,
             rcd_bds_material_vltn.future_prd_stndrd_cost,
             rcd_bds_material_vltn.future_price,
             rcd_bds_material_vltn.future_stndrd_cost_fiscal_year,
             rcd_bds_material_vltn.future_stndrd_cost_vltn_vrnt,
             rcd_bds_material_vltn.future_stndrd_costing_vrsn,
             rcd_bds_material_vltn.ledger_active,
             rcd_bds_material_vltn.lifo_vltn_pool_no,
             rcd_bds_material_vltn.lowest_value_indctr,
             rcd_bds_material_vltn.maint_status,
             rcd_bds_material_vltn.moving_price,
             rcd_bds_material_vltn.order_relevant,
             rcd_bds_material_vltn.origin_1,
             rcd_bds_material_vltn.origin_2,
             rcd_bds_material_vltn.prd_curr_stndrd_cost,
             rcd_bds_material_vltn.prd_prev_stndrd_cost,
             rcd_bds_material_vltn.prdct_cost_estimate_1,
             rcd_bds_material_vltn.prdct_cost_estimate_2,
             rcd_bds_material_vltn.prev_planned_price,
             rcd_bds_material_vltn.prev_prd_moving_price,
             rcd_bds_material_vltn.prev_prd_price_cntrl_indctr,
             rcd_bds_material_vltn.prev_prd_price_unit,
             rcd_bds_material_vltn.prev_prd_stndrd_price,
             rcd_bds_material_vltn.prev_prd_vltn_class,
             rcd_bds_material_vltn.prev_stndrd_cost_fiscal_year,
             rcd_bds_material_vltn.prev_stndrd_cost_vltn_vrnt,
             rcd_bds_material_vltn.prev_stndrd_costing_vrsn,
             rcd_bds_material_vltn.prev_year_moving_price,
             rcd_bds_material_vltn.prev_year_price_cntrl_indctr,
             rcd_bds_material_vltn.prev_year_price_unit,
             rcd_bds_material_vltn.prev_year_stndrd_price,
             rcd_bds_material_vltn.prev_year_vltn_class,
             rcd_bds_material_vltn.price_cntrl_indctr,
             rcd_bds_material_vltn.price_determination_cntrl,
             rcd_bds_material_vltn.price_unit,
             rcd_bds_material_vltn.produced_inhouse,
             rcd_bds_material_vltn.project_stock_vltn_class,
             rcd_bds_material_vltn.sales_order_stock_vltn_class,
             rcd_bds_material_vltn.sap_function,
             rcd_bds_material_vltn.stndrd_price,
             rcd_bds_material_vltn.tax_cmmrcl_price_unit,
             rcd_bds_material_vltn.tax_law_level_1_price,
             rcd_bds_material_vltn.tax_law_level_2_price,
             rcd_bds_material_vltn.tax_law_level_3_price,
             rcd_bds_material_vltn.total_stock_in_prd_bfr_last,
             rcd_bds_material_vltn.total_stock_in_year_bfr_last,
             rcd_bds_material_vltn.usage,
             rcd_bds_material_vltn.valid_from_date,
             rcd_bds_material_vltn.vltn_class,
             rcd_bds_material_vltn.vltn_ctgry,
             rcd_bds_material_vltn.value_stock_in_prd_bfr_last);

      end loop;
      close csr_lads_mat_mbe;

      /*-*/
      /* Process Material Distribution Chain
      /*-*/
      open csr_lads_mat_sad;
      loop
         fetch csr_lads_mat_sad into rcd_lads_mat_sad;
         if (csr_lads_mat_sad%notfound) then
            exit;
         end if;

         rcd_bds_material_dstrbtn_chain.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_dstrbtn_chain.sap_function := rcd_lads_mat_sad.msgfn;
         rcd_bds_material_dstrbtn_chain.sales_organisation := rcd_lads_mat_sad.vkorg;
         rcd_bds_material_dstrbtn_chain.dstrbtn_channel := rcd_lads_mat_sad.vtweg;
         rcd_bds_material_dstrbtn_chain.dstrbtn_chain_delete_indctr := rcd_lads_mat_sad.lvorm;
         rcd_bds_material_dstrbtn_chain.material_stats_grp := rcd_lads_mat_sad.versg;
         rcd_bds_material_dstrbtn_chain.volume_rebate_grp := rcd_lads_mat_sad.bonus;
         rcd_bds_material_dstrbtn_chain.commission_grp := rcd_lads_mat_sad.provg;
         rcd_bds_material_dstrbtn_chain.cash_discount_indctr := rcd_lads_mat_sad.sktof;
         rcd_bds_material_dstrbtn_chain.dstrbtn_chain_status := rcd_lads_mat_sad.vmsta;
         rcd_bds_material_dstrbtn_chain.bds_dstrbtn_chain_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_sad.vmstd,'yyyymmdd');
         rcd_bds_material_dstrbtn_chain.base_uom_min_order_qty := rcd_lads_mat_sad.aumng;
         rcd_bds_material_dstrbtn_chain.min_delivery_qty := rcd_lads_mat_sad.lfmng;
         rcd_bds_material_dstrbtn_chain.min_make_order_qty := rcd_lads_mat_sad.efmng;
         rcd_bds_material_dstrbtn_chain.delivery_unit := rcd_lads_mat_sad.scmng;
         rcd_bds_material_dstrbtn_chain.delivery_unit_uom := rcd_lads_mat_sad.schme;
         rcd_bds_material_dstrbtn_chain.sales_unit := rcd_lads_mat_sad.vrkme;
         rcd_bds_material_dstrbtn_chain.item_ctgry_grp := rcd_lads_mat_sad.mtpos;
         rcd_bds_material_dstrbtn_chain.delivering_plant := rcd_lads_mat_sad.dwerk;
         rcd_bds_material_dstrbtn_chain.prdct_hierachy := rcd_lads_mat_sad.prodh;
         rcd_bds_material_dstrbtn_chain.pricing_refrnc_material := rcd_lads_mat_sad.pmatn;
         rcd_bds_material_dstrbtn_chain.material_pricing_grp := rcd_lads_mat_sad.kondm;
         rcd_bds_material_dstrbtn_chain.accnt_assgnmnt_grp := rcd_lads_mat_sad.ktgrm;
         rcd_bds_material_dstrbtn_chain.crpc_material_ctgry := rcd_lads_mat_sad.mvgr1;
         rcd_bds_material_dstrbtn_chain.material_grp_2 := rcd_lads_mat_sad.mvgr2;
         rcd_bds_material_dstrbtn_chain.material_grp_3 := rcd_lads_mat_sad.mvgr3;
         rcd_bds_material_dstrbtn_chain.material_grp_4 := rcd_lads_mat_sad.mvgr4;
         rcd_bds_material_dstrbtn_chain.material_grp_5 := rcd_lads_mat_sad.mvgr5;
         rcd_bds_material_dstrbtn_chain.assortment_grade := rcd_lads_mat_sad.sstuf;
         rcd_bds_material_dstrbtn_chain.external_assortment_priority := rcd_lads_mat_sad.pflks;
         rcd_bds_material_dstrbtn_chain.store_list_prcdr := rcd_lads_mat_sad.lstfl;
         rcd_bds_material_dstrbtn_chain.dstrbtn_center_list_prcdr := rcd_lads_mat_sad.lstvz;
         rcd_bds_material_dstrbtn_chain.list_function_actv := rcd_lads_mat_sad.lstak;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_1 := rcd_lads_mat_sad.prat1;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_2 := rcd_lads_mat_sad.prat2;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_3 := rcd_lads_mat_sad.prat3;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_4 := rcd_lads_mat_sad.prat4;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_5 := rcd_lads_mat_sad.prat5;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_6 := rcd_lads_mat_sad.prat6;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_7 := rcd_lads_mat_sad.prat7;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_8 := rcd_lads_mat_sad.prat8;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_9 := rcd_lads_mat_sad.prat9;
         rcd_bds_material_dstrbtn_chain.prdct_attribute_id_10 := rcd_lads_mat_sad.prata;
         rcd_bds_material_dstrbtn_chain.block_variable_sales_unit := rcd_lads_mat_sad.vavme;
         rcd_bds_material_dstrbtn_chain.rounding_profile := rcd_lads_mat_sad.rdprf;
         rcd_bds_material_dstrbtn_chain.uom_grp := rcd_lads_mat_sad.megru;
         rcd_bds_material_dstrbtn_chain.long_material_code := rcd_lads_mat_sad.pmatn_external;
         rcd_bds_material_dstrbtn_chain.vrsn_number := rcd_lads_mat_sad.pmatn_version;
         rcd_bds_material_dstrbtn_chain.external_guid := rcd_lads_mat_sad.pmatn_guid;
         rcd_bds_material_dstrbtn_chain.mars_logistics_point := rcd_lads_mat_sad.zzlogist_point;

         /*----------------------------------*/
         /* UPDATE BDS_MATERIAL_DSTRBTN_CHAIN*/
         /*----------------------------------*/
         insert into bds_material_dstrbtn_chain
            (sap_material_code,
             sap_function,
             sales_organisation,
             dstrbtn_channel,
             dstrbtn_chain_delete_indctr,
             material_stats_grp,
             volume_rebate_grp,
             commission_grp,
             cash_discount_indctr,
             dstrbtn_chain_status,
             bds_dstrbtn_chain_valid,
             base_uom_min_order_qty,
             min_delivery_qty,
             min_make_order_qty,
             delivery_unit,
             delivery_unit_uom,
             sales_unit,
             item_ctgry_grp,
             delivering_plant,
             prdct_hierachy,
             pricing_refrnc_material,
             material_pricing_grp,
             accnt_assgnmnt_grp,
             crpc_material_ctgry,
             material_grp_2,
             material_grp_3,
             material_grp_4,
             material_grp_5,
             assortment_grade,
             external_assortment_priority,
             store_list_prcdr,
             dstrbtn_center_list_prcdr,
             list_function_actv,
             prdct_attribute_id_1,
             prdct_attribute_id_2,
             prdct_attribute_id_3,
             prdct_attribute_id_4,
             prdct_attribute_id_5,
             prdct_attribute_id_6,
             prdct_attribute_id_7,
             prdct_attribute_id_8,
             prdct_attribute_id_9,
             prdct_attribute_id_10,
             block_variable_sales_unit,
             rounding_profile,
             uom_grp,
             long_material_code,
             vrsn_number,
             external_guid,
             mars_logistics_point)
          values 
            (rcd_bds_material_dstrbtn_chain.sap_material_code,
             rcd_bds_material_dstrbtn_chain.sap_function,
             rcd_bds_material_dstrbtn_chain.sales_organisation,
             rcd_bds_material_dstrbtn_chain.dstrbtn_channel,
             rcd_bds_material_dstrbtn_chain.dstrbtn_chain_delete_indctr,
             rcd_bds_material_dstrbtn_chain.material_stats_grp,
             rcd_bds_material_dstrbtn_chain.volume_rebate_grp,
             rcd_bds_material_dstrbtn_chain.commission_grp,
             rcd_bds_material_dstrbtn_chain.cash_discount_indctr,
             rcd_bds_material_dstrbtn_chain.dstrbtn_chain_status,
             rcd_bds_material_dstrbtn_chain.bds_dstrbtn_chain_valid,
             rcd_bds_material_dstrbtn_chain.base_uom_min_order_qty,
             rcd_bds_material_dstrbtn_chain.min_delivery_qty,
             rcd_bds_material_dstrbtn_chain.min_make_order_qty,
             rcd_bds_material_dstrbtn_chain.delivery_unit,
             rcd_bds_material_dstrbtn_chain.delivery_unit_uom,
             rcd_bds_material_dstrbtn_chain.sales_unit,
             rcd_bds_material_dstrbtn_chain.item_ctgry_grp,
             rcd_bds_material_dstrbtn_chain.delivering_plant,
             rcd_bds_material_dstrbtn_chain.prdct_hierachy,
             rcd_bds_material_dstrbtn_chain.pricing_refrnc_material,
             rcd_bds_material_dstrbtn_chain.material_pricing_grp,
             rcd_bds_material_dstrbtn_chain.accnt_assgnmnt_grp,
             rcd_bds_material_dstrbtn_chain.crpc_material_ctgry,
             rcd_bds_material_dstrbtn_chain.material_grp_2,
             rcd_bds_material_dstrbtn_chain.material_grp_3,
             rcd_bds_material_dstrbtn_chain.material_grp_4,
             rcd_bds_material_dstrbtn_chain.material_grp_5,
             rcd_bds_material_dstrbtn_chain.assortment_grade,
             rcd_bds_material_dstrbtn_chain.external_assortment_priority,
             rcd_bds_material_dstrbtn_chain.store_list_prcdr,
             rcd_bds_material_dstrbtn_chain.dstrbtn_center_list_prcdr,
             rcd_bds_material_dstrbtn_chain.list_function_actv,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_1,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_2,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_3,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_4,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_5,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_6,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_7,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_8,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_9,
             rcd_bds_material_dstrbtn_chain.prdct_attribute_id_10,
             rcd_bds_material_dstrbtn_chain.block_variable_sales_unit,
             rcd_bds_material_dstrbtn_chain.rounding_profile,
             rcd_bds_material_dstrbtn_chain.uom_grp,
             rcd_bds_material_dstrbtn_chain.long_material_code,
             rcd_bds_material_dstrbtn_chain.vrsn_number,
             rcd_bds_material_dstrbtn_chain.external_guid,
             rcd_bds_material_dstrbtn_chain.mars_logistics_point);

      end loop;
      close csr_lads_mat_sad;

      /*-*/
      /* Process Material Regional Code Conversion
      /*-*/
      open csr_lads_mat_lcd;
      loop
         fetch csr_lads_mat_lcd into rcd_lads_mat_lcd;
         if (csr_lads_mat_lcd%notfound) then
            exit;
         end if;

         rcd_bds_material_regional.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_regional.regional_code_id := rcd_lads_mat_lcd.z_lcdid;
         rcd_bds_material_regional.regional_code := rcd_lads_mat_lcd.z_lcdnr;

         /*--------------------------------*/
         /* UPDATE BDS_MATERIAL_REGIONAL   */
         /*--------------------------------*/
         insert into bds_material_regional
            (sap_material_code,
             regional_code_id,
             regional_code)
          values 
            (rcd_bds_material_regional.sap_material_code,
             rcd_bds_material_regional.regional_code_id,
             rcd_bds_material_regional.regional_code);

      end loop;
      close csr_lads_mat_lcd;

      /*-*/
      /* Process Material Unit of Measure Conversions
      /*-*/
      open csr_lads_mat_uom;
      loop
         fetch csr_lads_mat_uom into rcd_lads_mat_uom;
         if (csr_lads_mat_uom%notfound) then
            exit;
         end if;

         rcd_bds_material_uom.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_uom.uom_code := rcd_lads_mat_uom.meinh;
         rcd_bds_material_uom.sap_function := rcd_lads_mat_uom.msgfn;
         rcd_bds_material_uom.base_uom_numerator := rcd_lads_mat_uom.umrez;
         rcd_bds_material_uom.base_uom_denominator := rcd_lads_mat_uom.umren;
         rcd_bds_material_uom.interntl_article_no := rcd_lads_mat_uom.ean11;
         rcd_bds_material_uom.interntl_article_no_ctgry := rcd_lads_mat_uom.numtp;
         rcd_bds_material_uom.length := rcd_lads_mat_uom.laeng;
         rcd_bds_material_uom.width := rcd_lads_mat_uom.breit;
         rcd_bds_material_uom.height := rcd_lads_mat_uom.hoehe;
         rcd_bds_material_uom.dimension_uom := rcd_lads_mat_uom.meabm;
         rcd_bds_material_uom.volume := rcd_lads_mat_uom.volum;
         rcd_bds_material_uom.volume_unit := rcd_lads_mat_uom.voleh;
         rcd_bds_material_uom.gross_weight := rcd_lads_mat_uom.brgew;
         rcd_bds_material_uom.gross_weight_unit := rcd_lads_mat_uom.gewei;
         rcd_bds_material_uom.lower_level_hierachy_uom := rcd_lads_mat_uom.mesub;
         rcd_bds_material_uom.global_trade_item_variant := rcd_lads_mat_uom.gtin_variant;
         rcd_bds_material_uom.mars_mutli_convrsn_uom_indctr := rcd_lads_mat_uom.zzmultitdu;
         rcd_bds_material_uom.mars_pc_item_code := rcd_lads_mat_uom.zzpcitem;
         rcd_bds_material_uom.mars_pc_level := rcd_lads_mat_uom.zzpclevel;
         rcd_bds_material_uom.mars_order_uom_prfrnc_indctr := rcd_lads_mat_uom.zzpreforder;
         rcd_bds_material_uom.mars_sales_uom_prfrnc_indctr := rcd_lads_mat_uom.zzprefsales;
         rcd_bds_material_uom.mars_issue_uom_prfrnc_indctr := rcd_lads_mat_uom.zzprefissue;
         rcd_bds_material_uom.mars_wm_uom_prfrnc_indctr := rcd_lads_mat_uom.zzprefwm;
         rcd_bds_material_uom.mars_rprsnttv_material_code := rcd_lads_mat_uom.zzrefmatnr;

         /*-*/
         /* Calculate factor conversion to base UOM
         /*-*/
         case 
            when (rcd_bds_material_uom.base_uom_denominator is null or
                  rcd_bds_material_uom.base_uom_denominator = 0) then
               rcd_bds_material_uom.bds_factor_to_base_uom := 0;   
            else
               rcd_bds_material_uom.bds_factor_to_base_uom := rcd_bds_material_uom.base_uom_numerator/rcd_bds_material_uom.base_uom_denominator;      
         end case;

         /*-*/
         /* Calculate factor conversion from base UOM
         /*-*/
         case 
            when (rcd_bds_material_uom.base_uom_numerator is null or
                  rcd_bds_material_uom.base_uom_numerator = 0) then
               rcd_bds_material_uom.bds_factor_from_base_uom := 0;   
            else
               rcd_bds_material_uom.bds_factor_from_base_uom := rcd_bds_material_uom.base_uom_denominator/rcd_bds_material_uom.base_uom_numerator;      
         end case;

         /*----------------------------*/
         /* UPDATE BDS_MATERIAL_UOM    */
         /*----------------------------*/
         insert into bds_material_uom
            (sap_material_code,
             uom_code,
             sap_function,
             base_uom_numerator,
             base_uom_denominator,
             bds_factor_to_base_uom,
             bds_factor_from_base_uom,
             interntl_article_no,
             interntl_article_no_ctgry,
             length,
             width,
             height,
             dimension_uom,
             volume,
             volume_unit,
             gross_weight,
             gross_weight_unit,
             lower_level_hierachy_uom,
             global_trade_item_variant,
             mars_mutli_convrsn_uom_indctr,
             mars_pc_item_code,
             mars_pc_level,
             mars_order_uom_prfrnc_indctr,
             mars_sales_uom_prfrnc_indctr,
             mars_issue_uom_prfrnc_indctr,
             mars_wm_uom_prfrnc_indctr,
             mars_rprsnttv_material_code)
          values 
            (rcd_bds_material_uom.sap_material_code,
             rcd_bds_material_uom.uom_code,
             rcd_bds_material_uom.sap_function,
             rcd_bds_material_uom.base_uom_numerator,
             rcd_bds_material_uom.base_uom_denominator,
             rcd_bds_material_uom.bds_factor_to_base_uom,
             rcd_bds_material_uom.bds_factor_from_base_uom,
             rcd_bds_material_uom.interntl_article_no,
             rcd_bds_material_uom.interntl_article_no_ctgry,
             rcd_bds_material_uom.length,
             rcd_bds_material_uom.width,
             rcd_bds_material_uom.height,
             rcd_bds_material_uom.dimension_uom,
             rcd_bds_material_uom.volume,
             rcd_bds_material_uom.volume_unit,
             rcd_bds_material_uom.gross_weight,
             rcd_bds_material_uom.gross_weight_unit,
             rcd_bds_material_uom.lower_level_hierachy_uom,
             rcd_bds_material_uom.global_trade_item_variant,
             rcd_bds_material_uom.mars_mutli_convrsn_uom_indctr,
             rcd_bds_material_uom.mars_pc_item_code,
             rcd_bds_material_uom.mars_pc_level,
             rcd_bds_material_uom.mars_order_uom_prfrnc_indctr,
             rcd_bds_material_uom.mars_sales_uom_prfrnc_indctr,
             rcd_bds_material_uom.mars_issue_uom_prfrnc_indctr,
             rcd_bds_material_uom.mars_wm_uom_prfrnc_indctr,
             rcd_bds_material_uom.mars_rprsnttv_material_code);

         /*-*/
         /* Process Material Unit of Measure Conversions for EAN
         /*-*/
         open csr_lads_mat_uoe;
         loop
            fetch csr_lads_mat_uoe into rcd_lads_mat_uoe;
            if (csr_lads_mat_uoe%notfound) then
               exit;
            end if;

            rcd_bds_material_uom_ean.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_material_uom_ean.uom_code := rcd_bds_material_uom.uom_code;
            rcd_bds_material_uom_ean.consecutive_no := rcd_lads_mat_uoe.lfnum;
            rcd_bds_material_uom_ean.sap_function := rcd_lads_mat_uoe.msgfn;
            rcd_bds_material_uom_ean.interntl_article_no := rcd_lads_mat_uoe.ean11;
            rcd_bds_material_uom_ean.interntl_article_no_ctgry := rcd_lads_mat_uoe.eantp;
            rcd_bds_material_uom_ean.main_ean_indctr := rcd_lads_mat_uoe.hpean;

            /*-----------------------------*/
            /* UPDATE BDS_MATERIAL_UOM_EAN */
            /*-----------------------------*/
            insert into bds_material_uom_ean
               (sap_material_code,
                uom_code,
                consecutive_no,
                sap_function,
                interntl_article_no,
                interntl_article_no_ctgry,
                main_ean_indctr)
             values 
               (rcd_bds_material_uom_ean.sap_material_code,
                rcd_bds_material_uom_ean.uom_code,
                rcd_bds_material_uom_ean.consecutive_no,
                rcd_bds_material_uom_ean.sap_function,
                rcd_bds_material_uom_ean.interntl_article_no,
                rcd_bds_material_uom_ean.interntl_article_no_ctgry,
                rcd_bds_material_uom_ean.main_ean_indctr);

         end loop;
         close csr_lads_mat_uoe;

      end loop;
      close csr_lads_mat_uom;

      /*-*/
      /* Process Material Plant Header
      /*-*/
      open csr_lads_mat_mrc;
      loop
         fetch csr_lads_mat_mrc into rcd_lads_mat_mrc;
         if (csr_lads_mat_mrc%notfound) then
            exit;
         end if;

         rcd_bds_material_plant_hdr.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_plant_hdr.sap_function := rcd_lads_mat_mrc.msgfn;
         rcd_bds_material_plant_hdr.plant_code := rcd_lads_mat_mrc.werks;
         rcd_bds_material_plant_hdr.maint_status := rcd_lads_mat_mrc.pstat;
         rcd_bds_material_plant_hdr.deletion_indctr := rcd_lads_mat_mrc.lvorm;
         rcd_bds_material_plant_hdr.vltn_ctgry := rcd_lads_mat_mrc.bwtty;
         rcd_bds_material_plant_hdr.abc_indctr := rcd_lads_mat_mrc.maabc;
         rcd_bds_material_plant_hdr.critical_part_indctr := rcd_lads_mat_mrc.kzkri;
         rcd_bds_material_plant_hdr.purchasing_grp := rcd_lads_mat_mrc.ekgrp;
         rcd_bds_material_plant_hdr.issue_unit := rcd_lads_mat_mrc.ausme;
         rcd_bds_material_plant_hdr.mrp_profile := rcd_lads_mat_mrc.dispr;
         rcd_bds_material_plant_hdr.mrp_type := rcd_lads_mat_mrc.dismm;
         rcd_bds_material_plant_hdr.mrp_controller := rcd_lads_mat_mrc.dispo;
         rcd_bds_material_plant_hdr.planned_delivery_days := rcd_lads_mat_mrc.plifz;
         rcd_bds_material_plant_hdr.gr_processing_days := rcd_lads_mat_mrc.webaz;
         rcd_bds_material_plant_hdr.prd_indctr := rcd_lads_mat_mrc.perkz;
         rcd_bds_material_plant_hdr.assembly_scrap_percntg := rcd_lads_mat_mrc.ausss;
         rcd_bds_material_plant_hdr.lot_size := rcd_lads_mat_mrc.disls;
         rcd_bds_material_plant_hdr.procurement_type := rcd_lads_mat_mrc.beskz;
         rcd_bds_material_plant_hdr.special_procurement_type := rcd_lads_mat_mrc.sobsl;
         rcd_bds_material_plant_hdr.reorder_point := rcd_lads_mat_mrc.minbe;
         rcd_bds_material_plant_hdr.safety_stock := rcd_lads_mat_mrc.eisbe;
         rcd_bds_material_plant_hdr.min_lot_size := rcd_lads_mat_mrc.bstmi;
         rcd_bds_material_plant_hdr.max_lot_size := rcd_lads_mat_mrc.bstma;
         rcd_bds_material_plant_hdr.fixed_lot_size := rcd_lads_mat_mrc.bstfe;
         rcd_bds_material_plant_hdr.purchase_order_qty_rounding := rcd_lads_mat_mrc.bstrf;
         rcd_bds_material_plant_hdr.max_stock_level := rcd_lads_mat_mrc.mabst;
         rcd_bds_material_plant_hdr.ordering_costs := rcd_lads_mat_mrc.losfx;
         rcd_bds_material_plant_hdr.dependent_reqrmnt_indctr := rcd_lads_mat_mrc.sbdkz;
         rcd_bds_material_plant_hdr.storage_cost_indctr := rcd_lads_mat_mrc.lagpr;
         rcd_bds_material_plant_hdr.altrntv_bom_select_method := rcd_lads_mat_mrc.altsl;
         rcd_bds_material_plant_hdr.discontinuation_indctr := rcd_lads_mat_mrc.kzaus;
         rcd_bds_material_plant_hdr.effective_out_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_mrc.ausdt,'yyyymmdd');
         rcd_bds_material_plant_hdr.followup_material := rcd_lads_mat_mrc.nfmat;
         rcd_bds_material_plant_hdr.reqrmnts_grping_indctr := rcd_lads_mat_mrc.kzbed;
         rcd_bds_material_plant_hdr.mixed_mrp_indctr := rcd_lads_mat_mrc.miskz;
         rcd_bds_material_plant_hdr.float_schedule_margin_key := rcd_lads_mat_mrc.fhori;
         rcd_bds_material_plant_hdr.planned_order_auto_fix_indctr := rcd_lads_mat_mrc.pfrei;
         rcd_bds_material_plant_hdr.prdctn_order_release_indctr := rcd_lads_mat_mrc.ffrei;
         rcd_bds_material_plant_hdr.backflush_indctr := rcd_lads_mat_mrc.rgekz;
         rcd_bds_material_plant_hdr.prdctn_scheduler := rcd_lads_mat_mrc.fevor;
         rcd_bds_material_plant_hdr.processing_time := rcd_lads_mat_mrc.bearz;
         rcd_bds_material_plant_hdr.configuration_time := rcd_lads_mat_mrc.ruezt;
         rcd_bds_material_plant_hdr.interoperation_time := rcd_lads_mat_mrc.tranz;
         rcd_bds_material_plant_hdr.base_qty := rcd_lads_mat_mrc.basmg;
         rcd_bds_material_plant_hdr.inhouse_prdctn_time := rcd_lads_mat_mrc.dzeit;
         rcd_bds_material_plant_hdr.max_storage_prd := rcd_lads_mat_mrc.maxlz;
         rcd_bds_material_plant_hdr.max_storage_prd_unit := rcd_lads_mat_mrc.lzeih;
         rcd_bds_material_plant_hdr.prdctn_bin_withdraw_indctr := rcd_lads_mat_mrc.kzpro;
         rcd_bds_material_plant_hdr.roughcut_planning_indctr := rcd_lads_mat_mrc.gpmkz;
         rcd_bds_material_plant_hdr.over_delivery_tolrnc_limit := rcd_lads_mat_mrc.ueeto;
         rcd_bds_material_plant_hdr.over_delivery_allowed_indctr := rcd_lads_mat_mrc.ueetk;
         rcd_bds_material_plant_hdr.under_delivery_tolrnc_limit := rcd_lads_mat_mrc.uneto;
         rcd_bds_material_plant_hdr.replenishment_lead_time := rcd_lads_mat_mrc.wzeit;
         rcd_bds_material_plant_hdr.replacement_part_indctr := rcd_lads_mat_mrc.atpkz;
         rcd_bds_material_plant_hdr.surcharge_factor := rcd_lads_mat_mrc.vzusl;
         rcd_bds_material_plant_hdr.manufacture_status := rcd_lads_mat_mrc.herbl;
         rcd_bds_material_plant_hdr.inspection_stock_post_indctr := rcd_lads_mat_mrc.insmk;
         rcd_bds_material_plant_hdr.qa_control_key := rcd_lads_mat_mrc.ssqss;
         rcd_bds_material_plant_hdr.documentation_reqrd_indctr := rcd_lads_mat_mrc.kzdkz;
         rcd_bds_material_plant_hdr.stock_transfer := rcd_lads_mat_mrc.umlmc;
         rcd_bds_material_plant_hdr.loading_grp := rcd_lads_mat_mrc.ladgr;
         rcd_bds_material_plant_hdr.batch_manage_reqrmnt_indctr := rcd_lads_mat_mrc.xchpf;
         rcd_bds_material_plant_hdr.quota_arrangement_usage := rcd_lads_mat_mrc.usequ;
         rcd_bds_material_plant_hdr.service_level := rcd_lads_mat_mrc.lgrad;
         rcd_bds_material_plant_hdr.splitting_indctr := rcd_lads_mat_mrc.auftl;
         rcd_bds_material_plant_hdr.plan_version := rcd_lads_mat_mrc.plvar;
         rcd_bds_material_plant_hdr.object_type := rcd_lads_mat_mrc.otype;
         rcd_bds_material_plant_hdr.object_id := rcd_lads_mat_mrc.objid;
         rcd_bds_material_plant_hdr.availability_check_grp := rcd_lads_mat_mrc.mtvfp;
         rcd_bds_material_plant_hdr.fiscal_year_variant := rcd_lads_mat_mrc.periv;
         rcd_bds_material_plant_hdr.correction_factor_indctr := rcd_lads_mat_mrc.kzkfk;
         rcd_bds_material_plant_hdr.shipping_setup_time := rcd_lads_mat_mrc.vrvez;
         rcd_bds_material_plant_hdr.capacity_planning_base_qty := rcd_lads_mat_mrc.vbamg;
         rcd_bds_material_plant_hdr.shipping_processing_time := rcd_lads_mat_mrc.vbeaz;
         rcd_bds_material_plant_hdr.delivery_cycle := rcd_lads_mat_mrc.lizyk;
         rcd_bds_material_plant_hdr.supply_source := rcd_lads_mat_mrc.bwscl;
         rcd_bds_material_plant_hdr.auto_purchase_order_indctr := rcd_lads_mat_mrc.kautb;
         rcd_bds_material_plant_hdr.source_list_reqrmnt_indctr := rcd_lads_mat_mrc.kordb;
         rcd_bds_material_plant_hdr.commodity_code := rcd_lads_mat_mrc.stawn;
         rcd_bds_material_plant_hdr.origin_country := rcd_lads_mat_mrc.herkl;
         rcd_bds_material_plant_hdr.origin_region := rcd_lads_mat_mrc.herkr;
         rcd_bds_material_plant_hdr.comodity_uom := rcd_lads_mat_mrc.expme;
         rcd_bds_material_plant_hdr.trade_grp := rcd_lads_mat_mrc.mtver;
         rcd_bds_material_plant_hdr.profit_center := rcd_lads_mat_mrc.prctr;
         rcd_bds_material_plant_hdr.stock_in_transit := rcd_lads_mat_mrc.trame;
         rcd_bds_material_plant_hdr.ppc_planning_calendar := rcd_lads_mat_mrc.mrppp;
         rcd_bds_material_plant_hdr.repetitive_manu_allowed_indctr := rcd_lads_mat_mrc.sauft;
         rcd_bds_material_plant_hdr.planning_time_fence := rcd_lads_mat_mrc.fxhor;
         rcd_bds_material_plant_hdr.consumption_mode := rcd_lads_mat_mrc.vrmod;
         rcd_bds_material_plant_hdr.consumption_prd_back := rcd_lads_mat_mrc.vint1;
         rcd_bds_material_plant_hdr.consumption_prd_forward := rcd_lads_mat_mrc.vint2;
         rcd_bds_material_plant_hdr.alternative_bom := rcd_lads_mat_mrc.stlal;
         rcd_bds_material_plant_hdr.bom_usage := rcd_lads_mat_mrc.stlan;
         rcd_bds_material_plant_hdr.task_list_grp_key := rcd_lads_mat_mrc.plnnr;
         rcd_bds_material_plant_hdr.grp_counter := rcd_lads_mat_mrc.aplal;
         rcd_bds_material_plant_hdr.prdct_costing_lot_size := rcd_lads_mat_mrc.losgr;
         rcd_bds_material_plant_hdr.special_cost_procurement_type := rcd_lads_mat_mrc.sobsk;
         rcd_bds_material_plant_hdr.production_unit := rcd_lads_mat_mrc.frtme;
         rcd_bds_material_plant_hdr.issue_storage_location := rcd_lads_mat_mrc.lgpro;
         rcd_bds_material_plant_hdr.mrp_group := rcd_lads_mat_mrc.disgr;
         rcd_bds_material_plant_hdr.component_scrap_percntg := rcd_lads_mat_mrc.kausf;
         rcd_bds_material_plant_hdr.certificate_type := rcd_lads_mat_mrc.qzgtp;
         rcd_bds_material_plant_hdr.takt_time := rcd_lads_mat_mrc.takzt;
         rcd_bds_material_plant_hdr.coverage_profile := rcd_lads_mat_mrc.rwpro;
         rcd_bds_material_plant_hdr.local_field_name := rcd_lads_mat_mrc.copam;
         rcd_bds_material_plant_hdr.physical_inventory_indctr := rcd_lads_mat_mrc.abcin;
         rcd_bds_material_plant_hdr.variance_key := rcd_lads_mat_mrc.awsls;
         rcd_bds_material_plant_hdr.serial_number_profile := rcd_lads_mat_mrc.sernp;
         rcd_bds_material_plant_hdr.configurable_material := rcd_lads_mat_mrc.stdpd;
         rcd_bds_material_plant_hdr.repetitive_manu_profile := rcd_lads_mat_mrc.sfepr;
         rcd_bds_material_plant_hdr.negative_stocks_allowed_indctr := rcd_lads_mat_mrc.xmcng;
         rcd_bds_material_plant_hdr.reqrd_qm_vendor_system := rcd_lads_mat_mrc.qssys;
         rcd_bds_material_plant_hdr.planning_cycle := rcd_lads_mat_mrc.lfrhy;
         rcd_bds_material_plant_hdr.rounding_profile := rcd_lads_mat_mrc.rdprf;
         rcd_bds_material_plant_hdr.refrnc_consumption_material := rcd_lads_mat_mrc.vrbmt;
         rcd_bds_material_plant_hdr.refrnc_consumption_plant := rcd_lads_mat_mrc.vrbwk;
         rcd_bds_material_plant_hdr.consumption_material_copy_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_mrc.vrbdt,'yyyymmdd');
         rcd_bds_material_plant_hdr.refrnc_consumption_multiplier := rcd_lads_mat_mrc.vrbfk;
         rcd_bds_material_plant_hdr.auto_forecast_model_reset := rcd_lads_mat_mrc.autru;
         rcd_bds_material_plant_hdr.trade_prfrnc_indctr := rcd_lads_mat_mrc.prefe;
         rcd_bds_material_plant_hdr.exemption_certificate_indctr := rcd_lads_mat_mrc.prenc;
         rcd_bds_material_plant_hdr.exemption_certificate_qty := rcd_lads_mat_mrc.preno;
         rcd_bds_material_plant_hdr.exemption_certificate_issued := bds_date.bds_to_date('*DATE',rcd_lads_mat_mrc.prend,'yyyymmdd');
         rcd_bds_material_plant_hdr.vendor_declaration_indctr := rcd_lads_mat_mrc.prene;
         rcd_bds_material_plant_hdr.vendor_declaration_valid_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_mrc.preng,'yyyymmdd');
         rcd_bds_material_plant_hdr.military_goods_indctr := rcd_lads_mat_mrc.itark;
         rcd_bds_material_plant_hdr.char_field := rcd_lads_mat_mrc.prfrq;
         rcd_bds_material_plant_hdr.coprdct_material_indctr := rcd_lads_mat_mrc.kzkup;
         rcd_bds_material_plant_hdr.planning_strategy_grp := rcd_lads_mat_mrc.strgr;
         rcd_bds_material_plant_hdr.default_storage_location := rcd_lads_mat_mrc.lgfsb;
         rcd_bds_material_plant_hdr.bulk_material_indctr := rcd_lads_mat_mrc.schgt;
         rcd_bds_material_plant_hdr.fixed_cc_indctr := rcd_lads_mat_mrc.ccfix;
         rcd_bds_material_plant_hdr.stock_withdrawal_seq_grp := rcd_lads_mat_mrc.eprio;
         rcd_bds_material_plant_hdr.qm_activity_authorisation_grp := rcd_lads_mat_mrc.qmata;
         rcd_bds_material_plant_hdr.task_list_type := rcd_lads_mat_mrc.plnty;
         rcd_bds_material_plant_hdr.plant_specific_status := rcd_lads_mat_mrc.mmsta;
         rcd_bds_material_plant_hdr.prdctn_scheduling_profile := rcd_lads_mat_mrc.sfcpf;
         rcd_bds_material_plant_hdr.safety_time_indctr := rcd_lads_mat_mrc.shflg;
         rcd_bds_material_plant_hdr.safety_time_days := rcd_lads_mat_mrc.shzet;
         rcd_bds_material_plant_hdr.planned_order_action_cntrl := rcd_lads_mat_mrc.mdach;
         rcd_bds_material_plant_hdr.batch_entry_determination := rcd_lads_mat_mrc.kzech;
         rcd_bds_material_plant_hdr.plant_specific_status_valid := bds_date.bds_to_date('*DATE',rcd_lads_mat_mrc.mmstd,'yyyymmdd');
         rcd_bds_material_plant_hdr.freight_grp := rcd_lads_mat_mrc.mfrgr;
         rcd_bds_material_plant_hdr.prdctn_version_for_costing := rcd_lads_mat_mrc.fvidk;
         rcd_bds_material_plant_hdr.cfop_ctgry := rcd_lads_mat_mrc.indus;
         rcd_bds_material_plant_hdr.cap_prdcts_list_no := rcd_lads_mat_mrc.mownr;
         rcd_bds_material_plant_hdr.cap_prdcts_grp := rcd_lads_mat_mrc.mogru;
         rcd_bds_material_plant_hdr.cas_no := rcd_lads_mat_mrc.casnr;
         rcd_bds_material_plant_hdr.prodcom_no := rcd_lads_mat_mrc.gpnum;
         rcd_bds_material_plant_hdr.consumption_taxes_cntrl_code := rcd_lads_mat_mrc.steuc;
         rcd_bds_material_plant_hdr.jit_delivery_schedules_indctr := rcd_lads_mat_mrc.fabkz;
         rcd_bds_material_plant_hdr.transition_matrix_grp := rcd_lads_mat_mrc.matgr;
         rcd_bds_material_plant_hdr.logistics_handling_grp := rcd_lads_mat_mrc.loggr;
         rcd_bds_material_plant_hdr.proposed_supply_area := rcd_lads_mat_mrc.vspvb;
         rcd_bds_material_plant_hdr.fair_share_rule := rcd_lads_mat_mrc.dplfs;
         rcd_bds_material_plant_hdr.push_dstrbtn_indctr := rcd_lads_mat_mrc.dplpu;
         rcd_bds_material_plant_hdr.deployment_horizon_days := rcd_lads_mat_mrc.dplho;
         rcd_bds_material_plant_hdr.supply_demand_min_lot_size := rcd_lads_mat_mrc.minls;
         rcd_bds_material_plant_hdr.supply_demand_max_lot_size := rcd_lads_mat_mrc.maxls;
         rcd_bds_material_plant_hdr.supply_demand_fixed_lot_size := rcd_lads_mat_mrc.fixls;
         rcd_bds_material_plant_hdr.supply_demand_lot_size_incrmnt := rcd_lads_mat_mrc.ltinc;
         rcd_bds_material_plant_hdr.completion_level := rcd_lads_mat_mrc.compl;
         rcd_bds_material_plant_hdr.prdctn_figure_conversion_type := rcd_lads_mat_mrc.convt;
         rcd_bds_material_plant_hdr.dstrbtn_profile := rcd_lads_mat_mrc.fprfm;
         rcd_bds_material_plant_hdr.safety_time_prd_profile := rcd_lads_mat_mrc.shpro;
         rcd_bds_material_plant_hdr.fixed_price_coprdct := rcd_lads_mat_mrc.fxpru;
         rcd_bds_material_plant_hdr.xproject_material_indctr := rcd_lads_mat_mrc.kzpsp;
         rcd_bds_material_plant_hdr.ocm_profile := rcd_lads_mat_mrc.ocmpf;
         rcd_bds_material_plant_hdr.apo_relevant_indctr := rcd_lads_mat_mrc.apokz;
         rcd_bds_material_plant_hdr.mrp_relevancy_reqrmnts := rcd_lads_mat_mrc.ahdis;
         rcd_bds_material_plant_hdr.min_safety_stock := rcd_lads_mat_mrc.eislo;
         rcd_bds_material_plant_hdr.do_not_cost_indctr := rcd_lads_mat_mrc.ncost;
         rcd_bds_material_plant_hdr.uom_grp := rcd_lads_mat_mrc.megru;
         rcd_bds_material_plant_hdr.rotation_date := rcd_lads_mat_mrc.rotation_date;
         rcd_bds_material_plant_hdr.original_batch_manage_indctr := rcd_lads_mat_mrc.uchkz;
         rcd_bds_material_plant_hdr.original_batch_refrnc_material := rcd_lads_mat_mrc.ucmat;
         rcd_bds_material_plant_hdr.sap_function_1 := rcd_lads_mat_mrc.msgfn1;
         rcd_bds_material_plant_hdr.cim_resource_object_type := rcd_lads_mat_mrc.objty;
         rcd_bds_material_plant_hdr.cim_resource_object_id := rcd_lads_mat_mrc.objid1;
         rcd_bds_material_plant_hdr.internal_counter := rcd_lads_mat_mrc.zaehl;
         rcd_bds_material_plant_hdr.cim_resource_object_type_1 := rcd_lads_mat_mrc.objty_v;
         rcd_bds_material_plant_hdr.cim_resource_object_id_1 := rcd_lads_mat_mrc.objid_v;
         rcd_bds_material_plant_hdr.create_load_records_indctr := rcd_lads_mat_mrc.kzkbl;
         rcd_bds_material_plant_hdr.manage_prdctn_tools_key := rcd_lads_mat_mrc.steuf;
         rcd_bds_material_plant_hdr.cntrl_key_change_indctr := rcd_lads_mat_mrc.steuf_ref;
         rcd_bds_material_plant_hdr.prdctn_tool_grp_key_1 := rcd_lads_mat_mrc.fgru1;
         rcd_bds_material_plant_hdr.prdctn_tool_grp_key_2 := rcd_lads_mat_mrc.fgru2;
         rcd_bds_material_plant_hdr.prdctn_tool_usage := rcd_lads_mat_mrc.planv;
         rcd_bds_material_plant_hdr.prdctn_tool_standard_text_key := rcd_lads_mat_mrc.ktsch;
         rcd_bds_material_plant_hdr.refrnc_key_change_indctr := rcd_lads_mat_mrc.ktsch_ref;
         rcd_bds_material_plant_hdr.prdctn_tool_usage_start_date := rcd_lads_mat_mrc.bzoffb;
         rcd_bds_material_plant_hdr.start_offset_change_indctr := rcd_lads_mat_mrc.bzoffb_ref;
         rcd_bds_material_plant_hdr.start_offset_prdctn_tool := rcd_lads_mat_mrc.offstb;
         rcd_bds_material_plant_hdr.start_offset_unit_prdctn_tool := rcd_lads_mat_mrc.ehoffb;
         rcd_bds_material_plant_hdr.start_offset_change_indctr_1 := rcd_lads_mat_mrc.offstb_ref;
         rcd_bds_material_plant_hdr.end_prdctn_tool_usage_date := rcd_lads_mat_mrc.bzoffe;
         rcd_bds_material_plant_hdr.end_refrnc_date_change_indctr := rcd_lads_mat_mrc.bzoffe_ref;
         rcd_bds_material_plant_hdr.finish_offset_prdctn_tool := rcd_lads_mat_mrc.offste;
         rcd_bds_material_plant_hdr.finish_offset_unit_prdctn_tool := rcd_lads_mat_mrc.ehoffe;
         rcd_bds_material_plant_hdr.finish_offset_change_indctr := rcd_lads_mat_mrc.offste_ref;
         rcd_bds_material_plant_hdr.total_prt_qty_formula := rcd_lads_mat_mrc.mgform;
         rcd_bds_material_plant_hdr.total_prt_qty_change_indctr := rcd_lads_mat_mrc.mgform_ref;
         rcd_bds_material_plant_hdr.total_prt_usage_value_formula := rcd_lads_mat_mrc.ewform;
         rcd_bds_material_plant_hdr.total_prt_usage_change_indctr := rcd_lads_mat_mrc.ewform_ref;
         rcd_bds_material_plant_hdr.formula_parameter_1 := rcd_lads_mat_mrc.par01;
         rcd_bds_material_plant_hdr.formula_parameter_2 := rcd_lads_mat_mrc.par02;
         rcd_bds_material_plant_hdr.formula_parameter_3 := rcd_lads_mat_mrc.par03;
         rcd_bds_material_plant_hdr.formula_parameter_4 := rcd_lads_mat_mrc.par04;
         rcd_bds_material_plant_hdr.formula_parameter_5 := rcd_lads_mat_mrc.par05;
         rcd_bds_material_plant_hdr.formula_parameter_6 := rcd_lads_mat_mrc.par06;
         rcd_bds_material_plant_hdr.parameter_unit_1 := rcd_lads_mat_mrc.paru1;
         rcd_bds_material_plant_hdr.parameter_unit_2 := rcd_lads_mat_mrc.paru2;
         rcd_bds_material_plant_hdr.parameter_unit_3 := rcd_lads_mat_mrc.paru3;
         rcd_bds_material_plant_hdr.parameter_unit_4 := rcd_lads_mat_mrc.paru4;
         rcd_bds_material_plant_hdr.parameter_unit_5 := rcd_lads_mat_mrc.paru5;
         rcd_bds_material_plant_hdr.parameter_unit_6 := rcd_lads_mat_mrc.paru6;
         rcd_bds_material_plant_hdr.parameter_value_1 := rcd_lads_mat_mrc.parv1;
         rcd_bds_material_plant_hdr.parameter_value_2 := rcd_lads_mat_mrc.parv2;
         rcd_bds_material_plant_hdr.parameter_value_3 := rcd_lads_mat_mrc.parv3;
         rcd_bds_material_plant_hdr.parameter_value_4 := rcd_lads_mat_mrc.parv4;
         rcd_bds_material_plant_hdr.parameter_value_5 := rcd_lads_mat_mrc.parv5;
         rcd_bds_material_plant_hdr.parameter_value_6 := rcd_lads_mat_mrc.parv6;
         rcd_bds_material_plant_hdr.sap_function_2 := rcd_lads_mat_mrc.msgfn2;
         rcd_bds_material_plant_hdr.planning_material := rcd_lads_mat_mrc.prgrp;
         rcd_bds_material_plant_hdr.planning_plant := rcd_lads_mat_mrc.prwrk;
         rcd_bds_material_plant_hdr.conversion_factor := rcd_lads_mat_mrc.umref;
         rcd_bds_material_plant_hdr.long_material_code := rcd_lads_mat_mrc.prgrp_external;
         rcd_bds_material_plant_hdr.version_number := rcd_lads_mat_mrc.prgrp_version;
         rcd_bds_material_plant_hdr.external_guid := rcd_lads_mat_mrc.prgrp_guid;
         rcd_bds_material_plant_hdr.sap_function_3 := rcd_lads_mat_mrc.msgfn3;
         rcd_bds_material_plant_hdr.forecast_parameter_version_no := rcd_lads_mat_mrc.versp;
         rcd_bds_material_plant_hdr.forecast_profile := rcd_lads_mat_mrc.propr;
         rcd_bds_material_plant_hdr.model_selection_indctr := rcd_lads_mat_mrc.modaw;
         rcd_bds_material_plant_hdr.model_selection_prcdr := rcd_lads_mat_mrc.modav;
         rcd_bds_material_plant_hdr.parameter_optimisation_indctr := rcd_lads_mat_mrc.kzpar;
         rcd_bds_material_plant_hdr.optimisation_level := rcd_lads_mat_mrc.opgra;
         rcd_bds_material_plant_hdr.initialisation_indctr := rcd_lads_mat_mrc.kzini;
         rcd_bds_material_plant_hdr.forecast_model := rcd_lads_mat_mrc.prmod;
         rcd_bds_material_plant_hdr.basic_value_factor_alpha := rcd_lads_mat_mrc.alpha;
         rcd_bds_material_plant_hdr.basic_value_factor_beta := rcd_lads_mat_mrc.beta1;
         rcd_bds_material_plant_hdr.seasonal_index_factor_gamma := rcd_lads_mat_mrc.gamma;
         rcd_bds_material_plant_hdr.mad_factor_delta := rcd_lads_mat_mrc.delta;
         rcd_bds_material_plant_hdr.factor_epsilon := rcd_lads_mat_mrc.epsil;
         rcd_bds_material_plant_hdr.tracking_limit := rcd_lads_mat_mrc.siggr;
         rcd_bds_material_plant_hdr.indctr := rcd_lads_mat_mrc.perkz1;
         rcd_bds_material_plant_hdr.last_forecast_date := rcd_lads_mat_mrc.prdat;
         rcd_bds_material_plant_hdr.historical_prd_no := rcd_lads_mat_mrc.peran;
         rcd_bds_material_plant_hdr.prd_initialisation_no := rcd_lads_mat_mrc.perin;
         rcd_bds_material_plant_hdr.prd_per_seasonal_cycle_no := rcd_lads_mat_mrc.perio;
         rcd_bds_material_plant_hdr.prd_expost_forecast_no := rcd_lads_mat_mrc.perex;
         rcd_bds_material_plant_hdr.prd_forecast_no := rcd_lads_mat_mrc.anzpr;
         rcd_bds_material_plant_hdr.prd_fixed := rcd_lads_mat_mrc.fimon;
         rcd_bds_material_plant_hdr.basic_value := rcd_lads_mat_mrc.gwert;
         rcd_bds_material_plant_hdr.basic_value_1 := rcd_lads_mat_mrc.gwer1;
         rcd_bds_material_plant_hdr.basic_value_2 := rcd_lads_mat_mrc.gwer2;
         rcd_bds_material_plant_hdr.prev_prd_basic_value := rcd_lads_mat_mrc.vmgwe;
         rcd_bds_material_plant_hdr.prev_prd_base_value_1 := rcd_lads_mat_mrc.vmgw1;
         rcd_bds_material_plant_hdr.prev_prd_base_value_2 := rcd_lads_mat_mrc.vmgw2;
         rcd_bds_material_plant_hdr.trend_value := rcd_lads_mat_mrc.twert;
         rcd_bds_material_plant_hdr.prev_prd_trend_value := rcd_lads_mat_mrc.vmtwe;
         rcd_bds_material_plant_hdr.mad := rcd_lads_mat_mrc.prmad;
         rcd_bds_material_plant_hdr.prev_prd_mad := rcd_lads_mat_mrc.vmmad;
         rcd_bds_material_plant_hdr.error_total := rcd_lads_mat_mrc.fsumm;
         rcd_bds_material_plant_hdr.prev_prd_error_total := rcd_lads_mat_mrc.vmfsu;
         rcd_bds_material_plant_hdr.weighting_grp := rcd_lads_mat_mrc.gewgr;
         rcd_bds_material_plant_hdr.theil_coefficient := rcd_lads_mat_mrc.thkof;
         rcd_bds_material_plant_hdr.exception_message_bar := rcd_lads_mat_mrc.ausna;
         rcd_bds_material_plant_hdr.forecast_flow_cntrl := rcd_lads_mat_mrc.proab;

         open csr_lads_mat_zmc;
         fetch csr_lads_mat_zmc into rcd_lads_mat_zmc;
         if (csr_lads_mat_zmc%notfound) then
            exit;
         end if;
         close csr_lads_mat_zmc;

         rcd_bds_material_plant_hdr.mars_plant_material_type := rcd_lads_mat_zmc.zzmtart;
         rcd_bds_material_plant_hdr.mars_maturation_lead_time_days := rcd_lads_mat_zmc.zzmattim_pl;
         rcd_bds_material_plant_hdr.mars_fpps_source := rcd_lads_mat_zmc.zzfppsmoe;

         /*-------------------------------*/
         /* UPDATE BDS_MATERIAL_PLANT_HDR */
         /*-------------------------------*/
         insert into bds_material_plant_hdr
            (sap_material_code,
             plant_code,
             sap_function,
             maint_status,
             mars_plant_material_type,
             mars_maturation_lead_time_days,
             mars_fpps_source,
             deletion_indctr,
             vltn_ctgry,
             abc_indctr,
             critical_part_indctr,
             purchasing_grp,
             issue_unit,
             mrp_profile,
             mrp_type,
             mrp_controller,
             planned_delivery_days,
             gr_processing_days,
             prd_indctr,
             assembly_scrap_percntg,
             lot_size,
             procurement_type,
             special_procurement_type,
             reorder_point,
             safety_stock,
             min_lot_size,
             max_lot_size,
             fixed_lot_size,
             purchase_order_qty_rounding,
             max_stock_level,
             ordering_costs,
             dependent_reqrmnt_indctr,
             storage_cost_indctr,
             altrntv_bom_select_method,
             discontinuation_indctr,
             effective_out_date,
             followup_material,
             reqrmnts_grping_indctr,
             mixed_mrp_indctr,
             float_schedule_margin_key,
             planned_order_auto_fix_indctr,
             prdctn_order_release_indctr,
             backflush_indctr,
             prdctn_scheduler,
             processing_time,
             configuration_time,
             interoperation_time,
             base_qty,
             inhouse_prdctn_time,
             max_storage_prd,
             max_storage_prd_unit,
             prdctn_bin_withdraw_indctr,
             roughcut_planning_indctr,
             over_delivery_tolrnc_limit,
             over_delivery_allowed_indctr,
             under_delivery_tolrnc_limit,
             replenishment_lead_time,
             replacement_part_indctr,
             surcharge_factor,
             manufacture_status,
             inspection_stock_post_indctr,
             qa_control_key,
             documentation_reqrd_indctr,
             stock_transfer,
             loading_grp,
             batch_manage_reqrmnt_indctr,
             quota_arrangement_usage,
             service_level,
             splitting_indctr,
             plan_version,
             object_type,
             object_id,
             availability_check_grp,
             fiscal_year_variant,
             correction_factor_indctr,
             shipping_setup_time,
             capacity_planning_base_qty,
             shipping_processing_time,
             delivery_cycle,
             supply_source,
             auto_purchase_order_indctr,
             source_list_reqrmnt_indctr,
             commodity_code,
             origin_country,
             origin_region,
             comodity_uom,
             trade_grp,
             profit_center,
             stock_in_transit,
             ppc_planning_calendar,
             repetitive_manu_allowed_indctr,
             planning_time_fence,
             consumption_mode,
             consumption_prd_back,
             consumption_prd_forward,
             alternative_bom,
             bom_usage,
             task_list_grp_key,
             grp_counter,
             prdct_costing_lot_size,
             special_cost_procurement_type,
             production_unit,
             issue_storage_location,
             mrp_group,
             component_scrap_percntg,
             certificate_type,
             takt_time,
             coverage_profile,
             local_field_name,
             physical_inventory_indctr,
             variance_key,
             serial_number_profile,
             configurable_material,
             repetitive_manu_profile,
             negative_stocks_allowed_indctr,
             reqrd_qm_vendor_system,
             planning_cycle,
             rounding_profile,
             refrnc_consumption_material,
             refrnc_consumption_plant,
             consumption_material_copy_date,
             refrnc_consumption_multiplier,
             auto_forecast_model_reset,
             trade_prfrnc_indctr,
             exemption_certificate_indctr,
             exemption_certificate_qty,
             exemption_certificate_issued,
             vendor_declaration_indctr,
             vendor_declaration_valid_date,
             military_goods_indctr,
             char_field,
             coprdct_material_indctr,
             planning_strategy_grp,
             default_storage_location,
             bulk_material_indctr,
             fixed_cc_indctr,
             stock_withdrawal_seq_grp,
             qm_activity_authorisation_grp,
             task_list_type,
             plant_specific_status,
             prdctn_scheduling_profile,
             safety_time_indctr,
             safety_time_days,
             planned_order_action_cntrl,
             batch_entry_determination,
             plant_specific_status_valid,
             freight_grp,
             prdctn_version_for_costing,
             cfop_ctgry,
             cap_prdcts_list_no,
             cap_prdcts_grp,
             cas_no,
             prodcom_no,
             consumption_taxes_cntrl_code,
             jit_delivery_schedules_indctr,
             transition_matrix_grp,
             logistics_handling_grp,
             proposed_supply_area,
             fair_share_rule,
             push_dstrbtn_indctr,
             deployment_horizon_days,
             supply_demand_min_lot_size,
             supply_demand_max_lot_size,
             supply_demand_fixed_lot_size,
             supply_demand_lot_size_incrmnt,
             completion_level,
             prdctn_figure_conversion_type,
             dstrbtn_profile,
             safety_time_prd_profile,
             fixed_price_coprdct,
             xproject_material_indctr,
             ocm_profile,
             apo_relevant_indctr,
             mrp_relevancy_reqrmnts,
             min_safety_stock,
             do_not_cost_indctr,
             uom_grp,
             rotation_date,
             original_batch_manage_indctr,
             original_batch_refrnc_material,
             sap_function_1,
             cim_resource_object_type,
             cim_resource_object_id,
             internal_counter,
             cim_resource_object_type_1,
             cim_resource_object_id_1,
             create_load_records_indctr,
             manage_prdctn_tools_key,
             cntrl_key_change_indctr,
             prdctn_tool_grp_key_1,
             prdctn_tool_grp_key_2,
             prdctn_tool_usage,
             prdctn_tool_standard_text_key,
             refrnc_key_change_indctr,
             prdctn_tool_usage_start_date,
             start_offset_change_indctr,
             start_offset_prdctn_tool,
             start_offset_unit_prdctn_tool,
             start_offset_change_indctr_1,
             end_prdctn_tool_usage_date,
             end_refrnc_date_change_indctr,
             finish_offset_prdctn_tool,
             finish_offset_unit_prdctn_tool,
             finish_offset_change_indctr,
             total_prt_qty_formula,
             total_prt_qty_change_indctr,
             total_prt_usage_value_formula,
             total_prt_usage_change_indctr,
             formula_parameter_1,
             formula_parameter_2,
             formula_parameter_3,
             formula_parameter_4,
             formula_parameter_5,
             formula_parameter_6,
             parameter_unit_1,
             parameter_unit_2,
             parameter_unit_3,
             parameter_unit_4,
             parameter_unit_5,
             parameter_unit_6,
             parameter_value_1,
             parameter_value_2,
             parameter_value_3,
             parameter_value_4,
             parameter_value_5,
             parameter_value_6,
             sap_function_2,
             planning_material,
             planning_plant,
             conversion_factor,
             long_material_code,
             version_number,
             external_guid,
             sap_function_3,
             forecast_parameter_version_no,
             forecast_profile,
             model_selection_indctr,
             model_selection_prcdr,
             parameter_optimisation_indctr,
             optimisation_level,
             initialisation_indctr,
             forecast_model,
             basic_value_factor_alpha,
             basic_value_factor_beta,
             seasonal_index_factor_gamma,
             mad_factor_delta,
             factor_epsilon,
             tracking_limit,
             indctr,
             last_forecast_date,
             historical_prd_no,
             prd_initialisation_no,
             prd_per_seasonal_cycle_no,
             prd_expost_forecast_no,
             prd_forecast_no,
             prd_fixed,
             basic_value,
             basic_value_1,
             basic_value_2,
             prev_prd_basic_value,
             prev_prd_base_value_1,
             prev_prd_base_value_2,
             trend_value,
             prev_prd_trend_value,
             mad,
             prev_prd_mad,
             error_total,
             prev_prd_error_total,
             weighting_grp,
             theil_coefficient,
             exception_message_bar,
             forecast_flow_cntrl)
          values 
            (rcd_bds_material_plant_hdr.sap_material_code,
             rcd_bds_material_plant_hdr.plant_code,
             rcd_bds_material_plant_hdr.sap_function,
             rcd_bds_material_plant_hdr.maint_status,
             rcd_bds_material_plant_hdr.mars_plant_material_type,
             rcd_bds_material_plant_hdr.mars_maturation_lead_time_days,
             rcd_bds_material_plant_hdr.mars_fpps_source,
             rcd_bds_material_plant_hdr.deletion_indctr,
             rcd_bds_material_plant_hdr.vltn_ctgry,
             rcd_bds_material_plant_hdr.abc_indctr,
             rcd_bds_material_plant_hdr.critical_part_indctr,
             rcd_bds_material_plant_hdr.purchasing_grp,
             rcd_bds_material_plant_hdr.issue_unit,
             rcd_bds_material_plant_hdr.mrp_profile,
             rcd_bds_material_plant_hdr.mrp_type,
             rcd_bds_material_plant_hdr.mrp_controller,
             rcd_bds_material_plant_hdr.planned_delivery_days,
             rcd_bds_material_plant_hdr.gr_processing_days,
             rcd_bds_material_plant_hdr.prd_indctr,
             rcd_bds_material_plant_hdr.assembly_scrap_percntg,
             rcd_bds_material_plant_hdr.lot_size,
             rcd_bds_material_plant_hdr.procurement_type,
             rcd_bds_material_plant_hdr.special_procurement_type,
             rcd_bds_material_plant_hdr.reorder_point,
             rcd_bds_material_plant_hdr.safety_stock,
             rcd_bds_material_plant_hdr.min_lot_size,
             rcd_bds_material_plant_hdr.max_lot_size,
             rcd_bds_material_plant_hdr.fixed_lot_size,
             rcd_bds_material_plant_hdr.purchase_order_qty_rounding,
             rcd_bds_material_plant_hdr.max_stock_level,
             rcd_bds_material_plant_hdr.ordering_costs,
             rcd_bds_material_plant_hdr.dependent_reqrmnt_indctr,
             rcd_bds_material_plant_hdr.storage_cost_indctr,
             rcd_bds_material_plant_hdr.altrntv_bom_select_method,
             rcd_bds_material_plant_hdr.discontinuation_indctr,
             rcd_bds_material_plant_hdr.effective_out_date,
             rcd_bds_material_plant_hdr.followup_material,
             rcd_bds_material_plant_hdr.reqrmnts_grping_indctr,
             rcd_bds_material_plant_hdr.mixed_mrp_indctr,
             rcd_bds_material_plant_hdr.float_schedule_margin_key,
             rcd_bds_material_plant_hdr.planned_order_auto_fix_indctr,
             rcd_bds_material_plant_hdr.prdctn_order_release_indctr,
             rcd_bds_material_plant_hdr.backflush_indctr,
             rcd_bds_material_plant_hdr.prdctn_scheduler,
             rcd_bds_material_plant_hdr.processing_time,
             rcd_bds_material_plant_hdr.configuration_time,
             rcd_bds_material_plant_hdr.interoperation_time,
             rcd_bds_material_plant_hdr.base_qty,
             rcd_bds_material_plant_hdr.inhouse_prdctn_time,
             rcd_bds_material_plant_hdr.max_storage_prd,
             rcd_bds_material_plant_hdr.max_storage_prd_unit,
             rcd_bds_material_plant_hdr.prdctn_bin_withdraw_indctr,
             rcd_bds_material_plant_hdr.roughcut_planning_indctr,
             rcd_bds_material_plant_hdr.over_delivery_tolrnc_limit,
             rcd_bds_material_plant_hdr.over_delivery_allowed_indctr,
             rcd_bds_material_plant_hdr.under_delivery_tolrnc_limit,
             rcd_bds_material_plant_hdr.replenishment_lead_time,
             rcd_bds_material_plant_hdr.replacement_part_indctr,
             rcd_bds_material_plant_hdr.surcharge_factor,
             rcd_bds_material_plant_hdr.manufacture_status,
             rcd_bds_material_plant_hdr.inspection_stock_post_indctr,
             rcd_bds_material_plant_hdr.qa_control_key,
             rcd_bds_material_plant_hdr.documentation_reqrd_indctr,
             rcd_bds_material_plant_hdr.stock_transfer,
             rcd_bds_material_plant_hdr.loading_grp,
             rcd_bds_material_plant_hdr.batch_manage_reqrmnt_indctr,
             rcd_bds_material_plant_hdr.quota_arrangement_usage,
             rcd_bds_material_plant_hdr.service_level,
             rcd_bds_material_plant_hdr.splitting_indctr,
             rcd_bds_material_plant_hdr.plan_version,
             rcd_bds_material_plant_hdr.object_type,
             rcd_bds_material_plant_hdr.object_id,
             rcd_bds_material_plant_hdr.availability_check_grp,
             rcd_bds_material_plant_hdr.fiscal_year_variant,
             rcd_bds_material_plant_hdr.correction_factor_indctr,
             rcd_bds_material_plant_hdr.shipping_setup_time,
             rcd_bds_material_plant_hdr.capacity_planning_base_qty,
             rcd_bds_material_plant_hdr.shipping_processing_time,
             rcd_bds_material_plant_hdr.delivery_cycle,
             rcd_bds_material_plant_hdr.supply_source,
             rcd_bds_material_plant_hdr.auto_purchase_order_indctr,
             rcd_bds_material_plant_hdr.source_list_reqrmnt_indctr,
             rcd_bds_material_plant_hdr.commodity_code,
             rcd_bds_material_plant_hdr.origin_country,
             rcd_bds_material_plant_hdr.origin_region,
             rcd_bds_material_plant_hdr.comodity_uom,
             rcd_bds_material_plant_hdr.trade_grp,
             rcd_bds_material_plant_hdr.profit_center,
             rcd_bds_material_plant_hdr.stock_in_transit,
             rcd_bds_material_plant_hdr.ppc_planning_calendar,
             rcd_bds_material_plant_hdr.repetitive_manu_allowed_indctr,
             rcd_bds_material_plant_hdr.planning_time_fence,
             rcd_bds_material_plant_hdr.consumption_mode,
             rcd_bds_material_plant_hdr.consumption_prd_back,
             rcd_bds_material_plant_hdr.consumption_prd_forward,
             rcd_bds_material_plant_hdr.alternative_bom,
             rcd_bds_material_plant_hdr.bom_usage,
             rcd_bds_material_plant_hdr.task_list_grp_key,
             rcd_bds_material_plant_hdr.grp_counter,
             rcd_bds_material_plant_hdr.prdct_costing_lot_size,
             rcd_bds_material_plant_hdr.special_cost_procurement_type,
             rcd_bds_material_plant_hdr.production_unit,
             rcd_bds_material_plant_hdr.issue_storage_location,
             rcd_bds_material_plant_hdr.mrp_group,
             rcd_bds_material_plant_hdr.component_scrap_percntg,
             rcd_bds_material_plant_hdr.certificate_type,
             rcd_bds_material_plant_hdr.takt_time,
             rcd_bds_material_plant_hdr.coverage_profile,
             rcd_bds_material_plant_hdr.local_field_name,
             rcd_bds_material_plant_hdr.physical_inventory_indctr,
             rcd_bds_material_plant_hdr.variance_key,
             rcd_bds_material_plant_hdr.serial_number_profile,
             rcd_bds_material_plant_hdr.configurable_material,
             rcd_bds_material_plant_hdr.repetitive_manu_profile,
             rcd_bds_material_plant_hdr.negative_stocks_allowed_indctr,
             rcd_bds_material_plant_hdr.reqrd_qm_vendor_system,
             rcd_bds_material_plant_hdr.planning_cycle,
             rcd_bds_material_plant_hdr.rounding_profile,
             rcd_bds_material_plant_hdr.refrnc_consumption_material,
             rcd_bds_material_plant_hdr.refrnc_consumption_plant,
             rcd_bds_material_plant_hdr.consumption_material_copy_date,
             rcd_bds_material_plant_hdr.refrnc_consumption_multiplier,
             rcd_bds_material_plant_hdr.auto_forecast_model_reset,
             rcd_bds_material_plant_hdr.trade_prfrnc_indctr,
             rcd_bds_material_plant_hdr.exemption_certificate_indctr,
             rcd_bds_material_plant_hdr.exemption_certificate_qty,
             rcd_bds_material_plant_hdr.exemption_certificate_issued,
             rcd_bds_material_plant_hdr.vendor_declaration_indctr,
             rcd_bds_material_plant_hdr.vendor_declaration_valid_date,
             rcd_bds_material_plant_hdr.military_goods_indctr,
             rcd_bds_material_plant_hdr.char_field,
             rcd_bds_material_plant_hdr.coprdct_material_indctr,
             rcd_bds_material_plant_hdr.planning_strategy_grp,
             rcd_bds_material_plant_hdr.default_storage_location,
             rcd_bds_material_plant_hdr.bulk_material_indctr,
             rcd_bds_material_plant_hdr.fixed_cc_indctr,
             rcd_bds_material_plant_hdr.stock_withdrawal_seq_grp,
             rcd_bds_material_plant_hdr.qm_activity_authorisation_grp,
             rcd_bds_material_plant_hdr.task_list_type,
             rcd_bds_material_plant_hdr.plant_specific_status,
             rcd_bds_material_plant_hdr.prdctn_scheduling_profile,
             rcd_bds_material_plant_hdr.safety_time_indctr,
             rcd_bds_material_plant_hdr.safety_time_days,
             rcd_bds_material_plant_hdr.planned_order_action_cntrl,
             rcd_bds_material_plant_hdr.batch_entry_determination,
             rcd_bds_material_plant_hdr.plant_specific_status_valid,
             rcd_bds_material_plant_hdr.freight_grp,
             rcd_bds_material_plant_hdr.prdctn_version_for_costing,
             rcd_bds_material_plant_hdr.cfop_ctgry,
             rcd_bds_material_plant_hdr.cap_prdcts_list_no,
             rcd_bds_material_plant_hdr.cap_prdcts_grp,
             rcd_bds_material_plant_hdr.cas_no,
             rcd_bds_material_plant_hdr.prodcom_no,
             rcd_bds_material_plant_hdr.consumption_taxes_cntrl_code,
             rcd_bds_material_plant_hdr.jit_delivery_schedules_indctr,
             rcd_bds_material_plant_hdr.transition_matrix_grp,
             rcd_bds_material_plant_hdr.logistics_handling_grp,
             rcd_bds_material_plant_hdr.proposed_supply_area,
             rcd_bds_material_plant_hdr.fair_share_rule,
             rcd_bds_material_plant_hdr.push_dstrbtn_indctr,
             rcd_bds_material_plant_hdr.deployment_horizon_days,
             rcd_bds_material_plant_hdr.supply_demand_min_lot_size,
             rcd_bds_material_plant_hdr.supply_demand_max_lot_size,
             rcd_bds_material_plant_hdr.supply_demand_fixed_lot_size,
             rcd_bds_material_plant_hdr.supply_demand_lot_size_incrmnt,
             rcd_bds_material_plant_hdr.completion_level,
             rcd_bds_material_plant_hdr.prdctn_figure_conversion_type,
             rcd_bds_material_plant_hdr.dstrbtn_profile,
             rcd_bds_material_plant_hdr.safety_time_prd_profile,
             rcd_bds_material_plant_hdr.fixed_price_coprdct,
             rcd_bds_material_plant_hdr.xproject_material_indctr,
             rcd_bds_material_plant_hdr.ocm_profile,
             rcd_bds_material_plant_hdr.apo_relevant_indctr,
             rcd_bds_material_plant_hdr.mrp_relevancy_reqrmnts,
             rcd_bds_material_plant_hdr.min_safety_stock,
             rcd_bds_material_plant_hdr.do_not_cost_indctr,
             rcd_bds_material_plant_hdr.uom_grp,
             rcd_bds_material_plant_hdr.rotation_date,
             rcd_bds_material_plant_hdr.original_batch_manage_indctr,
             rcd_bds_material_plant_hdr.original_batch_refrnc_material,
             rcd_bds_material_plant_hdr.sap_function_1,
             rcd_bds_material_plant_hdr.cim_resource_object_type,
             rcd_bds_material_plant_hdr.cim_resource_object_id,
             rcd_bds_material_plant_hdr.internal_counter,
             rcd_bds_material_plant_hdr.cim_resource_object_type_1,
             rcd_bds_material_plant_hdr.cim_resource_object_id_1,
             rcd_bds_material_plant_hdr.create_load_records_indctr,
             rcd_bds_material_plant_hdr.manage_prdctn_tools_key,
             rcd_bds_material_plant_hdr.cntrl_key_change_indctr,
             rcd_bds_material_plant_hdr.prdctn_tool_grp_key_1,
             rcd_bds_material_plant_hdr.prdctn_tool_grp_key_2,
             rcd_bds_material_plant_hdr.prdctn_tool_usage,
             rcd_bds_material_plant_hdr.prdctn_tool_standard_text_key,
             rcd_bds_material_plant_hdr.refrnc_key_change_indctr,
             rcd_bds_material_plant_hdr.prdctn_tool_usage_start_date,
             rcd_bds_material_plant_hdr.start_offset_change_indctr,
             rcd_bds_material_plant_hdr.start_offset_prdctn_tool,
             rcd_bds_material_plant_hdr.start_offset_unit_prdctn_tool,
             rcd_bds_material_plant_hdr.start_offset_change_indctr_1,
             rcd_bds_material_plant_hdr.end_prdctn_tool_usage_date,
             rcd_bds_material_plant_hdr.end_refrnc_date_change_indctr,
             rcd_bds_material_plant_hdr.finish_offset_prdctn_tool,
             rcd_bds_material_plant_hdr.finish_offset_unit_prdctn_tool,
             rcd_bds_material_plant_hdr.finish_offset_change_indctr,
             rcd_bds_material_plant_hdr.total_prt_qty_formula,
             rcd_bds_material_plant_hdr.total_prt_qty_change_indctr,
             rcd_bds_material_plant_hdr.total_prt_usage_value_formula,
             rcd_bds_material_plant_hdr.total_prt_usage_change_indctr,
             rcd_bds_material_plant_hdr.formula_parameter_1,
             rcd_bds_material_plant_hdr.formula_parameter_2,
             rcd_bds_material_plant_hdr.formula_parameter_3,
             rcd_bds_material_plant_hdr.formula_parameter_4,
             rcd_bds_material_plant_hdr.formula_parameter_5,
             rcd_bds_material_plant_hdr.formula_parameter_6,
             rcd_bds_material_plant_hdr.parameter_unit_1,
             rcd_bds_material_plant_hdr.parameter_unit_2,
             rcd_bds_material_plant_hdr.parameter_unit_3,
             rcd_bds_material_plant_hdr.parameter_unit_4,
             rcd_bds_material_plant_hdr.parameter_unit_5,
             rcd_bds_material_plant_hdr.parameter_unit_6,
             rcd_bds_material_plant_hdr.parameter_value_1,
             rcd_bds_material_plant_hdr.parameter_value_2,
             rcd_bds_material_plant_hdr.parameter_value_3,
             rcd_bds_material_plant_hdr.parameter_value_4,
             rcd_bds_material_plant_hdr.parameter_value_5,
             rcd_bds_material_plant_hdr.parameter_value_6,
             rcd_bds_material_plant_hdr.sap_function_2,
             rcd_bds_material_plant_hdr.planning_material,
             rcd_bds_material_plant_hdr.planning_plant,
             rcd_bds_material_plant_hdr.conversion_factor,
             rcd_bds_material_plant_hdr.long_material_code,
             rcd_bds_material_plant_hdr.version_number,
             rcd_bds_material_plant_hdr.external_guid,
             rcd_bds_material_plant_hdr.sap_function_3,
             rcd_bds_material_plant_hdr.forecast_parameter_version_no,
             rcd_bds_material_plant_hdr.forecast_profile,
             rcd_bds_material_plant_hdr.model_selection_indctr,
             rcd_bds_material_plant_hdr.model_selection_prcdr,
             rcd_bds_material_plant_hdr.parameter_optimisation_indctr,
             rcd_bds_material_plant_hdr.optimisation_level,
             rcd_bds_material_plant_hdr.initialisation_indctr,
             rcd_bds_material_plant_hdr.forecast_model,
             rcd_bds_material_plant_hdr.basic_value_factor_alpha,
             rcd_bds_material_plant_hdr.basic_value_factor_beta,
             rcd_bds_material_plant_hdr.seasonal_index_factor_gamma,
             rcd_bds_material_plant_hdr.mad_factor_delta,
             rcd_bds_material_plant_hdr.factor_epsilon,
             rcd_bds_material_plant_hdr.tracking_limit,
             rcd_bds_material_plant_hdr.indctr,
             rcd_bds_material_plant_hdr.last_forecast_date,
             rcd_bds_material_plant_hdr.historical_prd_no,
             rcd_bds_material_plant_hdr.prd_initialisation_no,
             rcd_bds_material_plant_hdr.prd_per_seasonal_cycle_no,
             rcd_bds_material_plant_hdr.prd_expost_forecast_no,
             rcd_bds_material_plant_hdr.prd_forecast_no,
             rcd_bds_material_plant_hdr.prd_fixed,
             rcd_bds_material_plant_hdr.basic_value,
             rcd_bds_material_plant_hdr.basic_value_1,
             rcd_bds_material_plant_hdr.basic_value_2,
             rcd_bds_material_plant_hdr.prev_prd_basic_value,
             rcd_bds_material_plant_hdr.prev_prd_base_value_1,
             rcd_bds_material_plant_hdr.prev_prd_base_value_2,
             rcd_bds_material_plant_hdr.trend_value,
             rcd_bds_material_plant_hdr.prev_prd_trend_value,
             rcd_bds_material_plant_hdr.mad,
             rcd_bds_material_plant_hdr.prev_prd_mad,
             rcd_bds_material_plant_hdr.error_total,
             rcd_bds_material_plant_hdr.prev_prd_error_total,
             rcd_bds_material_plant_hdr.weighting_grp,
             rcd_bds_material_plant_hdr.theil_coefficient,
             rcd_bds_material_plant_hdr.exception_message_bar,
             rcd_bds_material_plant_hdr.forecast_flow_cntrl);

         /*-*/
         /* Process Material Plant Forecast Values
         /*-*/
         open csr_lads_mat_mpm;
         loop
            fetch csr_lads_mat_mpm into rcd_lads_mat_mpm;
            if (csr_lads_mat_mpm%notfound) then
               exit;
            end if;

            rcd_bds_material_plant_frcst.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_material_plant_frcst.plant_code := rcd_bds_material_plant_hdr.plant_code;
            rcd_bds_material_plant_frcst.period_first_day := rcd_lads_mat_mpm.ertag;
            rcd_bds_material_plant_frcst.sap_function := rcd_lads_mat_mpm.msgfn;
            rcd_bds_material_plant_frcst.forecast_value := rcd_lads_mat_mpm.prwrt;
            rcd_bds_material_plant_frcst.corrected_forecast_value := rcd_lads_mat_mpm.koprw;
            rcd_bds_material_plant_frcst.seasonal_index := rcd_lads_mat_mpm.saiin;
            rcd_bds_material_plant_frcst.consumption_value_fixed_indctr := rcd_lads_mat_mpm.fixkz;
            rcd_bds_material_plant_frcst.expost_forecast_value := rcd_lads_mat_mpm.exprw;
            rcd_bds_material_plant_frcst.forecast_values_ratio := rcd_lads_mat_mpm.antei;
   
            /*------------------------------------*/
            /* UPDATE BDS_MATERIAL_PLANT_FORECAST */
            /*------------------------------------*/
            insert into bds_material_plant_forecast
               (sap_material_code,
                plant_code,
                period_first_day,
                sap_function,
                forecast_value,
                corrected_forecast_value,
                seasonal_index,
                consumption_value_fixed_indctr,
                expost_forecast_value,
                forecast_values_ratio)
             values 
               (rcd_bds_material_plant_frcst.sap_material_code,
                rcd_bds_material_plant_frcst.plant_code,
                rcd_bds_material_plant_frcst.period_first_day,
                rcd_bds_material_plant_frcst.sap_function,
                rcd_bds_material_plant_frcst.forecast_value,
                rcd_bds_material_plant_frcst.corrected_forecast_value,
                rcd_bds_material_plant_frcst.seasonal_index,
                rcd_bds_material_plant_frcst.consumption_value_fixed_indctr,
                rcd_bds_material_plant_frcst.expost_forecast_value,
                rcd_bds_material_plant_frcst.forecast_values_ratio);

         end loop;
         close csr_lads_mat_mpm;

         /*-*/
         /* Process Material Plant Production Version
         /*-*/
         open csr_lads_mat_mpv;
         loop
            fetch csr_lads_mat_mpv into rcd_lads_mat_mpv;
            if (csr_lads_mat_mpv%notfound) then
               exit;
            end if;

            rcd_bds_material_plant_vrsn.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_material_plant_vrsn.plant_code := rcd_bds_material_plant_hdr.plant_code;
            rcd_bds_material_plant_vrsn.prdctn_vrsn := rcd_lads_mat_mpv.verid;
            rcd_bds_material_plant_vrsn.sap_function := rcd_lads_mat_mpv.msgfn;
            rcd_bds_material_plant_vrsn.runtime_end := bds_date.bds_to_date('*DATE',rcd_lads_mat_mpv.bdatu,'yyyymmdd');
            rcd_bds_material_plant_vrsn.prdctn_vrsn_valid_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_mpv.adatu,'yyyymmdd');
            rcd_bds_material_plant_vrsn.alternative_bom := rcd_lads_mat_mpv.stlal;
            rcd_bds_material_plant_vrsn.bom_usage := rcd_lads_mat_mpv.stlan;
            rcd_bds_material_plant_vrsn.task_list_type := rcd_lads_mat_mpv.plnty;
            rcd_bds_material_plant_vrsn.task_list_grp_key := rcd_lads_mat_mpv.plnnr;
            rcd_bds_material_plant_vrsn.grp_counter := rcd_lads_mat_mpv.alnal;
            rcd_bds_material_plant_vrsn.procurement_type := rcd_lads_mat_mpv.beskz;
            rcd_bds_material_plant_vrsn.special_procurement_type := rcd_lads_mat_mpv.sobsl;
            rcd_bds_material_plant_vrsn.prdct_costing_lot_size := rcd_lads_mat_mpv.losgr;
            rcd_bds_material_plant_vrsn.aggregation_field_1 := rcd_lads_mat_mpv.mdv01;
            rcd_bds_material_plant_vrsn.aggregation_field_2 := rcd_lads_mat_mpv.mdv02;
            rcd_bds_material_plant_vrsn.short_text := rcd_lads_mat_mpv.text1;
            rcd_bds_material_plant_vrsn.vrsn_cntrl_usage_probability := rcd_lads_mat_mpv.ewahr;
            rcd_bds_material_plant_vrsn.qty_produced_dstrbtn_key := rcd_lads_mat_mpv.verto;
            rcd_bds_material_plant_vrsn.repetitive_manu_allowed_indctr := rcd_lads_mat_mpv.serkz;
            rcd_bds_material_plant_vrsn.lot_size_lower_value_interval := rcd_lads_mat_mpv.bstmi;
            rcd_bds_material_plant_vrsn.lot_size_upper_value_interval := rcd_lads_mat_mpv.bstma;
            rcd_bds_material_plant_vrsn.rs_header_backflush_indctr := rcd_lads_mat_mpv.rgekz;
            rcd_bds_material_plant_vrsn.repetitive_manu_receive_storg := rcd_lads_mat_mpv.alort;
            rcd_bds_material_plant_vrsn.task_list_type_1 := rcd_lads_mat_mpv.pltyg;
            rcd_bds_material_plant_vrsn.task_list_grp_key_1 := rcd_lads_mat_mpv.plnng;
            rcd_bds_material_plant_vrsn.grp_counter_1 := rcd_lads_mat_mpv.alnag;
            rcd_bds_material_plant_vrsn.task_list_type_2 := rcd_lads_mat_mpv.pltym;
            rcd_bds_material_plant_vrsn.task_list_grp_key_2 := rcd_lads_mat_mpv.plnnm;
            rcd_bds_material_plant_vrsn.grp_counter_2 := rcd_lads_mat_mpv.alnam;
            rcd_bds_material_plant_vrsn.apportionment_structure := rcd_lads_mat_mpv.csplt;
            rcd_bds_material_plant_vrsn.similar_bom_tasklist_material := rcd_lads_mat_mpv.matko;
            rcd_bds_material_plant_vrsn.issue_storg_location := rcd_lads_mat_mpv.elpro;
            rcd_bds_material_plant_vrsn.default_supply_area := rcd_lads_mat_mpv.prvbe;
            rcd_bds_material_plant_vrsn.long_material_code := rcd_lads_mat_mpv.matko_external;
            rcd_bds_material_plant_vrsn.vrsn_number := rcd_lads_mat_mpv.matko_version;
            rcd_bds_material_plant_vrsn.external_guid := rcd_lads_mat_mpv.matko_guid;

            /*-----------------------------------*/
            /* UPDATE BDS_MATERIAL_PLANT_VRSN   */
            /*-----------------------------------*/
            insert into bds_material_plant_vrsn
               (sap_material_code,
                plant_code,
                prdctn_vrsn,
                sap_function,
                runtime_end,
                prdctn_vrsn_valid_date,
                alternative_bom,
                bom_usage,
                task_list_type,
                task_list_grp_key,
                grp_counter,
                procurement_type,
                special_procurement_type,
                prdct_costing_lot_size,
                aggregation_field_1,
                aggregation_field_2,
                short_text,
                vrsn_cntrl_usage_probability,
                qty_produced_dstrbtn_key,
                repetitive_manu_allowed_indctr,
                lot_size_lower_value_interval,
                lot_size_upper_value_interval,
                rs_header_backflush_indctr,
                repetitive_manu_receive_storg,
                task_list_type_1,
                task_list_grp_key_1,
                grp_counter_1,
                task_list_type_2,
                task_list_grp_key_2,
                grp_counter_2,
                apportionment_structure,
                similar_bom_tasklist_material,
                issue_storg_location,
                default_supply_area,
                long_material_code,
                vrsn_number,
                external_guid)
             values 
               (rcd_bds_material_plant_vrsn.sap_material_code,
                rcd_bds_material_plant_vrsn.plant_code,
                rcd_bds_material_plant_vrsn.prdctn_vrsn,
                rcd_bds_material_plant_vrsn.sap_function,
                rcd_bds_material_plant_vrsn.runtime_end,
                rcd_bds_material_plant_vrsn.prdctn_vrsn_valid_date,
                rcd_bds_material_plant_vrsn.alternative_bom,
                rcd_bds_material_plant_vrsn.bom_usage,
                rcd_bds_material_plant_vrsn.task_list_type,
                rcd_bds_material_plant_vrsn.task_list_grp_key,
                rcd_bds_material_plant_vrsn.grp_counter,
                rcd_bds_material_plant_vrsn.procurement_type,
                rcd_bds_material_plant_vrsn.special_procurement_type,
                rcd_bds_material_plant_vrsn.prdct_costing_lot_size,
                rcd_bds_material_plant_vrsn.aggregation_field_1,
                rcd_bds_material_plant_vrsn.aggregation_field_2,
                rcd_bds_material_plant_vrsn.short_text,
                rcd_bds_material_plant_vrsn.vrsn_cntrl_usage_probability,
                rcd_bds_material_plant_vrsn.qty_produced_dstrbtn_key,
                rcd_bds_material_plant_vrsn.repetitive_manu_allowed_indctr,
                rcd_bds_material_plant_vrsn.lot_size_lower_value_interval,
                rcd_bds_material_plant_vrsn.lot_size_upper_value_interval,
                rcd_bds_material_plant_vrsn.rs_header_backflush_indctr,
                rcd_bds_material_plant_vrsn.repetitive_manu_receive_storg,
                rcd_bds_material_plant_vrsn.task_list_type_1,
                rcd_bds_material_plant_vrsn.task_list_grp_key_1,
                rcd_bds_material_plant_vrsn.grp_counter_1,
                rcd_bds_material_plant_vrsn.task_list_type_2,
                rcd_bds_material_plant_vrsn.task_list_grp_key_2,
                rcd_bds_material_plant_vrsn.grp_counter_2,
                rcd_bds_material_plant_vrsn.apportionment_structure,
                rcd_bds_material_plant_vrsn.similar_bom_tasklist_material,
                rcd_bds_material_plant_vrsn.issue_storg_location,
                rcd_bds_material_plant_vrsn.default_supply_area,
                rcd_bds_material_plant_vrsn.long_material_code,
                rcd_bds_material_plant_vrsn.vrsn_number,
                rcd_bds_material_plant_vrsn.external_guid);

         end loop;
         close csr_lads_mat_mpv;

         /*-*/
         /* Process Material Plant Warehouse & Batch
         /*-*/
         open csr_lads_mat_mrd;
         loop
            fetch csr_lads_mat_mrd into rcd_lads_mat_mrd;
            if (csr_lads_mat_mrd%notfound) then
               exit;
            end if;

            rcd_bds_material_plant_batch.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_material_plant_batch.plant_code := rcd_bds_material_plant_hdr.plant_code;         
            rcd_bds_material_plant_batch.storage_location := rcd_lads_mat_mrd.lgort;
            rcd_bds_material_plant_batch.sap_function := rcd_lads_mat_mrd.msgfn;
            rcd_bds_material_plant_batch.maint_status := rcd_lads_mat_mrd.pstat;
            rcd_bds_material_plant_batch.deletion_flag := rcd_lads_mat_mrd.lvorm;
            rcd_bds_material_plant_batch.mrp_storg_location_indctr := rcd_lads_mat_mrd.diskz;
            rcd_bds_material_plant_batch.special_procurement_type := rcd_lads_mat_mrd.lsobs;
            rcd_bds_material_plant_batch.mrp_reorder_point := rcd_lads_mat_mrd.lminb;
            rcd_bds_material_plant_batch.mrp_replenishment_qty := rcd_lads_mat_mrd.lbstf;
            rcd_bds_material_plant_batch.origin_country := rcd_lads_mat_mrd.herkl;
            rcd_bds_material_plant_batch.prfrnc_indctr := rcd_lads_mat_mrd.exppg;
            rcd_bds_material_plant_batch.export_indctr := rcd_lads_mat_mrd.exver;
            rcd_bds_material_plant_batch.storg_bin := rcd_lads_mat_mrd.lgpbe;
            rcd_bds_material_plant_batch.profit_center := rcd_lads_mat_mrd.prctl;
            rcd_bds_material_plant_batch.pick_area := rcd_lads_mat_mrd.lwmkb;
            rcd_bds_material_plant_batch.invetory_correction_factor := rcd_lads_mat_mrd.bskrf;
      
            /*-----------------------------------*/
            /* UPDATE BDS_MATERIAL_PLANT_BATCH   */
            /*-----------------------------------*/
            insert into bds_material_plant_batch
               (sap_material_code,
                plant_code,
                storage_location,
                sap_function,
                maint_status,
                deletion_flag,
                mrp_storg_location_indctr,
                special_procurement_type,
                mrp_reorder_point,
                mrp_replenishment_qty,
                origin_country,
                prfrnc_indctr,
                export_indctr,
                storg_bin,
                profit_center,
                pick_area,
                invetory_correction_factor)
             values 
               (rcd_bds_material_plant_batch.sap_material_code,
                rcd_bds_material_plant_batch.plant_code,
                rcd_bds_material_plant_batch.storage_location,
                rcd_bds_material_plant_batch.sap_function,
                rcd_bds_material_plant_batch.maint_status,
                rcd_bds_material_plant_batch.deletion_flag,
                rcd_bds_material_plant_batch.mrp_storg_location_indctr,
                rcd_bds_material_plant_batch.special_procurement_type,
                rcd_bds_material_plant_batch.mrp_reorder_point,
                rcd_bds_material_plant_batch.mrp_replenishment_qty,
                rcd_bds_material_plant_batch.origin_country,
                rcd_bds_material_plant_batch.prfrnc_indctr,
                rcd_bds_material_plant_batch.export_indctr,
                rcd_bds_material_plant_batch.storg_bin,
                rcd_bds_material_plant_batch.profit_center,
                rcd_bds_material_plant_batch.pick_area,
                rcd_bds_material_plant_batch.invetory_correction_factor);

         end loop;
         close csr_lads_mat_mrd;

         /*-*/
         /* Process Material Plant Unplanned Consumption
         /*-*/
         open csr_lads_mat_mum;
         loop
            fetch csr_lads_mat_mum into rcd_lads_mat_mum;
            if (csr_lads_mat_mum%notfound) then
               exit;
            end if;

            rcd_bds_matl_plant_unp_cnsmptn.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_matl_plant_unp_cnsmptn.plant_code := rcd_bds_material_plant_hdr.plant_code;         
            rcd_bds_matl_plant_unp_cnsmptn.sap_function := rcd_lads_mat_mum.msgfn;
            rcd_bds_matl_plant_unp_cnsmptn.period_first_day := rcd_lads_mat_mum.ertag;
            rcd_bds_matl_plant_unp_cnsmptn.consumption_value_fixed_indctr := rcd_lads_mat_mum.vbwrt;
            rcd_bds_matl_plant_unp_cnsmptn.corrected_consumption_value := rcd_lads_mat_mum.kovbw;
            rcd_bds_matl_plant_unp_cnsmptn.checkbox := rcd_lads_mat_mum.kzexi;
            rcd_bds_matl_plant_unp_cnsmptn.consumption_values_ratio := rcd_lads_mat_mum.antei;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PLANT_UNP_CNSMPTN */
            /*---------------------------------------*/
            insert into bds_material_plant_unp_cnsmptn
               (sap_material_code,
                plant_code,
                sap_function,
                period_first_day,
                consumption_value_fixed_indctr,
                corrected_consumption_value,
                checkbox,
                consumption_values_ratio)
             values 
               (rcd_bds_matl_plant_unp_cnsmptn.sap_material_code,
                rcd_bds_matl_plant_unp_cnsmptn.plant_code,
                rcd_bds_matl_plant_unp_cnsmptn.sap_function,
                rcd_bds_matl_plant_unp_cnsmptn.period_first_day,
                rcd_bds_matl_plant_unp_cnsmptn.consumption_value_fixed_indctr,
                rcd_bds_matl_plant_unp_cnsmptn.corrected_consumption_value,
                rcd_bds_matl_plant_unp_cnsmptn.checkbox,
                rcd_bds_matl_plant_unp_cnsmptn.consumption_values_ratio);

         end loop;
         close csr_lads_mat_mum;

         /*-*/
         /* Process Material Plant Total Consumption
         /*-*/

         open csr_lads_mat_mvm;
         loop
            fetch csr_lads_mat_mvm into rcd_lads_mat_mvm;
            if (csr_lads_mat_mvm%notfound) then
               exit;
            end if;

            rcd_bds_matl_plant_ttl_cnsmptn.sap_material_code := rcd_bds_material_hdr.sap_material_code;
            rcd_bds_matl_plant_ttl_cnsmptn.plant_code := rcd_bds_material_plant_hdr.plant_code;         
            rcd_bds_matl_plant_ttl_cnsmptn.sap_function := rcd_lads_mat_mvm.msgfn;
            rcd_bds_matl_plant_ttl_cnsmptn.period_first_day := rcd_lads_mat_mvm.ertag;
            rcd_bds_matl_plant_ttl_cnsmptn.consumption_value_fixed_indctr := rcd_lads_mat_mvm.vbwrt;
            rcd_bds_matl_plant_ttl_cnsmptn.corrected_consumption_value := rcd_lads_mat_mvm.kovbw;
            rcd_bds_matl_plant_ttl_cnsmptn.checkbox := rcd_lads_mat_mvm.kzexi;
            rcd_bds_matl_plant_ttl_cnsmptn.consumption_values_ratio := rcd_lads_mat_mvm.antei;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PLANT_TTL_CNSMPTN */
            /*---------------------------------------*/
            insert into bds_material_plant_ttl_cnsmptn
               (sap_material_code,
                plant_code,
                sap_function,
                period_first_day,
                consumption_value_fixed_indctr,
                corrected_consumption_value,
                checkbox,
                consumption_values_ratio)
             values 
               (rcd_bds_matl_plant_ttl_cnsmptn.sap_material_code,
                rcd_bds_matl_plant_ttl_cnsmptn.plant_code,
                rcd_bds_matl_plant_ttl_cnsmptn.sap_function,
                rcd_bds_matl_plant_ttl_cnsmptn.period_first_day,
                rcd_bds_matl_plant_ttl_cnsmptn.consumption_value_fixed_indctr,
                rcd_bds_matl_plant_ttl_cnsmptn.corrected_consumption_value,
                rcd_bds_matl_plant_ttl_cnsmptn.checkbox,
                rcd_bds_matl_plant_ttl_cnsmptn.consumption_values_ratio);

         end loop;
         close csr_lads_mat_mvm;

      end loop;
      close csr_lads_mat_mrc;

      /*-*/
      /* Process Material Packaging Instruction Header
      /*-*/
      open csr_lads_mat_pkg_instr_hdr;
      loop
         fetch csr_lads_mat_pkg_instr_hdr into rcd_lads_mat_pkg_instr_hdr;
         if (csr_lads_mat_pkg_instr_hdr%notfound) then
            exit;
         end if;

         rcd_bds_material_pkg_instr_hdr.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage := rcd_lads_mat_pkg_instr_hdr.kvewe;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_table := rcd_lads_mat_pkg_instr_hdr.kotabnr;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_type := rcd_lads_mat_pkg_instr_hdr.kschl;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_application := rcd_lads_mat_pkg_instr_hdr.kappl;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date := bds_date.bds_to_date('*START_DATE',rcd_lads_mat_pkg_instr_hdr.datab,'yyyymmdd');
         rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date := bds_date.bds_to_date('*END_DATE',rcd_lads_mat_pkg_instr_hdr.datbi,'yyyymmdd');
         rcd_bds_material_pkg_instr_hdr.sales_organisation := rcd_lads_mat_pkg_instr_hdr.vkorg;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_no := rcd_lads_mat_pkg_instr_hdr.packnr;
         rcd_bds_material_pkg_instr_hdr.variable_key := rcd_lads_mat_pkg_instr_hdr.vakey;
         rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_1 := rcd_lads_mat_pkg_instr_hdr.packnr1;
         rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_2 := rcd_lads_mat_pkg_instr_hdr.packnr2;
         rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_3 := rcd_lads_mat_pkg_instr_hdr.packnr3;
         rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_4 := rcd_lads_mat_pkg_instr_hdr.packnr4;
         rcd_bds_material_pkg_instr_hdr.height := rcd_lads_mat_pkg_instr_hdr.height;
         rcd_bds_material_pkg_instr_hdr.width := rcd_lads_mat_pkg_instr_hdr.width;
         rcd_bds_material_pkg_instr_hdr.length := rcd_lads_mat_pkg_instr_hdr.length;
         rcd_bds_material_pkg_instr_hdr.pkg_material_tare_weight := rcd_lads_mat_pkg_instr_hdr.tarewei;
         rcd_bds_material_pkg_instr_hdr.goods_load_weight := rcd_lads_mat_pkg_instr_hdr.loadwei;
         rcd_bds_material_pkg_instr_hdr.hu_total_weight := rcd_lads_mat_pkg_instr_hdr.totlwei;
         rcd_bds_material_pkg_instr_hdr.pkg_material_tare_volume := rcd_lads_mat_pkg_instr_hdr.tarevol;
         rcd_bds_material_pkg_instr_hdr.goods_load_volume := rcd_lads_mat_pkg_instr_hdr.loadvol;
         rcd_bds_material_pkg_instr_hdr.hu_total_volume := rcd_lads_mat_pkg_instr_hdr.totlvol;
         rcd_bds_material_pkg_instr_hdr.pkg_instr_id_no := rcd_lads_mat_pkg_instr_hdr.pobjid;
         rcd_bds_material_pkg_instr_hdr.stack_factor := rcd_lads_mat_pkg_instr_hdr.stfac;
         rcd_bds_material_pkg_instr_hdr.change_date := bds_date.bds_to_date('*DATE',rcd_lads_mat_pkg_instr_hdr.chdat,'yyyymmdd');
         rcd_bds_material_pkg_instr_hdr.dimension_uom := rcd_lads_mat_pkg_instr_hdr.unitdim;
         rcd_bds_material_pkg_instr_hdr.weight_unit := rcd_lads_mat_pkg_instr_hdr.unitwei;
         rcd_bds_material_pkg_instr_hdr.max_weight_unit := rcd_lads_mat_pkg_instr_hdr.unitwei_max;
         rcd_bds_material_pkg_instr_hdr.volume_unit := rcd_lads_mat_pkg_instr_hdr.unitvol;
         rcd_bds_material_pkg_instr_hdr.max_volume_unit := rcd_lads_mat_pkg_instr_hdr.unitvol_max;

         /*---------------------------------------*/
         /* UPDATE BDS_MATERIAL_PKG_INSTR_HDR     */
         /*---------------------------------------*/
         insert into bds_material_pkg_instr_hdr
            (sap_material_code,
             pkg_instr_table_usage,
             pkg_instr_table,
             pkg_instr_type,
             pkg_instr_application,
             pkg_instr_start_date,
             pkg_instr_end_date,
             sales_organisation,
             pkg_instr_no,
             variable_key,
             alternative_pkg_instr_1,
             alternative_pkg_instr_2,
             alternative_pkg_instr_3,
             alternative_pkg_instr_4,
             height,
             width,
             length,
             pkg_material_tare_weight,
             goods_load_weight,
             hu_total_weight,
             pkg_material_tare_volume,
             goods_load_volume,
             hu_total_volume,
             pkg_instr_id_no,
             stack_factor,
             change_date,
             dimension_uom,
             weight_unit,
             max_weight_unit,
             volume_unit,
             max_volume_unit)
          values 
            (rcd_bds_material_pkg_instr_hdr.sap_material_code,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_table,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_type,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_application,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date,
             rcd_bds_material_pkg_instr_hdr.sales_organisation,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_no,
             rcd_bds_material_pkg_instr_hdr.variable_key,
             rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_1,
             rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_2,
             rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_3,
             rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_4,
             rcd_bds_material_pkg_instr_hdr.height,
             rcd_bds_material_pkg_instr_hdr.width,
             rcd_bds_material_pkg_instr_hdr.length,
             rcd_bds_material_pkg_instr_hdr.pkg_material_tare_weight,
             rcd_bds_material_pkg_instr_hdr.goods_load_weight,
             rcd_bds_material_pkg_instr_hdr.hu_total_weight,
             rcd_bds_material_pkg_instr_hdr.pkg_material_tare_volume,
             rcd_bds_material_pkg_instr_hdr.goods_load_volume,
             rcd_bds_material_pkg_instr_hdr.hu_total_volume,
             rcd_bds_material_pkg_instr_hdr.pkg_instr_id_no,
             rcd_bds_material_pkg_instr_hdr.stack_factor,
             rcd_bds_material_pkg_instr_hdr.change_date,
             rcd_bds_material_pkg_instr_hdr.dimension_uom,
             rcd_bds_material_pkg_instr_hdr.weight_unit,
             rcd_bds_material_pkg_instr_hdr.max_weight_unit,
             rcd_bds_material_pkg_instr_hdr.volume_unit,
             rcd_bds_material_pkg_instr_hdr.max_volume_unit);

         /*-*/
         /* Process Material Packaging Instruction Detail
         /*-*/
         open csr_lads_mat_pid;
         loop
            fetch csr_lads_mat_pid into rcd_lads_mat_pid;
            if (csr_lads_mat_pid%notfound) then
               exit;
            end if;

            rcd_bds_material_pkg_instr_det.sap_material_code := rcd_bds_material_pkg_instr_hdr.sap_material_code;
            rcd_bds_material_pkg_instr_det.pkg_instr_table_usage := rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage;
            rcd_bds_material_pkg_instr_det.pkg_instr_table := rcd_bds_material_pkg_instr_hdr.pkg_instr_table;
            rcd_bds_material_pkg_instr_det.pkg_instr_type := rcd_bds_material_pkg_instr_hdr.pkg_instr_type;
            rcd_bds_material_pkg_instr_det.pkg_instr_application := rcd_bds_material_pkg_instr_hdr.pkg_instr_application;
            rcd_bds_material_pkg_instr_det.pkg_instr_start_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date;
            rcd_bds_material_pkg_instr_det.pkg_instr_end_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date;
            rcd_bds_material_pkg_instr_det.sales_organisation := rcd_bds_material_pkg_instr_hdr.sales_organisation;
            rcd_bds_material_pkg_instr_det.item_ctgry := rcd_lads_mat_pid.detail_itemtype;
            rcd_bds_material_pkg_instr_det.component := rcd_lads_mat_pid.component;
            rcd_bds_material_pkg_instr_det.target_qty := rcd_lads_mat_pid.trgqty;
            rcd_bds_material_pkg_instr_det.min_qty := rcd_lads_mat_pid.minqty;
            rcd_bds_material_pkg_instr_det.rounding_qty := rcd_lads_mat_pid.rndqty;
            rcd_bds_material_pkg_instr_det.uom := rcd_lads_mat_pid.unitqty;
            rcd_bds_material_pkg_instr_det.load_carrier_indctr := rcd_lads_mat_pid.indmapaco;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PKG_INSTR_DET     */
            /*---------------------------------------*/
            insert into bds_material_pkg_instr_det
               (sap_material_code,
                pkg_instr_table_usage,
                pkg_instr_table,
                pkg_instr_type,
                pkg_instr_application,
                pkg_instr_start_date,
                pkg_instr_end_date,
                sales_organisation,
                item_ctgry,
                component,
                target_qty,
                min_qty,
                rounding_qty,
                uom,
                load_carrier_indctr,
                pkg_instr_no,
                variable_key,
                alternative_pkg_instr_1,
                alternative_pkg_instr_2,
                alternative_pkg_instr_3,
                alternative_pkg_instr_4,
                height,
                width,
                length,
                pkg_material_tare_weight,
                goods_load_weight,
                hu_total_weight,
                pkg_material_tare_volume,
                goods_load_volume,
                hu_total_volume,
                pkg_instr_id_no,
                stack_factor,
                change_date,
                dimension_uom,
                weight_unit,
                max_weight_unit,
                volume_unit,
                max_volume_unit)
                values 
               (rcd_bds_material_pkg_instr_det.sap_material_code,
                rcd_bds_material_pkg_instr_det.pkg_instr_table_usage,
                rcd_bds_material_pkg_instr_det.pkg_instr_table,
                rcd_bds_material_pkg_instr_det.pkg_instr_type,
                rcd_bds_material_pkg_instr_det.pkg_instr_application,
                rcd_bds_material_pkg_instr_det.pkg_instr_start_date,
                rcd_bds_material_pkg_instr_det.pkg_instr_end_date,
                rcd_bds_material_pkg_instr_det.sales_organisation,
                rcd_bds_material_pkg_instr_det.item_ctgry,
                rcd_bds_material_pkg_instr_det.component,
                rcd_bds_material_pkg_instr_det.target_qty,
                rcd_bds_material_pkg_instr_det.min_qty,
                rcd_bds_material_pkg_instr_det.rounding_qty,
                rcd_bds_material_pkg_instr_det.uom,
                rcd_bds_material_pkg_instr_det.load_carrier_indctr,
                rcd_bds_material_pkg_instr_hdr.pkg_instr_no,
                rcd_bds_material_pkg_instr_hdr.variable_key,
                rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_1,
                rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_2,
                rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_3,
                rcd_bds_material_pkg_instr_hdr.alternative_pkg_instr_4,
                rcd_bds_material_pkg_instr_hdr.height,
                rcd_bds_material_pkg_instr_hdr.width,
                rcd_bds_material_pkg_instr_hdr.length,
                rcd_bds_material_pkg_instr_hdr.pkg_material_tare_weight,
                rcd_bds_material_pkg_instr_hdr.goods_load_weight,
                rcd_bds_material_pkg_instr_hdr.hu_total_weight,
                rcd_bds_material_pkg_instr_hdr.pkg_material_tare_volume,
                rcd_bds_material_pkg_instr_hdr.goods_load_volume,
                rcd_bds_material_pkg_instr_hdr.hu_total_volume,
                rcd_bds_material_pkg_instr_hdr.pkg_instr_id_no,
                rcd_bds_material_pkg_instr_hdr.stack_factor,
                rcd_bds_material_pkg_instr_hdr.change_date,
                rcd_bds_material_pkg_instr_hdr.dimension_uom,
                rcd_bds_material_pkg_instr_hdr.weight_unit,
                rcd_bds_material_pkg_instr_hdr.max_weight_unit,
                rcd_bds_material_pkg_instr_hdr.volume_unit,
                rcd_bds_material_pkg_instr_hdr.max_volume_unit);

         end loop;
         close csr_lads_mat_pid;

         /*-*/
         /* Process Material Packaging Instruction EAN
         /*-*/
         open csr_lads_mat_pie;
         loop
            fetch csr_lads_mat_pie into rcd_lads_mat_pie;
            if (csr_lads_mat_pie%notfound) then
               exit;
            end if;

            rcd_bds_material_pkg_instr_ean.sap_material_code := rcd_bds_material_pkg_instr_hdr.sap_material_code;
            rcd_bds_material_pkg_instr_ean.pkg_instr_table_usage := rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage;
            rcd_bds_material_pkg_instr_ean.pkg_instr_table := rcd_bds_material_pkg_instr_hdr.pkg_instr_table;
            rcd_bds_material_pkg_instr_ean.pkg_instr_type := rcd_bds_material_pkg_instr_hdr.pkg_instr_type;
            rcd_bds_material_pkg_instr_ean.pkg_instr_application := rcd_bds_material_pkg_instr_hdr.pkg_instr_application;
            rcd_bds_material_pkg_instr_ean.pkg_instr_start_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date;
            rcd_bds_material_pkg_instr_ean.pkg_instr_end_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date;
            rcd_bds_material_pkg_instr_ean.sales_organisation := rcd_bds_material_pkg_instr_hdr.sales_organisation;
            rcd_bds_material_pkg_instr_ean.interntl_article_no := rcd_lads_mat_pie.ean11;
            rcd_bds_material_pkg_instr_ean.interntl_article_no_ctgry := rcd_lads_mat_pie.eantp;
            rcd_bds_material_pkg_instr_ean.main_ean_indctr := rcd_lads_mat_pie.hpean;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PKG_INSTR_EAN     */
            /*---------------------------------------*/
            insert into bds_material_pkg_instr_ean
               (sap_material_code,
                pkg_instr_table_usage,
                pkg_instr_table,
                pkg_instr_type,
                pkg_instr_application,
                pkg_instr_start_date,
                pkg_instr_end_date,
                sales_organisation,
                interntl_article_no,
                interntl_article_no_ctgry,
                main_ean_indctr)
             values 
               (rcd_bds_material_pkg_instr_ean.sap_material_code,
                rcd_bds_material_pkg_instr_ean.pkg_instr_table_usage,
                rcd_bds_material_pkg_instr_ean.pkg_instr_table,
                rcd_bds_material_pkg_instr_ean.pkg_instr_type,
                rcd_bds_material_pkg_instr_ean.pkg_instr_application,
                rcd_bds_material_pkg_instr_ean.pkg_instr_start_date,
                rcd_bds_material_pkg_instr_ean.pkg_instr_end_date,
                rcd_bds_material_pkg_instr_ean.sales_organisation,
                rcd_bds_material_pkg_instr_ean.interntl_article_no,
                rcd_bds_material_pkg_instr_ean.interntl_article_no_ctgry,
                rcd_bds_material_pkg_instr_ean.main_ean_indctr);

         end loop;
         close csr_lads_mat_pie;

         /*-*/
         /* Process Material Packaging Instruction MOE
         /*-*/
         open csr_lads_mat_pim;
         loop
            fetch csr_lads_mat_pim into rcd_lads_mat_pim;
            if (csr_lads_mat_pim%notfound) then
               exit;
            end if;

            rcd_bds_material_pkg_instr_moe.sap_material_code := rcd_bds_material_pkg_instr_hdr.sap_material_code;
            rcd_bds_material_pkg_instr_moe.pkg_instr_table_usage := rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage;
            rcd_bds_material_pkg_instr_moe.pkg_instr_table := rcd_bds_material_pkg_instr_hdr.pkg_instr_table;
            rcd_bds_material_pkg_instr_moe.pkg_instr_type := rcd_bds_material_pkg_instr_hdr.pkg_instr_type;
            rcd_bds_material_pkg_instr_moe.pkg_instr_application := rcd_bds_material_pkg_instr_hdr.pkg_instr_application;
            rcd_bds_material_pkg_instr_moe.pkg_instr_start_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date;
            rcd_bds_material_pkg_instr_moe.pkg_instr_end_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date;
            rcd_bds_material_pkg_instr_moe.sales_organisation := rcd_bds_material_pkg_instr_hdr.sales_organisation;
            rcd_bds_material_pkg_instr_moe.moe_code := rcd_lads_mat_pim.moe;
            rcd_bds_material_pkg_instr_moe.usage_code := rcd_lads_mat_pim.usagecode;
            rcd_bds_material_pkg_instr_moe.start_date := bds_date.bds_to_date('*START_DATE',rcd_lads_mat_pim.datab,'yyyymmdd');
            rcd_bds_material_pkg_instr_moe.end_date := bds_date.bds_to_date('*END_DATE',rcd_lads_mat_pim.dated,'yyyymmdd');

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PKG_INSTR_MOE     */
            /*---------------------------------------*/
            insert into bds_material_pkg_instr_moe
               (sap_material_code,
                pkg_instr_table_usage,
                pkg_instr_table,
                pkg_instr_type,
                pkg_instr_application,
                pkg_instr_start_date,
                pkg_instr_end_date,
                sales_organisation,
                moe_code,
                usage_code,
                start_date,
                end_date)
             values 
               (rcd_bds_material_pkg_instr_moe.sap_material_code,
                rcd_bds_material_pkg_instr_moe.pkg_instr_table_usage,
                rcd_bds_material_pkg_instr_moe.pkg_instr_table,
                rcd_bds_material_pkg_instr_moe.pkg_instr_type,
                rcd_bds_material_pkg_instr_moe.pkg_instr_application,
                rcd_bds_material_pkg_instr_moe.pkg_instr_start_date,
                rcd_bds_material_pkg_instr_moe.pkg_instr_end_date,
                rcd_bds_material_pkg_instr_moe.sales_organisation,
                rcd_bds_material_pkg_instr_moe.moe_code,
                rcd_bds_material_pkg_instr_moe.usage_code,
                rcd_bds_material_pkg_instr_moe.start_date,
                rcd_bds_material_pkg_instr_moe.end_date);

         end loop;
         close csr_lads_mat_pim;

         /*-*/
         /* Process Material Packaging Instruction Regional Code Conversion
         /*-*/
         open csr_lads_mat_pir;
         loop
            fetch csr_lads_mat_pir into rcd_lads_mat_pir;
            if (csr_lads_mat_pir%notfound) then
               exit;
            end if;

            rcd_bds_material_pkg_instr_reg.sap_material_code := rcd_bds_material_pkg_instr_hdr.sap_material_code;
            rcd_bds_material_pkg_instr_reg.pkg_instr_table_usage := rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage;
            rcd_bds_material_pkg_instr_reg.pkg_instr_table := rcd_bds_material_pkg_instr_hdr.pkg_instr_table;
            rcd_bds_material_pkg_instr_reg.pkg_instr_type := rcd_bds_material_pkg_instr_hdr.pkg_instr_type;
            rcd_bds_material_pkg_instr_reg.pkg_instr_application := rcd_bds_material_pkg_instr_hdr.pkg_instr_application;
            rcd_bds_material_pkg_instr_reg.pkg_instr_start_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date;
            rcd_bds_material_pkg_instr_reg.pkg_instr_end_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date;
            rcd_bds_material_pkg_instr_reg.sales_organisation := rcd_bds_material_pkg_instr_hdr.sales_organisation;
            rcd_bds_material_pkg_instr_reg.regional_code_id := rcd_lads_mat_pir.z_lcdid;
            rcd_bds_material_pkg_instr_reg.regional_code := rcd_lads_mat_pir.z_lcdnr;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PKG_INSTR_REG     */
            /*---------------------------------------*/
            insert into bds_material_pkg_instr_reg
               (sap_material_code,
                pkg_instr_table_usage,
                pkg_instr_table,
                pkg_instr_type,
                pkg_instr_application,
                pkg_instr_start_date,
                pkg_instr_end_date,
                sales_organisation,
                regional_code_id,
                regional_code)
             values 
               (rcd_bds_material_pkg_instr_reg.sap_material_code,
                rcd_bds_material_pkg_instr_reg.pkg_instr_table_usage,
                rcd_bds_material_pkg_instr_reg.pkg_instr_table,
                rcd_bds_material_pkg_instr_reg.pkg_instr_type,
                rcd_bds_material_pkg_instr_reg.pkg_instr_application,
                rcd_bds_material_pkg_instr_reg.pkg_instr_start_date,
                rcd_bds_material_pkg_instr_reg.pkg_instr_end_date,
                rcd_bds_material_pkg_instr_reg.sales_organisation,
                rcd_bds_material_pkg_instr_reg.regional_code_id,
                rcd_bds_material_pkg_instr_reg.regional_code);

         end loop;
         close csr_lads_mat_pir;

         /*-*/
         /* Process Material Packaging Instruction Text
         /*-*/
         open csr_lads_mat_pit;
         loop
            fetch csr_lads_mat_pit into rcd_lads_mat_pit;
            if (csr_lads_mat_pit%notfound) then
               exit;
            end if;

            rcd_bds_matl_pkg_instr_text.sap_material_code := rcd_bds_material_pkg_instr_hdr.sap_material_code;
            rcd_bds_matl_pkg_instr_text.pkg_instr_table_usage := rcd_bds_material_pkg_instr_hdr.pkg_instr_table_usage;
            rcd_bds_matl_pkg_instr_text.pkg_instr_table := rcd_bds_material_pkg_instr_hdr.pkg_instr_table;
            rcd_bds_matl_pkg_instr_text.pkg_instr_type := rcd_bds_material_pkg_instr_hdr.pkg_instr_type;
            rcd_bds_matl_pkg_instr_text.pkg_instr_application := rcd_bds_material_pkg_instr_hdr.pkg_instr_application;
            rcd_bds_matl_pkg_instr_text.pkg_instr_start_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_start_date;
            rcd_bds_matl_pkg_instr_text.pkg_instr_end_date := rcd_bds_material_pkg_instr_hdr.pkg_instr_end_date;
            rcd_bds_matl_pkg_instr_text.sales_organisation := rcd_bds_material_pkg_instr_hdr.sales_organisation;
            rcd_bds_matl_pkg_instr_text.text_language := rcd_lads_mat_pit.spras;
            rcd_bds_matl_pkg_instr_text.short_text := rcd_lads_mat_pit.content;

            /*---------------------------------------*/
            /* UPDATE BDS_MATERIAL_PKG_INSTR_TEXT    */
            /*---------------------------------------*/
            insert into bds_material_pkg_instr_text
               (sap_material_code,
                pkg_instr_table_usage,
                pkg_instr_table,
                pkg_instr_type,
                pkg_instr_application,
                pkg_instr_start_date,
                pkg_instr_end_date,
                sales_organisation,
                text_language,
                short_text)
             values 
               (rcd_bds_matl_pkg_instr_text.sap_material_code,
                rcd_bds_matl_pkg_instr_text.pkg_instr_table_usage,
                rcd_bds_matl_pkg_instr_text.pkg_instr_table,
                rcd_bds_matl_pkg_instr_text.pkg_instr_type,
                rcd_bds_matl_pkg_instr_text.pkg_instr_application,
                rcd_bds_matl_pkg_instr_text.pkg_instr_start_date,
                rcd_bds_matl_pkg_instr_text.pkg_instr_end_date,
                rcd_bds_matl_pkg_instr_text.sales_organisation,
                rcd_bds_matl_pkg_instr_text.text_language,
                rcd_bds_matl_pkg_instr_text.short_text);

         end loop;
         close csr_lads_mat_pit;

      end loop;
      close csr_lads_mat_pkg_instr_hdr;


      /*-*/
      /* Process Material/Plant for MFANZ
      /*  Note: This is a custom table for MFANZ Plant use only
      /*        It is intended to be used for Fast Refresh Materialised views to Plant DB's 
      /*-*/
      open csr_lads_material_plant_mfanz;
      loop
         fetch csr_lads_material_plant_mfanz into rcd_lads_material_plant_mfanz;
         if (csr_lads_material_plant_mfanz%notfound) then
            exit;
         end if;


         rcd_bds_material_plant_mfanz.sap_material_code := rcd_bds_material_hdr.sap_material_code;
         rcd_bds_material_plant_mfanz.plant_code := rcd_lads_material_plant_mfanz.plant_code;
         rcd_bds_material_plant_mfanz.mars_rprsnttv_item_code := rcd_lads_material_plant_mfanz.mars_rprsnttv_item_code;
         rcd_bds_material_plant_mfanz.bds_material_desc_en := rcd_lads_material_plant_mfanz.bds_material_desc_en;
         rcd_bds_material_plant_mfanz.material_type := rcd_lads_material_plant_mfanz.material_type;
         rcd_bds_material_plant_mfanz.material_grp := rcd_lads_material_plant_mfanz.material_grp;
         rcd_bds_material_plant_mfanz.base_uom := rcd_lads_material_plant_mfanz.base_uom;
         rcd_bds_material_plant_mfanz.order_unit := rcd_lads_material_plant_mfanz.order_unit;
         rcd_bds_material_plant_mfanz.gross_weight := rcd_lads_material_plant_mfanz.gross_weight;
         rcd_bds_material_plant_mfanz.net_weight := rcd_lads_material_plant_mfanz.net_weight;
         rcd_bds_material_plant_mfanz.gross_weight_unit := rcd_lads_material_plant_mfanz.gross_weight_unit;
         rcd_bds_material_plant_mfanz.length := rcd_lads_material_plant_mfanz.length;
         rcd_bds_material_plant_mfanz.width := rcd_lads_material_plant_mfanz.width;
         rcd_bds_material_plant_mfanz.height := rcd_lads_material_plant_mfanz.height;
         rcd_bds_material_plant_mfanz.dimension_uom := rcd_lads_material_plant_mfanz.dimension_uom;
         rcd_bds_material_plant_mfanz.interntl_article_no := rcd_lads_material_plant_mfanz.interntl_article_no;
         rcd_bds_material_plant_mfanz.total_shelf_life := rcd_lads_material_plant_mfanz.total_shelf_life;
         rcd_bds_material_plant_mfanz.mars_intrmdt_prdct_compnt_flag := rcd_lads_material_plant_mfanz.mars_intrmdt_prdct_compnt_flag;
         rcd_bds_material_plant_mfanz.mars_merchandising_unit_flag := rcd_lads_material_plant_mfanz.mars_merchandising_unit_flag;
         rcd_bds_material_plant_mfanz.mars_prmotional_material_flag := rcd_lads_material_plant_mfanz.mars_prmotional_material_flag;
         rcd_bds_material_plant_mfanz.mars_retail_sales_unit_flag := rcd_lads_material_plant_mfanz.mars_retail_sales_unit_flag;
         rcd_bds_material_plant_mfanz.mars_semi_finished_prdct_flag := rcd_lads_material_plant_mfanz.mars_semi_finished_prdct_flag;
         rcd_bds_material_plant_mfanz.mars_rprsnttv_item_flag := rcd_lads_material_plant_mfanz.mars_rprsnttv_item_flag;
         rcd_bds_material_plant_mfanz.mars_traded_unit_flag := rcd_lads_material_plant_mfanz.mars_traded_unit_flag;
         rcd_bds_material_plant_mfanz.xplant_status := rcd_lads_material_plant_mfanz.xplant_status;
         rcd_bds_material_plant_mfanz.xplant_status_valid := rcd_lads_material_plant_mfanz.xplant_status_valid;
         rcd_bds_material_plant_mfanz.batch_mngmnt_reqrmnt_indctr := rcd_lads_material_plant_mfanz.batch_mngmnt_reqrmnt_indctr;
         rcd_bds_material_plant_mfanz.mars_plant_material_type := rcd_lads_material_plant_mfanz.mars_plant_material_type;
         rcd_bds_material_plant_mfanz.procurement_type := rcd_lads_material_plant_mfanz.procurement_type;
         rcd_bds_material_plant_mfanz.special_procurement_type := rcd_lads_material_plant_mfanz.special_procurement_type;
         rcd_bds_material_plant_mfanz.issue_storage_location := rcd_lads_material_plant_mfanz.issue_storage_location;
         rcd_bds_material_plant_mfanz.mrp_controller := rcd_lads_material_plant_mfanz.mrp_controller;
         rcd_bds_material_plant_mfanz.plant_specific_status_valid := rcd_lads_material_plant_mfanz.plant_specific_status_valid;
         rcd_bds_material_plant_mfanz.deletion_indctr := rcd_lads_material_plant_mfanz.deletion_indctr;
         rcd_bds_material_plant_mfanz.plant_specific_status := rcd_lads_material_plant_mfanz.plant_specific_status;
         rcd_bds_material_plant_mfanz.assembly_scrap_percntg := rcd_lads_material_plant_mfanz.assembly_scrap_percntg;
         rcd_bds_material_plant_mfanz.component_scrap_percntg := rcd_lads_material_plant_mfanz.component_scrap_percntg;
         rcd_bds_material_plant_mfanz.backflush_indctr := rcd_lads_material_plant_mfanz.backflush_indctr;
         rcd_bds_material_plant_mfanz.sales_text_147 := rcd_lads_material_plant_mfanz.sales_text_147;
         rcd_bds_material_plant_mfanz.sales_text_149 := rcd_lads_material_plant_mfanz.sales_text_149;
         rcd_bds_material_plant_mfanz.regional_code_10 := rcd_lads_material_plant_mfanz.regional_code_10;
         rcd_bds_material_plant_mfanz.regional_code_18 := rcd_lads_material_plant_mfanz.regional_code_18;
         rcd_bds_material_plant_mfanz.regional_code_17 := rcd_lads_material_plant_mfanz.regional_code_17;
         rcd_bds_material_plant_mfanz.regional_code_19 := rcd_lads_material_plant_mfanz.regional_code_19;
         rcd_bds_material_plant_mfanz.future_planned_price_1 := rcd_lads_material_plant_mfanz.future_planned_price_1;
         rcd_bds_material_plant_mfanz.vltn_class := rcd_lads_material_plant_mfanz.vltn_class;
         rcd_bds_material_plant_mfanz.bds_pce_factor_from_base_uom := rcd_lads_material_plant_mfanz.bds_pce_factor_from_base_uom;
         rcd_bds_material_plant_mfanz.mars_pce_item_code := rcd_lads_material_plant_mfanz.mars_pce_item_code;
         rcd_bds_material_plant_mfanz.mars_pce_interntl_article_no := rcd_lads_material_plant_mfanz.mars_pce_interntl_article_no;
         rcd_bds_material_plant_mfanz.bds_sb_factor_from_base_uom := rcd_lads_material_plant_mfanz.bds_sb_factor_from_base_uom;
         rcd_bds_material_plant_mfanz.mars_sb_item_code := rcd_lads_material_plant_mfanz.mars_sb_item_code;
         rcd_bds_material_plant_mfanz.effective_out_date := rcd_lads_material_plant_mfanz.effective_out_date;
         rcd_bds_material_plant_mfanz.discontinuation_indctr := rcd_lads_material_plant_mfanz.discontinuation_indctr;
         rcd_bds_material_plant_mfanz.followup_material := rcd_lads_material_plant_mfanz.followup_material;
         rcd_bds_material_plant_mfanz.material_division := rcd_lads_material_plant_mfanz.material_division;
         rcd_bds_material_plant_mfanz.mrp_type := rcd_lads_material_plant_mfanz.mrp_type;
         rcd_bds_material_plant_mfanz.max_storage_prd := rcd_lads_material_plant_mfanz.max_storage_prd;
         rcd_bds_material_plant_mfanz.max_storage_prd_unit := rcd_lads_material_plant_mfanz.max_storage_prd_unit;

         /*-*/
         /* Calculate Unit Cost
         /*-*/
         case 
            when (rcd_lads_material_plant_mfanz.stndrd_price is null or
                  rcd_lads_material_plant_mfanz.stndrd_price = 0) then
               rcd_bds_material_plant_mfanz.bds_unit_cost := 0;   
            else
               rcd_bds_material_plant_mfanz.bds_unit_cost := rcd_lads_material_plant_mfanz.stndrd_price/rcd_lads_material_plant_mfanz.price_unit;      
         end case;


         /*------------------------------------*/
         /* UPDATE BDS_MATERIAL_PLANT_MFANZ    */
         /*------------------------------------*/
         insert into bds_material_plant_mfanz
            (sap_material_code,
             plant_code,
             mars_rprsnttv_item_code,
             bds_material_desc_en,
             material_type,
             material_grp,
             base_uom,
             order_unit,
             gross_weight,
             net_weight,
             gross_weight_unit,
             length,
             width,
             height,
             dimension_uom,
             interntl_article_no,
             total_shelf_life,
             mars_intrmdt_prdct_compnt_flag,
             mars_merchandising_unit_flag,
             mars_prmotional_material_flag,
             mars_retail_sales_unit_flag,
             mars_semi_finished_prdct_flag,
             mars_rprsnttv_item_flag,
             mars_traded_unit_flag,
             xplant_status,
             xplant_status_valid,
             batch_mngmnt_reqrmnt_indctr,
             mars_plant_material_type,
             procurement_type,
             special_procurement_type,
             issue_storage_location,
             mrp_controller,
             plant_specific_status_valid,
             deletion_indctr,
             plant_specific_status,
             assembly_scrap_percntg,
             component_scrap_percntg,
             backflush_indctr,
             sales_text_147,
             sales_text_149,
             regional_code_10,
             regional_code_18,
             regional_code_17,
             regional_code_19,
             bds_unit_cost,
             future_planned_price_1,
             vltn_class,
             bds_pce_factor_from_base_uom,
             mars_pce_item_code,
             mars_pce_interntl_article_no,
             bds_sb_factor_from_base_uom,
             mars_sb_item_code,
             effective_out_date,
             discontinuation_indctr,
             followup_material,
             material_division,
             mrp_type,
             max_storage_prd,
             max_storage_prd_unit)
          values 
            (rcd_bds_material_plant_mfanz.sap_material_code,
             rcd_bds_material_plant_mfanz.plant_code,
             rcd_bds_material_plant_mfanz.mars_rprsnttv_item_code,
             rcd_bds_material_plant_mfanz.bds_material_desc_en,
             rcd_bds_material_plant_mfanz.material_type,
             rcd_bds_material_plant_mfanz.material_grp,
             rcd_bds_material_plant_mfanz.base_uom,
             rcd_bds_material_plant_mfanz.order_unit,
             rcd_bds_material_plant_mfanz.gross_weight,
             rcd_bds_material_plant_mfanz.net_weight,
             rcd_bds_material_plant_mfanz.gross_weight_unit,
             rcd_bds_material_plant_mfanz.length,
             rcd_bds_material_plant_mfanz.width,
             rcd_bds_material_plant_mfanz.height,
             rcd_bds_material_plant_mfanz.dimension_uom,
             rcd_bds_material_plant_mfanz.interntl_article_no,
             rcd_bds_material_plant_mfanz.total_shelf_life,
             rcd_bds_material_plant_mfanz.mars_intrmdt_prdct_compnt_flag,
             rcd_bds_material_plant_mfanz.mars_merchandising_unit_flag,
             rcd_bds_material_plant_mfanz.mars_prmotional_material_flag,
             rcd_bds_material_plant_mfanz.mars_retail_sales_unit_flag,
             rcd_bds_material_plant_mfanz.mars_semi_finished_prdct_flag,
             rcd_bds_material_plant_mfanz.mars_rprsnttv_item_flag,
             rcd_bds_material_plant_mfanz.mars_traded_unit_flag,
             rcd_bds_material_plant_mfanz.xplant_status,
             rcd_bds_material_plant_mfanz.xplant_status_valid,
             rcd_bds_material_plant_mfanz.batch_mngmnt_reqrmnt_indctr,
             rcd_bds_material_plant_mfanz.mars_plant_material_type,
             rcd_bds_material_plant_mfanz.procurement_type,
             rcd_bds_material_plant_mfanz.special_procurement_type,
             rcd_bds_material_plant_mfanz.issue_storage_location,
             rcd_bds_material_plant_mfanz.mrp_controller,
             rcd_bds_material_plant_mfanz.plant_specific_status_valid,
             rcd_bds_material_plant_mfanz.deletion_indctr,
             rcd_bds_material_plant_mfanz.plant_specific_status,
             rcd_bds_material_plant_mfanz.assembly_scrap_percntg,
             rcd_bds_material_plant_mfanz.component_scrap_percntg,
             rcd_bds_material_plant_mfanz.backflush_indctr,
             rcd_bds_material_plant_mfanz.sales_text_147,
             rcd_bds_material_plant_mfanz.sales_text_149,
             rcd_bds_material_plant_mfanz.regional_code_10,
             rcd_bds_material_plant_mfanz.regional_code_18,
             rcd_bds_material_plant_mfanz.regional_code_17,
             rcd_bds_material_plant_mfanz.regional_code_19,
             rcd_bds_material_plant_mfanz.bds_unit_cost,
             rcd_bds_material_plant_mfanz.future_planned_price_1,
             rcd_bds_material_plant_mfanz.vltn_class,
             rcd_bds_material_plant_mfanz.bds_pce_factor_from_base_uom,
             rcd_bds_material_plant_mfanz.mars_pce_item_code,
             rcd_bds_material_plant_mfanz.mars_pce_interntl_article_no,
             rcd_bds_material_plant_mfanz.bds_sb_factor_from_base_uom,
             rcd_bds_material_plant_mfanz.mars_sb_item_code,
             rcd_bds_material_plant_mfanz.effective_out_date,
             rcd_bds_material_plant_mfanz.discontinuation_indctr,
             rcd_bds_material_plant_mfanz.followup_material,
             rcd_bds_material_plant_mfanz.material_division,
             rcd_bds_material_plant_mfanz.mrp_type,
             rcd_bds_material_plant_mfanz.max_storage_prd,
             rcd_bds_material_plant_mfanz.max_storage_prd_unit);


      end loop;
      close csr_lads_material_plant_mfanz;


      /*-*/
      /* Perform exclusion processing
      /*-*/   
      if (var_excluded) then
         var_flattened := '2';
      end if;


      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/         
      update lads_mat_hdr
         set lads_flattened = var_flattened
      where matnr = par_matnr;


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
         raise_application_error(-20000, 'BDS_FLATTEN -  ' || 'MATNR: ' || nvl(par_matnr,'null') || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_matnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_mat_hdr t01
         where t01.matnr = par_matnr
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
         bds_flatten(par_matnr);

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
         select t01.matnr
         from lads_mat_hdr t01
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

         lads_lock(rcd_flatten.matnr);

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
      bds_table.truncate('bds_material_plant_mfanz');
      bds_table.truncate('bds_material_pkg_instr_reg');
      bds_table.truncate('bds_material_pkg_instr_text');
      bds_table.truncate('bds_material_pkg_instr_moe');
      bds_table.truncate('bds_material_pkg_instr_ean');
      bds_table.truncate('bds_material_pkg_instr_det');
      bds_table.truncate('bds_material_pkg_instr_hdr');
      bds_table.truncate('bds_material_plant_ttl_cnsmptn');
      bds_table.truncate('bds_material_plant_unp_cnsmptn');
      bds_table.truncate('bds_material_plant_batch');
      bds_table.truncate('bds_material_plant_vrsn');
      bds_table.truncate('bds_material_plant_forecast');
      bds_table.truncate('bds_material_plant_hdr');
      bds_table.truncate('bds_material_uom_ean');
      bds_table.truncate('bds_material_uom');
      bds_table.truncate('bds_material_regional');
      bds_table.truncate('bds_material_dstrbtn_chain');
      bds_table.truncate('bds_material_desc');
      bds_table.truncate('bds_material_moe');
      bds_table.truncate('bds_material_moe_grp');
      bds_table.truncate('bds_material_tax');
      bds_table.truncate('bds_material_text_en');
      bds_table.truncate('bds_material_text');
      bds_table.truncate('bds_material_vltn');
      bds_table.truncate('bds_material_hdr');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_mat_hdr
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

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad04_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad04_flatten for bds_app.bds_atllad04_flatten;
grant execute on bds_atllad04_flatten to lics_app;
grant execute on bds_atllad04_flatten to lads_app;
