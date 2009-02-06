/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_bom_tmp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_bom_tmp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table lads.lads_bom_tmp
   (tab_name                                     varchar2(30 char)                   not null,
    tab_data                                     varchar2(512 char)                  not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table lads.lads_bom_tmp is 'LADS Bill Of Material Temporary Table';
comment on column lads.lads_bom_tmp.tab_name is 'SAP table name';
comment on column lads.lads_bom_tmp.tab_data is 'SAP table data';

/**/
/* Authority
/**/
grant select, insert, update, delete on lads.lads_bom_tmp to lads_app;

/**/
/* Synonym
/**/
create public synonym lads_bom_tmp for lads.lads_bom_tmp;
