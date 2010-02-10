/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_stk_detail
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Stocktake Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_stk_detail
   (std_stk_code                    varchar2(32)                  not null,
    std_mat_code                    varchar2(32)                  not null,
    std_mat_qnty                    number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_stk_detail is 'Stocktake Detail Table';
comment on column psa.psa_stk_detail.std_stk_code is 'Stocktake code - STOCKTAKE_YYYYMMDDHHMISS';
comment on column psa.psa_stk_detail.std_mat_code is 'Material code';
comment on column psa.psa_stk_detail.std_mat_qnty is 'Material quantity';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_stk_detail
   add constraint psa_stk_detail_pk primary key (std_stk_code, std_mat_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_stk_detail to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_stk_detail for psa.psa_stk_detail;