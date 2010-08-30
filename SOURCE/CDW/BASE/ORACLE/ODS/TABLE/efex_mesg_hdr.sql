/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : efex_mesg_hdr
 Owner   : ods 
 Author  : Steve Gregan 

 Description 
 ----------- 
 Operational Data Store - efex_mesg_hdr

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/06   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.efex_mesg_hdr
   (hdr_seqn            number                not null,
    valdtn_type_code    number                not null,
    efex_mkt_id         number                not null,
    efex_bus_id         number                not null,
    key_text            varchar2(256)         not null);

/**/
/* Primary Key Constraint 
/**/
alter table ods.efex_mesg_hdr
   add constraint efex_mesg_hdr_pk primary key (hdr_seqn);

/**/
/* Column comments 
/**/
comment on table ods.efex_mesg_hdr is 'Operational Data Store - Efex Message Header';
comment on column ods.efex_mesg_hdr.hdr_seqn is 'Header sequence';
comment on column ods.efex_mesg_hdr.valdtn_type_code is 'Validation type code';
comment on column ods.efex_mesg_hdr.efex_mkt_id is 'Efex market';
comment on column ods.efex_mesg_hdr.efex_bus_id is 'Efex business unit';
comment on column ods.efex_mesg_hdr.key_text is 'Validation key text';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.efex_mesg_hdr to ods_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym efex_mesg_hdr for ods.efex_mesg_hdr;
