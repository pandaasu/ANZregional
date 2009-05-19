/*****************/
/* Package Types */
/*****************/
create or replace type bpip_allocation_object as object (alc_type varchar2(32 char),
                                                         bom_plant varchar2(4 char),
                                                         bom_matl_code varchar2(18 char),
                                                         bom_altv varchar2(2 char),
                                                         bom_qty number,
                                                         bom_uom varchar2(10 char),
                                                         bom_matl_type varchar2(10 char),
                                                         bom_trdd_unit varchar2(10 char),
                                                         bom_base_uom varchar2(10 char),
                                                         bom_net_wght number,
                                                         bom_gross_wght number,
                                                         cmpnt_matl_code varchar2(18 char),
                                                         cmpnt_qty number,
                                                         cmpnt_uom varchar2(10 char),
                                                         cmpnt_matl_type varchar2(32 char),
                                                         cmpnt_base_uom varchar2(10 char),
                                                         cmpnt_net_wght number,
                                                         cmpnt_gross_wght number,
                                                         proportion number,
                                                         bom_hierarchy_level number,
                                                         bom_hierarchy_root varchar2(1024 char),
                                                         bom_hierarchy_path varchar2(1024 char));
/
create or replace type bpip_allocation_table as table of bpip_allocation_object;
/
