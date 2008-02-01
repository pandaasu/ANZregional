/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_pdp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_pdp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_pdp
   (kunnr                                        varchar2(10 char)                   not null,
    pdpseq                                       number                              not null,
    locnr                                        varchar2(10 char)                   null,
    abtnr                                        varchar2(4 char)                    null,
    empst                                        varchar2(25 char)                   null,
    verfl                                        number                              null,
    verfe                                        varchar2(3 char)                    null,
    layvr                                        varchar2(10 char)                   null,
    flvar                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_pdp is 'LADS Customer Plant Department';
comment on column lads_cus_pdp.kunnr is 'Customer Number';
comment on column lads_cus_pdp.pdpseq is 'PDP - generated sequence number';
comment on column lads_cus_pdp.locnr is 'Customer number for plant';
comment on column lads_cus_pdp.abtnr is 'Department number';
comment on column lads_cus_pdp.empst is 'Receiving point';
comment on column lads_cus_pdp.verfl is 'Sales area (floor space)';
comment on column lads_cus_pdp.verfe is 'Sales area (floor space) unit';
comment on column lads_cus_pdp.layvr is 'Layout';
comment on column lads_cus_pdp.flvar is 'Area schema';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_pdp
   add constraint lads_cus_pdp_pk primary key (kunnr, pdpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_pdp to lads_app;
grant select, insert, update, delete on lads_cus_pdp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_pdp for lads.lads_cus_pdp;
