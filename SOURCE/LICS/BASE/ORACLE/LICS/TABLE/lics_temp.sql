/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_temp
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_temp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table lics_temp
   (dat_dta_seq                  number(9,0)                     not null,
    dat_record                   varchar2(4000 char)             not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table lics_temp is 'LICS Temporary Table';
comment on column lics_temp.dat_dta_seq is 'Data - data sequence number';
comment on column lics_temp.dat_record is 'Data - record string';

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_temp to lics_app;
grant select on lics_temp to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_temp for lics.lics_temp;
