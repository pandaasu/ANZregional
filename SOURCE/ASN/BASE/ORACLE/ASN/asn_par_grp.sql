/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_par_grp
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_par_grp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_par_grp
   (apg_group varchar2(32 char) not null,
    apg_desc varchar2(128 char) not null);

/**/
/* Comments
/**/
comment on table asn_par_grp is 'ASN Parameter Group Table';
comment on column asn_par_grp.apg_group is 'Parameter - group';
comment on column asn_par_grp.apg_desc is 'Parameter - description';

/**/
/* Primary Key Constraint
/**/
alter table asn_par_grp
   add constraint asn_par_grp_pk primary key (apg_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_par_grp to ics_app;
grant select on asn_par_grp to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym asn_par_grp for asn.asn_par_grp;
