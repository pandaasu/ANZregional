/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_hdr_trace
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_hdr_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_hdr_trace
   (het_header                   number(15,0)                    not null,
    het_hdr_trace                number(5,0)                     not null,
    het_execution                number(15,0)                    null,
    het_user                     varchar2(30 char)               not null,
    het_str_time                 date                            not null,
    het_end_time                 date                            not null,
    het_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_hdr_trace is 'LICS Header Trace Table';
comment on column lics_hdr_trace.het_header is 'Header trace - header sequence number';
comment on column lics_hdr_trace.het_hdr_trace is 'Header trace - trace sequence number';
comment on column lics_hdr_trace.het_execution is 'Header trace - job execution number';
comment on column lics_hdr_trace.het_user is 'Header trace - creation user';
comment on column lics_hdr_trace.het_str_time is 'Header trace - trace start time';
comment on column lics_hdr_trace.het_end_time is 'Header trace - trace end time';
comment on column lics_hdr_trace.het_status is 'Header trace - trace status';

/**/
/* Primary Key Constraint
/**/
alter table lics_hdr_trace
   add constraint lics_hdr_trace_pk primary key (het_header, het_hdr_trace);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_hdr_trace
--   add constraint lics_hdr_trace_fk01 foreign key (het_header)
--      references lics_header (hea_header);

--alter table lics_hdr_trace
--   add constraint lics_hdr_trace_fk02 foreign key (het_execution)
--      references lics_job_trace (jot_execution);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_hdr_trace to lics_app;
grant select on lics_hdr_trace to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_hdr_trace for lics.lics_hdr_trace;
