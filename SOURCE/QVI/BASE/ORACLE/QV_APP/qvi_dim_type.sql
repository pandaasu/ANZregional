/*****************/
/* Package Types */
/*****************/
create or replace type qvi_dim_object as object
   (dim_code                    varchar2(32),
    dat_seqn                    number,
    dat_data                    sys.anydata);
/

create or replace type qvi_dim_table as table of qvi_dim_object;
/