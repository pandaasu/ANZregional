/*****************/
/* Package Types */
/*****************/

--        123456789012345678901234567890 .. Maximum identifier length ..
drop type qvi_src_table;
drop type qvi_src_object;

--                     123456789012345678901234567890 .. Maximum identifier length ..
create or replace type qvi_src_object as object
   (das_code                    varchar2(32),
    fac_code                    varchar2(32),
    tim_code                    varchar2(32),
    par_code                    varchar2(32),
    dat_seqn                    number,
    dat_data                    sys.anydata);
/

create or replace type qvi_src_table as table of qvi_src_object;
/