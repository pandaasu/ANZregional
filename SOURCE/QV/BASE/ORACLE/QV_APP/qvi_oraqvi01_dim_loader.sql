/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_oraqvi01_dim_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_oraqvi01_dim_loader
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Material Hierarchy

    This package contain the Material Hierarchy dimension loader functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Created loader from templace

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qvi_oraqvi01_dim_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_oraqvi01_dim_loader as
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_ORAQVI01_DIM_LOADER';
   
   con_delimiter constant varchar2(32)  := ',';
   con_regexp_switch constant varchar2(4) := null; -- oracle regexp_like match_parameter
   con_trim_flag constant boolean := true;

   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Module name is fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   var_src_error boolean;

   -- Record Type 04, Material
   type rcd_rec04 is record (
    "Hierarchy Code"                varchar2(6),
    "Category Level"                number(2),
    "Material Code"                 varchar2(18),
    "Material"                      varchar2(40),
    "Sub Brand 3 Code"              varchar2(6),
    "Sub Brand 2 Code"              varchar2(6),
    "Sub Brand 1 Code"              varchar2(6),
    "Brand Code"                    varchar2(6),
    "Product Code"                  varchar2(6),
    "Market Code"                   varchar2(6),
    "Business Code"                 varchar2(6),
    "Top Level Code"                varchar2(6));
   type tab_typ_rec04 is table of rcd_rec04 index by binary_integer;
   array_rec04 tab_typ_rec04;

   -- Record Type 05, Category
   type rcd_rec05 is record (
    "Hierarchy Code"                varchar2(6),
    "Category Code"                 varchar2(6),
    "Category"                      varchar2(35),
    "Category Short"                varchar2(20),
    "Category Level"                number(2));
   type tab_typ_rec05 is table of rcd_rec05 index by varchar2(6);
   array_rec05 tab_typ_rec05;

   type rcd_hierarchy is record (
    "Hierarchy Code"                varchar2(6),
    "Category Level"                number(2),
    "Material Code"                 varchar2(18),
    "Sub Brand 3 Code"              varchar2(6),
    "Sub Brand 2 Code"              varchar2(6),
    "Sub Brand 1 Code"              varchar2(6),
    "Brand Code"                    varchar2(6),
    "Product Code"                  varchar2(6),
    "Market Code"                   varchar2(6),
    "Business Code"                 varchar2(6),
    "Top Level Code"                varchar2(6));
   type tab_typ_hierarchy is table of rcd_hierarchy index by varchar2(48);
   array_hierarchy tab_typ_hierarchy;
   
   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_START';
      var_statement_tag := null;

      /*-*/
      /* Initialise the package level variables
      /*-*/
      var_src_error := false;
      array_rec04.delete;
      array_rec05.delete;

      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('hierarchy_builder_material');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is
      /*-*/
      /* Local definitions
      /*-*/
      var_rec varchar2(4000);
      var_rec_type varchar2(256);
      var_rec_key varchar2(256);
      var_rec_header varchar2(256);
      var_hierarchy_key varchar2(256);
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_DATA';
      var_statement_tag := null;

      /*-*/
      /* Remove extraneous trailing whitespace (cr/lf/tab/etc..) from record
      /* and return is nothing to process
      /*-*/
      var_rec := regexp_replace(par_record,'[[:space:]]*$',null);
      if trim(var_rec) is null then
         return;
      end if;

      /*-*/
      /* Break out record type
      /*-*/
      var_rec_type := rtrim(substr(var_rec,1,8));
      
      /*-*/
      /* Return is not record type 01,04,05
      /*-*/
      if var_rec_type not in ('FPGL1 01', 'FPGL1 04', 'FPGL1 05') then
         return;
      end if;
      
      /*-*/
      /* Process record type 01 - Hierarchy 
      /*-*/
      if var_rec_type = 'FPGL1 01' then
         var_rec_header := 'FPGL1 01FPGL1 017FPPS Global (Dev)';
         if trim(substr(var_rec,1,length(trim(var_rec_header)))) != var_rec_header then
            lics_inbound_utility.add_exception('Record "'||var_rec||'" not recognised, expected "'||var_rec_header||'".');
            var_src_error := true;
         end if;
         return;
      end if;
      
      /*-*/
      /* Process record type 04 - Material 
      /*-*/
      if var_rec_type = 'FPGL1 04' then
         array_rec04(array_rec04.count+1)."Hierarchy Code" := qvi_util.get_validated_string(
            'Hierarchy Code',rtrim(substr(var_rec,1,6)),'Alphanumeric of 1 to 6 characters','^[[:alnum:]]{1,6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Category Level" := 0; -- material level
         array_rec04(array_rec04.count)."Material Code" := qvi_util.get_validated_string(
            'Material Code',rtrim(substr(var_rec,9,18)),'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Material" := qvi_util.get_validated_string(
            'Material',rtrim(substr(var_rec,27,40)),'String of 1 to 40 characters','^.{1,40}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Sub Brand 3 Code" := qvi_util.get_validated_string(
            'Sub Brand 3 Code',rtrim(substr(var_rec,67,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Sub Brand 2 Code" := qvi_util.get_validated_string(
            'Sub Brand 2 Code',rtrim(substr(var_rec,73,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Sub Brand 1 Code" := qvi_util.get_validated_string(
            'Sub Brand 1 Code',rtrim(substr(var_rec,79,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Brand Code" := qvi_util.get_validated_string(
            'Brand Code',rtrim(substr(var_rec,85,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Product Code" := qvi_util.get_validated_string(
            'Product Code',rtrim(substr(var_rec,91,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Market Code" := qvi_util.get_validated_string(
            'Market Code',rtrim(substr(var_rec,97,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Business Code" := qvi_util.get_validated_string(
            'Business Code',rtrim(substr(var_rec,103,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec04(array_rec04.count)."Top Level Code" := qvi_util.get_validated_string(
            'Top Level Code',rtrim(substr(var_rec,109,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         /*-*/
         /* Create hierarchy records .
         /*-*/
         var_hierarchy_key := rtrim(substr(var_rec,67,48));
         for idx in 1..8 loop
            var_rec_key := substr(var_hierarchy_key,((idx-1)*6)+1);
            array_hierarchy(var_rec_key)."Hierarchy Code" := array_rec04(array_rec04.count)."Hierarchy Code";
            /*-*/
            /* Set material code to lowest level hierarchy code 
            /*-*/
            if idx = 1 then  
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Sub Brand 3 Code";
            elsif idx = 2 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Sub Brand 2 Code";
            elsif idx = 3 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Sub Brand 1 Code";
            elsif idx = 4 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Brand Code";
            elsif idx = 5 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Product Code";
            elsif idx = 6 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Market Code";
            elsif idx = 7 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Business Code";
            elsif idx = 8 then 
                  array_hierarchy(var_rec_key)."Material Code" := array_rec04(array_rec04.count)."Top Level Code";
            end if;
            /*-*/
            /* Populate appropriate hierarchy codes  
            /*-*/
            array_hierarchy(var_rec_key)."Top Level Code" := array_rec04(array_rec04.count)."Top Level Code";
            if idx < 8 then
               array_hierarchy(var_rec_key)."Business Code" := array_rec04(array_rec04.count)."Business Code";
               if idx < 7 then
                  array_hierarchy(var_rec_key)."Market Code" := array_rec04(array_rec04.count)."Market Code";
                  if idx < 6 then
                     array_hierarchy(var_rec_key)."Product Code" := array_rec04(array_rec04.count)."Product Code";
                     if idx < 5 then
                        array_hierarchy(var_rec_key)."Brand Code" := array_rec04(array_rec04.count)."Brand Code";
                        if idx < 4 then
                           array_hierarchy(var_rec_key)."Sub Brand 1 Code" := array_rec04(array_rec04.count)."Sub Brand 1 Code";
                           if idx < 3 then
                              array_hierarchy(var_rec_key)."Sub Brand 2 Code" := array_rec04(array_rec04.count)."Sub Brand 2 Code";            
                              if idx < 2 then            
                                 array_hierarchy(var_rec_key)."Sub Brand 3 Code" := array_rec04(array_rec04.count)."Sub Brand 3 Code";
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end loop;
         return;
      end if;      
      
      /*-*/
      /* Process record type 05 - Category
      /*-*/
      if var_rec_type = 'FPGL1 05' then
         -- Record key
         var_rec_key := rtrim(substr(var_rec,9,6));
         array_rec05(var_rec_key)."Hierarchy Code" := qvi_util.get_validated_string(
            'Hierarchy Code',rtrim(substr(var_rec,1,6)),'Alphanumeric of 1 to 6 characters','^[[:alnum:]]{1,6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec05(var_rec_key)."Category Code" := qvi_util.get_validated_string(
            'Category Code',rtrim(substr(var_rec,9,6)),'Alphanumeric of 6 characters','^[[:alnum:]]{6}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec05(var_rec_key)."Category" := qvi_util.get_validated_string(
            'Category',rtrim(substr(var_rec,15,35)),'String of 1 to 35 characters','^[[:print:]|[:space:]]{1,35}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec05(var_rec_key)."Category Short" := qvi_util.get_validated_string(
            'Category Short',rtrim(substr(var_rec,50,20)),'String of 1 to 20 characters','^[[:print:]|[:space:]]{1,20}$',con_regexp_switch,con_trim_flag,var_src_error);
         array_rec05(var_rec_key)."Category Level" := to_number(qvi_util.get_validated_string(
            'Category Level',rtrim(substr(var_rec,70,2)),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',con_regexp_switch,con_trim_flag,var_src_error));
         return;
      end if;     

      /*-*/
      /* Exceptions raised in LICS_INBOUND_UTILITY
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_src_error := true;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_hierarchy_key varchar2(256);
      var_load_obj qvi_oraqvi01_dim_obj;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_END';
      var_statement_tag := null;

      /*-*/
      /* Rollback the database when required
      /*-*/
      if var_src_error = true then
         rollback;
         return;
      end if;

      /*-*/
      /* Add hierarchy dimension into materials (flattern hierarchy)
      /*-*/
      var_hierarchy_key := array_hierarchy.first;
      while var_hierarchy_key is not null loop
         array_rec04(array_rec04.count+1)."Hierarchy Code" := array_hierarchy(var_hierarchy_key)."Hierarchy Code";
         array_rec04(array_rec04.count)."Category Level" := array_rec05(array_hierarchy(var_hierarchy_key)."Material Code")."Category Level";
         array_rec04(array_rec04.count)."Material Code" := array_hierarchy(var_hierarchy_key)."Material Code";
         array_rec04(array_rec04.count)."Material" := array_rec05(array_hierarchy(var_hierarchy_key)."Material Code")."Category";
         array_rec04(array_rec04.count)."Sub Brand 3 Code" := array_hierarchy(var_hierarchy_key)."Sub Brand 3 Code";
         array_rec04(array_rec04.count)."Sub Brand 2 Code" := array_hierarchy(var_hierarchy_key)."Sub Brand 2 Code";
         array_rec04(array_rec04.count)."Sub Brand 1 Code" := array_hierarchy(var_hierarchy_key)."Sub Brand 1 Code";
         array_rec04(array_rec04.count)."Brand Code" := array_hierarchy(var_hierarchy_key)."Brand Code";
         array_rec04(array_rec04.count)."Product Code" := array_hierarchy(var_hierarchy_key)."Product Code";
         array_rec04(array_rec04.count)."Market Code" := array_hierarchy(var_hierarchy_key)."Market Code";
         array_rec04(array_rec04.count)."Business Code" := array_hierarchy(var_hierarchy_key)."Business Code";
         array_rec04(array_rec04.count)."Top Level Code" := array_hierarchy(var_hierarchy_key)."Top Level Code";
         var_hierarchy_key := array_hierarchy.next(var_hierarchy_key);
      end loop;
      
      /*-*/
      /* Load the dimension data
      /*-*/
      for idx in 1..array_rec04.count loop
         var_load_obj := qvi_oraqvi01_dim_obj(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
         var_load_obj."Hierarchy Code" := array_rec04(idx)."Hierarchy Code";
         var_load_obj."Category Level" := array_rec04(idx)."Category Level";
         var_load_obj."Material Code" := array_rec04(idx)."Material Code";
         var_load_obj."Material" := array_rec04(idx)."Material";
         if array_rec04(idx)."Sub Brand 3 Code" is not null then
            var_load_obj."Sub Brand 3 Code" := array_rec04(idx)."Sub Brand 3 Code";
            var_load_obj."Sub Brand 3" := array_rec05(array_rec04(idx)."Sub Brand 3 Code")."Category";
         end if;
         if array_rec04(idx)."Sub Brand 2 Code" is not null then
            var_load_obj."Sub Brand 2 Code" := array_rec04(idx)."Sub Brand 2 Code";
            var_load_obj."Sub Brand 2" := array_rec05(array_rec04(idx)."Sub Brand 2 Code")."Category";
         end if;
         if array_rec04(idx)."Sub Brand 1 Code" is not null then
            var_load_obj."Sub Brand 1 Code" := array_rec04(idx)."Sub Brand 1 Code";
            var_load_obj."Sub Brand 1" := array_rec05(array_rec04(idx)."Sub Brand 1 Code")."Category";
         end if;
         if array_rec04(idx)."Brand Code" is not null then
            var_load_obj."Brand Code" := array_rec04(idx)."Brand Code";
            var_load_obj."Brand" := array_rec05(array_rec04(idx)."Brand Code")."Category";
         end if;
         if array_rec04(idx)."Product Code" is not null then
            var_load_obj."Product Code" := array_rec04(idx)."Product Code";
            var_load_obj."Product" := array_rec05(array_rec04(idx)."Product Code")."Category";
         end if;
         if array_rec04(idx)."Market Code" is not null then
            var_load_obj."Market Code" := array_rec04(idx)."Market Code";
            var_load_obj."Market" := array_rec05(array_rec04(idx)."Market Code")."Category";
         end if;
         if array_rec04(idx)."Business Code" is not null then
            var_load_obj."Business Code" := array_rec04(idx)."Business Code";
            var_load_obj."Business" := array_rec05(array_rec04(idx)."Business Code")."Category";
         end if;
         var_load_obj."Top Level Code" := array_rec04(idx)."Top Level Code";
         var_load_obj."Top Level" := array_rec05(array_rec04(idx)."Top Level Code")."Category";
         
         qvi_dim_function.append_data(sys.anydata.ConvertObject(var_load_obj));
      end loop;
      
      /*-*/
      /* Finalise the loader and commit the database
      /*-*/
      qvi_dim_function.finalise_loader;
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;
   
end qvi_oraqvi01_dim_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on qvi_oraqvi01_dim_loader to lics_app;
