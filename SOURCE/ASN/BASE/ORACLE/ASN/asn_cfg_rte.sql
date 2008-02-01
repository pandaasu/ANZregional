/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_cfg_rte
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_cfg_rte

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_cfg_rte
   (cfr_src_code varchar2(15 char) not null,
    cfr_tar_code varchar2(15 char) not null,
    cfr_msg_proc varchar2(128 char) not null,
    cfr_wrn_type varchar2(1 char) not null,
    cfr_wrn_time number not null,
    cfr_wrn_text varchar2(256 char) null,
    cfr_alt_type varchar2(1 char) not null,
    cfr_alt_time number not null,
    cfr_alt_text varchar2(256 char) null);

/**/
/* Comments
/**/
comment on table asn_cfg_rte is 'ASN Configuration Route';
comment on column asn_cfg_rte.cfr_src_code is 'Source (ship from) code';
comment on column asn_cfg_rte.cfr_tar_code is 'Target (ship to) code';
comment on column asn_cfg_rte.cfr_msg_proc is 'EDI message procedure';
comment on column asn_cfg_rte.cfr_wrn_type is 'Warning type (0=none, 1=email)';
comment on column asn_cfg_rte.cfr_wrn_time is 'Warning wait time (seconds)';
comment on column asn_cfg_rte.cfr_wrn_text is 'Warning text - email group';
comment on column asn_cfg_rte.cfr_alt_type is 'Alert type (0=none, 1=email, 2=alert)';
comment on column asn_cfg_rte.cfr_alt_time is 'Alert wait time (seconds)';
comment on column asn_cfg_rte.cfr_alt_text is 'Alert text - email group or alert string';

/**/
/* Primary Key Constraint
/**/
alter table asn_cfg_rte
   add constraint asn_cfg_rte_pk primary key (cfr_src_code, cfr_tar_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_cfg_rte to ics_app;
grant select on asn_cfg_rte to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym asn_cfg_rte for asn.asn_cfg_rte;
