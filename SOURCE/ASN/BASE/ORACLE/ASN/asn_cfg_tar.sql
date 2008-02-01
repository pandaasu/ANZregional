/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_cfg_tar
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_cfg_tar

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_cfg_tar
   (cft_tar_code varchar2(15 char) not null,
    cft_tar_text varchar2(128 char) not null,
    cft_wrn_type varchar2(1 char) not null,
    cft_wrn_time number not null,
    cft_wrn_text varchar2(256 char) null);

/**/
/* Comments
/**/
comment on table asn_cfg_tar is 'ASN Configuration Target';
comment on column asn_cfg_tar.cft_tar_code is 'Target (ship to) code';
comment on column asn_cfg_tar.cft_tar_text is 'Target (ship to) description';
comment on column asn_cfg_tar.cft_wrn_type is 'Acknowledgement - Warning type (0=none, 1=email, 2=alert)';
comment on column asn_cfg_tar.cft_wrn_time is 'Acknowledgement - Warning wait time (seconds)';
comment on column asn_cfg_tar.cft_wrn_text is 'Acknowledgement - Warning text - email group or alert string';

/**/
/* Primary Key Constraint
/**/
alter table asn_cfg_tar
   add constraint asn_cfg_tar_pk primary key (cft_tar_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_cfg_tar to ics_app;
grant select on asn_cfg_tar to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym asn_cfg_tar for asn.asn_cfg_tar;
