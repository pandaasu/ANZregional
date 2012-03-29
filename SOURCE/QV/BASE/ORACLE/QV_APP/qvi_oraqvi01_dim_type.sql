/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_oraqvi01_dim_tab;
drop type qvi_oraqvi01_dim_obj;

create or replace type qvi_oraqvi01_dim_obj as object
--   123456789012345678901234567890 .. Maximum identifier length ..
   ("Hierarchy Code"                varchar2(6),
    "Category Level"                number(2),
    "Material Code"                 varchar2(18),
    "Material"                      varchar2(40),
    "Sub Brand 3 Code"              varchar2(6),
    "Sub Brand 3"                   varchar2(35),
    "Sub Brand 2 Code"              varchar2(6),
    "Sub Brand 2"                   varchar2(35),
    "Sub Brand 1 Code"              varchar2(6),
    "Sub Brand 1"                   varchar2(35),
    "Brand Code"                    varchar2(6),
    "Brand"                         varchar2(35),
    "Product Code"                  varchar2(6),
    "Product"                       varchar2(35),
    "Market Code"                   varchar2(6),
    "Market"                        varchar2(35),
    "Business Code"                 varchar2(6),
    "Business"                      varchar2(35),
    "Top Level Code"                varchar2(6),
    "Top Level"                     varchar2(35));
/

create or replace type qvi_oraqvi01_dim_tab as table of qvi_oraqvi01_dim_obj;
/
