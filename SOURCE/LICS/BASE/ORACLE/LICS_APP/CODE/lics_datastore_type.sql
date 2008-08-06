/*****************/
/* Package Types */
/*****************/
create or replace type lics_datastore_object as object
   (dsv_system varchar2(32 char),
    dsv_group varchar2(32 char),
    dsv_code varchar2(32 char),
    dsv_value varchar2(256 char));
/
create or replace type lics_datastore_table as table of lics_datastore_object;
/