/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_stk_bal_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_stk_bal_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_stk_bal_hdr
   (bukrs                                        varchar2(3 char)                    not null,
    werks                                        varchar2(4 char)                    not null,
    lgort                                        varchar2(4 char)                    not null,
    budat                                        varchar2(8 char)                    not null,
    credat                                       varchar2(8 char)                    null,
    cretim                                       varchar2(6 char)                    null,
    vbund                                        varchar2(6 char)                    null,
    timlo                                        varchar2(8 char)                    not null,
    mblnr                                        varchar2(10 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_stk_bal_hdr is 'LADS Stock Balance Header';
comment on column lads_stk_bal_hdr.bukrs is 'Company Code';
comment on column lads_stk_bal_hdr.werks is 'Plant';
comment on column lads_stk_bal_hdr.lgort is 'Storage Location. Intransit and Consignment does not have a storage location.';
comment on column lads_stk_bal_hdr.budat is 'Date of stock balance';
comment on column lads_stk_bal_hdr.credat is 'Idoc Creation Date';
comment on column lads_stk_bal_hdr.cretim is 'Idoc Creation Time';
comment on column lads_stk_bal_hdr.vbund is 'Company ID';
comment on column lads_stk_bal_hdr.timlo is 'Stock balance Time';
comment on column lads_stk_bal_hdr.mblnr is 'Physical Inventory Document';
comment on column lads_stk_bal_hdr.idoc_name is 'IDOC name';
comment on column lads_stk_bal_hdr.idoc_number is 'IDOC number';
comment on column lads_stk_bal_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_stk_bal_hdr.lads_date is 'LADS date loaded';
comment on column lads_stk_bal_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_stk_bal_hdr
   add constraint lads_stk_bal_hdr_pk primary key (bukrs, werks, lgort, budat, timlo);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_stk_bal_hdr to lads_app;
grant select, insert, update, delete on lads_stk_bal_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_stk_bal_hdr for lads.lads_stk_bal_hdr;
