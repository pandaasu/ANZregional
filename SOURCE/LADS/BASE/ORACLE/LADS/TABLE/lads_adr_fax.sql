/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_fax
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_fax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_fax
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    faxseq                                       number                              not null,
    country                                      varchar2(3 char)                    null,
    countryiso                                   varchar2(2 char)                    null,
    std_no                                       varchar2(1 char)                    null,
    fax                                          varchar2(30 char)                   null,
    extension                                    varchar2(10 char)                   null,
    fax_no                                       varchar2(30 char)                   null,
    sender_no                                    varchar2(30 char)                   null,
    fax_group                                    varchar2(1 char)                    null,
    std_recip                                    varchar2(1 char)                    null,
    r_3_user                                     varchar2(1 char)                    null,
    home_flag                                    varchar2(1 char)                    null,
    consnumber                                   number                              null,
    errorflag                                    varchar2(1 char)                    null,
    flg_nouse                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_fax is 'LADS Address Fax';
comment on column lads_adr_fax.obj_type is 'Address owner object type';
comment on column lads_adr_fax.obj_id is 'Address owner object ID';
comment on column lads_adr_fax.context is 'Semantic description of an object address';
comment on column lads_adr_fax.faxseq is 'FAX - generated sequence number';
comment on column lads_adr_fax.country is 'Country for telephone/fax number';
comment on column lads_adr_fax.countryiso is 'Country ISO code';
comment on column lads_adr_fax.std_no is 'Standard Sender Address in this Communication Type';
comment on column lads_adr_fax.fax is 'Fax number: dialling code+number';
comment on column lads_adr_fax.extension is 'Fax no.: Extension';
comment on column lads_adr_fax.fax_no is 'Complete number: dialling code+number+extension';
comment on column lads_adr_fax.sender_no is 'Fax number for finding sender';
comment on column lads_adr_fax.fax_group is '"Fax group (G3, G4, ...)"';
comment on column lads_adr_fax.std_recip is 'Flag: Recipient is standard recipient for this number';
comment on column lads_adr_fax.r_3_user is 'Flag: connected to R/3';
comment on column lads_adr_fax.home_flag is 'Recipient address in this communication type (mail sys.grp)';
comment on column lads_adr_fax.consnumber is 'Sequence number';
comment on column lads_adr_fax.errorflag is 'Flag: Record not processed';
comment on column lads_adr_fax.flg_nouse is 'Flag: This Communication Number is Not Used';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_fax
   add constraint lads_adr_fax_pk primary key (obj_type, obj_id, context, faxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_fax to lads_app;
grant select, insert, update, delete on lads_adr_fax to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_fax for lads.lads_adr_fax;
