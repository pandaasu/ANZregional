/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_fax
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Fax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_fax
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_sequence                   number                   not null,
    country                            varchar2(3 char)         null,
    country_iso                        varchar2(2 char)         null,
    standard_sender_flag               varchar2(1 char)         null,
    fax_number                         varchar2(30 char)        null,
    fax_extension                      varchar2(10 char)        null,
    fax_full_number                    varchar2(30 char)        null,
    sender_number                      varchar2(30 char)        null,
    fax_group                          varchar2(1 char)         null,
    standard_receiver_flag             varchar2(1 char)         null,
    sap_r3_user                        varchar2(1 char)         null,
    home_flag                          varchar2(1 char)         null,
    sequence_number                    number                   null,
    error_flag                         varchar2(1 char)         null,
    not_used_flag                      varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_fax is 'Business Data Store - Address Fax';
comment on column bds_addr_fax.address_type is 'Address owner object type - lads_adr_fax.obj_type';
comment on column bds_addr_fax.address_code is 'Address owner object ID - lads_adr_fax.obj_id';
comment on column bds_addr_fax.address_context is 'Semantic description of an object address - lads_adr_fax.context';
comment on column bds_addr_fax.address_sequence is 'FAX - generated sequence number - lads_adr_fax.faxseq';
comment on column bds_addr_fax.country is 'Country for telephone/fax number - lads_adr_fax.country';
comment on column bds_addr_fax.country_iso is 'Country ISO code - lads_adr_fax.countryiso';
comment on column bds_addr_fax.standard_sender_flag is 'Standard Sender Address in this Communication Type - lads_adr_fax.std_no';
comment on column bds_addr_fax.fax_number is 'Fax number: dialling code+number - lads_adr_fax.fax';
comment on column bds_addr_fax.fax_extension is 'Fax no.: Extension - lads_adr_fax.extension';
comment on column bds_addr_fax.fax_full_number is 'Complete number: dialling code+number+extension - lads_adr_fax.fax_no';
comment on column bds_addr_fax.sender_number is 'Fax number for finding sender - lads_adr_fax.sender_no';
comment on column bds_addr_fax.fax_group is '''Fax group (G3, G4, ...)'' - lads_adr_fax.fax_group';
comment on column bds_addr_fax.standard_receiver_flag is 'Flag: Recipient is standard recipient for this number - lads_adr_fax.std_recip';
comment on column bds_addr_fax.sap_r3_user is 'Flag: connected to R/3 - lads_adr_fax.r_3_user';
comment on column bds_addr_fax.home_flag is 'Recipient address in this communication type (mail sys.grp) - lads_adr_fax.home_flag';
comment on column bds_addr_fax.sequence_number is 'Sequence number - lads_adr_fax.consnumber';
comment on column bds_addr_fax.error_flag is 'Flag: Record not processed - lads_adr_fax.errorflag';
comment on column bds_addr_fax.not_used_flag is 'Flag: This Communication Number is Not Used - lads_adr_fax.flg_nouse';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_fax
   add constraint bds_addr_fax_pk primary key (address_type, address_code, address_context, address_sequence);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_fax to lics_app;
grant select, insert, update, delete on bds_addr_fax to lads_app;
grant select, insert, update, delete on bds_addr_fax to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_fax for bds.bds_addr_fax;