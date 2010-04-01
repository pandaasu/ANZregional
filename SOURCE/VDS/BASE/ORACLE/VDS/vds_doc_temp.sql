/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_doc_temp
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - vds_doc_temp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table vds.vds_doc_temp
   (doc_type                          varchar2(30 char)        not null,
    doc_table                         varchar2(30 char)        not null,
    doc_index                         varchar2(30 char)        not null,
    doc_data                          varchar2(2000 char)      not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table vds.vds_doc_temp is 'VDS Document Temporary Table';
comment on column vds.vds_doc_temp.doc_type is 'Document type - *META or *DATA';
comment on column vds.vds_doc_temp.doc_table is 'Document table';
comment on column vds.vds_doc_temp.doc_index is 'Document index';
comment on column vds.vds_doc_temp.doc_data is 'Document data';

--*META,MARA,1,data

--*DATA,MARA,'0000234567',xxxxxxxxxxxxxxxxxxxxxxxxx
--*DATA,MARC,'0000234567',xxxxxxxxxxxxxxxxxxxxxxxxx
--*DATA,MARC,'0000234567',xxxxxxxxxxxxxxxxxxxxxxxxx
--*DATA,MARC,'0000234567',xxxxxxxxxxxxxxxxxxxxxxxxx

/**/
/* Authority
/**/
grant select, insert, update, delete on vds.vds_doc_temp to vds_app;

/**/
/* Synonym
/**/
create public synonym vds_doc_temp for vds.vds_doc_temp;
