/******************/
/* Package Header */
/******************/
create or replace package cad_to_efex_cust_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : cad_to_efex_cust_loader
    Owner   : iface_app

    Description
    -----------
    CAD to EFEX data loader

    This package loads the CAD to Efex customer conversion data.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2);
   procedure process_user(par_cad_cust_data in iface.cad_to_efex_cust_master%rowtype);
   procedure process_customer(par_cad_cust_data in iface.cad_to_efex_cust_master%rowtype, var_distributor in varchar2);
   procedure write_log(par_type in varchar2, par_line in number, par_text in varchar2);

end cad_to_efex_cust_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body cad_to_efex_cust_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;
   con_snack_business_unit_id constant number := 5;
   con_pet_business_unit_id constant number := 6;
   con_icsf_segment_id constant number := 13;
   con_pcmm_segment_id constant number := 14;
   con_mtsf_segment_id constant number := 15;
   con_mtpc_segment_id constant number := 16;
   con_pcpc_segment_id constant number := 17;

   /*-*/
   /* Private definitions
   /*-*/
   var_log_type varchar2(32);
   var_log_line number;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_process boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_cad_cust_data is
         select t01.*
           from iface.cad_to_efex_cust_master t01;
      rcd_cad_cust_data csr_cad_cust_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the users (active)
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*USER' then
         var_log_type := 'CAD_ACTIVE_USER_LOAD';
         var_log_line := 0;
         delete from iface_log where log_type = var_log_type;
         commit;
         open csr_cad_cust_data;
         loop
            fetch csr_cad_cust_data into rcd_cad_cust_data;
            if csr_cad_cust_data%notfound then
               exit;
            end if;
            var_process := true;
            if rcd_cad_cust_data.business_unit_id is null then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team != 'MT' and rcd_cad_cust_data.sales_team != 'IC') then
               var_process := false;
            end if;
            if rcd_cad_cust_data.otl_status != 'A' then
               var_process := false;
            end if;
            if var_process = true then
               process_user(rcd_cad_cust_data);
            end if;
         end loop;
         close csr_cad_cust_data;
      end if;

      /*-*/
      /* Process the users (inactive)
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*USER' then
         var_log_type := 'CAD_INACTIVE_USER_LOAD';
         var_log_line := 0;
         delete from iface_log where log_type = var_log_type;
         commit;
         open csr_cad_cust_data;
         loop
            fetch csr_cad_cust_data into rcd_cad_cust_data;
            if csr_cad_cust_data%notfound then
               exit;
            end if;
            var_process := true;
            if rcd_cad_cust_data.business_unit_id is null then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team != 'MT' and rcd_cad_cust_data.sales_team != 'IC') then
               var_process := false;
            end if;
            if rcd_cad_cust_data.otl_status = 'A' then
               var_process := false;
            end if;
            if var_process = true then
               process_user(rcd_cad_cust_data);
            end if;
         end loop;
         close csr_cad_cust_data;
      end if;

      /*-*/
      /* Process the distributors (snack)
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*WHSLR' then
         var_log_type := 'CAD_SNACK_WHSLR_LOAD';
         var_log_line := 0;
         delete from iface_log where log_type = var_log_type;
         commit;
         open csr_cad_cust_data;
         loop
            fetch csr_cad_cust_data into rcd_cad_cust_data;
            if csr_cad_cust_data%notfound then
               exit;
            end if;
            var_process := true;
            if rcd_cad_cust_data.business_unit_id = 6 then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team != 'MT' and rcd_cad_cust_data.sales_team != 'IC' and rcd_cad_cust_data.sales_team != 'WS') then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team = 'WS' and rcd_cad_cust_data.outlet_flag = 'Y') then
               var_process := false;
            end if;
            if rcd_cad_cust_data.distributor_flag != 'Y' then
               var_process := false;
            end if;
            if var_process = true then
               process_customer(rcd_cad_cust_data, '5');
            end if;
         end loop;
         close csr_cad_cust_data;
      end if;

      /*-*/
      /* Process the distributors (pet)
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*WHSLR' then
         var_log_type := 'CAD_PET_WHSLR_LOAD';
         var_log_line := 0;
         delete from iface_log where log_type = var_log_type;
         commit;
         open csr_cad_cust_data;
         loop
            fetch csr_cad_cust_data into rcd_cad_cust_data;
            if csr_cad_cust_data%notfound then
               exit;
            end if;
            var_process := true;
            if rcd_cad_cust_data.business_unit_id = 5 then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team != 'IC' and rcd_cad_cust_data.sales_team != 'WS') then
               var_process := false;
            end if;
            if (rcd_cad_cust_data.sales_team = 'WS' and rcd_cad_cust_data.outlet_flag = 'Y') then
               var_process := false;
            end if;
            if rcd_cad_cust_data.distributor_flag != 'Y' then
               var_process := false;
            end if;
            if var_process = true then
               process_customer(rcd_cad_cust_data, '6');
            end if;
         end loop;
         close csr_cad_cust_data;
      end if;

      /*-*/
      /* Process the customers
      /*-*/
      if upper(par_action) = '*ALL' or upper(par_action) = '*CUST' then
         var_log_type := 'CAD_CUST_LOAD';
         var_log_line := 0;
         delete from iface_log where log_type = var_log_type;
         commit;
         open csr_cad_cust_data;
         loop
            fetch csr_cad_cust_data into rcd_cad_cust_data;
            if csr_cad_cust_data%notfound then
               exit;
            end if;
            var_process := true;
            if (rcd_cad_cust_data.sales_team != 'MT' and rcd_cad_cust_data.sales_team != 'IC') then
               var_process := false;
            end if;
            if rcd_cad_cust_data.distributor_flag = 'Y' then
               var_process := false;
            end if;
            if var_process = true then
               process_customer(rcd_cad_cust_data, 'N');
            end if;
         end loop;
         close csr_cad_cust_data;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CAD TO EFEX CONVERSION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /****************************************************/
   /* This procedure performs the process user routine */
   /****************************************************/
   procedure process_user(par_cad_cust_data in iface.cad_to_efex_cust_master%rowtype) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_save number;
      var_text varchar2(4000);
      var_business_unit_id number;
      var_segment_id number;
      var_user_id number;
      var_manager_id number;
      var_sales_region_id number;
      var_sales_area_id number;
      var_sales_territory_id number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_users is
         select t01.*,
                t02.sales_territory_id
           from users t01,
                sales_territory t02
          where t01.user_id = t02.user_id(+)
            and username = par_cad_cust_data.sales_prsn_code
          order by t02.sales_territory_id asc;
      rcd_users csr_users%rowtype;

      cursor csr_manager is
         select t01.*,
                t02.sales_area_id
           from users t01,
                sales_area t02
          where t01.user_id = t02.user_id(+)
            and username = par_cad_cust_data.line_mgr_code;
      rcd_manager csr_manager%rowtype;

      cursor csr_sales_region is
         select t01.*,
                t02.business_unit_id
           from sales_region t01,
                segment t02
          where t01.segment_id = t02.segment_id
            and t01.user_id = var_manager_id
          order by t01.sales_region_id asc;
      rcd_sales_region csr_sales_region%rowtype;

      cursor csr_sales_area is
         select t01.*
           from sales_area t01
          where t01.sales_region_id = var_sales_region_id
            and t01.user_id = var_manager_id
          order by t01.sales_area_id asc;
      rcd_sales_area csr_sales_area%rowtype;

      cursor csr_sales_territory is
         select t01.*
           from sales_territory t01
          where t01.sales_area_id = var_sales_area_id
            and t01.user_id = var_user_id
          order by t01.sales_territory_id asc;
      rcd_sales_territory csr_sales_territory%rowtype;

      cursor csr_user_sales_territory is
         select t01.*
           from user_sales_territory t01
          where t01.user_id = var_user_id
            and t01.sales_territory_id = var_sales_territory_id;
      rcd_user_sales_territory csr_user_sales_territory%rowtype;

      cursor csr_user_segment is
         select t01.*
           from user_segment t01
          where t01.user_id = var_user_id
            and t01.segment_id = var_segment_id;
      rcd_user_segment csr_user_segment%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log data
      /*-*/
      var_log_save := var_log_line;
      var_text := 'User ('||par_cad_cust_data.sales_prsn_code||') name ('||par_cad_cust_data.sales_prsn_name||')';

      /*-*/
      /* Set the business unit id and segment id
      /*-*/
      var_business_unit_id := null;
      var_segment_id := null;
      if not(par_cad_cust_data.business_unit_id is null) then
         var_business_unit_id := to_number(par_cad_cust_data.business_unit_id);
         if par_cad_cust_data.sales_team = 'MT' then
            var_segment_id := con_mtsf_segment_id;
         end if;
         if par_cad_cust_data.sales_team = 'IC' then
            if var_business_unit_id = con_snack_business_unit_id then
               var_segment_id := con_icsf_segment_id;
            end if;
            if var_business_unit_id = con_pet_business_unit_id then
               var_segment_id := con_pcmm_segment_id;
            end if;
         end if;
      end if;

      /*-*/
      /* Insert the log row when required
      /*-*/
      if var_business_unit_id is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no business unit id');
      end if;
      if (par_cad_cust_data.sales_team = 'MT' and
          var_business_unit_id != con_snack_business_unit_id) then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - sales team MT must be business unit id 5 (snack)');
      end if;
      if var_segment_id is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no segment id');
      end if;
      if par_cad_cust_data.sales_prsn_code is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no sales person code');
      end if;
      if par_cad_cust_data.sales_prsn_name is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no sales person name');
      end if;
      if par_cad_cust_data.line_mgr_code is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no line manager code');
      end if;
      if par_cad_cust_data.line_mgr_name is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no line manager name');
      end if;

      /*-*/
      /* Create the sales person when required
      /*-*/
      open csr_users;
      fetch csr_users into rcd_users;
      if csr_users%found then
         var_user_id := rcd_users.user_id;
         if rcd_users.status != 'A' then
            update users set status = 'A'
            where user_id = var_user_id;
         end if;
      else
         select users_seq.nextval into var_user_id from dual;
         insert into users
           (user_id,
            username,
            lastname,
            description,
            associate_code,
            market_id,
            status,
            modified_user,
            modified_date,
            city,
            business_unit_id)
           values(var_user_id,
                  par_cad_cust_data.sales_prsn_code,
                  par_cad_cust_data.sales_prsn_name,
                  par_cad_cust_data.sales_prsn_type,
                  par_cad_cust_data.sales_prsn_code,
                  con_market_id,
                  'A',
                  user,
                  sysdate,
                  par_cad_cust_data.sales_prsn_city_name,
                  var_business_unit_id);
      end if;
      close csr_users;

      /*-*/
      /* Create the line manager when required
      /*-*/
      open csr_manager;
      fetch csr_manager into rcd_manager;
      if csr_manager%found then
         var_manager_id := rcd_manager.user_id;
         if rcd_manager.status != 'A' then
            update users set status = 'A'
            where user_id = var_manager_id;
         end if;
      else
         select users_seq.nextval into var_manager_id from dual;
         insert into users
           (user_id,
            username,
            lastname,
            description,
            associate_code,
            market_id,
            status,
            modified_user,
            modified_date,
            city,
            business_unit_id)
           values(var_manager_id,
                  par_cad_cust_data.line_mgr_code,
                  par_cad_cust_data.line_mgr_name,
                  par_cad_cust_data.sales_team,
                  par_cad_cust_data.line_mgr_code,
                  con_market_id,
                  'A',
                  user,
                  sysdate,
                  par_cad_cust_data.sales_prsn_city_name,
                  var_business_unit_id);
      end if;
      close csr_manager;

      /*-*/
      /* Create the sales region when required
      /* 1. Based on manager name
      /*-*/
      open csr_sales_region;
      fetch csr_sales_region into rcd_sales_region;
      if csr_sales_region%found then
         var_sales_region_id := rcd_sales_region.sales_region_id;
         if rcd_sales_region.segment_id != var_segment_id then
            var_log_line := var_log_line + 1;
            write_log(var_log_type, var_log_line, var_text||' - manager already has a sales region in a differemt segment');
         end if;
         if rcd_sales_region.business_unit_id != var_business_unit_id then
            var_log_line := var_log_line + 1;
            write_log(var_log_type, var_log_line, var_text||' - manager already has a sales region in a differemt business unit');
         end if;
      else
         select sales_region_seq.nextval into var_sales_region_id from dual;
         insert into sales_region
           (sales_region_id,
            sales_region_name,
            sales_region_name_en,
            segment_id,
            user_id,
            status,
            modified_user,
            modified_date)
           values(var_sales_region_id,
                  par_cad_cust_data.line_mgr_name,
                  par_cad_cust_data.line_mgr_name,
                  var_segment_id,
                  var_manager_id,
                  'A',
                  user,
                  sysdate);
      end if;
      close csr_sales_region;

      /*-*/
      /* Create the sales area when required
      /* 1. Based on manager name
      /*-*/
      open csr_sales_area;
      fetch csr_sales_area into rcd_sales_area;
      if csr_sales_area%found then
         var_sales_area_id := rcd_sales_area.sales_area_id;
      else
         select sales_area_seq.nextval into var_sales_area_id from dual;
         insert into sales_area
           (sales_area_id,
            sales_area_name,
            sales_area_name_en,
            sales_region_id,
            user_id,
            status,
            modified_user,
            modified_date)
           values(var_sales_area_id,
                  par_cad_cust_data.line_mgr_name,
                  par_cad_cust_data.line_mgr_name,
                  var_sales_region_id,
                  var_manager_id,
                  'A',
                  user,
                  sysdate);
      end if;
      close csr_sales_area;

      /*-*/
      /* Create the sales territory when required
      /* 1. Based on user name
      /*-*/
      open csr_sales_territory;
      fetch csr_sales_territory into rcd_sales_territory;
      if csr_sales_territory%found then
         var_sales_territory_id := rcd_sales_territory.sales_territory_id;
      else
         select sales_territory_seq.nextval into var_sales_territory_id from dual;
         insert into sales_territory
           (sales_territory_id,
            sales_territory_name,
            sales_territory_name_en,
            sales_area_id,
            user_id,
            status,
            modified_user,
            modified_date)
           values(var_sales_territory_id,
                  par_cad_cust_data.sales_prsn_name,
                  par_cad_cust_data.sales_prsn_name,
                  var_sales_area_id,
                  var_user_id,
                  'A',
                  user,
                  sysdate);
      end if;
      close csr_sales_territory;

      /*-*/
      /* Create the user sales territory when required
      /*-*/
      open csr_user_sales_territory;
      fetch csr_user_sales_territory into rcd_user_sales_territory;
      if csr_user_sales_territory%notfound then
         insert into user_sales_territory
           (user_id,
            sales_territory_id,
            status,
            modified_user,
            modified_date)
           values(var_user_id,
                  var_sales_territory_id,
                  'A',
                  user,
                  sysdate);
      end if;
      close csr_user_sales_territory;

      /*-*/
      /* Create the user segment when required
      /*-*/
      open csr_user_segment;
      fetch csr_user_segment into rcd_user_segment;
      if csr_user_segment%notfound then
         insert into user_segment
           (user_id,
            segment_id,
            status,
            modified_user,
            modified_date)
           values(var_user_id,
                  var_segment_id,
                  'A',
                  user,
                  sysdate);
      end if;
      close csr_user_segment;

      /*-*/
      /* Commit/rollback the database
      /*-*/
      if var_log_save != var_log_line then
         rollback;
      else
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_user;

   /********************************************************/
   /* This procedure performs the process customer routine */
   /********************************************************/
   procedure process_customer(par_cad_cust_data in iface.cad_to_efex_cust_master%rowtype, var_distributor in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_save number;
      var_text varchar2(4000);
      var_business_unit_id number;
      var_user_id number;
      var_sales_territory_id number;
      var_cust_type_id number;
      var_cust_grade_id number;
      var_distributor_id number;
      var_affiliation_id number;
      var_geo_level1_code varchar2(10);
      var_geo_level2_code varchar2(10);
      var_geo_level3_code varchar2(10);
      var_geo_level4_code varchar2(10);
      var_geo_level5_code varchar2(10);
      var_std_level1_code varchar2(10);
      var_std_level2_code varchar2(10);
      var_std_level3_code varchar2(10);
      var_std_level4_code varchar2(10);
      var_customer_id number;
      var_cust_contact_id number;
      var_active_flg varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*
           from customer t01
          where t01.customer_code = par_cad_cust_data.otl_code;
      rcd_customer csr_customer%rowtype;

      cursor csr_users is
         select t02.*
           from users t01,
                sales_territory t02
          where t01.user_id = t02.user_id
            and t01.username = par_cad_cust_data.sales_prsn_code
          order by t01.user_id asc,
                   t02.sales_territory_id asc;
      rcd_users csr_users%rowtype;

      cursor csr_cust_type is
         select t01.*
           from cust_type t01,
                cust_trade_channel t02,
                cust_channel t03
          where t01.cust_trade_channel_id = t02.cust_trade_channel_id
            and t02.cust_channel_id = t03.cust_channel_id
            and t01.cust_type_name = par_cad_cust_data.outlet_type_name
            and t03.market_id = con_market_id
            and t03.business_unit_id = var_business_unit_id;
      rcd_cust_type csr_cust_type%rowtype;

      cursor csr_cust_trade_channel is
         select t01.*
           from cust_trade_channel t01,
                cust_channel t02
          where t01.cust_channel_id = t02.cust_channel_id
            and t01.cust_trade_channel_name = par_cad_cust_data.otl_chnl_name
            and t02.market_id = con_market_id
            and t02.business_unit_id = var_business_unit_id;
      rcd_cust_trade_channel csr_cust_trade_channel%rowtype;

      cursor csr_cust_grade is
         select t01.cust_grade_id
           from cust_grade t01
          where t01.cust_grade_name = nvl(par_cad_cust_data.sales_vol_range,'NA')
            and t01.market_id = con_market_id
            and t01.business_unit_id = var_business_unit_id;
      rcd_cust_grade csr_cust_grade%rowtype;

      cursor csr_distributor is
         select t01.*
           from customer t01
          where t01.customer_code = par_cad_cust_data.pur_from_wholesaler_code;
      rcd_distributor csr_distributor%rowtype;

      cursor csr_affiliation_indirect is
         select t01.*
           from affiliation t01
          where t01.affiliation_name = par_cad_cust_data.chain_store_banner_name;
      rcd_affiliation_indirect csr_affiliation_indirect%rowtype;

      cursor csr_affiliation_direct is
         select t01.*
           from affiliation t01
          where t01.affiliation_name = par_cad_cust_data.outlet_type_name;
      rcd_affiliation_direct csr_affiliation_direct%rowtype;

      cursor csr_geo_hierarchy is
         select t01.*
           from geo_hierarchy t01
          where t01.geo_level5_code = par_cad_cust_data.cust_city_code;
      rcd_geo_hierarchy csr_geo_hierarchy%rowtype;

      cursor csr_std_hierarchy is
         select t01.*
           from standard_hierarchy t01
          where t01.std_level4_code = par_cad_cust_data.chain_store_banner_code;
      rcd_std_hierarchy csr_std_hierarchy%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log data
      /*-*/
      var_log_save := var_log_line;
      var_text := 'Customer ('||par_cad_cust_data.otl_code||') name ('||par_cad_cust_data.otl_name||')';

      /*-*/
      /* Set the business unit id
      /*-*/
      var_business_unit_id := null;
      if var_distributor = 'N' then
         if not(par_cad_cust_data.business_unit_id is null) then
            var_business_unit_id := to_number(par_cad_cust_data.business_unit_id);
         end if;
      else
         var_business_unit_id := to_number(var_distributor);
      end if;

      /*-*/
      /* Insert the log row when required
      /*-*/
      if var_business_unit_id is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no business unit id');
      end if;
      if (par_cad_cust_data.sales_team = 'MT' and
          var_business_unit_id != con_snack_business_unit_id) then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - sales team MT must be business unit id 5 (snack)');
      end if;
      if (par_cad_cust_data.sales_team != 'WS' and
          par_cad_cust_data.pur_from_wholesaler_code is null) then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - sales team MT and IC must have a wholesaler code');
      end if;

      /*-*/
      /* Retrieve the sales person when required
      /*-*/
      var_user_id := null;
      var_sales_territory_id := null;
      if par_cad_cust_data.sales_team != 'WS' then
         open csr_users;
         fetch csr_users into rcd_users;
         if csr_users%found then
            var_user_id := rcd_users.user_id;
            var_sales_territory_id := rcd_users.sales_territory_id;
         else
            var_log_line := var_log_line + 1;
            write_log(var_log_type, var_log_line, var_text||' - user ('||par_cad_cust_data.sales_prsn_code||') does not exist');
         end if;
         close csr_users;
      end if;

      /*-*/
      /* Retrieve/create the cust type
      /*-*/
      var_cust_type_id := null;
      if par_cad_cust_data.outlet_type_name is null then
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - has no outlet type name');
      else
         open csr_cust_type;
         fetch csr_cust_type into rcd_cust_type;
         if csr_cust_type%found then
            var_cust_type_id := rcd_cust_type.cust_type_id;
         else
            open csr_cust_trade_channel;
            fetch csr_cust_trade_channel into rcd_cust_trade_channel;
            if csr_cust_trade_channel%found then
               select cust_type_seq.nextval into var_cust_type_id from dual;
               insert into cust_type
                 (cust_type_id,
                  cust_type_name,
                  cust_type_name_en,
                  cust_trade_channel_id,
                  status,
                  modified_user,
                  modified_date)
                 values(var_cust_type_id,
                        par_cad_cust_data.outlet_type_name,
                        par_cad_cust_data.outlet_type_name,
                        rcd_cust_trade_channel.cust_trade_channel_id,
                        'A',
                        user,
                        sysdate);
               commit;
            else
               var_log_line := var_log_line + 1;
               write_log(var_log_type, var_log_line, var_text||' - customer type ('||par_cad_cust_data.outlet_type_name||') does not exist AND customer trade channel ('||par_cad_cust_data.otl_chnl_name||') does not exist');
            end if;
            close csr_cust_trade_channel;
         end if;
         close csr_cust_type;
      end if;

      /*-*/
      /* Retrieve the cust grade
      /*-*/
      var_cust_grade_id := null;
      open csr_cust_grade;
      fetch csr_cust_grade into rcd_cust_grade;
      if csr_cust_grade%found then
         var_cust_grade_id := rcd_cust_grade.cust_grade_id;
      end if;
      close csr_cust_grade;

      /*-*/
      /* Retrieve the distributor when required
      /*-*/
      var_distributor_id := null;
      if not(par_cad_cust_data.pur_from_wholesaler_code is null) then
         open csr_distributor;
         fetch csr_distributor into rcd_distributor;
         if csr_distributor%found then
            var_distributor_id := rcd_distributor.customer_id;
         else
            if par_cad_cust_data.outlet_flag = 'Y' then
               var_log_line := var_log_line + 1;
               write_log(var_log_type, var_log_line, var_text||' - distributor ('||par_cad_cust_data.pur_from_wholesaler_code||') not found on customer table');
            end if;
         end if;
         close csr_distributor;
      end if;

      /*-*/
      /* Retrieve the affiliation when required (indirect customer)
      /*-*/
      if par_cad_cust_data.outlet_flag = 'Y' then
         var_affiliation_id := null;
         var_std_level1_code := null;
         var_std_level2_code := null;
         var_std_level3_code := null;
         var_std_level4_code := null;
         open csr_affiliation_indirect;
         fetch csr_affiliation_indirect into rcd_affiliation_indirect;
         if csr_affiliation_indirect%found then
            var_affiliation_id := rcd_affiliation_indirect.affiliation_id;
         else
            var_log_line := var_log_line + 1;
            write_log(var_log_type, var_log_line, var_text||' - affiliation ('||par_cad_cust_data.chain_store_banner_name||') not found on affiliation table');
         end if;
         close csr_affiliation_indirect;
      end if;

      /*-*/
      /* Retrieve the standard hierarchy when required (direct customer)
      /*-*/
      if par_cad_cust_data.outlet_flag = 'N' then
         var_affiliation_id := null;
         var_std_level1_code := null;
         var_std_level2_code := null;
         var_std_level3_code := null;
         var_std_level4_code := null;
         if par_cad_cust_data.distributor_flag = 'Y' then
            open csr_affiliation_direct;
            fetch csr_affiliation_direct into rcd_affiliation_direct;
            if csr_affiliation_direct%found then
               var_affiliation_id := rcd_affiliation_direct.affiliation_id;
            else
               var_log_line := var_log_line + 1;
               write_log(var_log_type, var_log_line, var_text||' - affiliation ('||par_cad_cust_data.outlet_type_name||') not found on affiliation table');
            end if;
            close csr_affiliation_direct;
         end if;
         open csr_std_hierarchy;
         fetch csr_std_hierarchy into rcd_std_hierarchy;
         if csr_std_hierarchy%found then
            var_std_level1_code := rcd_std_hierarchy.std_level1_code;
            var_std_level2_code := rcd_std_hierarchy.std_level2_code;
            var_std_level3_code := rcd_std_hierarchy.std_level3_code;
            var_std_level4_code := rcd_std_hierarchy.std_level4_code;
         else
            var_log_line := var_log_line + 1;
            write_log(var_log_type, var_log_line, var_text||' - standard hierarchy level 4 ('||par_cad_cust_data.chain_store_banner_code||') not found on standard hierarchy table');
         end if;
         close csr_std_hierarchy;
      end if;

      /*-*/
      /* Retrieve the geo hierarchy when required
      /*-*/
      var_geo_level1_code := null;
      var_geo_level2_code := null;
      var_geo_level3_code := null;
      var_geo_level4_code := null;
      var_geo_level5_code := null;
      open csr_geo_hierarchy;
      fetch csr_geo_hierarchy into rcd_geo_hierarchy;
      if csr_geo_hierarchy%found then
         var_geo_level1_code := rcd_geo_hierarchy.geo_level1_code;
         var_geo_level2_code := rcd_geo_hierarchy.geo_level2_code;
         var_geo_level3_code := rcd_geo_hierarchy.geo_level3_code;
         var_geo_level4_code := rcd_geo_hierarchy.geo_level4_code;
         var_geo_level5_code := rcd_geo_hierarchy.geo_level5_code;
      else
         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - geo hierarchy level 5 ('||par_cad_cust_data.cust_city_code||') not found on geo hierarchy table');
      end if;
      close csr_geo_hierarchy;

      /*-*/
      /* Create the customer when required
      /*
      /* Create the customer contact data when required
      /* 1. What to use email or fax
      /*
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%found then

         var_log_line := var_log_line + 1;
         write_log(var_log_type, var_log_line, var_text||' - customer already exists on customer table');

      else

         if par_cad_cust_data.otl_status = 'A' then
            var_active_flg := 'Y';
         else
            var_active_flg := 'N';
         end if;

         select customer_seq.nextval into var_customer_id from dual;
         insert into customer
           (customer_id,
            customer_code,
            customer_name,
            customer_name_en,
            address_1,
            city,
            postcode,
            distributor_flg,
            outlet_flg,
            active_flg,
            market_id,
            cust_type_id,
            affiliation_id,
            distributor_id,
            cust_grade_id,
            status,
            modified_user,
            modified_date,
            setup_date,
            setup_person,
            outlet_location,
            geo_level1_code,
            geo_level2_code,
            geo_level3_code,
            geo_level4_code,
            geo_level5_code,
            std_level1_code,
            std_level2_code,
            std_level3_code,
            std_level4_code,
            business_unit_id)
           values(var_customer_id,
                  par_cad_cust_data.otl_code,
                  par_cad_cust_data.otl_name,
                  par_cad_cust_data.otl_name,
                  par_cad_cust_data.otl_addr,
                  par_cad_cust_data.cust_city_name,
                  par_cad_cust_data.post_code,
                  par_cad_cust_data.distributor_flag,
                  par_cad_cust_data.outlet_flag,
                  var_active_flg,
                  con_market_id,
                  var_cust_type_id,
                  var_distributor_id,
                  var_affiliation_id,
                  var_cust_grade_id,
                  'A',
                  user,
                  sysdate,
                  par_cad_cust_data.otl_crdt,
                  par_cad_cust_data.otl_lupdp,
                  par_cad_cust_data.outlet_loc,
                  var_geo_level1_code,
                  var_geo_level2_code,
                  var_geo_level3_code,
                  var_geo_level4_code,
                  var_geo_level5_code,
                  var_std_level1_code,
                  var_std_level2_code,
                  var_std_level3_code,
                  var_std_level4_code,
                  var_business_unit_id);

         if par_cad_cust_data.sales_team != 'WS' then
            if par_cad_cust_data.otl_status = 'A' then
               insert into cust_sales_territory
                 (customer_id,
                  sales_territory_id,
                  status,
                  modified_user,
                  modified_date,
                  primary_flg)
                 values(var_customer_id,
                        var_sales_territory_id,
                        'A',
                        user,
                        sysdate,
                        'Y');
            end if;
         end if;

         if not(par_cad_cust_data.cont_name) is null then
            select cust_contact_seq.nextval into var_cust_contact_id from dual;
            insert into cust_contact
              (cust_contact_id,
               last_name,
               phone_number,
               email_address,
               status,
               customer_id,
               modified_user,
               modified_date)
              values(var_cust_contact_id,
                     par_cad_cust_data.cont_name,
                     par_cad_cust_data.cont_tel,
                     par_cad_cust_data.cont_fax,
                     var_customer_id,
                     'A',
                     user,
                     sysdate);
         end if;

         if (not(par_cad_cust_data.pur_from_wholesaler_code is null) and
             not(par_cad_cust_data.cust_otl_code is null)) then
            insert into distributor_cust
              (distributor_id,
               customer_id,
               distcust_code,
               status,
               modified_user,
               modified_date)
              values(var_distributor_id,
                     var_customer_id,
                     par_cad_cust_data.cust_otl_code,
                     'A',
                     user,
                     sysdate);
         end if;

      end if;
      close csr_customer;

      /*-*/
      /* Commit/rollback the database
      /*-*/
      if var_log_save != var_log_line then
         rollback;
      else
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_customer;

   /*************************************************/
   /* This procedure performs the write log routine */
   /*************************************************/
   procedure write_log(par_type in varchar2, par_line in number, par_text in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the log row
      /*-*/
      insert into iface_log values(par_type, par_line, sysdate, par_text);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end write_log;

end cad_to_efex_cust_loader;
/
