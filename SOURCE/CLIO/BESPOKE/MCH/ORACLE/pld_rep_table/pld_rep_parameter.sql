/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_rep_parameter                                  */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_rep_parameter
   (par_group varchar2(20 char) not null,
    par_code varchar2(20 char) not null,
    par_value varchar2(256 char) not null);

/**/
/* Comment */
/**/
comment on table pld_rep_parameter is 'Planning Report Parameter Table';
comment on column pld_rep_parameter.par_group is 'Parameter group';
comment on column pld_rep_parameter.par_code is 'Parameter code';
comment on column pld_rep_parameter.par_value is 'Parameter value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_rep_parameter
   add constraint pld_rep_parameter_pk primary key (par_group, par_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_rep_parameter to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_rep_parameter for pld_rep.pld_rep_parameter;
