/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_essqvi01_fact_tab;
drop type qvi_essqvi01_fact_obj;

create or replace type qvi_essqvi01_fact_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Essbase Unit"                  varchar2(64),
    "Essbase Line Item"             varchar2(64),
    "Essbase YYYYPP"                number(6),
    "Essbase Current YYYYPP Flag"   varchar2(1),
    "Essbase Measure"               varchar2(8),
    "Essbase Value"                 number(32,5),
    "Essbase Currency"              varchar2(3));
/

create or replace type qvi_essqvi01_fact_tab as table of qvi_essqvi01_fact_obj;
/