/*****************/
/* Package Types */
/*****************/
create or replace type lics_store_object as object
   (sto_depth                    number,
    sto_node                     varchar2(1 char),
    sto_group                    varchar2(32 char),
    sto_code                     varchar2(32 char),
    sto_text                     varchar2(4000 char),
    sto_value                    varchar2(4000 char),
    sto_type                     varchar2(10 char),
    sto_data                     varchar2(10 char));
/
create or replace type lics_store_table as table of lics_store_object;
/