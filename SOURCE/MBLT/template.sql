/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : mblt
 Table   : mblt_file_hdr
 Owner   : mblt
 Author  : Jonathan Girling

 Description
 -----------
 Mobility Reporting - mblt_file_hdr

 YYYY/MM   Author               Description
 -------   ------               -----------
 2012/01   Jonathan Girling     Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table mblt_file_hdr
   (file_code                   number(7)         not null,
    rec_code_num                number(6)         not null,
    acc_num                     varchar2(32 char) not null,
    bill_prd_cut_off_date       varchar2(14 char) not null,
    tax_inv                     varchar2(40 char) not null,
    bill_prd_start_date         varchar2(10 char) null,
    due_date                    varchar2(30 char) null,
    amnt_due                    varchar2(30 char) null,
    total_phone_count           varchar2(30 char) null,
    sftwr_rvsn_lvl              varchar2(30 char) null,
    file_lupdp                  varchar2(8 char)  not null,
    file_lupdt                  date              not null);

/**/
/* Comments
/**/
comment on table mblt_file_hdr is 'MBLT File Header';
comment on column mblt_file_hdr.file_code is 'File Header - Unique ID';
comment on column mblt_file_hdr.rec_code_num is 'File Header - Record Code Number (Always "000000")';
comment on column mblt_file_hdr.acc_num is 'File Header - Account Number (Billiung Account Number eg. "9005773643")';
comment on column mblt_file_hdr.bill_period_cut_off_date is 'File Header - code description';
comment on column mblt_file_hdr.tax_inv is 'File Header - value type (*SINGLE,*LIST)';
comment on column mblt_file_hdr.bill_prd_start_date is 'File Header - Software Revision Level (Always Blank. Currently not used)';
comment on column mblt_file_hdr.due_date is 'File Header - Software Revision Level (Always Blank. Currently not used)';
comment on column mblt_file_hdr.amount_date is 'File Header - Software Revision Level (Always Blank. Currently not used)';
comment on column mblt_file_hdr.total_phone_count is 'File Header - Software Revision Level (Always Blank. Currently not used)';
comment on column mblt_file_hdr.software_revision_level is 'File Header - Software Revision Level (Always Blank. Currently not used)';
comment on column mblt_file_hdr.dsc_upd_user is 'File Header - update user';
comment on column mblt_file_hdr.dsc_upd_date is 'File Header - update date';

/**/
/* Primary Key Constraint
/**/
alter table mblt_file_hdr
   add constraint mblt_file_hdr_pk primary key (XXXXXX); /***** TBC ******/

/**/
/* Authority
/**/
grant select, insert, update, delete on mblt_file_hdr to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym mblt_file_hdr for mblt.mblt_file_hdr;
