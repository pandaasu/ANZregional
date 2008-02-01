/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_email
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Email

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_email
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_sequence                   number                   not null,
    standard_sender_flag               varchar2(1 char)         null,
    email_address                      varchar2(241)            null,
    email_search                       varchar2(20 char)        null,
    standard_receiver_flag             varchar2(1 char)         null,
    sap_r3_user                        varchar2(1 char)         null,
    smtp_encoding                      varchar2(1 char)         null,
    tnef_coding_flag                   varchar2(1 char)         null,
    home_flag                          varchar2(1 char)         null,
    sequence_number                    number                   null,
    error_flag                         varchar2(1 char)         null,
    not_used_flag                      varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_email is 'Business Data Store - Address Email';
comment on column bds_addr_email.address_type is 'Address owner object type - lads_adr_ema.obj_type';
comment on column bds_addr_email.address_code is 'Address owner object ID - lads_adr_ema.obj_id';
comment on column bds_addr_email.address_context is 'Semantic description of an object address - lads_adr_ema.context';
comment on column bds_addr_email.address_sequence is 'EMA - generated sequence number - lads_adr_ema.emaseq';
comment on column bds_addr_email.standard_sender_flag is 'Standard Sender Address in this Communication Type - lads_adr_ema.std_no';
comment on column bds_addr_email.email_address is 'E-Mail Address - lads_adr_ema.e_mail';
comment on column bds_addr_email.email_search is 'E-Mail Address Search Field - lads_adr_ema.email_srch';
comment on column bds_addr_email.standard_receiver_flag is 'Flag: Recipient is standard recipient for this number - lads_adr_ema.std_recip';
comment on column bds_addr_email.sap_r3_user is 'Flag: connected to R/3 - lads_adr_ema.r_3_user';
comment on column bds_addr_email.smtp_encoding is 'Desired data coding (SMTP) - lads_adr_ema.encode';
comment on column bds_addr_email.tnef_coding_flag is 'Flag: Receiver can receive TNEF coding via SMTP - lads_adr_ema.tnef';
comment on column bds_addr_email.home_flag is 'Recipient address in this communication type (mail sys.grp) - lads_adr_ema.home_flag';
comment on column bds_addr_email.sequence_number is 'Sequence number - lads_adr_ema.consnumber';
comment on column bds_addr_email.error_flag is 'Flag: Record not processed - lads_adr_ema.errorflag';
comment on column bds_addr_email.not_used_flag is 'Flag: This Communication Number is Not Used - lads_adr_ema.flg_nouse';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_email
   add constraint bds_addr_email_pk primary key (address_type, address_code, address_context, address_sequence);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_email to lics_app;
grant select, insert, update, delete on bds_addr_email to lads_app;
grant select, insert, update, delete on bds_addr_email to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_email for bds.bds_addr_email;