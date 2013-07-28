create or replace 
package body pxipmx04_extract as
   -- Private exceptions
   pc_application_exception pls_integer := -20000;
   application_exception exception;
   pragma exception_init(application_exception, -20000);

/*******************************************************************************
  NAME:      GET_CUSTOMER_HIERARCHY                                        PUBLIC
*******************************************************************************/
  function get_customer_hierarchy return tt_hierachy pipelined is
    -- This cursor generates the product level data in a flatterned table structure.
    cursor csr_customer_level_data is
      ;
    rv_cust_level csr_cust_level_data%rowtype; 
    -- Define the table structure for the product hierarchy.
    type tt_hierachy_collection is table of rt_hierarchy_node index by pls_integer;
    tv_hierarchy tt_hierachy_collection;
    v_counter pls_integer;
     
    -- This procedure looks through the existing node paths and checks if one already exists.  
    procedure add_path(i_cust_code in varchar2, i_cust_name in varchar2,i_parent_cust_code in varchar2,i_level in number) is
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
          if i_node_code = tv_hierarchy(v_counter).node_code then 
            v_found := true;
            -- Check that the parent node and name are the same.
            if i_node_name <> tv_hierarchy(v_counter).node_name or i_parent_node_code <> tv_hierarchy(v_counter).parent_node_code then 
              raise_application_error(pc_application_exception,'Node : ' || i_node_code || ' Node Name or Parenet Node Code did not match a previous instance.');
            end if;
          elsif i_node_code < tv_hierarchy(v_counter).node_code then 
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
        rv_node.node_code := i_node_code;
        rv_node.node_name := i_node_name;
        rv_node.parent_node_code := i_parent_node_code;
        rv_node.node_level := i_level;
        tv_hierarchy(v_counter) := rv_node;
      end if;
    end;
    
   begin
     -- Now process each of the rows of product data and build the hierarchy data in memory.
     open csr_cust_level_data;
     loop 
       fetch csr_cust_level_data into rv_cust_level;
       exit when csr_cust_level_data%notfound;
       -- Now process the material. 
       add_path('L1'||rv_product_level.level1,rv_product_level.level1_desc,null,1);
       add_path('L2'||rv_product_level.level1||rv_product_level.level2,rv_product_level.level2_desc,'L1'||rv_product_level.level1,2);
       add_path('L3'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3,rv_product_level.level3_desc,'L2'||rv_product_level.level1||rv_product_level.level2,3);
       add_path('L4'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4,rv_product_level.level4_desc,'L3'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3,4);
       add_path('L5'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4||rv_product_level.level5,rv_product_level.level5_desc,'L4'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4,5);
       add_material(rv_product_level.zrep_code,rv_product_level.zrep_desc,'L5'||rv_product_level.level1||rv_product_level.level2||rv_product_level.level3||rv_product_level.level4||rv_product_level.level5,6);
     end loop;
     close csr_cust_level_data;
     -- Now output the actual hierarchy rows. 
     v_counter := 0;
     loop 
       v_counter := v_counter + 1;
       exit when v_counter > tv_hierarchy.count;
       pipe row(tv_hierarchy(v_counter));
     end loop;
   end get_cust_hierarchy;  

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute is
      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('303001', 6, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '303001' -> ICRecordType
          pxi_common.char_format(node_code, 40, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- node_code -> Attribute
          pxi_common.char_format(node_name, 40, pxi_common.format_type_none, pxi_common.is_nullable) || -- node_name -> NodeName
          pxi_common.char_format(parent_node_code, 40, pxi_common.format_type_none, pxi_common.is_nullable) || -- parent_node_code -> ParrentAttribute
          pxi_common.char_format(material_code, 18, pxi_common.format_type_none, pxi_common.is_nullable) || -- material_code -> MaterialNumber
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) -- CONSTANT '149' -> PXDivisionCode
        ------------------------------------------------------------------------
        from 
          table(get_product_hierarchy);
        --======================================================================

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIPMX04');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX04_EXTRACT;
/
