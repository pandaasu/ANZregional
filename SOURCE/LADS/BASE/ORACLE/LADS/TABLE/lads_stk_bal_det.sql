/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_stk_bal_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_stk_bal_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_stk_bal_det
   (bukrs                                        varchar2(3 char)                    not null,
    werks                                        varchar2(4 char)                    not null,
    lgort                                        varchar2(4 char)                    not null,
    budat                                        varchar2(8 char)                    not null,
    timlo                                        varchar2(8 char)                    not null,
    detseq                                       number                              not null,
    matnr                                        varchar2(18 char)                   null,
    charg                                        varchar2(10 char)                   null,
    sobkz                                        varchar2(1 char)                    null,
    menga                                        number                              null,
    altme                                        varchar2(3 char)                    null,
    vfdat                                        varchar2(8 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    umlgo                                        varchar2(4 char)                    null,
    insmk                                        varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_stk_bal_det is 'LADS Stock Balance Detail';
comment on column lads_stk_bal_det.bukrs is 'Company Code';
comment on column lads_stk_bal_det.werks is 'Plant';
comment on column lads_stk_bal_det.lgort is 'Storage Location. Intransit and Consignment does not have a storage location.';
comment on column lads_stk_bal_det.budat is 'Date of stock balance';
comment on column lads_stk_bal_det.timlo is 'Stock balance Time';
comment on column lads_stk_bal_det.detseq is 'DET - generated sequence number';
comment on column lads_stk_bal_det.matnr is 'Material Code';
comment on column lads_stk_bal_det.charg is 'Batch Number of the material in stock';
comment on column lads_stk_bal_det.sobkz is 'Inspection stock indicator';
comment on column lads_stk_bal_det.menga is 'Quantity in stock';
comment on column lads_stk_bal_det.altme is 'Stock-keeping unit of measure';
comment on column lads_stk_bal_det.vfdat is 'Best Before Date';
comment on column lads_stk_bal_det.kunnr is 'Indicates consignment customer or vendor';
comment on column lads_stk_bal_det.umlgo is 'Receiving/Issuing Storage Location';
comment on column lads_stk_bal_det.insmk is 'Stock Type for ESIS';

/**/
/* Primary Key Constraint
/**/
alter table lads_stk_bal_det
   add constraint lads_stk_bal_det_pk primary key (bukrs, werks, lgort, budat, timlo, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_stk_bal_det to lads_app;
grant select, insert, update, delete on lads_stk_bal_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_stk_bal_det for lads.lads_stk_bal_det;
