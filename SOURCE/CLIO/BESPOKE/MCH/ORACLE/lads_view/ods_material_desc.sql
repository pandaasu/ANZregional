/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material_desc
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material Description View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/06   Linden Glen    Modified to use market text when available

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material_desc as
select lads_trim_code(matnr) as sap_material_code,
       spras_iso as sap_lang_code,
       decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as material_desc
from (select t01.matnr,
             t01.spras_iso,
             t01.maktx as sls_text,
             null as mkt_text
      from lads_mat_mkt t01
      union all
      select t01.matnr,
             t01.spras_iso,
             null as sls_txt,
             substr(max(t02.tdline),1,40) as mkt_text
      from lads_mat_txh t01,
           lads_mat_txl t02
      where t01.matnr = t02.matnr(+)
        and t01.txhseq = t02.txhseq(+)
        and trim(substr(t01.tdname,19,6)) = '137 10'
        and t01.tdobject = 'MVKE'
        and t02.txlseq = 1
      group by t01.matnr, t01.spras_iso)
group by matnr,spras_iso;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material_desc to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material_desc for lads.ods_material_desc;

