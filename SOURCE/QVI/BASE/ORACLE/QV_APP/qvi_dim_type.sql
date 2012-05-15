/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_dim_table;
drop type qvi_dim_object;

--                     123456789012345678901234567890 .. Maximum identifier length ..
create or replace type qvi_dim_object as object
   (dim_code                    varchar2(32),
    dat_seqn                    number,
    dat_data                    sys.anydata);
/

create or replace type qvi_dim_table as table of qvi_dim_object;
/