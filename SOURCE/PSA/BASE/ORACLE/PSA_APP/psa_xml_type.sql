/*****************/
/* Package Types */
/*****************/
create or replace type psa_xml_object as object (xml_text varchar2(2000 char));
/

create or replace type psa_xml_type as table of psa_xml_object;
/