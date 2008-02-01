/*****************/
/* Package Types */
/*****************/
create or replace type bds_bom_dataset_object as object
   (bom_material_code                 varchar2(18 char),
    bom_alternative                   varchar2(2 char),
    bom_plant                         varchar2(4 char),
    bom_number                        varchar2(8 char),
    bom_msg_function                  varchar2(3 char),
    bom_usage                         varchar2(1 char),
    bom_eff_from_date                 date,
    bom_eff_to_date                   date,
    bom_base_qty                      number,
    bom_base_uom                      varchar2(3 char),
    bom_status                        varchar2(2 char),
    item_sequence                     number,
    item_number                       varchar2(4 char),
    item_msg_function                 varchar2(3 char),
    item_material_code                varchar2(18 char),
    item_category                     varchar2(1 char),
    item_base_qty                     number,
    item_base_uom                     varchar2(3 char),
    item_eff_from_date                date,
    item_eff_to_date                  date);
/

create or replace type bds_bom_dataset as table of bds_bom_dataset_object;
/
