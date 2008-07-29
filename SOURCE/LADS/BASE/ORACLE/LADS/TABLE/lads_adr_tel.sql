/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_tel
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_tel

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_tel
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    telseq                                       number                              not null,
    country                                      varchar2(3 char)                    null,
    countryiso                                   varchar2(2 char)                    null,
    std_no                                       varchar2(1 char)                    null,
    telephone                                    varchar2(30 char)                   null,
    extension                                    varchar2(10 char)                   null,
    tel_no                                       varchar2(30 char)                   null,
    caller_no                                    varchar2(30 char)                   null,
    std_recip                                    varchar2(1 char)                    null,
    r_3_user                                     varchar2(1 char)                    null,
    home_flag                                    varchar2(1 char)                    null,
    consnumber                                   number                              null,
    errorflag                                    varchar2(1 char)                    null,
    flg_nouse                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_tel is 'LADS Address Telephone';
comment on column lads_adr_tel.obj_type is 'Address owner object type';
comment on column lads_adr_tel.obj_id is 'Address owner object ID';
comment on column lads_adr_tel.context is 'Semantic description of an object address';
comment on column lads_adr_tel.telseq is 'TEL - generated sequence number';
comment on column lads_adr_tel.country is 'Country for telephone/fax number';
comment on column lads_adr_tel.countryiso is 'Country ISO code';
comment on column lads_adr_tel.std_no is 'Standard Sender Address in this Communication Type';
comment on column lads_adr_tel.telephone is 'Telephone no.: dialling code+number';
comment on column lads_adr_tel.extension is 'Telephone no.: Extension';
comment on column lads_adr_tel.tel_no is 'Complete number: dialling code+number+extension';
comment on column lads_adr_tel.caller_no is 'Telephone number for determining caller';
comment on column lads_adr_tel.std_recip is 'Flag: Recipient is standard recipient for this number';
comment on column lads_adr_tel.r_3_user is 'Flag: connected to R/3';
comment on column lads_adr_tel.home_flag is 'Recipient address in this communication type (mail sys.grp)';
comment on column lads_adr_tel.consnumber is 'Sequence number';
comment on column lads_adr_tel.errorflag is 'Flag: Record not processed';
comment on column lads_adr_tel.flg_nouse is 'Flag: This Communication Number is Not Used';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_tel
   add constraint lads_adr_tel_pk primary key (obj_type, obj_id, context, telseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_tel to lads_app;
grant select, insert, update, delete on lads_adr_tel to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_tel for lads.lads_adr_tel;
