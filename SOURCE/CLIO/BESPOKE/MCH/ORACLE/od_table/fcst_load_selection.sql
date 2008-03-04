/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_selection
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Selection Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_selection
   (load_identifier                 varchar2(64 char)      not null,
    fcst_planner                    varchar2(32 char)      not null);

/**/
/* Comments
/**/
comment on table od.fcst_load_selection is 'Forecast Load Selection Table';
comment on column od.fcst_load_selection.load_identifier is 'Load identifier';
comment on column od.fcst_load_selection.fcst_planner is 'Forecast Planner';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_selection
   add constraint fcst_load_selection_pk primary key (load_identifier, fcst_planner);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_selection to od_app;
grant select, insert, update, delete on od.fcst_load_selection to dw_app;
grant select on od.fcst_load_selection to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_selection for od.fcst_load_selection;