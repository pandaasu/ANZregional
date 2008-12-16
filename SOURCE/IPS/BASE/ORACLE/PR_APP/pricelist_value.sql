/*****************/
/* Package Types */
/*****************/
create or replace type pricelist_value_object as object
   (value varchar2(200),
    text varchar2(200));
/

create or replace type pricelist_value as table of pricelist_value_object;
/