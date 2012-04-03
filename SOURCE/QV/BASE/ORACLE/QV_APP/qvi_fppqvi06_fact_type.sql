/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_fppqvi06_fact_tab;
drop type qvi_fppqvi06_fact_obj;

create or replace type qvi_fppqvi06_fact_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Dashboard Unit Code"           varchar2(18),
    "Solve Type"                    varchar2(18),
    "Unit Code"                     varchar2(18),
    "Plan Version"                  varchar2(64),
    "Dest Code"                     varchar2(18),
    "Cust Code"                     varchar2(18),
    "Line Item Code"                varchar2(18),
    "Material Code"                 varchar2(18),
    "Source Code"                   varchar2(18),
    "YYYYPP"                        number(6),
    "Value"                         varchar2(64),
    "Currency"                      varchar2(3));
/

create or replace type qvi_fppqvi06_fact_tab as table of qvi_fppqvi06_fact_obj;
/