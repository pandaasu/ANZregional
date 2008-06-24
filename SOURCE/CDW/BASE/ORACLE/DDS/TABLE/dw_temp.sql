/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_temp
 Owner  : dds

 Description
 -----------
 Data Warehouse - Temporary Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table dds.dw_temp
   (doc_num                    varchar2(20 char)             null,
    doc_line_num               varchar2(20 char)             null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table dds.dw_temp is 'Data Warehouse Temporary Table';
comment on column dds.dw_temp.doc_num is 'Document number';
comment on column dds.dw_temp.doc_line_num is 'Document line number';

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_temp to dw_app;

/**/
/* Synonym
/**/
create or replace public synonym dw_temp for dds.dw_temp;
