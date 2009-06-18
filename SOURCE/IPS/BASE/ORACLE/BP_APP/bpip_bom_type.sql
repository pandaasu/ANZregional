/*****************/
/* Package Types */
/*****************/
create or replace type bpip_allocation_object as object (alc_type varchar2(32 char),
                                                         bom_plant varchar2(4 char),
                                                         bom_matl_code varchar2(18 char),
                                                         proportion number,
                                                         bom_hierarchy_path varchar2(1024 char));
/
create or replace type bpip_allocation_table as table of bpip_allocation_object;
/
