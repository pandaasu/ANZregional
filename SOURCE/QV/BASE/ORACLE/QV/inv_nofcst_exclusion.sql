/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : inv_nofcst_exclusion
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - inv_nofcst_exclusion 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table inv_nofcst_exclusion
(
  ine_version         number not null,
  ine_tdu_code        varchar2(20) not null,
  ine_zrep_code       varchar2(20) null
);

/**/
/* Comments 
/**/
comment on table inv_nofcst_exclusion is 'INV - No Forecast Exclusion List';
comment on column inv_nofcst_exclusion.ine_version is 'INV - No Forecast Exclusion - load version';
comment on column inv_nofcst_exclusion.ine_tdu_code is 'INV - No Forecast Exclusion - material TDU code';
comment on column inv_nofcst_exclusion.ine_zrep_code is 'INV - No Forecast Exclusion - material ZREP code';

/**/
/* Authority 
/**/
grant select, insert, update, delete on inv_nofcst_exclusion to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym inv_nofcst_exclusion for qv.inv_nofcst_exclusion;

/**/
/* Sequence 
/**/
create sequence inv_nofcst_exclusion_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on inv_nofcst_exclusion_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym inv_nofcst_exclusion_seq for qv.inv_nofcst_exclusion_seq;