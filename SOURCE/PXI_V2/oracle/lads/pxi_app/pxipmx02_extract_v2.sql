prompt :: Compile Package [pxipmx02_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx02_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX02_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Product Hierarchy - PX Interface 303 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 28/07/2013    Chris Horn            Created.
 21/08/2013    Chris Horn            Cleaned Up Code.
 28/08/2013    Chris Horn            Made code more generic for OZ and NZ.
 11/10/2013    Chris Horn            Implemented the Percare Product Hierarchy.
 06/11/2013    Jonathan Girling      Updated logic.
 2013-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of product hierarchy data.

             It defaults to all available live promax companies and divisions
             and just current data as of yesterday.  If null is supplied as
             the creation date then historial information will be supplied
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.
  1.3   2013-10-11 Chris Horn           Implemented the Petcare Hierarchy.

*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_creation_date in date);

/*******************************************************************************
  NAME:      GET_PRODUCT_HIERARCHY
  PURPOSE:   Calculates a product hierarchy by taking the product classification
             and flatterns its output and outputs.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-28 Chris Horn           Created.
  1.1   2013-08-28 Chris Horn           Added Promax Company and Division Info.
  1.2   2013-11-06 Jonathan Girling     Updated xdstrbtn_chain_status filter to
                                        include status 40

*******************************************************************************/
  -- Hierarchy Node Record
  type rt_hierarchy_node is record (
      promax_company pxi_common.st_company,
      promax_division pxi_common.st_promax_division,
      node_code varchar2(40),
      node_name varchar2(40),
      parent_node_code varchar2(40),
      material_code varchar2(18),
      node_level number(2)
    );
  -- Define the hierarchy table type.
  type tt_hierachy is table of rt_hierarchy_node;
  -- The pipelined table function to return the product hierarchy nodes.
  function get_product_hierarchy(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
    ) return tt_hierachy pipelined;

end pxipmx02_extract_v2;
/

create or replace package body pxi_app.pxipmx02_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX02_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX02';

/*******************************************************************************
  NAME:      GET_PRODUCT_HIERARCHY                                        PUBLIC
*******************************************************************************/
-- NOTE : When coding australian product hierachy.  This can be built into this
-- query by providing case / decode statements around each level based on the
-- t4.promax_company and t4.promax_division values as needed.
  function get_product_hierarchy(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division
    ) return tt_hierachy pipelined is
    -- This cursor generates the product level data in a flatterned table structure.
    c_not_defined constant pxi_common.st_data := 'NOT DEFINED';
    cursor csr_product_level_data is
      select
       t4.promax_company,
       t4.promax_division,
       t1.sap_material_code as zrep_code,
       t1.bds_material_desc_en as zrep_desc,
       -- Level 1 Code
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl(t2.sales_organisation,'###')  -- Sales Organisation
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl(t3.sap_fighting_unit_code,'##') -- Fighting Unit
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl(t3.sap_brand_flag_code,'###') -- Brand Flag
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level1,
       -- Level 1 Description
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl(( select t0.sales_organisation_name from (
           -- This Query should be turned into a view.
           select t10.vkorg as sales_organisation, t10.vtext as sales_organisation_name
             from (
               select
                 trim(substr(t01.z_data,1,3)) as mandt,
                 trim(substr(t01.z_data,4,1)) as spras,
                 trim(substr(t01.z_data,5,4)) as vkorg,
                 trim(SUBSTR(t01.z_data,9,20)) AS vtext
               from
                 lads_ref_dat t01 -- 
               where
                 t01.z_tabname = 'TVKOT' and
                 -- Remove any records that have been deleted by a D in the z_chgtyp column
                 substr(t01.z_data,1,28) not in (
                   select substr(t01.z_data,1,28) from lads_ref_dat /* */  t01
                   where t01.z_tabname = 'TVKOT' and z_chgtyp ='D')
               ) t10 where t10.spras = 'E'
             -- End of code for view.
             ) t0 where t0.sales_organisation = t2.sales_organisation),'NOT DEFINED')  -- Sales Organisation Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
          nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR6' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_fighting_unit_code),c_not_defined) -- Fighting Unit Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC003' and t0.sap_charistic_value_code = t3.sap_brand_flag_code),c_not_defined)  -- Brand Flag Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level1_desc,
       -- Level 2 Code
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl(t3.sap_bus_sgmnt_code,'##')  -- Business Segment aka Division
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl(t3.sap_brand_flag_code,'###') -- Brand Flag
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
          nvl(t3.sap_mrkt_sub_ctgry_code,'###') -- Market SUb Category Flag
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level2,
       -- Level 2 Description
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC001' and t0.sap_charistic_value_code = t3.sap_bus_sgmnt_code),c_not_defined) -- Business Segment
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC003' and t0.sap_charistic_value_code = t3.sap_brand_flag_code),c_not_defined)  -- Brand Flag Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR2' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_mrkt_sub_ctgry_code),c_not_defined) -- Fighting Unit Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level2_desc,
       -- Level 3 Code
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
            nvl(t3.sap_trade_sector_code,'##') || nvl(t3.sap_bus_sgmnt_code,'##') -- Trade Sector, Business Segment
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl(t3.sap_cnsmr_pack_frmt_code,'###') -- Consumer Pack Format
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
          nvl(t3.sap_mrkt_sub_ctgry_grp_code,'###') -- Market SUb Category Flag
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level3,
       -- Level 3 Description
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC008' and t0.sap_charistic_value_code = t3.sap_trade_sector_code) || ' ' || -- Trade Sector
               (select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC001' and t0.sap_charistic_value_code = t3.sap_bus_sgmnt_code),c_not_defined)   -- Business Segment
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC025' and t0.sap_charistic_value_code = t3.sap_cnsmr_pack_frmt_code),c_not_defined)  -- Brand Flag Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR3' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_mrkt_sub_ctgry_grp_code),c_not_defined) -- Fighting Unit Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level3_desc,
       -- Level 4 Code
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl(t3.sap_nz_launch_ranking_code,'###') -- NZ Launch Ranking Code
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl(t3.sap_au_snk_activity_name,'###') -- AU Snack Activity Name / Promoted Group
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl(t3.sap_cnsmr_pack_frmt_code,'###') -- Consumer Pack Format
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level4,
       -- Level 4 Description
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR22' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_nz_launch_ranking_code),c_not_defined) -- NZ Launch Ranking Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR14' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_au_snk_activity_name),c_not_defined) -- AU SNK AU Activity / Promoted Group
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC025' and t0.sap_charistic_value_code = t3.sap_cnsmr_pack_frmt_code),c_not_defined)  -- Brand Flag Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level4_desc,
       -- Level 5 Code
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl(t3.sap_nz_promotional_grp_code,'###') -- NZ Promotional Group
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           null -- No Level 5
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl(t3.sap_size_code,'###') -- size
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level5,
       -- Level 5 Description
       case
         when t4.promax_company = pxi_common.gc_new_zealand then
           nvl((select t0.sap_charistic_value_desc from bds_charistic_value t0 where t0.sap_charistic_code = 'Z_APCHAR11' and t0.sap_charistic_value_lang = 'EN' and t0.sap_charistic_value_code = t3.sap_nz_promotional_grp_code),c_not_defined) -- -- NZ Promotional Group Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_petcare then
           null -- No Level 5 Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_food then
           nvl((select t0.sap_charistic_value_long_desc from bds_refrnc_charistic t0 where t0.sap_charistic_code = '/MARS/MD_CHC014' and t0.sap_charistic_value_code = t3.sap_size_code),c_not_defined)  -- Brand Flag Description
         when t4.promax_company = pxi_common.gc_australia and t4.promax_division = pxi_common.gc_bus_sgmnt_snack then
           c_not_defined
         else
           c_not_defined
       end as level5_desc
     from
       bds_material_hdr t1,  -- TDU Material Header Information  -- 
       bds_material_dstrbtn_chain t2, -- Material Sales Area Information -- 
       bds_material_classfctn t3, -- Material Classification Data  --
       pxi.pmx_extract_criteria t4, -- selection criteria table
       bds_material_moe t5  -- maeterial to MOE relationship
     where
       -- Table Joins
       t2.sap_material_code = t1.sap_material_code and
       t3.sap_material_code = t1.sap_material_code and
       t5.sap_material_code = t1.sap_material_code and
       -- make sure we're referring to correct company
       t4.promax_company = i_promax_company and
       t4.promax_division = i_promax_division and
       t4.required_for_prod = 'YES' and
       -- Ensure Material Type is a FERT and that it is a Tradded Unit
       t1.material_type = 'ZREP' and t1.mars_traded_unit_flag = 'X' and
       -- Ensure that this project is allowed to be distributed.
       (t1.xdstrbtn_chain_status = '10' or t1.xdstrbtn_chain_status = '40') and
       -- Make sure the distribution channel status is not inactive
       t2.dstrbtn_chain_status != '99' and
       -- Ensure the data hasn't been deleted and is correct in lads.
       t1.deletion_flag is null and t1.bds_lads_status = 1 and t2.dstrbtn_chain_delete_indctr is null and
       t3.bds_lads_status = 1 and
       -- Now join to the sales organisation and division information.
       t2.sales_organisation = t4.promax_company and
       -- Make sure this product is not being sold to affilate markers or as a raws and packs product.
       t2.dstrbtn_channel = t4.distribution_channel and
       t5.moe_code = t4.selling_moe and
       ((t2.sales_organisation = pxi_common.gc_australia and t1.material_division = t4.promax_division) or (t2.sales_organisation = pxi_common.gc_new_zealand));

    -- Record variable to hold the hierarch output.
    rv_product_level csr_product_level_data%rowtype;
    -- Define the table structure for the product hierarchy.
    type tt_hierachy_collection is table of rt_hierarchy_node index by pls_integer;
    tv_hierarchy tt_hierachy_collection;
    v_counter pls_integer;

    -- This procedure looks through the existing node paths and checks if one already exists.
    procedure add_path(i_promax_company in pxi_common.st_company, i_promax_division in pxi_common.st_promax_division, i_node_code in varchar2, i_node_name in varchar2,i_parent_node_code in varchar2,i_level in number) is
      rv_node rt_hierarchy_node;
      v_counter pls_integer;
      v_mover pls_integer;
      v_found boolean;
      v_stop boolean;
    begin
      v_counter := 0;
      v_found := false;
      v_stop := false;
      loop
        v_counter := v_counter + 1;
        exit when v_counter > tv_hierarchy.count;
        -- Check if we reached the end of the nodes at this level that we need and the record hadn't been found.
        if tv_hierarchy(v_counter).node_level = i_level then
          if i_node_code = tv_hierarchy(v_counter).node_code and i_promax_company = tv_hierarchy(v_counter).promax_company and i_promax_division = tv_hierarchy(v_counter).promax_division then
            v_found := true;
            -- Check that the parent node and name are the same.
            if i_node_name <> tv_hierarchy(v_counter).node_name or i_parent_node_code <> tv_hierarchy(v_counter).parent_node_code then
              pxi_common.raise_promax_error(pc_package_name,'ADD_PATH','Node : ' || i_node_code || ' Node Name or Parent Node Code did not match a previous instance.');
            end if;
          elsif i_node_code < tv_hierarchy(v_counter).node_code and i_promax_company = tv_hierarchy(v_counter).promax_company and i_promax_division = tv_hierarchy(v_counter).promax_division then
            v_stop := true;
          end if;
        elsif i_level < tv_hierarchy(v_counter).node_level then
          v_stop := true;
        end if;
        -- If a flag has been set then exit.
        exit when v_stop = true or v_found = true;
      end loop;
      -- If stop was executed then insert a blank space here in the hierarchy.
      if v_stop = true then
        v_mover := tv_hierarchy.count;
        loop
          tv_hierarchy(v_mover+1) := tv_hierarchy(v_mover);
          exit when v_mover = v_counter;
          v_mover := v_mover - 1;
        end loop;
        tv_hierarchy(v_counter) := null;
      end if;
      -- If the node was not found then assign this node to the current position of the counter.
      if v_found = false then
        rv_node.promax_company := i_promax_company;
        rv_node.promax_division := i_promax_division;
        rv_node.node_code := i_node_code;
        rv_node.node_name := i_node_name;
        rv_node.parent_node_code := i_parent_node_code;
        rv_node.node_level := i_level;
        tv_hierarchy(v_counter) := rv_node;
      end if;
    end;

    procedure add_material(i_promax_company in pxi_common.st_company, i_promax_division in pxi_common.st_promax_division, i_zrep_code in varchar2, i_zrep_name in varchar2,i_parent_node_code in varchar2,i_level in number) is
      rv_material rt_hierarchy_node;
    begin
      rv_material.promax_company := i_promax_company;
      rv_material.promax_division := i_promax_division;
      rv_material.node_code := i_zrep_code;
      rv_material.node_name := i_zrep_name;
      rv_material.parent_node_code := i_parent_node_code;
      rv_material.node_level := i_level;
      rv_material.material_code := i_zrep_code;
      tv_hierarchy(tv_hierarchy.count+1) := rv_material;
    end;

   begin
     -- Now process each of the rows of product data and build the hierarchy data in memory.
     open csr_product_level_data;
     loop
       fetch csr_product_level_data into rv_product_level;
       exit when csr_product_level_data%notfound;
       -- Now process the material.
       add_path(rv_product_level.promax_company, rv_product_level.promax_division,'L1'||rv_product_level.level1,rv_product_level.level1_desc,null,1);
       add_path(rv_product_level.promax_company, rv_product_level.promax_division,'L2'||rv_product_level.level1||rv_product_level.level2,rv_product_level.level2_desc,'L1'||rv_product_level.level1,2);
       add_path(rv_product_level.promax_company, rv_product_level.promax_division,'L3'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3,rv_product_level.level3_desc,'L2'||rv_product_level.level1||rv_product_level.level2,3);
       add_path(rv_product_level.promax_company, rv_product_level.promax_division,'L4'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4,rv_product_level.level4_desc,'L3'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3,4);
       if rv_product_level.level5 is not null then
         add_path(rv_product_level.promax_company, rv_product_level.promax_division,'L5'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4||rv_product_level.level5,rv_product_level.level5_desc,'L4'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4,5);
         add_material(rv_product_level.promax_company, rv_product_level.promax_division,rv_product_level.zrep_code,rv_product_level.zrep_desc,'L5'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4||rv_product_level.level5,6);
       else
         add_material(rv_product_level.promax_company, rv_product_level.promax_division,rv_product_level.zrep_code,rv_product_level.zrep_desc,'L4'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4,5);
       end if;
     end loop;
     close csr_product_level_data;
     -- Now output the actual hierarchy rows.
     v_counter := 0;
     loop
       v_counter := v_counter + 1;
       exit when v_counter > tv_hierarchy.count;
       pipe row(tv_hierarchy(v_counter));
     end loop;
   end get_product_hierarchy;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_creation_date in date) is
     -- Variables
     v_instance number(15,0);
     v_data pxi_common.st_data;

     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('303002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '303002' -> ICRecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(node_code, 40, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- node_code -> Attribute
          pxi_common.char_format(node_name, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- node_name -> NodeName
          pxi_common.char_format(parent_node_code, 40, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) || -- parent_node_code -> ParrentAttribute
          pxi_common.char_format(material_code, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) -- material_code -> MaterialNumber
        ------------------------------------------------------------------------
        from
          table(get_product_hierarchy(i_promax_company, i_promax_division));
        --======================================================================

   begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_promax_company,i_promax_division));
      end if;
      -- Append the interface data
      lics_outbound_loader.append_data(v_data);
    end loop;
    close csr_input;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx02_extract_v2;
/

grant execute on pxi_app.pxipmx02_extract_v2 to lics_app, fflu_app, site_app;
