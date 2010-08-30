/*****************/
/* Package Types */
/*****************/
create or replace type ods_npc_object as object
   (sale_material_code           varchar2(32 char),
    sale_buom_qty                number,
    sale_buom_code               varchar2(32 char),
    bom_sequence                 number,
    bom_plant_code               varchar2(32 char),
    fert_material_code           varchar2(32 char),
    fert_qty                     number,
    fert_uom                     varchar2(32 char),
    item_material_code           varchar2(32 char),
    item_qty                     number,
    item_uom                     varchar2(32 char));
/

create or replace type ods_npc_type as table of ods_npc_object;
/