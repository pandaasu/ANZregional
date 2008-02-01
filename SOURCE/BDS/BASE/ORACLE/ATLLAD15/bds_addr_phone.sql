/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_phone
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Telephone

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_phone
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_sequence                   number                   not null,
    country                            varchar2(3 char)         null,
    country_iso                        varchar2(2 char)         null,
    standard_sender_flag               varchar2(1 char)         null,
    phone_number                       varchar2(30 char)        null,
    phone_extension                    varchar2(10 char)        null,
    phone_full_number                  varchar2(30 char)        null,
    caller_number                      varchar2(30 char)        null,
    standard_receiver_flag             varchar2(1 char)         null,
    sap_r3_user                        varchar2(1 char)         null,
    home_flag                          varchar2(1 char)         null,
    sequence_number                    number                   null,
    error_flag                         varchar2(1 char)         null,
    not_used_flag                      varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_phone is 'Business Data Store - Address Telephone';
comment on column bds_addr_phone.address_type is 'Address owner object type - lads_adr_tel.obj_type';
comment on column bds_addr_phone.address_code is 'Address owner object ID - lads_adr_tel.obj_id';
comment on column bds_addr_phone.address_context is 'Semantic description of an object address - lads_adr_tel.context';
comment on column bds_addr_phone.address_sequence is 'TEL - generated sequence number - lads_adr_tel.telseq';
comment on column bds_addr_phone.country is 'Country for telephone/fax number - lads_adr_tel.country';
comment on column bds_addr_phone.country_iso is 'Country ISO code - lads_adr_tel.countryiso';
comment on column bds_addr_phone.standard_sender_flag is 'Standard Sender Address in this Communication Type - lads_adr_tel.std_no';
comment on column bds_addr_phone.phone_number is 'Telephone no.: dialling code+number - lads_adr_tel.telephone';
comment on column bds_addr_phone.phone_extension is 'Telephone no.: Extension - lads_adr_tel.extension';
comment on column bds_addr_phone.phone_full_number is 'Complete number: dialling code+number+extension - lads_adr_tel.tel_no';
comment on column bds_addr_phone.caller_number is 'Telephone number for determining caller - lads_adr_tel.caller_no';
comment on column bds_addr_phone.standard_receiver_flag is 'Flag: Recipient is standard recipient for this number - lads_adr_tel.std_recip';
comment on column bds_addr_phone.sap_r3_user is 'Flag: connected to R/3 - lads_adr_tel.r_3_user';
comment on column bds_addr_phone.home_flag is 'Recipient address in this communication type (mail sys.grp) - lads_adr_tel.home_flag';
comment on column bds_addr_phone.sequence_number is 'Sequence number - lads_adr_tel.consnumber';
comment on column bds_addr_phone.error_flag is 'Flag: Record not processed - lads_adr_tel.errorflag';
comment on column bds_addr_phone.not_used_flag is 'Flag: This Communication Number is Not Used - lads_adr_tel.flg_nouse';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_phone
   add constraint bds_addr_phone_pk primary key (address_type, address_code, address_context, address_sequence);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_phone to lics_app;
grant select, insert, update, delete on bds_addr_phone to lads_app;
grant select, insert, update, delete on bds_addr_phone to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_phone for bds.bds_addr_phone;