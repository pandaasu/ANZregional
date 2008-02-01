/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_icb_llt_det
 Owner   : lads
 Author  : Matthew Hardinge

 Description
 -----------
 Local Atlas Data Store - lads_icb_mfj_det

 YYYY/MM   Author            Description
 -------   ------            -----------
 2006/05   Matthew Hardinge  Created

*******************************************************************************/

drop table lads_icb_llt_det;


/**/
/* Table creation
/**/
create table lads_icb_llt_det
   (venum                                        varchar2(10 char)                   not null,
    detseq					 number        			     not null,
    matnr                                        varchar2(18 char)                   null,
    vemng					 number				     null,
    charg					 varchar2(10 char)                   null,
    vfdat					 varchar2(8 char)                    null,
    werks					 varchar2(4 char)                    null,
    lgort					 varchar2(4 char)                    null,
    venum1                                       varchar2(10 char)                   null,
    meins					 varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_icb_llt_det is 'LADS ICB MFJ Intransit Detail';
comment on column lads_icb_llt_det.venum is 'Internal Handling Unit Number';
comment on column lads_icb_llt_det.detseq is 'Details sequence';
comment on column lads_icb_llt_det.matnr is 'Material Number';
comment on column lads_icb_llt_det.vemng is 'Base Quantity Packed in the Handling Unit Item';
comment on column lads_icb_llt_det.charg is 'Batch Number';
comment on column lads_icb_llt_det.vfdat is 'Shelf Life Expiration Date';
comment on column lads_icb_llt_det.werks is 'Plant';
comment on column lads_icb_llt_det.lgort is 'Storage Location';
comment on column lads_icb_llt_det.venum1 is 'Internal Handling Unit Number (replicated)';
comment on column lads_icb_llt_det.meins is 'Base Unit of Measure';

/**/
/* Primary Key Constraint
/**/
alter table lads_icb_llt_det
   add constraint lads_icb_llt_det_pk primary key (venum, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_icb_llt_det to lads_app;
grant select, insert, update, delete on lads_icb_llt_det to ics_app;
grant select on lads_icb_llt_det to site_app;
grant select on lads_icb_llt_det to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_icb_llt_det for lads.lads_icb_llt_det;
