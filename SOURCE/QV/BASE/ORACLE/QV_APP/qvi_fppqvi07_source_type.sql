/*****************/
/* Package Types */
/*****************/
drop type qvi_fppqvi07_source_table;
drop type qvi_fppqvi07_source_object;

create or replace type qvi_fppqvi07_source_object as object
   ("Unit Code"                 varchar2(8),
    "Plan Version"              varchar2(64),
    "Dest Code"                 varchar2(8),
    "Cust Code"                 varchar2(8),
    "Year"                      number(4),
    "Period"                    number(2),
    "Line Item Code"            varchar2(8),
    "Material Code"             varchar2(8),
    "Source Code"               varchar2(8),
    "Actual Value"              number(15,5));
/

create or replace type qvi_fppqvi07_source_table as table of qvi_fppqvi07_source_object;
/