/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reporting                             */
/* Object  : pld_xml                                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2006                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create global temporary table pld_xml
   (xml_indx number not null,
    xml_data varchar2(4000 char) not null)
on commit preserve rows;

/**/
/* Comment */
/**/
comment on table pld_xml is 'Planning XML Temporary Table';
comment on column pld_xml.xml_data is 'XML data';

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_xml to pld_rep_app;
grant select on pld_xml to public;

/**/
/* Synonym */
/**/
create or replace public synonym pld_xml for pld_rep.pld_xml;
