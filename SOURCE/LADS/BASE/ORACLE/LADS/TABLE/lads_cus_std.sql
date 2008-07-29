/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_std
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_std

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_std
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    satseq                                       number                              not null,
    stdseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_cus_std is 'LADS Customer Sales Area Text Line';
comment on column lads_cus_std.kunnr is 'Customer Number';
comment on column lads_cus_std.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_std.satseq is 'SAT - generated sequence number';
comment on column lads_cus_std.stdseq is 'STD - generated sequence number';
comment on column lads_cus_std.tdformat is 'Tag column';
comment on column lads_cus_std.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_std
   add constraint lads_cus_std_pk primary key (kunnr, sadseq, satseq, stdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_std to lads_app;
grant select, insert, update, delete on lads_cus_std to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_std for lads.lads_cus_std;
