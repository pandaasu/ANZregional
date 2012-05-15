/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_xml_type;
drop type qvi_xml_object;

--                     123456789012345678901234567890 .. Maximum identifier length ..
create or replace type qvi_xml_object as object (xml_text varchar2(2000 char));
/

create or replace type qvi_xml_type as table of qvi_xml_object;
/