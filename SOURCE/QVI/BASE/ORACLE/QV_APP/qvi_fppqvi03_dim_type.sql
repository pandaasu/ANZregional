/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_fppqvi03_dim_tab;
drop type qvi_fppqvi03_dim_obj;

create or replace type qvi_fppqvi03_dim_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Line Item Code"                varchar2(18),
    "Line Item Owner"               varchar2(32),
    "Line Item User Owner"          varchar2(32),
    "Line Item Classification"      varchar2(128),
    "Line Item Short"               varchar2(16),
    "Line Item"                     varchar2(64),
    "Line Item Sign Flag"           varchar2(1),
    "Line Item Financial Unit"      varchar2(32));
/

create or replace type qvi_fppqvi03_dim_tab as table of qvi_fppqvi03_dim_obj;
/