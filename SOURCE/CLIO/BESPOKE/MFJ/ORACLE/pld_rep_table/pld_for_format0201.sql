/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reporting                             */
/* Object  : pld_for_format0201                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : September 2003                                     */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format0201
   (sap_material_code varchar2(18 char) not null,
    planning_status varchar2(1 char) not null,
    planning_type varchar2(60 char) not null,
    planning_cat_old varchar2(1 char) not null,
    planning_cat_prv varchar2(1 char) not null,
    planning_category varchar2(1 char) not null,
    planning_src_unit varchar2(255 char) not null);

/**/
/* Comment */
/**/
comment on table pld_for_format0201 is 'Planning Forecast Format 02 Material Table';
comment on column pld_for_format0201.sap_material_code is 'SAP Material code';
comment on column pld_for_format0201.planning_status is 'Planning status';
comment on column pld_for_format0201.planning_type is 'Planning type';
comment on column pld_for_format0201.planning_cat_old is 'Planning category old';
comment on column pld_for_format0201.planning_cat_prv is 'Planning category previous';
comment on column pld_for_format0201.planning_category is 'Planning category';
comment on column pld_for_format0201.planning_src_unit is 'Planning source unit';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_format0201
   add constraint pld_for_format0201_pk primary key (sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format0201 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format0201 for pld_rep.pld_for_format0201;
