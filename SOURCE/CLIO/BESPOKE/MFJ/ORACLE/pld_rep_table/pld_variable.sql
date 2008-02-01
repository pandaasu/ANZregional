/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reporting                             */
/* Object  : pld_variable                                      */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : September 2003                                     */
/****************************************************************/

/**/
/* Table creation */
/**/
create global temporary table pld_variable
   (var_type varchar2(20 char) not null,
    var_code varchar2(256 char) not null)
on commit preserve rows;

/**/
/* Comment */
/**/
comment on table pld_variable is 'Planning Variable Temporary Table';
comment on column pld_variable.var_type is 'Variable type';
comment on column pld_variable.var_code is 'Variable code';

/**/
/* Primary Key Constraint */
/**/
alter table pld_variable
   add constraint pld_variable_pk primary key (var_type, var_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_variable to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_variable for pld_rep.pld_variable;
