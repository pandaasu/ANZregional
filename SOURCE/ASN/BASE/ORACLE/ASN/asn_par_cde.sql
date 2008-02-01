/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_par_cde
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_par_cde

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_par_cde
   (apc_group varchar2(32 char) not null,
    apc_code varchar2(32 char) not null,
    apc_type varchar2(4 char) not null);

/**/
/* Comments
/**/
comment on table asn_par_cde is 'ASN Parameter Code Table';
comment on column asn_par_cde.apc_group is 'Parameter - group';
comment on column asn_par_cde.apc_code is 'Parameter - code';
comment on column asn_par_cde.apc_type is 'Parameter - type (*CHR, *NUM)';

/**/
/* Primary Key Constraint
/**/
alter table asn_par_cde
   add constraint asn_par_cde_pk primary key (apc_group, apc_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_par_cde to ics_app;
grant select on asn_par_cde to lics_app;

/**/
/* Synonym
/**/
create public synonym asn_par_cde for asn.asn_par_cde;
