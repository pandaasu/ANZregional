/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : efex_mesg_det
 Owner   : ods 
 Author  : Steve Gregan 

 Description 
 ----------- 
 Operational Data Store - efex_mesg_det

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/06   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.efex_mesg_det
   (hdr_seqn            number                not null,
    det_seqn            number                not null,
    msg_text            varchar2(256 char)    not null);

/**/
/* Primary Key Constraint 
/**/
alter table ods.efex_mesg_det
   add constraint efex_mesg_det_pk primary key (hdr_seqn, det_seqn);

/**/
/* Column comments 
/**/
comment on table ods.efex_mesg_det is 'Operational Data Store - Efex Message Detail';
comment on column ods.efex_mesg_det.hdr_seqn is 'Header sequence';
comment on column ods.efex_mesg_det.det_seqn is 'Detail sequence';
comment on column ods.efex_mesg_det.msg_text is 'Message text';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.efex_mesg_det to ods_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym efex_mesg_det for ods.efex_mesg_det;