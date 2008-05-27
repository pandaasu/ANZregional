/*****************/
/* Package Types */
/*****************/
create or replace type edi_billing_object as object
   (sndto_code          varchar2(20),
    bilto_date          varchar2(8),
    bilto_str_date      varchar2(8),
    bilto_end_date      varchar2(8),
    sndon_date          varchar2(8));
/

create or replace type edi_billing_table as table of edi_billing_object;
/

create or replace type edi_cycle_object as object
   (sndto_code          varchar2(20),
    effat_month         varchar2(6),
    cycle_text          varchar2(4000));
/

create or replace type edi_cycle_table as table of edi_cycle_object;
/
