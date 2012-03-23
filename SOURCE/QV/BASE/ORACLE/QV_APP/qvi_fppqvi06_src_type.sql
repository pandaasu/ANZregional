/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_fppqvi06_src_tab;
drop type qvi_fppqvi06_src_obj;

create or replace type qvi_fppqvi06_src_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Unit Code"                     varchar2(18),
    "Plan Version"                  varchar2(64),
    "Dest Code"                     varchar2(18),
    "Cust Code"                     varchar2(18),
    "Year"                          number(4),
    "Period"                        number(2),
    "Line Item Code"                varchar2(18),
    "Material Code"                 varchar2(18),
    "Source Code"                   varchar2(18),
    "Value"                         number(15,5),
    "Currency"                      varchar2(3));
/

create or replace type qvi_fppqvi06_src_tab as table of qvi_fppqvi06_src_obj;
/