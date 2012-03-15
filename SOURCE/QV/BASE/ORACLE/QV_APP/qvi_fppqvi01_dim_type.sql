/*****************/
/* Package Types */
/*****************/
create or replace type qvi_fppqvi01_dim_object as object
   ("Cust Code"                 varchar2(6),
    "Customer"                  varchar2(32),
    "Cust Parent Code"          varchar2(6),
    "Cust Parent"               varchar2(32));
/

create or replace type qvi_fppqvi01_dim_table as table of qvi_fppqvi01_dim_object;
/