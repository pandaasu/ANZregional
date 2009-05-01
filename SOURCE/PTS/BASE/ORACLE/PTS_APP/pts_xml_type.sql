/*****************/
/* Package Types */
/*****************/
create or replace type pts_xml_object as object (xml_text varchar2(2000 char));
/

create or replace type pts_xml_type as table of pts_xml_object;
/