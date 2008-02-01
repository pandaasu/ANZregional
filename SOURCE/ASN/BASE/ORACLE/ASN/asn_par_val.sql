/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_par_val
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_par_val

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_par_val
   (apv_group varchar2(32 char) not null,
    apv_code varchar2(32 char) not null,
    apv_value varchar(256 char) not null,
    apv_updt_tim date not null);

/**/
/* Comments
/**/
comment on table asn_par_val is 'ASN Parameter Value Table';
comment on column asn_par_val.apv_group is 'Parameter - group';
comment on column asn_par_val.apv_code is 'Parameter - code';
comment on column asn_par_val.apv_value is 'Parameter - value';
comment on column asn_par_val.apv_updt_tim is 'Parameter - update time';

/**/
/* Primary Key Constraint
/**/
alter table asn_par_val
   add constraint asn_par_val_pk primary key (apv_group, apv_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_par_val to ics_app;
grant select on asn_par_val to lics_app;

/**/
/* Synonym
/**/
create public synonym asn_par_val for asn.asn_par_val;
