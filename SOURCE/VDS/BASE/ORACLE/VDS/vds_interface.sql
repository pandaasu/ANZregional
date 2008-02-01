/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_interface
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_interface
   (vin_interface                                varchar2(30 char)                   not null,
    vin_description                              varchar2(128 char)                  not null,
    vin_logon01                                  varchar2(1 char)                    not null,
    vin_logon02                                  varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table vds_interface is 'Validation Interface';
comment on column vds_interface.vin_interface is 'Interface code';
comment on column vds_interface.vin_description is 'Interface description';
comment on column vds_interface.vin_logon01 is 'Interface logon 01 required';
comment on column vds_interface.vin_logon01 is 'Interface logon 02 required';

/**/
/* Primary Key Constraint
/**/
alter table vds_interface
   add constraint vds_interface_pk primary key (vin_interface);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_interface to vds_app;
grant select on vds_interface to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_interface for vds.vds_interface;