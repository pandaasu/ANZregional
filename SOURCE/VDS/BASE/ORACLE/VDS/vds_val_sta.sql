/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_sta
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Statistic

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_sta
   (vas_group                                    varchar2(30 char)                   not null,
    vas_statistic                                varchar2(30 char)                   not null,
    vas_identifier                               varchar2(30 char)                   not null,
    vas_description                              varchar2(128 char)                  not null,
    vas_missing                                  number                              not null,
    vas_error                                    number                              not null,
    vas_valid                                    number                              not null,
    vas_message                                  number                              not null);

/**/
/* Comments
/**/
comment on table vds_val_sta is 'VDS Validation Statistic';
comment on column vds_val_sta.vas_group is 'Validation statistic group';
comment on column vds_val_sta.vas_statistic is 'Validation statistic code';
comment on column vds_val_sta.vas_identifier is 'Validation statistic identifier';
comment on column vds_val_sta.vas_description is 'Validation statistic description';
comment on column vds_val_sta.vas_missing is 'Validation statistic missing count';
comment on column vds_val_sta.vas_error is 'Validation statistic error count';
comment on column vds_val_sta.vas_valid is 'Validation statistic valid count';
comment on column vds_val_sta.vas_message is 'Validation statistic message count';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_sta
   add constraint vds_val_sta_pk primary key (vas_group, vas_statistic, vas_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_sta to vds_app;
grant select on vds_val_sta to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_sta for vds.vds_val_sta;
