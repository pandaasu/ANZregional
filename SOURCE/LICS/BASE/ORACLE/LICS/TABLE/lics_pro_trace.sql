/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_pro_trace
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_pro_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_pro_trace
   (prt_process                  varchar2(32 char)               not null,
    prt_date                     varchar2(8 char)                not null);

/**/
/* Comments
/**/
comment on table lics_pro_trace is 'LICS Processing Trace Table';
comment on column lics_pro_trace.prt_process is 'Processing Trace - process code';
comment on column lics_pro_trace.prt_date is 'Processing Trace - process date (YYYYMMDD)';

/**/
/* Primary Key Constraint
/**/
alter table lics_pro_trace
   add constraint lics_pro_trace_pk primary key (prt_process, prt_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_pro_trace to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_pro_trace for lics.lics_pro_trace;
