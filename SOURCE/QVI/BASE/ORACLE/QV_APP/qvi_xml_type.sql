/*****************/
/* Package Types */
/*****************/
create or replace type qvi_xml_object as object (xml_text varchar2(2000 char));
/

create or replace type qvi_xml_type as table of qvi_xml_object;
/