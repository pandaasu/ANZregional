/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : reg_dbp
 Owner  : dd

 Description
 -----------
 Data Warehouse - Regional DBP Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.reg_dbp
   (bus_sgmnt                varchar2(30 char)                not null,
    brand_flag               varchar2(30 char)                not null,
    ptd                      number(16)                       not null,
    br_casting_yyyypp        number(16)                       not null,
    op_casting_yyyy          number(16)                       not null,
    br_p01                   number(16)                       not null,
    br_p02                   number(16)                       not null,
    br_p03                   number(16)                       not null,
    br_p04                   number(16)                       not null,
    br_p05                   number(16)                       not null,
    br_p06                   number(16)                       not null,
    br_p07                   number(18)                       not null,
    br_p08                   number(18)                       not null,
    br_p09                   number(16)                       not null,
    br_p10                   number(16)                       not null,
    br_p11                   number(16)                       not null,
    br_p12                   number(16)                       not null,
    br_p13                   number(16)                       not null,
    op_p01                   number(16)                       not null,
    op_p02                   number(16)                       not null,
    op_p03                   number(16)                       not null,
    op_p04                   number(16)                       not null,
    op_p05                   number(16)                       not null,
    op_p06                   number(16)                       not null,
    op_p07                   number(18)                       not null,
    op_p08                   number(18)                       not null,
    op_p09                   number(16)                       not null,
    op_p10                   number(16)                       not null,
    op_p11                   number(16)                       not null,
    op_p12                   number(16)                       not null,
    op_p13                   number(16)                       not null,
    reg_dbp_lupdp            varchar2(8)                      not null,
    reg_dbp_lupdt            date                             not null,
    br_batch_code            varchar2(15)                     not null,
    op_batch_code            varchar2(15)                     not null);

/**/
/* Comments
/**/
comment on table dd.reg_dbp is 'Regional DBP Table';
comment on column dd.reg_dbp.bus_sgmnt is 'Business segment';
comment on column dd.reg_dbp.brand_flag is 'Brand';
comment on column dd.reg_dbp.ptd is 'Period to date';
comment on column dd.reg_dbp.br_casting_yyyypp is 'BR casting period';
comment on column dd.reg_dbp.op_casting_yyyy is 'OP casting period';
comment on column dd.reg_dbp.br_p01 is 'BR for this period number';
comment on column dd.reg_dbp.br_p02 is 'BR for this period number';
comment on column dd.reg_dbp.br_p03 is 'BR for this period number';
comment on column dd.reg_dbp.br_p04 is 'BR for this period number';
comment on column dd.reg_dbp.br_p05 is 'BR for this period number';
comment on column dd.reg_dbp.br_p06 is 'BR for this period number';
comment on column dd.reg_dbp.br_p07 is 'BR for this period number';
comment on column dd.reg_dbp.br_p08 is 'BR for this period number';
comment on column dd.reg_dbp.br_p09 is 'BR for this period number';
comment on column dd.reg_dbp.br_p10 is 'BR for this period number';
comment on column dd.reg_dbp.br_p11 is 'BR for this period number';
comment on column dd.reg_dbp.br_p12 is 'BR for this period number';
comment on column dd.reg_dbp.br_p13 is 'BR for this period number';
comment on column dd.reg_dbp.op_p01 is 'OP for this period number';
comment on column dd.reg_dbp.op_p02 is 'OP for this period number';
comment on column dd.reg_dbp.op_p03 is 'OP for this period number';
comment on column dd.reg_dbp.op_p04 is 'OP for this period number';
comment on column dd.reg_dbp.op_p05 is 'OP for this period number';
comment on column dd.reg_dbp.op_p06 is 'OP for this period number';
comment on column dd.reg_dbp.op_p07 is 'OP for this period number';
comment on column dd.reg_dbp.op_p08 is 'OP for this period number';
comment on column dd.reg_dbp.op_p09 is 'OP for this period number';
comment on column dd.reg_dbp.op_p10 is 'OP for this period number';
comment on column dd.reg_dbp.op_p11 is 'OP for this period number';
comment on column dd.reg_dbp.op_p12 is 'OP for this period number';
comment on column dd.reg_dbp.op_p13 is 'OP for this period number';
comment on column dd.reg_dbp.reg_dbp_lupdp is 'last updated person';
comment on column dd.reg_dbp.reg_dbp_lupdt is 'last updated time';
comment on column dd.reg_dbp.br_batch_code is 'BR batch code';
comment on column dd.reg_dbp.op_batch_code is 'OP batch code';

/**/
/* Primary Key Constraint
/**/
alter table dd.reg_dbp
   add constraint reg_dbp_pk primary key (bus_sgmnt, brand_flag);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.reg_dbp to dw_app;

/**/
/* Synonym
/**/
create or replace public synonym reg_dbp for dd.reg_dbp;