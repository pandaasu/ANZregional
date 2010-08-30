/*****************/
/* Package Types */
/*****************/
create or replace type ods_xml_object as object (xml_text varchar2(2000 char));
/

create or replace type ods_xml_type as table of ods_xml_object;
/