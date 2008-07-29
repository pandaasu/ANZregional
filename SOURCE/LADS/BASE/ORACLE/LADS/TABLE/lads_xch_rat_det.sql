/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_xch_rat_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_xch_rat_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_xch_rat_det
   (rate_type                                    varchar2(4 char)                    not null,
    from_curr                                    varchar2(5 char)                    not null,
    to_currncy                                   varchar2(5 char)                    not null,
    valid_from                                   varchar2(8 char)                    not null,
    exch_rate                                    number                              null,
    from_factor                                  number                              null,
    to_factor                                    number                              null,
    exch_rate_v                                  number                              null,
    from_factor_v                                number                              null,
    to_factor_v                                  number                              null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_xch_rat_det is 'LADS Exchange Rate Detail';
comment on column lads_xch_rat_det.rate_type is 'Exchange Rate Type';
comment on column lads_xch_rat_det.from_curr is 'From Currency';
comment on column lads_xch_rat_det.to_currncy is 'To Currency';
comment on column lads_xch_rat_det.valid_from is 'Date From Which Entry Is Valid';
comment on column lads_xch_rat_det.exch_rate is 'Direct Quoted Exchange Rate';
comment on column lads_xch_rat_det.from_factor is 'Ratio for the from currency units';
comment on column lads_xch_rat_det.to_factor is 'Ratio for the to currency units';
comment on column lads_xch_rat_det.exch_rate_v is 'Indirect Quoted Exchange Rate';
comment on column lads_xch_rat_det.from_factor_v is 'Ratio for the from currency units';
comment on column lads_xch_rat_det.to_factor_v is 'Ratio for the to currency units';
comment on column lads_xch_rat_det.idoc_name is 'IDOC name';
comment on column lads_xch_rat_det.idoc_number is 'IDOC number';
comment on column lads_xch_rat_det.idoc_timestamp is 'IDOC timestamp';
comment on column lads_xch_rat_det.lads_date is 'LADS date loaded';
comment on column lads_xch_rat_det.lads_status is 'LADS status (1=valid, 2=error)';

/**/
/* Primary Key Constraint
/**/
alter table lads_xch_rat_det
   add constraint lads_xch_rat_det_pk primary key (rate_type, from_curr, to_currncy, valid_from);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_xch_rat_det to lads_app;
grant select, insert, update, delete on lads_xch_rat_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_xch_rat_det for lads.lads_xch_rat_det;
