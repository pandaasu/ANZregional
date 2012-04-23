/*****************/
/* Package Types */
/*****************/
create or replace type test_dim_object as object
   (mat_code                    varchar2(20),
    mat_name                    varchar2(40));
/

create or replace type test_dim_table as table of test_dim_object;
/