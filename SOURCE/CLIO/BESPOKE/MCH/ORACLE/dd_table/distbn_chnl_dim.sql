/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : distbn_chnl_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Distribution Channel Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.distbn_chnl_dim
   (sap_distbn_chnl_code     varchar2(2 char)                 not null,
    distbn_chnl_desc         varchar2(60 char)                not null);

/**/
/* Comments
/**/
comment on table dd.distbn_chnl_dim is 'Distribution Channel Dimension Table';
comment on column dd.distbn_chnl_dim.sap_distbn_chnl_code is 'SAP Distribution Channel Code';
comment on column dd.distbn_chnl_dim.distbn_chnl_desc is 'Distribution Channel Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.distbn_chnl_dim
   add constraint distbn_chnl_dim_pk primary key (sap_distbn_chnl_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.distbn_chnl_dim to dw_app;
grant select on dd.distbn_chnl_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym distbn_chnl_dim for dd.distbn_chnl_dim;
