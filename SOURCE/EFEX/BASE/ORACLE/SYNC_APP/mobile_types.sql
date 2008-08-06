/****************/
/* Mobile Types */
/****************/

create or replace type mobile_stream as table of varchar2(2000 char);
/

create or replace type mobile_code_object as object
   (record_id number);
/

create or replace type mobile_code_table as table of mobile_code_object;
/
