/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_int_stk_det
 Owner   : lads
 Author  : Megan Henderson

 Description
 -----------
 Local Atlas Data Store - lads_int_stk_det

 YYYY/MM   Author            Description
 -------   ------            -----------
 2004/11   Megan Henderson   Created
 2005/01   Linden Glen       Added exidv2,inhalt,exti1,signi
 2005/03   Linden Glen       Added SELECT grant for ics_reader & site_app

*******************************************************************************/

/**/
/* Table creation
/**/

create table lads_int_stk_det
   (werks                                        varchar2(4 char)                    not null,
    detseq                                       number                              not null,
    burks					 varchar2(4 char)                    null,
    clf01					 number                              null,
    lifex                                        varchar2(35 char)                   null,
    vgbel                                        varchar2(10 char)		     null,
    vend                                         varchar2(10 char)                   null,
    tknum					 varchar2(10 char)                   null,
    vbeln                                        varchar2(10 char)                   null,
    werks1                                       varchar2(4 char)                    null,
    logort1                                      varchar2(4 char)                    null,
    werks2					 varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)		     null,
    werks3					 varchar2(4 char)                    null,
    aedat                                        varchar2(8 char)                    null,
    zardte					 varchar2(8 char)                    null,
    verab                                        varchar2(8 char)                    null,
    charg					 varchar2(10 char)                   null,
    atwrt					 varchar2(8 char)                    null,
    vsbed					 varchar2(2 char)                    null,
    tdlnr					 varchar2(10 char)		     null,
    trail                                        varchar2(10 char)                   null,
    matnr                                        varchar2(18 char)                   null,
    lfimg                                        number		                     null,
    meins                                        varchar2(3 char)                    null,
    insmk                                        varchar2(1 char)                    null,
    bsart                                        varchar2(4 char)                    null,
    exidv2                                       varchar2(20 char)                   null,
    inhalt                                       varchar2(40 char)                   null,
    exti1                                        varchar2(20 char)                   null,
    signi                                        varchar2(20 char)                   null,
    record_nb                                    varchar2(15 char)		     null,
    record_cnt                                   varchar2(15 char)                   null,
    time                                         varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_int_stk_det is 'LADS Intransit Stock Detail';
comment on column lads_int_stk_det.werks is 'Plant'; 
comment on column lads_int_stk_det.detseq is 'DET - generated sequence number';
comment on column lads_int_stk_det.burks is 'Company Code';
comment on column lads_int_stk_det.clf01 is 'Business Segment';
comment on column lads_int_stk_det.lifex is 'CNN Number';
comment on column lads_int_stk_det.vgbel is 'Purchase Order Number';
comment on column lads_int_stk_det.vend is 'Vendor Number';
comment on column lads_int_stk_det.tknum is 'Shipment Number';
comment on column lads_int_stk_det.vbeln is 'Inbound Delivery Number';
comment on column lads_int_stk_det.werks1 is 'Source Plant';
comment on column lads_int_stk_det.logort1 is 'Source Storage Location';
comment on column lads_int_stk_det.werks2 is 'Shipping Point';
comment on column lads_int_stk_det.lgort is 'Destination Storage Location';
comment on column lads_int_stk_det.werks3 is 'Target MRP Area';
comment on column lads_int_stk_det.aedat is 'Shipping (GI) Date';
comment on column lads_int_stk_det.zardte is 'Arrival Date';
comment on column lads_int_stk_det.verab is 'Maturation Date';
comment on column lads_int_stk_det.charg is 'Batch Number';
comment on column lads_int_stk_det.atwrt is 'Best Before Date';
comment on column lads_int_stk_det.vsbed is 'Transportation Model';
comment on column lads_int_stk_det.tdlnr is 'Number of forwarding agent (Carrier)';
comment on column lads_int_stk_det.trail is 'Forwarding agent (Trailer) Number';
comment on column lads_int_stk_det.matnr is 'Material Number';
comment on column lads_int_stk_det.lfimg is 'Actual quantity delivered (in sales units)';
comment on column lads_int_stk_det.meins is 'UoM';
comment on column lads_int_stk_det.insmk is 'Stock Type';
comment on column lads_int_stk_det.bsart is 'Order Type (Purchasing)';
comment on column lads_int_stk_det.exidv2 is 'Container Number';
comment on column lads_int_stk_det.inhalt is 'Seal Number';
comment on column lads_int_stk_det.exti1 is 'Vessel Name';
comment on column lads_int_stk_det.signi is 'Voyage';
comment on column lads_int_stk_det.record_nb is 'Record Sequence number';
comment on column lads_int_stk_det.record_cnt is 'Total Record number';
comment on column lads_int_stk_det.time is 'Time Stamp';

/**/
/* Primary Key Constraint
/**/
alter table lads_int_stk_det
   add constraint lads_int_stk_det_pk primary key (werks,detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_int_stk_det to lads_app;
grant select, insert, update, delete on lads_int_stk_det to ics_app;
grant select on lads_int_stk_det to site_app;
grant select on lads_int_stk_det to ics_reader;

/**/
/* Synonym
/**/
create public synonym lads_int_stk_det for lads.lads_int_stk_det;
