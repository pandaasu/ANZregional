/*****************/
/* Package Types */
/*****************/
create or replace type qvi_fac_object as object
   (das_code                    varchar2(32),
    fac_code                    varchar2(32),
    tim_code                    varchar2(32),
    dat_seqn                    number,
    dat_data                    sys.anydata);
/

create or replace type qvi_fac_type as table of qvi_fac_object;
/