/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_int_stk_hdr
 Owner   : lads
 Author  : Megan Henderson

 Description
 -----------
 Local Atlas Data Store - lads_int_stk_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Megan Henderson   Created
 2005/03   Linden Glen       Added SELECT grant for ics_reader & site_app
 2007/03   Steve Gregan   Added LADS_FLATTENED

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_int_stk_hdr
   (werks                                        varchar2(4 char)                    not null,
    berid					 varchar2(10 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null,
    lads_flattened                               varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_int_stk_hdr is 'LADS Intransit Stock Header';
comment on column lads_int_stk_hdr.werks is 'Plant';
comment on column lads_int_stk_hdr.berid is 'Target Planning Area';
comment on column lads_int_stk_hdr.idoc_name is 'IDOC name';
comment on column lads_int_stk_hdr.idoc_number is 'IDOC number';
comment on column lads_int_stk_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_int_stk_hdr.lads_date is 'LADS date loaded';
comment on column lads_int_stk_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';
comment on column lads_int_stk_hdr.lads_flattened is 'LADS Flattened Status - 0 Unflattened, 1 Flattened to BDS, 2 Excluded/Skipped';

/**/
/* Primary Key Constraint
/**/
alter table lads_int_stk_hdr
   add constraint lads_int_stk_hdr_pk primary key (werks);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_int_stk_hdr to lads_app;
grant select, insert, update, delete on lads_int_stk_hdr to ics_app;
grant select on lads_int_stk_hdr to site_app;
grant select on lads_int_stk_hdr to ics_reader;
grant select, update on lads_int_stk_hdr to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_int_stk_hdr for lads.lads_int_stk_hdr;
