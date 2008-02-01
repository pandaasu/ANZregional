/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_cfg_src
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_cfg_src

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_cfg_src
   (cfs_src_code varchar2(15 char) not null,
    cfs_src_text varchar2(128 char) not null,
    cfs_src_iden varchar2(15 char) not null,
    cfs_msg_proc varchar2(128 char) not null,
    cfs_wrn_type varchar2(1 char) not null,
    cfs_wrn_time number not null,
    cfs_wrn_text varchar2(256 char) null,
    cfs_alt_type varchar2(1 char) not null,
    cfs_alt_time number not null,
    cfs_alt_text varchar2(256 char) null);

/**/
/* Comments
/**/
comment on table asn_cfg_src is 'ASN Configuration Source';
comment on column asn_cfg_src.cfs_src_code is 'Source (ship from) code';
comment on column asn_cfg_src.cfs_src_text is 'Source (ship from) description';
comment on column asn_cfg_src.cfs_src_iden is 'Source (ship from) interchange id';
comment on column asn_cfg_src.cfs_msg_proc is 'Default - EDI message procedure';
comment on column asn_cfg_src.cfs_wrn_type is 'Default - Warning type (0=none, 1=email)';
comment on column asn_cfg_src.cfs_wrn_time is 'Default - Warning wait time (seconds)';
comment on column asn_cfg_src.cfs_wrn_text is 'Default - Warning text - email group';
comment on column asn_cfg_src.cfs_alt_type is 'Default - Alert type (0=none, 1=email, 2=alert)';
comment on column asn_cfg_src.cfs_alt_time is 'Default - Alert wait time (seconds)';
comment on column asn_cfg_src.cfs_alt_text is 'Default - Alert text - email group or alert string';

/**/
/* Primary Key Constraint
/**/
alter table asn_cfg_src
   add constraint asn_cfg_src_pk primary key (cfs_src_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_cfg_src to ics_app;
grant select on asn_cfg_src to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym asn_cfg_src for asn.asn_cfg_src;
