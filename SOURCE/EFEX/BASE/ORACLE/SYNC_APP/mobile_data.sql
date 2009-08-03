/******************/
/* Package Header */
/******************/
create or replace package mobile_data as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : mobile_data
    Owner   : sync_app

    Description
    -----------
    Efex - Synchronisation - Mobile Data

    This package contains the Efex synchronisation for mobile data.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/07   Steve Gregan   Created
    2008/10   Steve Gregan   Added the customer code to the customer list and data
    2009/05   Toui Lepkhammany Fix the xslProcessor.valueOf() issue by including /text() to the namespace.
    2009/06   Steve Gregan   China sales dedication - included business unit id in geographic hierarchy retrieval
                             Included existing distribution total in the call download
                             Included range update for customer update with customer type change
                             Fix oracle 10G cdata issue
    2009/08   Steve Gregan   Included BANNER and CHANNEL in customer communication selection

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function authenticate_session(par_username in varchar2, par_password in varchar2) return varchar2;
   procedure destroy_session(par_result in varchar2);
   procedure put_buffer(par_buffer in varchar2);
   function get_mobile_data return mobile_stream pipelined;
   function get_customer_call(par_customer_id in varchar2) return mobile_stream pipelined;
   function get_customer_data(par_customer_id in varchar2) return mobile_stream pipelined;
   function get_communication_list return mobile_code_table pipelined;
   procedure put_mobile_data;
   function mobile_to_timezone(par_date in date) return date;

end mobile_data;
/

/****************/
/* Package Body */
/****************/
create or replace package body mobile_data as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_timezone varchar2(64) := 'Asia/Shanghai';
   con_icsf_sync_group_id constant number := 23;
   con_pcmm_sync_group_id constant number := 24;
   con_icsf_segment_id constant number := 13;
   con_pcmm_segment_id constant number := 14;
   con_snack_business_unit_id constant number := 5;
   con_pet_business_unit_id constant number := 6;
   con_user_comm_type_id constant number := 4;
   con_customer_comm_type_id constant number := 5;
   con_status_active constant varchar2(1) := 'A';
   con_status_inactive constant varchar2(1) := 'X';
   con_uom_default constant varchar2(50) := 'RSU';
   con_list_uom varchar2(50) := 'CHN_UOM';
   con_list_cust_location varchar2(50) := 'CHN_CUST_LOCATION';

   /*-*/
   /* Private definitions
   /*-*/
   var_auth_user_id number;
   var_auth_username varchar2(10);
   var_auth_firstname varchar2(50);
   var_auth_lastname varchar2(50);
   var_auth_market_id number;
   var_auth_business_unit_id number;
   var_auth_city varchar2(50);
   var_auth_sync_log_id number;
   var_clob clob;
   type rcd_customer is record(new_code varchar2(20), new_id number);
   type typ_customer is table of rcd_customer index by binary_integer;
   tbl_customer typ_customer;
   rcd_device device%rowtype;
   rcd_sync_log sync_log%rowtype;
   upd_call call%rowtype;
   upd_distribution_total distribution_total%rowtype;
   upd_distribution distribution%rowtype;
   upd_orders orders%rowtype;
   upd_order_item order_item%rowtype;
   upd_display_distribution display_distribution%rowtype;
   upd_activity_distribution activity_distribution%rowtype;
   upd_customer customer%rowtype;
   upd_cust_contact cust_contact%rowtype;
   upd_cust_sales_territory cust_sales_territory%rowtype;

   /*-*/
   /* Private declarations
   /*-*/
   procedure get_call_data(par_route_plan_order in number, par_type in varchar2, par_customer_id in number);
   procedure update_call_data(par_order_flag in varchar2);
   procedure update_distribution_data;
   procedure update_orders_data;
   procedure update_order_item_data;
   procedure update_display_data;
   procedure update_activity_data;
   procedure update_customer_data;
   procedure create_customer_data(par_customer_id in varchar2);
   function mobile_get_customer_id(par_source in varchar2) return number;
   function mobile_to_number(par_number in varchar2) return number;
   function mobile_to_date(par_date in varchar2, par_format in varchar2) return date;
   procedure mobile_event(par_status in varchar2, par_connected varchar2);

   /**************************************************************/
   /* This procedure performs the authentication session routine */
   /**************************************************************/
   function authenticate_session(par_username in varchar2, par_password in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_result varchar2(256 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_users is
         select t01.*
           from users t01
          where t01.username = upper(par_username);
      rcd_users csr_users%rowtype;

      cursor csr_sync_user is
         select t01.*
           from sync_user t01
          where t01.user_id = rcd_users.user_id;
      rcd_sync_user csr_sync_user%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the authenticated user
      /*-*/
      var_auth_user_id := -1;
      var_auth_username := null;
      var_auth_firstname := null;
      var_auth_lastname := null;
      var_auth_market_id := null;
      var_auth_business_unit_id := null;
      var_auth_city := null;
      var_auth_sync_log_id := null;

      /*-*/
      /* Retrieve the authenticated user data when required
      /*-*/
      /*-*/
      /* Authenticate the user
      /* **notes** 1. User must exist
      /*           2. User must be enabled
      /*           3. User must be in valid business unit
      /*-*/
      var_result := '*OK';
      open csr_users;
      fetch csr_users into rcd_users;
      if csr_users%notfound then
         var_result := 'User ('||upper(par_username)||') does not exist';
      else
         if rcd_users.status != 'A' then
            var_result := 'User ('||upper(par_username)||') is not active';
         else
            if rcd_users.business_unit_id != con_snack_business_unit_id and
               rcd_users.business_unit_id != con_pet_business_unit_id then
               var_result := 'User ('||upper(par_username)||') business unit is invalid';
            end if;
         end if;
      end if;
      close csr_users;

      /*-*/
      /* Authenticate the synchronization user
      /* **notes** 1. Synchronization user must exist
      /*           2. Synchronization group must be valid
      /*           3. Synchronization user must be enabled
      /*           4. Synchronization password must be valid
      /*-*/
      if var_result = '*OK' then
         open csr_sync_user;
         fetch csr_sync_user into rcd_sync_user;
         if csr_sync_user%notfound then
            var_result := 'User ('||upper(par_username)||') synchronization account does not exist';
         else
            if rcd_sync_user.sync_group_id != con_icsf_sync_group_id and
               rcd_sync_user.sync_group_id != con_pcmm_sync_group_id then
               var_result := 'User ('||upper(par_username)||') synchronization group is invalid';
            elsif rcd_sync_user.account_disabled = 'Y' then
               var_result := 'User ('||upper(par_username)||') synchronization account is disabled';
            elsif rcd_users.business_unit_id = con_snack_business_unit_id and
                  rcd_sync_user.sync_group_id != con_icsf_sync_group_id then
               var_result := 'User ('||upper(par_username)||') synchronization group is invalid for the user business unit';
            elsif rcd_users.business_unit_id = con_pet_business_unit_id and
                  rcd_sync_user.sync_group_id != con_pcmm_sync_group_id then
               var_result := 'User ('||upper(par_username)||') synchronization group is invalid for the user business unit';
            else
               if trim(rcd_sync_user.password) != trim(par_password) then
                  var_result := 'User ('||upper(par_username)||') synchronization password is invalid';
                  if rcd_sync_user.lockout_count >= 2 then
                     update sync_user set account_disabled = 'Y', lockout_count = lockout_count + 1 where user_id = rcd_sync_user.user_id;
                  else
                     update sync_user set lockout_count = lockout_count + 1 where user_id = rcd_sync_user.user_id;
                  end if;
               end if;
            end if;
         end if;
         close csr_sync_user;
      end if;

      /*-*/
      /* Authentication successfull
      /*-*/
      if var_result = '*OK' then

         /*-*/
         /* Insert/update the device when required
         /*-*/
         rcd_device.device_serial_num := 'EFEX_MOBILE_'||upper(rcd_users.username);
         rcd_device.device_service_tag := null;
         rcd_device.device_type := 'Mobile Phone';
         rcd_device.os_type := 'Java ME';
         rcd_device.os_version := 'MIDP 2.0';
         rcd_device.total_memory := 0;
         rcd_device.available_memory := 0;
         rcd_device.timezone := 'N/A';
         rcd_device.region := 'N/A';
         rcd_device.last_user_id := rcd_users.user_id;
         rcd_device.status := 'A';
         begin
            insert into device
               (device_serial_num,
                device_service_tag,
                device_type,
                os_type,
                os_version,
                total_memory,
                available_memory,
                timezone,
                region,
                last_user_id,
                status)
               values(rcd_device.device_serial_num,
                      rcd_device.device_service_tag,
                      rcd_device.device_type,
                      rcd_device.os_type,
                      rcd_device.os_version,
                      rcd_device.total_memory,
                      rcd_device.available_memory,
                      rcd_device.timezone,
                      rcd_device.region,
                      rcd_device.last_user_id,
                      rcd_device.status);
         exception
            when dup_val_on_index then
               update device
                  set last_user_id = rcd_device.last_user_id,
                      status = rcd_device.status
                where device_serial_num = rcd_device.device_serial_num;
         end;

         /*-*/
         /* Insert the synchronization log row
         /*-*/
         select sync_log_seq.nextval into rcd_sync_log.sync_log_id from dual;
         rcd_sync_log.user_id := rcd_users.user_id;
         rcd_sync_log.device_serial_num := rcd_device.device_serial_num;
         rcd_sync_log.connect_datime := mobile_to_timezone(sysdate);
         rcd_sync_log.online_secs := 0;
         rcd_sync_log.status_text := 'Mobile session connected';
         rcd_sync_log.connected_flg := 'Y';
         insert into sync_log
            (sync_log_id,
             user_id,
             device_serial_num,
             connect_datime,
             online_secs,
             status_text,
             connected_flg)
            values(rcd_sync_log.sync_log_id,
                   rcd_sync_log.user_id,
                   rcd_sync_log.device_serial_num,
                   rcd_sync_log.connect_datime,
                   rcd_sync_log.online_secs,
                   rcd_sync_log.status_text,
                   rcd_sync_log.connected_flg);

         /*-*/
         /* Set the authenticated user data
         /*-*/
         var_auth_user_id := rcd_users.user_id;
         var_auth_username := rcd_users.username;
         var_auth_firstname := rcd_users.firstname;
         var_auth_lastname := rcd_users.lastname;
         var_auth_market_id := rcd_users.market_id;
         var_auth_business_unit_id := rcd_users.business_unit_id;
         var_auth_city := rcd_users.city;
         var_auth_sync_log_id := rcd_sync_log.sync_log_id;

      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

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
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - AUTHENTICATE_SESSION - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end authenticate_session;

   /*******************************************************/
   /* This procedure performs the destory session routine */
   /*******************************************************/
   procedure destroy_session(par_result in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the event
      /*-*/
      if par_result = '*OK' then
         mobile_event('Mobile session completed', 'N');
      else
         mobile_event('Mobile session failed', 'N');
      end if;

      /*-*/
      /* Reset the authenticated user
      /*-*/
      var_auth_user_id := -1;
      var_auth_username := null;
      var_auth_firstname := null;
      var_auth_lastname := null;
      var_auth_market_id := null;
      var_auth_business_unit_id := null;
      var_auth_city := null;
      var_auth_sync_log_id := null;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - DESTROY_SESSION - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end destroy_session;

   /**************************************************/
   /* This procedure performs the put buffer routine */
   /**************************************************/
   procedure put_buffer(par_buffer in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the buffer
      /*-*/
      if par_buffer = '*STR' then
         if var_clob is null then
            dbms_lob.createtemporary(var_clob,true,dbms_lob.session);
         end if;
         dbms_lob.trim(var_clob,0);
      else
         dbms_lob.writeappend(var_clob,length(par_buffer),par_buffer);
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - PUT_BUFFER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_buffer;

   /*******************************************************/
   /* This procedure performs the get mobile data routine */
   /*******************************************************/
   function get_mobile_data return mobile_stream pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_buffer_data varchar2(2000 char);
      var_buffer_size binary_integer := 2000;
      var_buffer_pointer integer := 1;
      var_exception varchar2(4000);
      var_output varchar2(2000 char);
      var_called boolean;
      var_ordered boolean;
      var_display_qty distribution.display_qty%type;
      var_facing_qty distribution.facing_qty%type;
      var_inventory_qty distribution.inventory_qty%type;
      var_order_qty order_item.order_qty%type;
      var_order_uom order_item.uom%type;
      var_display_in_store display_distribution.display_in_store%type;
      var_activity_in_store activity_distribution.activity_in_store%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_route is
         select t01.user_id,
                t01.route_plan_date,
                t01.route_plan_order,
                t01.customer_id
           from route_plan t01,
                customer t02
          where t01.customer_id = t02.customer_id
            and t01.user_id = var_auth_user_id
            and trunc(t01.route_plan_date) = trunc(mobile_to_timezone(sysdate))
            and t01.status = 'A'
            and t02.active_flg = 'Y'
            and t02.business_unit_id = var_auth_business_unit_id
          order by t01.route_plan_order asc;
      rcd_route csr_route%rowtype;

      cursor csr_customer is
         select t01.*,
                decode(t01.active_flg,'Y','A','N','X',t01.active_flg) as active_status
           from customer t01,
                (select distinct(t02.customer_id) as customer_id
                   from user_sales_territory t01,
                        cust_sales_territory t02
                  where t01.sales_territory_id = t02.sales_territory_id
                    and t01.user_id = var_auth_user_id
                    and t01.status = 'A'
                    and t02.status = 'A') t02
          where t01.customer_id = t02.customer_id
            and (t01.distributor_flg is null or t01.distributor_flg = 'N')
            and t01.status = 'A'
            and t01.active_flg = 'Y'
            and t01.business_unit_id = var_auth_business_unit_id
          order by t01.customer_name;
      rcd_customer csr_customer%rowtype;

      cursor csr_comm is
         select t01.comm_id,
                t01.comm_title,
                t01.comm_text,
                t01.modified_user comm_author,
                to_char(t01.modified_date,'dd/mm/yyyy') comm_date
           from comm t01
          where t01.comm_id in (select distinct(record_id) from table(mobile_data.get_communication_list))
          order by t01.comm_type asc,
                   t01.comm_id asc;
      rcd_comm csr_comm%rowtype;

      cursor csr_uom is
         select t01.list_value_name,
                t01.list_value_text
           from list_values t01
          where t01.list_type = con_list_uom
            and t01.status = 'A'
            and t01.market_id = var_auth_market_id
            and t01.business_unit_id = var_auth_business_unit_id
          order by t01.list_value_order asc;
      rcd_uom csr_uom%rowtype;

      cursor csr_cust_location is
         select t01.list_value_name,
                t01.list_value_text
           from list_values t01
          where t01.list_type = con_list_cust_location
            and t01.status = 'A'
            and t01.market_id = var_auth_market_id
            and t01.business_unit_id = var_auth_business_unit_id
          order by t01.list_value_order asc;
      rcd_cust_location csr_cust_location%rowtype;

      cursor csr_cust_type is
         select t01.*
           from cust_type t01,
                cust_trade_channel t02,
                cust_channel t03
          where t01.cust_trade_channel_id = t02.cust_trade_channel_id
            and t02.cust_channel_id = t03.cust_channel_id
            and t01.status = 'A'
            and t02.status = 'A'
            and t03.status = 'A'
            and t03.market_id = var_auth_market_id
            and t03.business_unit_id = var_auth_business_unit_id
          order by t01.cust_type_name asc;
      rcd_cust_type csr_cust_type%rowtype;

      cursor csr_cust_trade_channel is
         select t01.*
           from cust_trade_channel t01,
                cust_channel t02
          where t01.cust_channel_id = t02.cust_channel_id
            and t01.status = 'A'
            and t02.status = 'A'
            and t02.market_id = var_auth_market_id
            and t02.business_unit_id = var_auth_business_unit_id
          order by t01.cust_trade_channel_name asc;
      rcd_cust_trade_channel csr_cust_trade_channel%rowtype;

      cursor csr_distributor is
         select t01.customer_id,
                t01.customer_name
           from customer t01,
                (select distinct(t01.distributor_id) as distributor_id
                   from customer t01,
                        (select distinct(t02.customer_id) as customer_id
                           from user_sales_territory t01,
                                cust_sales_territory t02
                          where t01.sales_territory_id = t02.sales_territory_id
                            and t01.user_id = var_auth_user_id
                            and t01.status = 'A'
                            and t02.status = 'A') t02
                  where t01.customer_id = t02.customer_id
                    and t01.status = 'A') t02
          where t01.customer_id = t02.distributor_id
            and t01.status = 'A'
          order by t01.customer_name asc;
      rcd_distributor csr_distributor%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* User not authenticated
      /*-*/
      if var_auth_user_id = -1 then
         raise_application_error(-20000, 'User has not been authenticated');
      end if;

      /*-*/
      /* Create the XML temporary CLOB
      /*-*/
      if var_clob is null then
         dbms_lob.createtemporary(var_clob,true,dbms_lob.session);
      end if;
      dbms_lob.trim(var_clob,0);
      dbms_lob.writeappend(var_clob,length('<?xml version="1.0" encoding="UTF-8"?>'),'<?xml version="1.0" encoding="UTF-8"?>');

      /*-*/
      /* Open the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('<EFEX>'),'<EFEX>');

      /*-*/
      /* Output the control
      /*-*/
      var_output := '<CTL>';
      var_output := var_output||'<CTL_USER_FIRSTNAME><![CDATA[' || var_auth_firstname || ']]></CTL_USER_FIRSTNAME>';
      var_output := var_output||'<CTL_USER_LASTNAME><![CDATA[' || var_auth_lastname || ']]></CTL_USER_LASTNAME>';
      var_output := var_output||'<CTL_MOBILE_DATE><![CDATA[' || to_char(mobile_to_timezone(sysdate),'yyyy/mm/dd') || ']]></CTL_MOBILE_DATE>';
      var_output := var_output||'<CTL_MOBILE_STATUS><![CDATA[' || '*LOADED' || ']]></CTL_MOBILE_STATUS>';
      var_output := var_output||'<CTL_MOBILE_LOADED_TIME><![CDATA[' || to_char(mobile_to_timezone(sysdate),'yyyy/mm/dd hh24:mi:ss') || ']]></CTL_MOBILE_LOADED_TIME>';
      var_output := var_output||'<CTL_MOBILE_SAVED_TIME><![CDATA[' || '*NOT SAVED' || ']]></CTL_MOBILE_SAVED_TIME>';
      var_output := var_output||'</CTL>';
      dbms_lob.writeappend(var_clob,length(var_output),var_output);

      /*-*/
      /* Retrieve the route customer call data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<RTE>'),'<RTE>');
      open csr_route;
      loop
         fetch csr_route into rcd_route;
         if csr_route%notfound then
            exit;
         end if;
         get_call_data(rcd_route.route_plan_order,'*ROUTE',rcd_route.customer_id);
      end loop;
      close csr_route;
      dbms_lob.writeappend(var_clob,length('</RTE>'),'</RTE>');

      /*-*/
      /* Retrieve the non-route customers
      /*-*/
      dbms_lob.writeappend(var_clob,length('<CUS_LIST>'),'<CUS_LIST>');
      open csr_customer;
      loop
         fetch csr_customer into rcd_customer;
         if csr_customer%notfound then
            exit;
         end if;
         var_output := '<CUS>';
         var_output := var_output||'<CUS_DATA_TYPE><![CDATA[' || '*OLD' || ']]></CUS_DATA_TYPE>';
         var_output := var_output||'<CUS_DATA_ACTION><![CDATA[' || '*NONE' || ']]></CUS_DATA_ACTION>';
         var_output := var_output||'<CUS_CUSTOMER_ID><![CDATA[' || to_char(rcd_customer.customer_id) || ']]></CUS_CUSTOMER_ID>';
         var_output := var_output||'<CUS_CODE><![CDATA[' || rcd_customer.customer_code || ']]></CUS_CODE>';
         var_output := var_output||'<CUS_NAME><![CDATA[' || rcd_customer.customer_name || ']]></CUS_NAME>';
         var_output := var_output||'<CUS_STATUS><![CDATA[' || rcd_customer.active_status || ']]></CUS_STATUS>';
         var_output := var_output||'</CUS>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_customer;
      dbms_lob.writeappend(var_clob,length('</CUS_LIST>'),'</CUS_LIST>');

      /*-*/
      /* Retrieve the communication data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<MSG_LIST>'),'<MSG_LIST>');
      open csr_comm;
      loop
         fetch csr_comm into rcd_comm;
         if csr_comm%notfound then
            exit;
         end if;
         var_output := '<MSG>';
         var_output := var_output||'<MSG_ID><![CDATA[' || to_char(rcd_comm.comm_id) || ']]></MSG_ID>';
         var_output := var_output||'<MSG_OWNER><![CDATA[' || rcd_comm.comm_author || ']]></MSG_OWNER>';
         var_output := var_output||'<MSG_TITLE><![CDATA[' || substr(rcd_comm.comm_text,1,50) || ']]></MSG_TITLE>';
         var_output := var_output||'<MSG_TEXT><![CDATA[' || substr(rcd_comm.comm_text,1,1800) || ']]></MSG_TEXT>';
         var_output := var_output||'<MSG_STATUS><![CDATA[' || '0' || ']]></MSG_STATUS>';
         var_output := var_output||'</MSG>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_comm;
      dbms_lob.writeappend(var_clob,length('</MSG_LIST>'),'</MSG_LIST>');

      /*-*/
      /* Retrieve the UOM data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<UOM_LIST>'),'<UOM_LIST>');
      open csr_uom;
      loop
         fetch csr_uom into rcd_uom;
         if csr_uom%notfound then
            exit;
         end if;
         var_output := '<UOM>';
         var_output := var_output||'<UOM_NAME><![CDATA[' || rcd_uom.list_value_name || ']]></UOM_NAME>';
         var_output := var_output||'<UOM_TEXT><![CDATA[' || rcd_uom.list_value_text || ']]></UOM_TEXT>';
         var_output := var_output||'</UOM>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_uom;
      dbms_lob.writeappend(var_clob,length('</UOM_LIST>'),'</UOM_LIST>');

      /*-*/
      /* Retrieve the customer location data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<CUS_LOCN_LIST>'),'<CUS_LOCN_LIST>');
      open csr_cust_location;
      loop
         fetch csr_cust_location into rcd_cust_location;
         if csr_cust_location%notfound then
            exit;
         end if;
         var_output := '<CUS_LOCN>';
         var_output := var_output||'<CUS_LOCN_NAME><![CDATA[' || rcd_cust_location.list_value_name || ']]></CUS_LOCN_NAME>';
         var_output := var_output||'<CUS_LOCN_TEXT><![CDATA[' || rcd_cust_location.list_value_text || ']]></CUS_LOCN_TEXT>';
         var_output := var_output||'</CUS_LOCN>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_cust_location;
      dbms_lob.writeappend(var_clob,length('</CUS_LOCN_LIST>'),'</CUS_LOCN_LIST>');

      /*-*/
      /* Retrieve the customer type data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<CUS_TYPE_LIST>'),'<CUS_TYPE_LIST>');
      open csr_cust_type;
      loop
         fetch csr_cust_type into rcd_cust_type;
         if csr_cust_type%notfound then
            exit;
         end if;
         var_output := '<CUS_TYPE>';
         var_output := var_output||'<CUS_TYPE_ID><![CDATA[' || to_char(rcd_cust_type.cust_type_id) || ']]></CUS_TYPE_ID>';
         var_output := var_output||'<CUS_TYPE_NAME><![CDATA[' || rcd_cust_type.cust_type_name || ']]></CUS_TYPE_NAME>';
         var_output := var_output||'<CUS_TYPE_CHANNEL_ID><![CDATA[' || to_char(rcd_cust_type.cust_trade_channel_id) || ']]></CUS_TYPE_CHANNEL_ID>';
         var_output := var_output||'</CUS_TYPE>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_cust_type;
      dbms_lob.writeappend(var_clob,length('</CUS_TYPE_LIST>'),'</CUS_TYPE_LIST>');

      /*-*/
      /* Retrieve the customer trade channel data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<CUS_TRAD_CHAN_LIST>'),'<CUS_TRAD_CHAN_LIST>');
      open csr_cust_trade_channel;
      loop
         fetch csr_cust_trade_channel into rcd_cust_trade_channel;
         if csr_cust_trade_channel%notfound then
            exit;
         end if;
         var_output := '<CUS_TRAD_CHAN>';
         var_output := var_output||'<CUS_TRADE_CHANNEL_ID><![CDATA[' || to_char(rcd_cust_trade_channel.cust_trade_channel_id) || ']]></CUS_TRADE_CHANNEL_ID>';
         var_output := var_output||'<CUS_TRADE_CHANNEL_NAME><![CDATA[' || rcd_cust_trade_channel.cust_trade_channel_name || ']]></CUS_TRADE_CHANNEL_NAME>';
         var_output := var_output||'</CUS_TRAD_CHAN>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_cust_trade_channel;
      dbms_lob.writeappend(var_clob,length('</CUS_TRAD_CHAN_LIST>'),'</CUS_TRAD_CHAN_LIST>');

      /*-*/
      /* Retrieve the distributor data
      /*-*/
      dbms_lob.writeappend(var_clob,length('<DIS_LIST>'),'<DIS_LIST>');
      open csr_distributor;
      loop
         fetch csr_distributor into rcd_distributor;
         if csr_distributor%notfound then
            exit;
         end if;
         var_output := '<DIS>';
         var_output := var_output||'<DIS_ID><![CDATA[' || to_char(rcd_distributor.customer_id) || ']]></DIS_ID>';
         var_output := var_output||'<DIS_NAME><![CDATA[' || rcd_distributor.customer_name || ']]></DIS_NAME>';
         var_output := var_output||'</DIS>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end loop;
      close csr_distributor;
      dbms_lob.writeappend(var_clob,length('</DIS_LIST>'),'</DIS_LIST>');

      /*-*/
      /* Close the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('</EFEX>'),'</EFEX>');

      /*-*/
      /* Return the clob in character chunks
      /*-*/
      loop
         begin
            dbms_lob.read(var_clob,var_buffer_size,var_buffer_pointer,var_buffer_data);
            var_buffer_pointer := var_buffer_pointer + var_buffer_size;
         exception
            when no_data_found then
               var_buffer_pointer := -1;
         end;
         if var_buffer_pointer < 0 then
            exit;
         end if;
         pipe row(var_buffer_data);
      end loop;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - GET_MOBILE_DATA - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mobile_data;

   /*********************************************************/
   /* This procedure performs the get customer call routine */
   /*********************************************************/
   function get_customer_call(par_customer_id in varchar2) return mobile_stream pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_buffer_data varchar2(2000 char);
      var_buffer_size binary_integer := 2000;
      var_buffer_pointer integer := 1;
      var_exception varchar2(4000);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*
           from customer t01
          where t01.customer_id = to_number(par_customer_id);
      rcd_customer csr_customer%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* User not authenticated
      /*-*/
      if var_auth_user_id = -1 then
         raise_application_error(-20000, 'User has not been authenticated');
      end if;

      /*-*/
      /* Create/clear the XML temporary CLOB
      /*-*/
      if var_clob is null then
         dbms_lob.createtemporary(var_clob,true,dbms_lob.session);
      end if;
      dbms_lob.trim(var_clob,0);
      dbms_lob.writeappend(var_clob,length('<?xml version="1.0" encoding="UTF-8"?>'),'<?xml version="1.0" encoding="UTF-8"?>');

      /*-*/
      /* Open the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('<EFEX>'),'<EFEX>');

      /*-*/
      /* Retrieve the customer call data (active customer only)
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%found then
         if rcd_customer.active_flg = 'Y' then
            get_call_data(999,'*NONROUTE',to_number(par_customer_id));
         end if;
      end if;

      /*-*/
      /* Close the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('</EFEX>'),'</EFEX>');

      /*-*/
      /* Return the clob in character chunks
      /*-*/
      loop
         begin
            dbms_lob.read(var_clob,var_buffer_size,var_buffer_pointer,var_buffer_data);
            var_buffer_pointer := var_buffer_pointer + var_buffer_size;
         exception
            when no_data_found then
               var_buffer_pointer := -1;
         end;
         if var_buffer_pointer < 0 then
            exit;
         end if;
         pipe row(var_buffer_data);
      end loop;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - GET_CUSTOMER_CALL - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_customer_call;

   /*********************************************************/
   /* This procedure performs the get customer data routine */
   /*********************************************************/
   function get_customer_data(par_customer_id in varchar2) return mobile_stream pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_buffer_data varchar2(2000 char);
      var_buffer_size binary_integer := 2000;
      var_buffer_pointer integer := 1;
      var_exception varchar2(4000);
      var_output varchar2(2000 char);
      var_contact_name varchar2(50);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*,
                decode(t01.active_flg,'Y','A','N','X',t01.active_flg) as active_status
           from customer t01
          where t01.customer_id = to_number(par_customer_id);
      rcd_customer csr_customer%rowtype;

      cursor csr_cust_contact is
         select t01.*
           from cust_contact t01
          where t01.customer_id = to_number(par_customer_id)
            and t01.status = 'A'
          order by t01.cust_contact_id asc;
      rcd_cust_contact csr_cust_contact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* User not authenticated
      /*-*/
      if var_auth_user_id = -1 then
         raise_application_error(-20000, 'User has not been authenticated');
      end if;

      /*-*/
      /* Create/clear the XML temporary CLOB
      /*-*/
      if var_clob is null then
         dbms_lob.createtemporary(var_clob,true,dbms_lob.session);
      end if;
      dbms_lob.trim(var_clob,0);
      dbms_lob.writeappend(var_clob,length('<?xml version="1.0" encoding="UTF-8"?>'),'<?xml version="1.0" encoding="UTF-8"?>');

      /*-*/
      /* Open the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('<EFEX>'),'<EFEX>');

      /*-*/
      /* Retrieve the existing customer contact
      /* **notes** 1. The first active customer contact is retrieved
      /*-*/
      var_contact_name := null;
      open csr_cust_contact;
      fetch csr_cust_contact into rcd_cust_contact;
      if csr_cust_contact%found then
         var_contact_name := rcd_cust_contact.last_name;
      end if;
      close csr_cust_contact;

      /*-*/
      /* Retrieve the customer data
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%found then
         var_output := '<CUS>';
         var_output := var_output||'<CUS_DATA_TYPE><![CDATA[' || '*OLD' || ']]></CUS_DATA_TYPE>';
         var_output := var_output||'<CUS_DATA_ACTION><![CDATA[' || '*LOADED' || ']]></CUS_DATA_ACTION>';
         var_output := var_output||'<CUS_CUSTOMER_ID><![CDATA[' || to_char(rcd_customer.customer_id) || ']]></CUS_CUSTOMER_ID>';
         var_output := var_output||'<CUS_CODE><![CDATA[' || rcd_customer.customer_code || ']]></CUS_CODE>';
         var_output := var_output||'<CUS_NAME><![CDATA[' || rcd_customer.customer_name || ']]></CUS_NAME>';
         var_output := var_output||'<CUS_STATUS><![CDATA[' || rcd_customer.active_status || ']]></CUS_STATUS>';
         var_output := var_output||'<CUS_ADDRESS><![CDATA[' || rcd_customer.address_1 || ']]></CUS_ADDRESS>';
         var_output := var_output||'<CUS_CONTACT_NAME><![CDATA[' || var_contact_name || ']]></CUS_CONTACT_NAME>';
         var_output := var_output||'<CUS_PHONE_NUMBER><![CDATA[' || rcd_customer.phone_number || ']]></CUS_PHONE_NUMBER>';
         var_output := var_output||'<CUS_CUS_TYPE_ID><![CDATA[' || to_char(rcd_customer.cust_type_id) || ']]></CUS_CUS_TYPE_ID>';
         var_output := var_output||'<CUS_OUTLET_LOCATION><![CDATA[' || rcd_customer.outlet_location || ']]></CUS_OUTLET_LOCATION>';
         var_output := var_output||'<CUS_DISTRIBUTOR_ID><![CDATA[' || to_char(rcd_customer.distributor_id) || ']]></CUS_DISTRIBUTOR_ID>';
         var_output := var_output||'<CUS_POSTCODE><![CDATA[' || rcd_customer.postcode || ']]></CUS_POSTCODE>';
         var_output := var_output||'<CUS_FAX_NUMBER><![CDATA[' || rcd_customer.fax_number || ']]></CUS_FAX_NUMBER>';
         var_output := var_output||'<CUS_EMAIL_ADDRESS><![CDATA[' || rcd_customer.email_address || ']]></CUS_EMAIL_ADDRESS>';
         var_output := var_output||'</CUS>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);
      end if;
      close csr_customer;

      /*-*/
      /* Close the stream
      /*-*/
      dbms_lob.writeappend(var_clob,length('</EFEX>'),'</EFEX>');

      /*-*/
      /* Return the clob in character chunks
      /*-*/
      loop
         begin
            dbms_lob.read(var_clob,var_buffer_size,var_buffer_pointer,var_buffer_data);
            var_buffer_pointer := var_buffer_pointer + var_buffer_size;
         exception
            when no_data_found then
               var_buffer_pointer := -1;
         end;
         if var_buffer_pointer < 0 then
            exit;
         end if;
         pipe row(var_buffer_data);
      end loop;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - GET_CUSTOMER_DATA - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_customer_data;

   /*************************************************************/
   /* This procedure performs the get communicaton list routine */
   /*************************************************************/
   function get_communication_list return mobile_code_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_user_segment varchar2(128);
      var_user_area varchar2(128);
      var_user_territory varchar2(128);
      var_cust_segment varchar2(128);
      var_cust_region varchar2(128);
      var_cust_cluster varchar2(128);
      var_cust_area varchar2(128);
      var_cust_city varchar2(128);
      var_cust_channel varchar2(128);
      var_cust_banner varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_territory is
         select t01.sales_territory_id,
                t02.sales_area_id,
                t03.sales_region_id,
                t03.segment_id
           from sales_territory t01,
                sales_area t02,
                sales_region t03
          where t01.sales_area_id = t02.sales_area_id
            and t02.sales_region_id = t03.sales_region_id
            and t01.user_id = var_auth_user_id
            and t01.status = 'A'
          order by t01.sales_territory_id asc;
      rcd_sales_territory csr_sales_territory%rowtype;

      cursor csr_customer is
         select t01.customer_id,
                t01.geo_level1_code,
                t01.geo_level2_code,
                t01.geo_level3_code,
                t01.geo_level4_code,
                t01.geo_level5_code,
                t01.affiliation_id,
                t02.sales_territory_id,
                t03.sales_area_id,
                t04.sales_region_id,
                t05.segment_id,
                t06.cust_trade_channel_id
           from customer t01,
                (select t01.customer_id,
                        t01.sales_territory_id
                   from (select t01.customer_id,
                                t01.sales_territory_id,
                                rank() over (partition by t01.customer_id
                                                 order by t01.sales_territory_id) as rnkseq
                           from cust_sales_territory t01
                          where t01.customer_id in (select t01.customer_id
                                                      from route_plan t01
                                                     where t01.user_id = var_auth_user_id
                                                       and trunc(t01.route_plan_date) = trunc(mobile_to_timezone(sysdate))
                                                       and t01.status = 'A')
                            and t01.status = 'A'
                            and t01.primary_flg = 'Y') t01
                  where t01.rnkseq = 1) t02,
                sales_territory t03,
                sales_area t04,
                sales_region t05,
                cust_type t06
          where t01.customer_id = t02.customer_id
            and t02.sales_territory_id = t03.sales_territory_id
            and t03.sales_area_id = t04.sales_area_id
            and t04.sales_region_id = t05.sales_region_id
            and t01.cust_type_id = t06.cust_type_id
            and t01.status = 'A'
            and t01.active_flg = 'Y'
            and t01.customer_id in (select t01.customer_id
                                      from route_plan t01
                                     where t01.user_id = var_auth_user_id
                                       and trunc(t01.route_plan_date) = trunc(mobile_to_timezone(sysdate))
                                       and t01.status = 'A')
            and t01.business_unit_id = var_auth_business_unit_id;
      rcd_customer csr_customer%rowtype;

      cursor csr_user_comm is
         select t01.comm_id
           from comm_assignment t01,
                comm t02
          where t01.comm_id = t02.comm_id
            and t01.status = 'A'
            and trunc(t02.active_date) <= trunc(mobile_to_timezone(sysdate))
            and trunc(t02.inactive_date) >= trunc(mobile_to_timezone(sysdate))
            and t02.status = 'A'
            and t02.comm_type_id = con_user_comm_type_id
            and (t01.selection_string like var_user_segment or
                 t01.selection_string like '%<SEGMENT></SEGMENT>%' or
                 t01.selection_string not like '%<SEGMENT>%')
            and (t01.selection_string like var_user_area or
                 t01.selection_string like '%<SALES_AREA></SALES_AREA>%' or
                 t01.selection_string not like '%<SALES_AREA>%')
            and (t01.selection_string like var_user_territory or
                 t01.selection_string like '%<SALES_TERRITORY></SALES_TERRITORY>%' or
                 t01.selection_string not like '%<SALES_TERRITORY>%');
      rcd_user_comm csr_user_comm%rowtype;

      cursor csr_customer_comm is
         select t01.comm_id
           from comm_assignment t01,
                comm t02
          where t01.comm_id = t02.comm_id
            and t01.status = 'A'
            and trunc(t02.active_date) <= trunc(mobile_to_timezone(sysdate))
            and trunc(t02.inactive_date) >= trunc(mobile_to_timezone(sysdate))
            and t02.status = 'A'
            and t02.comm_type_id = con_customer_comm_type_id
            and (t01.selection_string like var_cust_segment or
                 t01.selection_string like '%<SEGMENT></SEGMENT>%' or
                 t01.selection_string not like '%<SEGMENT>%')
            and (t01.selection_string like var_cust_region or
                 t01.selection_string like '%<GRD_REGION></GRD_REGION>%' or
                 t01.selection_string not like '%<GRD_REGION>%')
            and (t01.selection_string like var_cust_cluster or
                 t01.selection_string like '%<GRD_CLUSTER></GRD_CLUSTER>%' or
                 t01.selection_string not like '%<GRD_CLUSTER>%')
            and (t01.selection_string like var_cust_area or
                 t01.selection_string like '%<GRD_AREA></GRD_AREA>%' or
                 t01.selection_string not like '%<GRD_AREA>%')
            and (t01.selection_string like var_cust_city or
                 t01.selection_string like '%<GRD_CITY></GRD_CITY>%' or
                 t01.selection_string not like '%<GRD_CITY>%')
            and (t01.selection_string like var_cust_channel or
                 t01.selection_string like '%<CHANNEL></CHANNEL>%' or
                 t01.selection_string not like '%<CHANNEL>%')
            and (t01.selection_string like var_cust_banner or
                 t01.selection_string like '%<BANNER></BANNER>%' or
                 t01.selection_string not like '%<BANNER>%');
      rcd_customer_comm csr_customer_comm%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* User not authenticated
      /*-*/
      if var_auth_user_id = -1 then
         raise_application_error(-20000, 'User has not been authenticated');
      end if;

      /*-*/
      /* Retrieve the user communications
      /*-*/
      open csr_sales_territory;
      loop
         fetch csr_sales_territory into rcd_sales_territory;
         if csr_sales_territory%notfound then
            exit;
         end if;
         var_user_segment := '%<SEGMENT>'||to_char(rcd_sales_territory.segment_id)||'</SEGMENT>%';
         var_user_area := '%<SALES_AREA>'||to_char(rcd_sales_territory.sales_area_id)||'</SALES_AREA>%';
         var_user_territory := '%<SALES_TERRITORY>'||to_char(rcd_sales_territory.sales_territory_id)||'</SALES_TERRITORY>%';
         open csr_user_comm;
         loop
            fetch csr_user_comm into rcd_user_comm;
            if csr_user_comm%notfound then
               exit;
            end if;
            pipe row(mobile_code_object(rcd_user_comm.comm_id));
         end loop;
         close csr_user_comm;
      end loop;
      close csr_sales_territory;

      /*-*/
      /* Retrieve the customer communications
      /*-*/
      open csr_customer;
      loop
         fetch csr_customer into rcd_customer;
         if csr_customer%notfound then
            exit;
         end if;
         var_cust_segment := '%<SEGMENT>'||to_char(rcd_customer.segment_id)||'</SEGMENT>%';
         var_cust_region := '%<GRD_REGION>'||rcd_customer.geo_level2_code||'</GRD_REGION>%';
         var_cust_cluster := '%<GRD_CLUSTER>'||rcd_customer.geo_level3_code||'</GRD_CLUSTER>%';
         var_cust_area := '%<GRD_AREA>'||rcd_customer.geo_level4_code||'</GRD_AREA>%';
         var_cust_city := '%<GRD_CITY>'||rcd_customer.geo_level5_code||'</GRD_CITY>%';
         var_cust_channel := '%<CHANNEL>'||to_char(rcd_customer.cust_trade_channel_id)||'</CHANNEL>%';
         var_cust_banner := '%<BANNER>'||to_char(rcd_customer.affiliation_id)||'</BANNER>%';
         open csr_customer_comm;
         loop
            fetch csr_customer_comm into rcd_customer_comm;
            if csr_customer_comm%notfound then
               exit;
            end if;
            pipe row(mobile_code_object(rcd_customer_comm.comm_id));
         end loop;
         close csr_customer_comm;
      end loop;
      close csr_customer;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - GET_COMMUNICATION_LIST - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_communication_list;

   /*****************************************************/
   /* This procedure performs the get call data routine */
   /*****************************************************/
   procedure get_call_data(par_route_plan_order in number, par_type in varchar2, par_customer_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(2000 char);
      var_called boolean;
      var_ordered boolean;
      var_total_qty distribution_total.total_qty%type;
      var_display_qty distribution.display_qty%type;
      var_facing_qty distribution.facing_qty%type;
      var_inventory_qty distribution.inventory_qty%type;
      var_order_qty order_item.order_qty%type;
      var_order_uom order_item.uom%type;
      var_order_value number;
      var_display_in_store display_distribution.display_in_store%type;
      var_activity_in_store activity_distribution.activity_in_store%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_call is
         select t01.customer_id,
                t01.customer_code,
                t01.customer_name,
                decode(t07.segment_id,con_pcmm_segment_id,'PCMM',con_icsf_segment_id,'ICSF','*NONE') as customer_market,
                t01.range_id,
                t02.cust_type_id,
                t03.cust_trade_channel_id,
                t04.sales_territory_id,
                t05.sales_area_id,
                t06.sales_region_id,
                t07.segment_id
           from customer t01,
                cust_type t02,
                cust_trade_channel t03,
                (select t01.customer_id,
                        t01.sales_territory_id
                   from (select t01.customer_id,
                                t01.sales_territory_id,
                                rank() over (partition by t01.customer_id
                                                 order by t01.sales_territory_id) as rnkseq
                           from cust_sales_territory t01
                          where t01.customer_id = par_customer_id
                            and t01.status = 'A'
                            and t01.primary_flg = 'Y') t01
                  where t01.rnkseq = 1) t04,
                sales_territory t05,
                sales_area t06,
                sales_region t07
          where t01.cust_type_id = t02.cust_type_id
            and t02.cust_trade_channel_id = t03.cust_trade_channel_id
            and t01.customer_id = t04.customer_id
            and t04.sales_territory_id = t05.sales_territory_id
            and t05.sales_area_id = t06.sales_area_id
            and t06.sales_region_id = t07.sales_region_id
            and t01.customer_id = par_customer_id
            and t01.status = 'A';
      rcd_call csr_call%rowtype;

      cursor csr_last_call is
         select t01.call_date
           from call t01
          where t01.customer_id = rcd_call.customer_id
            and t01.user_id = var_auth_user_id
            and t01.status = 'A'
          order by t01.call_date desc;
      rcd_last_call csr_last_call%rowtype;

      cursor csr_last_order is
         select t01.order_id
           from orders t01
          where t01.customer_id = rcd_call.customer_id
            and t01.order_status = 'CLOSED'
            and t01.status = 'A'
          order by t01.order_id desc;
      rcd_last_order csr_last_order%rowtype;

      cursor csr_range_item is
         select t02.item_id,
                t02.item_name,
                t02.tdu_price,
                t02.mcu_price,
                t02.rsu_price,
                t02.brand,
                t02.pack_size,
                t01.required_flg
           from range_item t01,
                item t02
          where t01.item_id = t02.item_id
            and t01.range_id = rcd_call.range_id
            and t01.status = 'A'
            and trunc(t01.start_date) <= trunc(mobile_to_timezone(sysdate))
            and t02.status = 'A';
      rcd_range_item csr_range_item%rowtype;

      cursor csr_last_order_item is
         select nvl(t01.order_qty,0) as order_qty,
                nvl(t01.uom,con_uom_default) as uom
           from order_item t01
          where t01.order_id = rcd_last_order.order_id
            and t01.item_id = rcd_range_item.item_id
            and t01.status = 'A';
      rcd_last_order_item csr_last_order_item%rowtype;

      cursor csr_distribution_total is
         select nvl(t01.total_qty,0) as total_qty
           from distribution_total t01
          where t01.customer_id = rcd_call.customer_id
            and t01.item_group_id = 0
            and t01.status = 'A';
      rcd_distribution_total csr_distribution_total%rowtype;

      cursor csr_distribution is
         select nvl(t01.inventory_qty,0) as inventory_qty
           from distribution t01
          where t01.customer_id = rcd_call.customer_id
            and t01.item_id = rcd_range_item.item_id
            and t01.status = 'A';
      rcd_distribution csr_distribution%rowtype;

      cursor csr_display_item is
         select t01.display_item_id,
                t01.display_item_name
           from display_item t01
          where t01.segment_id = rcd_call.segment_id
            and (t01.cust_trade_channel_id is null or t01.cust_trade_channel_id = rcd_call.cust_trade_channel_id)
            and (t01.cust_type_id is null or t01.cust_type_id = rcd_call.cust_type_id)
            and trunc(t01.start_date) <= trunc(mobile_to_timezone(sysdate))
            and trunc(t01.end_date) >= trunc(mobile_to_timezone(sysdate))
            and t01.status = 'A'
          order by t01.display_item_id asc;
      rcd_display_item csr_display_item%rowtype;

      cursor csr_display_distribution is
         select nvl(t01.display_in_store,0) as display_in_store
           from display_distribution t01
          where t01.display_item_id = rcd_display_item.display_item_id
            and t01.customer_id = rcd_call.customer_id
            and t01.user_id = var_auth_user_id
            and trunc(t01.call_date) = trunc(rcd_last_call.call_date);
      rcd_display_distribution csr_display_distribution%rowtype;

      cursor csr_activity_item is
         select t01.activity_item_id,
                t01.activity_item_name
           from activity_item t01
          where t01.segment_id = rcd_call.segment_id
            and (t01.cust_trade_channel_id is null or t01.cust_trade_channel_id = rcd_call.cust_trade_channel_id)
            and (t01.cust_type_id is null or t01.cust_type_id = rcd_call.cust_type_id)
            and trunc(t01.start_date) <= trunc(mobile_to_timezone(sysdate))
            and trunc(t01.end_date) >= trunc(mobile_to_timezone(sysdate))
            and t01.status = 'A'
          order by t01.activity_item_id asc;
      rcd_activity_item csr_activity_item%rowtype;

      cursor csr_activity_distribution is
         select nvl(t01.activity_in_store,0) as activity_in_store
           from activity_distribution t01
          where t01.activity_item_id = rcd_activity_item.activity_item_id
            and t01.customer_id = rcd_call.customer_id
            and t01.user_id = var_auth_user_id
            and trunc(t01.call_date) = trunc(rcd_last_call.call_date);
      rcd_activity_distribution csr_activity_distribution%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the customer call data
      /*-*/
      open csr_call;
      fetch csr_call into rcd_call;
      if csr_call%found then

         /*-*/
         /* Retrieve the last call for this customer by this user
         /* **notes** 1. Used to retrieve the current display and activity distribution
         /*-*/
         var_called := false;
         open csr_last_call;
         fetch csr_last_call into rcd_last_call;
         if csr_last_call%found then
            var_called := true;
         end if;
         close csr_last_call;

         /*-*/
         /* Retrieve the last completed customer order
         /* **notes** 1. Used to retrieve the current order values
         /*-*/
         var_ordered := false;
         open csr_last_order;
         fetch csr_last_order into rcd_last_order;
         if csr_last_order%found then
            var_ordered := true;
         end if;
         close csr_last_order;

         /*-*/
         /* Retrieve the stock distribution total
         /*-*/
         var_total_qty := 0;
         open csr_distribution_total;
         fetch csr_distribution_total into rcd_distribution_total;
         if csr_distribution_total%found then
            var_total_qty := rcd_distribution_total.total_qty;
         end if;
         close csr_distribution_total;

         /*-*/
         /* Open the call
         /*-*/
         var_output := '<RTE_CALL>';
         var_output := var_output||'<RTE_CALL_SEQUENCE><![CDATA[' || to_char(par_route_plan_order,'fm0000') || ']]></RTE_CALL_SEQUENCE>';
         var_output := var_output||'<RTE_CALL_CUSTOMER_ID><![CDATA[' || to_char(rcd_call.customer_id) || ']]></RTE_CALL_CUSTOMER_ID>';
         var_output := var_output||'<RTE_CALL_CUSTOMER_CODE><![CDATA[' || rcd_call.customer_code || ']]></RTE_CALL_CUSTOMER_CODE>';
         var_output := var_output||'<RTE_CALL_CUSTOMER_NAME><![CDATA[' || rcd_call.customer_name || ']]></RTE_CALL_CUSTOMER_NAME>';
         var_output := var_output||'<RTE_CALL_CUSTOMER_TYPE><![CDATA[' || par_type || ']]></RTE_CALL_CUSTOMER_TYPE>';
         var_output := var_output||'<RTE_CALL_MARKET><![CDATA[' || rcd_call.customer_market || ']]></RTE_CALL_MARKET>';
         var_output := var_output||'<RTE_CALL_STATUS><![CDATA[' || '0' || ']]></RTE_CALL_STATUS>';
         var_output := var_output||'<RTE_CALL_DATE><![CDATA[' || to_char(mobile_to_timezone(sysdate),'yyyymmdd') || ']]></RTE_CALL_DATE>';
         var_output := var_output||'<RTE_CALL_STR_TIME><![CDATA[' || '*NONE' || ']]></RTE_CALL_STR_TIME>';
         var_output := var_output||'<RTE_CALL_END_TIME><![CDATA[' || '*NONE' || ']]></RTE_CALL_END_TIME>';
         var_output := var_output||'<RTE_CALL_ORDER_SEND><![CDATA[' || '0' || ']]></RTE_CALL_ORDER_SEND>';
         var_output := var_output||'<RTE_CALL_STOCK_DIST_COUNT><![CDATA[' || to_char(var_total_qty) || ']]></RTE_CALL_STOCK_DIST_COUNT>';
         dbms_lob.writeappend(var_clob,length(var_output),var_output);

         /*-*/
         /* Retrieve the stock items
         /*-*/
         dbms_lob.writeappend(var_clob,length('<RTE_STCK_ITEMS>'),'<RTE_STCK_ITEMS>');
         open csr_range_item;
         loop
            fetch csr_range_item into rcd_range_item;
            if csr_range_item%notfound then
               exit;
            end if;

            /*-*/
            /* Only required (hero) items are stock items
            /*-*/
            if rcd_range_item.required_flg = 'Y' then

               /*-*/
               /* Retrieve the last item distribution
               /*-*/
               var_inventory_qty := 0;
               open csr_distribution;
               fetch csr_distribution into rcd_distribution;
               if csr_distribution%found then
                  var_inventory_qty := rcd_distribution.inventory_qty;
               end if;
               close csr_distribution;

               /*-*/
               /* Output the range item
               /*-*/
               var_output := '<RTE_STCK_ITEM>';
               var_output := var_output||'<RTE_STCK_ITEM_ID><![CDATA[' || to_char(rcd_range_item.item_id) || ']]></RTE_STCK_ITEM_ID>';
               var_output := var_output||'<RTE_STCK_ITEM_NAME><![CDATA[' || rcd_range_item.item_name || ']]></RTE_STCK_ITEM_NAME>';
               var_output := var_output||'<RTE_STCK_ITEM_REQUIRED><![CDATA[' || rcd_range_item.required_flg || ']]></RTE_STCK_ITEM_REQUIRED>';
               var_output := var_output||'<RTE_STCK_ITEM_QTY><![CDATA[' || to_char(var_inventory_qty) || ']]></RTE_STCK_ITEM_QTY>';
               var_output := var_output||'</RTE_STCK_ITEM>';
               dbms_lob.writeappend(var_clob,length(var_output),var_output);

            end if;

         end loop;
         close csr_range_item;
         dbms_lob.writeappend(var_clob,length('</RTE_STCK_ITEMS>'),'</RTE_STCK_ITEMS>');

         /*-*/
         /* Retrieve the call display items
         /*-*/
         dbms_lob.writeappend(var_clob,length('<RTE_DISP_ITEMS>'),'<RTE_DISP_ITEMS>');
         open csr_display_item;
         loop
            fetch csr_display_item into rcd_display_item;
            if csr_display_item%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the last call display when required
            /*-*/
            var_display_in_store := 0;
            if var_called = true then
              open csr_display_distribution;
               fetch csr_display_distribution into rcd_display_distribution;
               if csr_display_distribution%found then
                  var_display_in_store := rcd_display_distribution.display_in_store;
               end if;
               close csr_display_distribution;
            end if;

            /*-*/
            /* Output the call display
            /*-*/
            var_output := '<RTE_DISP_ITEM>';
            var_output := var_output||'<RTE_DISP_ITEM_ID><![CDATA[' || to_char(rcd_display_item.display_item_id) || ']]></RTE_DISP_ITEM_ID>';
            var_output := var_output||'<RTE_DISP_ITEM_NAME><![CDATA[' || rcd_display_item.display_item_name || ']]></RTE_DISP_ITEM_NAME>';
            var_output := var_output||'<RTE_DISP_ITEM_FLAG><![CDATA[' || to_char(var_display_in_store) || ']]></RTE_DISP_ITEM_FLAG>';
            var_output := var_output||'</RTE_DISP_ITEM>';
            dbms_lob.writeappend(var_clob,length(var_output),var_output);

         end loop;
         close csr_display_item;
         dbms_lob.writeappend(var_clob,length('</RTE_DISP_ITEMS>'),'</RTE_DISP_ITEMS>');

         /*-*/
         /* Retrieve the call activity items
         /*-*/
         dbms_lob.writeappend(var_clob,length('<RTE_ACTV_ITEMS>'),'<RTE_ACTV_ITEMS>');
         open csr_activity_item;
         loop
            fetch csr_activity_item into rcd_activity_item;
            if csr_activity_item%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the last call activity when required
            /*-*/
            var_activity_in_store := 0;
            if var_called = true then
              open csr_activity_distribution;
               fetch csr_activity_distribution into rcd_activity_distribution;
               if csr_activity_distribution%found then
                  var_activity_in_store := rcd_activity_distribution.activity_in_store;
               end if;
               close csr_activity_distribution;
            end if;

            /*-*/
            /* Output the call activity
            /*-*/
            var_output := '<RTE_ACTV_ITEM>';
            var_output := var_output||'<RTE_ACTV_ITEM_ID><![CDATA[' || to_char(rcd_activity_item.activity_item_id) || ']]></RTE_ACTV_ITEM_ID>';
            var_output := var_output||'<RTE_ACTV_ITEM_NAME><![CDATA[' || rcd_activity_item.activity_item_name || ']]></RTE_ACTV_ITEM_NAME>';
            var_output := var_output||'<RTE_ACTV_ITEM_FLAG><![CDATA[' || to_char(var_activity_in_store) || ']]></RTE_ACTV_ITEM_FLAG>';
            var_output := var_output||'</RTE_ACTV_ITEM>';
            dbms_lob.writeappend(var_clob,length(var_output),var_output);

         end loop;
         close csr_activity_item;
         dbms_lob.writeappend(var_clob,length('</RTE_ACTV_ITEMS>'),'</RTE_ACTV_ITEMS>');

         /*-*/
         /* Retrieve the order items
         /*-*/
         dbms_lob.writeappend(var_clob,length('<RTE_ORDR_ITEMS>'),'<RTE_ORDR_ITEMS>');
         open csr_range_item;
         loop
            fetch csr_range_item into rcd_range_item;
            if csr_range_item%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the last order item when required
            /*-*/
            var_order_qty := 0;
            var_order_uom := con_uom_default;
            if var_ordered = true then
              open csr_last_order_item;
               fetch csr_last_order_item into rcd_last_order_item;
               if csr_last_order_item%found then
                  var_order_qty := rcd_last_order_item.order_qty;
                  var_order_uom := rcd_last_order_item.uom;
               end if;
               close csr_last_order_item;
            end if;
            var_order_value := 0;
            if upper(var_order_uom) = 'TDU' then
               var_order_value := round(var_order_qty*rcd_range_item.tdu_price,2);
            elsif upper(var_order_uom) = 'MCU' then
               var_order_value := round(var_order_qty*rcd_range_item.mcu_price,2);
            elsif upper(var_order_uom) = 'RSU' then
               var_order_value := round(var_order_qty*rcd_range_item.rsu_price,2);
            end if;

            /*-*/
            /* Output the range item
            /*-*/
            var_output := '<RTE_ORDR_ITEM>';
            var_output := var_output||'<RTE_ORDR_ITEM_ID><![CDATA[' || to_char(rcd_range_item.item_id) || ']]></RTE_ORDR_ITEM_ID>';
            var_output := var_output||'<RTE_ORDR_ITEM_NAME><![CDATA[' || rcd_range_item.item_name || ']]></RTE_ORDR_ITEM_NAME>';
            var_output := var_output||'<RTE_ORDR_ITEM_PRICE_TDU><![CDATA[' || to_char(rcd_range_item.tdu_price) || ']]></RTE_ORDR_ITEM_PRICE_TDU>';
            var_output := var_output||'<RTE_ORDR_ITEM_PRICE_MCU><![CDATA[' || to_char(rcd_range_item.mcu_price) || ']]></RTE_ORDR_ITEM_PRICE_MCU>';
            var_output := var_output||'<RTE_ORDR_ITEM_PRICE_RSU><![CDATA[' || to_char(rcd_range_item.rsu_price) || ']]></RTE_ORDR_ITEM_PRICE_RSU>';
            var_output := var_output||'<RTE_ORDR_ITEM_BRAND><![CDATA[' || rcd_range_item.brand || ']]></RTE_ORDR_ITEM_BRAND>';
            var_output := var_output||'<RTE_ORDR_ITEM_PACKSIZE><![CDATA[' || rcd_range_item.pack_size || ']]></RTE_ORDR_ITEM_PACKSIZE>';
            var_output := var_output||'<RTE_ORDR_ITEM_REQUIRED><![CDATA[' || rcd_range_item.required_flg || ']]></RTE_ORDR_ITEM_REQUIRED>';
            var_output := var_output||'<RTE_ORDR_ITEM_UOM><![CDATA[' || var_order_uom || ']]></RTE_ORDR_ITEM_UOM>';
            var_output := var_output||'<RTE_ORDR_ITEM_QTY><![CDATA[' || to_char(var_order_qty) || ']]></RTE_ORDR_ITEM_QTY>';
            var_output := var_output||'<RTE_ORDR_ITEM_VALUE><![CDATA[' || to_char(var_order_value) || ']]></RTE_ORDR_ITEM_VALUE>';
            var_output := var_output||'</RTE_ORDR_ITEM>';
            dbms_lob.writeappend(var_clob,length(var_output),var_output);

         end loop;
         close csr_range_item;
         dbms_lob.writeappend(var_clob,length('</RTE_ORDR_ITEMS>'),'</RTE_ORDR_ITEMS>');

         /*-*/
         /* Close the call
         /*-*/
         dbms_lob.writeappend(var_clob,length('</RTE_CALL>'),'</RTE_CALL>');

      end if;
      close csr_call;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_call_data;

   /*******************************************************/
   /* This procedure performs the put mobile data routine */
   /*******************************************************/
   procedure put_mobile_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      obj_rte_stck_list xmlDom.domNodeList;
      obj_rte_stck_node xmlDom.domNode;
      obj_rte_disp_list xmlDom.domNodeList;
      obj_rte_disp_node xmlDom.domNode;
      obj_rte_actv_list xmlDom.domNodeList;
      obj_rte_actv_node xmlDom.domNode;
      obj_rte_ordr_list xmlDom.domNodeList;
      obj_rte_ordr_node xmlDom.domNode;
      obj_rte_item_list xmlDom.domNodeList;
      obj_rte_item_node xmlDom.domNode;
      var_data_type varchar2(32 char);
      var_send_order varchar2(32 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* User not authenticated
      /*-*/
      if var_auth_user_id = -1 then
         raise_application_error(-20000, 'User has not been authenticated');
      end if;

      /*-*/
      /* Clear the customer array table
      /*-*/
      tbl_customer.delete;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,var_clob);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the customer nodes
      /* **notes** must be processed first to create any new customers used on subsequent calls
      /*-*/
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/EFEX/CUS_LIST/CUS');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         var_data_type := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_DATA_TYPE/text()'),'['),']');
         upd_customer.customer_name := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_NAME/text()'),'['),']');
         upd_customer.address_1 := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_ADDRESS/text()'),'['),']');
         upd_customer.postcode := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_POSTCODE/text()'),'['),']');
         upd_customer.phone_number := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_PHONE_NUMBER/text()'),'['),']');
         upd_customer.fax_number := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_FAX_NUMBER/text()'),'['),']');
         upd_customer.email_address := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_EMAIL_ADDRESS/text()'),'['),']');
         upd_customer.cust_type_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_CUS_TYPE_ID/text()'),'['),']'));
         upd_customer.distributor_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_DISTRIBUTOR_ID/text()'),'['),']'));
         upd_customer.active_flg := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_STATUS/text()'),'['),']');
         upd_customer.outlet_location := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_OUTLET_LOCATION/text()'),'['),']');
         upd_cust_contact.last_name := rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_CONTACT_NAME/text()'),'['),']');
         if var_data_type = '*NEW' then
            create_customer_data(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_CUSTOMER_ID/text()'),'['),']'));
         else
            upd_customer.customer_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'CUS_CUSTOMER_ID/text()'),'['),']'));
            update_customer_data;
         end if;
      end loop;

      /*-*/
      /* Retrieve and process the route call nodes
      /*-*/
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/EFEX/RTE_CALLS/RTE_CALL');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop

         /*-*/
         /* Update the call data
         /*-*/
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         upd_call.customer_id := mobile_get_customer_id(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'RTE_CALL_CUSTOMER_ID/text()'),'['),']'));
         upd_call.call_date := mobile_to_date(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'RTE_CALL_STR_TIME/text()'),'['),']'),'yyyy/mm/dd hh24:mi:ss');
         upd_call.end_date := mobile_to_date(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'RTE_CALL_END_TIME/text()'),'['),']'),'yyyy/mm/dd hh24:mi:ss');
         upd_distribution_total.total_qty := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_xml_node,'RTE_CALL_STOCK_DIST_COUNT/text()'),'['),']'));
         obj_rte_ordr_list := xslProcessor.selectNodes(obj_xml_node,'RTE_ORDR');
         if xmlDom.getLength(obj_rte_ordr_list) = 0 then
            update_call_data('0');
         else
            update_call_data('1');
         end if;

         /*-*/
         /* Update the distribution data
         /*-*/
         obj_rte_stck_list := xslProcessor.selectNodes(obj_xml_node,'RTE_STCK_ITEMS/RTE_STCK_ITEM');
         for idy in 0..xmlDom.getLength(obj_rte_stck_list)-1 loop
            obj_rte_stck_node := xmlDom.item(obj_rte_stck_list,idy);
            upd_distribution.item_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_stck_node,'RTE_STCK_ITEM_ID/text()'),'['),']'));
            upd_distribution.inventory_qty := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_stck_node,'RTE_STCK_ITEM_QTY/text()'),'['),']'));
            update_distribution_data;
         end loop;

         /*-*/
         /* Update the display data
         /*-*/
         obj_rte_disp_list := xslProcessor.selectNodes(obj_xml_node,'RTE_DISP_ITEMS/RTE_DISP_ITEM');
         for idy in 0..xmlDom.getLength(obj_rte_disp_list)-1 loop
            obj_rte_disp_node := xmlDom.item(obj_rte_disp_list,idy);
            upd_display_distribution.display_item_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_disp_node,'RTE_DISP_ITEM_ID/text()'),'['),']'));
            upd_display_distribution.display_in_store := rtrim(ltrim(xslProcessor.valueOf(obj_rte_disp_node,'RTE_DISP_ITEM_FLAG/text()'),'['),']');
            update_display_data;
         end loop;

         /*-*/
         /* Update the activity data
         /*-*/
         obj_rte_actv_list := xslProcessor.selectNodes(obj_xml_node,'RTE_ACTV_ITEMS/RTE_ACTV_ITEM');
         for idy in 0..xmlDom.getLength(obj_rte_actv_list)-1 loop
            obj_rte_actv_node := xmlDom.item(obj_rte_actv_list,idy);
            upd_activity_distribution.activity_item_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_actv_node,'RTE_ACTV_ITEM_ID/text()'),'['),']'));
            upd_activity_distribution.activity_in_store := rtrim(ltrim(xslProcessor.valueOf(obj_rte_actv_node,'RTE_ACTV_ITEM_FLAG/text()'),'['),']');
            update_activity_data;
         end loop;

         /*-*/
         /* Update the order data
         /*-*/
         obj_rte_ordr_list := xslProcessor.selectNodes(obj_xml_node,'RTE_ORDR');
         for idy in 0..xmlDom.getLength(obj_rte_ordr_list)-1 loop
            obj_rte_ordr_node := xmlDom.item(obj_rte_ordr_list,idy);
            var_send_order := rtrim(ltrim(xslProcessor.valueOf(obj_rte_ordr_node,'RTE_ORDR_SEND_WHSLR/text()'),'['),']');
            upd_orders.order_status := 'CLOSED';
            if var_send_order = '1' then
               upd_orders.order_status := 'SUBMITTED';
            end if;
            upd_orders.total_items := 0;
            upd_orders.total_price := 0;
            obj_rte_item_list := xslProcessor.selectNodes(obj_rte_ordr_node,'RTE_ORDR_ITEM');
            for idz in 0..xmlDom.getLength(obj_rte_item_list)-1 loop
               obj_rte_item_node := xmlDom.item(obj_rte_item_list,idz);
               upd_orders.total_items := upd_orders.total_items + mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_item_node,'RTE_ORDR_ITEM_QTY/text()'),'['),']'));
               upd_orders.total_price := upd_orders.total_price + mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_item_node,'RTE_ORDR_ITEM_VALUE/text()'),'['),']'));
            end loop;
            update_orders_data;
            if upper(upd_orders.order_status) != 'IGNORE' then
               obj_rte_item_list := xslProcessor.selectNodes(obj_rte_ordr_node,'RTE_ORDR_ITEM');
               for idz in 0..xmlDom.getLength(obj_rte_item_list)-1 loop
                  obj_rte_item_node := xmlDom.item(obj_rte_item_list,idz);
                  upd_order_item.item_id := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_item_node,'RTE_ORDR_ITEM_ID/text()'),'['),']'));
                  upd_order_item.order_qty := mobile_to_number(rtrim(ltrim(xslProcessor.valueOf(obj_rte_item_node,'RTE_ORDR_ITEM_QTY/text()'),'['),']'));
                  upd_order_item.uom := rtrim(ltrim(xslProcessor.valueOf(obj_rte_item_node,'RTE_ORDR_ITEM_UOM/text()'),'['),']');
                  update_order_item_data;
               end loop;
            end if;
         end loop;

      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - MOBILE_DATA - PUT_MOBILE_DATA - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_mobile_data;

   /********************************************************/
   /* This procedure performs the update call data routine */
   /********************************************************/
   procedure update_call_data(par_order_flag in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*
           from customer t01
          where t01.customer_id = upd_call.customer_id;
      rcd_customer csr_customer%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the call customer
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%notfound then
         raise_application_error(-20000, 'update_call_data - Customer (' || to_char(upd_call.customer_id) || ') not found');
      end if;
      close csr_customer;

      /*-*/
      /* Set the call data
      /*-*/
      upd_call.customer_id := upd_call.customer_id;
      upd_call.call_date := upd_call.call_date;
      upd_call.user_id := var_auth_user_id;
      upd_call.accomp_user_id := null;
      upd_call.status := 'A';
      upd_call.modified_user := user;
      upd_call.modified_date := mobile_to_timezone(sysdate);
      upd_call.call_type := 'In Store';
      upd_call.end_date := upd_call.end_date;

      /*-*/
      /* Insert/update the call data
      /*-*/
      begin
         insert into call values upd_call;
      exception
         when dup_val_on_index then
            update call
               set status = upd_call.status,
                   modified_user = upd_call.modified_user,
                   modified_date = upd_call.modified_date,
                   end_date = upd_call.end_date
             where customer_id = upd_call.customer_id
               and call_date = upd_call.call_date
               and user_id = upd_call.user_id;
      end;

      /*-*/
      /* Set the distribution total data
      /*-*/
      upd_distribution_total.customer_id := upd_call.customer_id;
      upd_distribution_total.item_group_id := 0;
      upd_distribution_total.total_qty := upd_distribution_total.total_qty;
      upd_distribution_total.status := 'A';
      upd_distribution_total.modified_user := user;
      upd_distribution_total.modified_date := mobile_to_timezone(sysdate);

      /*-*/
      /* Insert/update the distribution total data
      /*-*/
      begin
         insert into distribution_total values upd_distribution_total;
      exception
         when dup_val_on_index then
            update distribution_total
               set total_qty = upd_distribution_total.total_qty,
                   status = upd_distribution_total.status,
                   modified_user = upd_distribution_total.modified_user,
                   modified_date = upd_distribution_total.modified_date
             where customer_id = upd_distribution_total.customer_id
               and item_group_id = upd_distribution_total.item_group_id;
      end;

      /*-*/
      /* Inactive related order when no order on call
      /* **notes** 1. the orders trigger will inactivate the related order items
      /*-*/
      if par_order_flag = '0' then
         update orders
            set status = 'X'
          where customer_id = upd_call.customer_id
            and order_date = upd_call.call_date
            and user_id = upd_call.user_id;
      end if;

      /*-*/
      /* Remove related display distributions
      /*-*/
      delete from display_distribution
       where customer_id = upd_call.customer_id
         and call_date = upd_call.call_date
         and user_id = upd_call.user_id;

      /*-*/
      /* Remove related activity distributions
      /*-*/
      delete from activity_distribution
       where customer_id = upd_call.customer_id
         and call_date = upd_call.call_date
         and user_id = upd_call.user_id;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_call_data;

   /****************************************************************/
   /* This procedure performs the update distribution data routine */
   /****************************************************************/
   procedure update_distribution_data is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_distribution is
         select t01.*
           from distribution t01
          where t01.customer_id = upd_distribution.customer_id
            and t01.item_id = upd_distribution.item_id;
      rcd_distribution csr_distribution%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the distribution data
      /*-*/
      upd_distribution.customer_id := upd_call.customer_id;
      upd_distribution.item_id := upd_distribution.item_id;
      upd_distribution.display_qty := null;
      upd_distribution.facing_qty := null;
      upd_distribution.out_of_stock_flg := null;
      upd_distribution.out_of_date_flg := null;
      upd_distribution.required_flg := null;
      upd_distribution.status := 'A';
      upd_distribution.modified_user := user;
      upd_distribution.modified_date := mobile_to_timezone(sysdate);
      upd_distribution.inventory_qty := upd_distribution.inventory_qty;
      upd_distribution.sell_price := null;
      upd_distribution.in_store_date := null;

      /*-*/
      /* Insert/update the distribution data
      /* **notes** 1. Insert is only performed when inventory quantity exists
      /*           2. All distribution items are returned from the mobile
      /*-*/
      open csr_distribution;
      fetch csr_distribution into rcd_distribution;
      if csr_distribution%notfound then
         if upd_distribution.inventory_qty != 0 then
            insert into distribution values upd_distribution;
         end if;
      else
         update distribution
            set status = upd_distribution.status,
                modified_user = upd_distribution.modified_user,
                modified_date = upd_distribution.modified_date,
                inventory_qty = upd_distribution.inventory_qty
          where customer_id = upd_distribution.customer_id
            and item_id = upd_distribution.item_id;
      end if;
      close csr_distribution;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_distribution_data;

   /**********************************************************/
   /* This procedure performs the update orders data routine */
   /**********************************************************/
   procedure update_orders_data is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*
           from customer t01
          where t01.customer_id = upd_call.customer_id;
      rcd_customer csr_customer%rowtype;

      cursor csr_orders is
         select t01.*
           from orders t01
          where t01.user_id = upd_orders.user_id
            and t01.customer_id = upd_orders.customer_id
            and t01.order_date = upd_orders.order_date;
      rcd_orders csr_orders%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the call customer
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%notfound then
         raise_application_error(-20000, 'update_orders_data - Customer (' || to_char(upd_call.customer_id) || ') not found');
      end if;
      close csr_customer;

      /*-*/
      /* Set the order values
      /*-*/
      upd_orders.customer_id := upd_call.customer_id;
      upd_orders.cust_contact_id := null;
      upd_orders.distributor_id := rcd_customer.distributor_id;
      upd_orders.user_id := upd_call.user_id;
      upd_orders.order_date := upd_call.call_date;
      upd_orders.deliver_date := upd_call.call_date;
      upd_orders.purchase_order := null;
      upd_orders.order_notes := null;
      upd_orders.total_items := upd_orders.total_items;
      upd_orders.total_price := upd_orders.total_price;
      upd_orders.confirm_flg := 'N';
      upd_orders.phoned_flg := 'N';
      upd_orders.delasap_flg := 'N';
      upd_orders.sendfax_flg := 'N';
      upd_orders.delnext_flg := 'N';
      upd_orders.order_status := upd_orders.order_status;
      upd_orders.status := 'A';
      upd_orders.modified_user := user;
      upd_orders.modified_date := mobile_to_timezone(sysdate);
      upd_orders.order_code := null;
      upd_orders.contact_signature := null;
      upd_orders.tp_amount := null;
      upd_orders.tp_paid_flg := 'N';
      upd_orders.delivered_flg := 'N';
      upd_orders.print_statement_flg := 'N';
      upd_orders.apply_discount_flg := 'N';
      upd_orders.mobile_control_flg := 'N';
      if upper(upd_orders.order_status) = 'SUBMITTED' then
         upd_orders.mobile_control_flg := 'Y';
      end if;

      /*-*/
      /* Insert/update the order data
      /* **notes** 1. Order updated is bypassed when the existing order has a
      /*              mobile control flag equal to "Y". This indicates that the
      /*              order has been sent to the distributor and and such must
      /*              not be modified or resent.
      /*           2. Inactivate any existing order lines for the existing order
      /*              as only new lines will be activated when processed.
      /*-*/
      open csr_orders;
      fetch csr_orders into rcd_orders;
      if csr_orders%notfound then
         select orders_seq.nextval into upd_orders.order_id from dual;
         insert into orders values upd_orders;
      else
         if rcd_orders.mobile_control_flg != 'Y' then
            upd_orders.order_id := rcd_orders.order_id;
            update orders
               set distributor_id = upd_orders.distributor_id,
                   deliver_date = upd_orders.deliver_date,
                   total_items = upd_orders.total_items,
                   total_price = upd_orders.total_price,
                   order_status = upd_orders.order_status,
                   status = upd_orders.status,
                   modified_user = upd_orders.modified_user,
                   modified_date = upd_orders.modified_date
             where order_id = upd_orders.order_id;
            update order_item
               set status = 'X'
             where order_id = upd_orders.order_id;
         else
            upd_orders.order_status := 'IGNORE';
         end if;
      end if;
      close csr_orders;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_orders_data;

   /**************************************************************/
   /* This procedure performs the update order item data routine */
   /**************************************************************/
   procedure update_order_item_data is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_item is
         select t01.*
           from order_item t01
          where t01.order_id = upd_order_item.order_id
            and t01.item_id = upd_order_item.item_id;
      rcd_order_item csr_order_item%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the order item data
      /*-*/
      upd_order_item.order_id := upd_orders.order_id;
      upd_order_item.item_id := upd_order_item.item_id;
      upd_order_item.order_qty := upd_order_item.order_qty;
      upd_order_item.alloc_qty := 0;
      upd_order_item.uom := upd_order_item.uom;
      upd_order_item.status := 'A';
      upd_order_item.modified_user := user;
      upd_order_item.modified_date := mobile_to_timezone(sysdate);

      /*-*/
      /* Insert/update the order item data
      /*-*/
      open csr_order_item;
      fetch csr_order_item into rcd_order_item;
      if csr_order_item%notfound then
         insert into order_item values upd_order_item;
      else
         update order_item
            set order_qty = upd_order_item.order_qty,
                uom = upd_order_item.uom,
                status = upd_order_item.status,
                modified_user = upd_order_item.modified_user,
                modified_date = upd_order_item.modified_date
          where order_id = upd_order_item.order_id
            and item_id = upd_order_item.item_id;
      end if;
      close csr_order_item;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_order_item_data;

   /***********************************************************/
   /* This procedure performs the update display data routine */
   /***********************************************************/
   procedure update_display_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the display distribution data
      /*-*/
      upd_display_distribution.customer_id := upd_call.customer_id;
      upd_display_distribution.display_item_id := upd_display_distribution.display_item_id;
      upd_display_distribution.user_id := upd_call.user_id;
      upd_display_distribution.call_date := upd_call.call_date;
      upd_display_distribution.display_in_store := upd_display_distribution.display_in_store;
      upd_display_distribution.modified_user := user;
      upd_display_distribution.modified_date := mobile_to_timezone(sysdate);
      insert into display_distribution values upd_display_distribution;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_display_data;

   /***********************************************************/
   /* This procedure performs the update activity data routine */
   /***********************************************************/
   procedure update_activity_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the activity distribution data
      /*-*/
      upd_activity_distribution.customer_id := upd_call.customer_id;
      upd_activity_distribution.activity_item_id := upd_activity_distribution.activity_item_id;
      upd_activity_distribution.user_id := upd_call.user_id;
      upd_activity_distribution.call_date := upd_call.call_date;
      upd_activity_distribution.activity_in_store := upd_activity_distribution.activity_in_store;
      upd_activity_distribution.modified_user := user;
      upd_activity_distribution.modified_date := mobile_to_timezone(sysdate);
      insert into activity_distribution values upd_activity_distribution;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_activity_data;

   /************************************************************/
   /* This procedure performs the update customer data routine */
   /************************************************************/
   procedure update_customer_data is

      /*-*/
      /* Local definitions
      /*-*/
      var_range_id number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer is
         select t01.*
           from customer t01
          where t01.customer_id = upd_customer.customer_id;
      rcd_customer csr_customer%rowtype;

      cursor csr_sales_territory is
         select t01.sales_territory_id,
                t03.segment_id
           from sales_territory t01,
                sales_area t02,
                sales_region t03
          where t01.sales_area_id = t02.sales_area_id(+)
            and t02.sales_region_id = t03.sales_region_id(+)
            and t01.user_id = var_auth_user_id
            and t01.status = 'A'
          order by t01.sales_territory_id asc;
      rcd_sales_territory csr_sales_territory%rowtype;

      cursor csr_range is
         select t01.range_id
           from range t01
          where t01.segment_id = rcd_sales_territory.segment_id
            and t01.cust_type_id = upd_customer.cust_type_id
            and t01.status = 'A'
          order by t01.range_id asc;
      rcd_range csr_range%rowtype;

      cursor csr_cust_contact is
         select t01.*
           from cust_contact t01
          where t01.customer_id = upd_customer.customer_id
            and t01.status = 'A'
          order by t01.cust_contact_id asc;
      rcd_cust_contact csr_cust_contact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the existing customer
      /*-*/
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%notfound then
         raise_application_error(-20000, 'update_customer_data - Customer (' || to_char(upd_customer.customer_id) || ') not found');
      end if;
      close csr_customer;
      var_range_id := rcd_customer.range_id;

      /*-*/
      /* Retrieve the range when sales territory segment found
      /* **notes** 1. The first active range is retrieved
      /*-*/
      if rcd_customer.cust_type_id != upd_customer.cust_type_id then

         /*-*/
         /* Retrieve the sales territory
         /* **notes** 1. The first active authenticated user sales territory is retrieved
         /*-*/
         open csr_sales_territory;
         fetch csr_sales_territory into rcd_sales_territory;
         if csr_sales_territory%notfound then
            raise_application_error(-20000, 'update_customer_data - User (' || to_char(var_auth_user_id) || ') has no active sales territory');
         end if;
         close csr_sales_territory;

         /*-*/
         /* Retrieve the range when sales territory segment found
         /* **notes** 1. The first active range is retrieved
         /*-*/
         var_range_id := null;
         open csr_range;
         fetch csr_range into rcd_range;
         if csr_range%found then
            var_range_id := rcd_range.range_id;
         end if;
         close csr_range;

      end if;

      /*-*/
      /* Update the customer data
      /*-*/
      if upd_customer.active_flg = 'A' then
         upd_customer.active_flg := 'Y';
      else
         upd_customer.active_flg := 'N';
      end if;
      update customer
         set customer_name = upd_customer.customer_name,
             address_1 = upd_customer.address_1,
             postcode = upd_customer.postcode,
             phone_number = upd_customer.phone_number,
             fax_number = upd_customer.fax_number,
             email_address = upd_customer.email_address,
             range_id = var_range_id,
             cust_type_id = upd_customer.cust_type_id,
             distributor_id = upd_customer.distributor_id,
             active_flg = upd_customer.active_flg,
             modified_user = user,
             modified_date = mobile_to_timezone(sysdate),
             outlet_location = upd_customer.outlet_location
       where customer_id = rcd_customer.customer_id;

      /*-*/
      /* Retrieve the existing customer contact and insert/update when required
      /* **notes** 1. The first active customer contact is retrieved
      /*           2. Only update when name has changed
      /*-*/
      if not(upd_cust_contact.last_name) is null then
         open csr_cust_contact;
         fetch csr_cust_contact into rcd_cust_contact;
         if csr_cust_contact%notfound then
            select cust_contact_seq.nextval into upd_cust_contact.cust_contact_id from dual;
            upd_cust_contact.first_name := null;
            upd_cust_contact.last_name := upd_cust_contact.last_name;
            upd_cust_contact.phone_number := null;
            upd_cust_contact.email_address := null;
            upd_cust_contact.contact_position_id := null;
            upd_cust_contact.customer_id := upd_customer.customer_id;
            upd_cust_contact.status := 'A';
            upd_cust_contact.modified_user := user;
            upd_cust_contact.modified_date := mobile_to_timezone(sysdate);
            insert into cust_contact values upd_cust_contact;
         else
            if rcd_cust_contact.last_name != upd_cust_contact.last_name then
               update cust_contact
                  set last_name = upd_cust_contact.last_name,
                      modified_user = user,
                      modified_date = mobile_to_timezone(sysdate)
                where cust_contact_id = rcd_cust_contact.cust_contact_id;
            end if;
         end if;
         close csr_cust_contact;
      end if;

      /*-*/
      /* Remove any future route plan data from inactivated customers
      /*-*/
      if upd_customer.active_flg = 'N' then
         update route_plan
            set status = 'X',
                modified_user = user,
                modified_date = mobile_to_timezone(sysdate)
          where user_id = var_auth_user_id
            and customer_id = upd_customer.customer_id
            and trunc(route_plan_date) > trunc(mobile_to_timezone(sysdate));
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_customer_data;

   /************************************************************/
   /* This procedure performs the create customer data routine */
   /************************************************************/
   procedure create_customer_data(par_customer_id in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_sales_territory_id number;
      var_segment_id number;
      var_range_id number;
      var_level5_name varchar2(100);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_geo_hierarchy is
         select t01.*
           from geo_hierarchy t01
          where t01.business_unit_id = var_auth_business_unit_id
            and upper(t01.geo_level5_name) like var_level5_name;
      rcd_geo_hierarchy csr_geo_hierarchy%rowtype;

      cursor csr_sales_territory is
         select t01.sales_territory_id,
                t03.segment_id
           from sales_territory t01,
                sales_area t02,
                sales_region t03
          where t01.sales_area_id = t02.sales_area_id(+)
            and t02.sales_region_id = t03.sales_region_id(+)
            and t01.user_id = var_auth_user_id
            and t01.status = 'A'
          order by t01.sales_territory_id asc;
      rcd_sales_territory csr_sales_territory%rowtype;

      cursor csr_range is
         select t01.range_id
           from range t01
          where t01.segment_id = var_segment_id
            and t01.cust_type_id = upd_customer.cust_type_id
            and t01.status = 'A'
          order by t01.range_id asc;
      rcd_range csr_range%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the sales territory
      /* **notes** 1. The first active authenticated user sales territory is retrieved
      /*-*/
      var_sales_territory_id := null;
      var_segment_id := null;
      open csr_sales_territory;
      fetch csr_sales_territory into rcd_sales_territory;
      if csr_sales_territory%notfound then
         raise_application_error(-20000, 'create_customer_data - User (' || to_char(var_auth_user_id) || ') has no active sales territory');
      else
         var_sales_territory_id := rcd_sales_territory.sales_territory_id;
         var_segment_id := rcd_sales_territory.segment_id;
      end if;
      close csr_sales_territory;

      /*-*/
      /* Retrieve the range when sales territory segment found
      /* **notes** 1. The first active range is retrieved
      /*-*/
      var_range_id := null;
      if not(var_segment_id is null) then
         open csr_range;
         fetch csr_range into rcd_range;
         if csr_range%found then
            var_range_id := rcd_range.range_id;
         end if;
         close csr_range;
      end if;

      /*-*/
      /* Attempt to find the related sales force hierarchy based on the authorised user city
      /*-*/
      upd_customer.geo_level1_code := null;
      upd_customer.geo_level2_code := null;
      upd_customer.geo_level3_code := null;
      upd_customer.geo_level4_code := null;
      upd_customer.geo_level5_code := null;
      var_level5_name := '%'||upper(var_auth_city)||'%';
      open csr_geo_hierarchy;
      fetch csr_geo_hierarchy into rcd_geo_hierarchy;
      if csr_geo_hierarchy%found then
         upd_customer.geo_level1_code := rcd_geo_hierarchy.geo_level1_code;
         upd_customer.geo_level2_code := rcd_geo_hierarchy.geo_level2_code;
         upd_customer.geo_level3_code := rcd_geo_hierarchy.geo_level3_code;
         upd_customer.geo_level4_code := rcd_geo_hierarchy.geo_level4_code;
         upd_customer.geo_level5_code := rcd_geo_hierarchy.geo_level5_code;
      end if;
      close csr_geo_hierarchy;

      /*-*/
      /* Insert the customer data
      /*-*/
      begin
         select customer_seq.nextval into upd_customer.customer_id from dual;
         upd_customer.customer_code := '8'||to_char(upd_customer.customer_id,'fm0000000');
         upd_customer.customer_name := upd_customer.customer_name;
         upd_customer.customer_name_en := upd_customer.customer_name;
         upd_customer.address_1 := upd_customer.address_1;
         upd_customer.address_2 := null;
         upd_customer.postal_address := null;
         upd_customer.city := var_auth_city;
         upd_customer.state := null;
         upd_customer.postcode := upd_customer.postcode;
         upd_customer.map_reference := null;
         upd_customer.phone_number := upd_customer.phone_number;
         upd_customer.fax_number := upd_customer.fax_number;
         upd_customer.email_address := upd_customer.email_address;
         upd_customer.web_address := null;
         upd_customer.meals_day := null;
         upd_customer.lead_time := null;
         upd_customer.best_call_day := null;
         upd_customer.best_call_time := null;
         upd_customer.distributor_flg := 'N';
         upd_customer.outlet_flg := 'Y';
         upd_customer.active_flg := 'Y';
         upd_customer.market_id := var_auth_market_id;
         upd_customer.range_id := var_range_id;
         upd_customer.cust_visit_freq_id := null;
         upd_customer.cust_type_id := upd_customer.cust_type_id;
         upd_customer.affiliation_id := null;
         upd_customer.distributor_id := upd_customer.distributor_id;
         upd_customer.cust_grade_id := null;
         upd_customer.status := 'A';
         upd_customer.modified_user := user;
         upd_customer.modified_date := mobile_to_timezone(sysdate);
         upd_customer.payee_name := null;
         upd_customer.merch_name := null;
         upd_customer.merch_code := null;
         upd_customer.vat_reg_num := null;
         upd_customer.discount_pct := null;
         upd_customer.corporate_flg := 'N';
         upd_customer.mobile_number := null;
         upd_customer.call_week1_day := null;
         upd_customer.call_week2_day := null;
         upd_customer.call_week3_day := null;
         upd_customer.call_week4_day := null;
         upd_customer.vendor_code := null;
         upd_customer.setup_date := mobile_to_timezone(sysdate);
         upd_customer.setup_person := var_auth_username;
         upd_customer.outlet_location := upd_customer.outlet_location;
         upd_customer.std_level1_code := null;
         upd_customer.std_level2_code := null;
         upd_customer.std_level3_code := null;
         upd_customer.std_level4_code := null;
         upd_customer.business_unit_id := var_auth_business_unit_id;
         insert into customer values upd_customer;
      exception
         when dup_val_on_index then
            raise_application_error(-20000, 'create_customer_data - Customer (' || to_char(upd_customer.customer_id) || ') already exists');
      end;

      /*-*/
      /* Add the new customer code and identifier to the array table
      /*-*/
      tbl_customer(tbl_customer.count+1).new_code := par_customer_id;
      tbl_customer(tbl_customer.count).new_id := upd_customer.customer_id;

      /*-*/
      /* Insert the customer contact data when required
      /*-*/
      if not(upd_cust_contact.last_name) is null then
         select cust_contact_seq.nextval into upd_cust_contact.cust_contact_id from dual;
         upd_cust_contact.first_name := null;
         upd_cust_contact.last_name := upd_cust_contact.last_name;
         upd_cust_contact.phone_number := null;
         upd_cust_contact.email_address := null;
         upd_cust_contact.contact_position_id := null;
         upd_cust_contact.customer_id := upd_customer.customer_id;
         upd_cust_contact.status := 'A';
         upd_cust_contact.modified_user := user;
         upd_cust_contact.modified_date := mobile_to_timezone(sysdate);
         insert into cust_contact values upd_cust_contact;
      end if;

      /*-*/
      /* Insert the customer sales territory data
      /*-*/
      upd_cust_sales_territory.customer_id := upd_customer.customer_id;
      upd_cust_sales_territory.sales_territory_id := var_sales_territory_id;
      upd_cust_sales_territory.status := 'A';
      upd_cust_sales_territory.modified_user := user;
      upd_cust_sales_territory.modified_date := mobile_to_timezone(sysdate);
      upd_cust_sales_territory.primary_flg := 'Y';
      insert into cust_sales_territory values upd_cust_sales_territory;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_customer_data;

   /***************************************************************/
   /* This procedure performs the get customer identifier routine */
   /***************************************************************/
   function mobile_get_customer_id(par_source in varchar2) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and return the customer id from the source data
      /*-*/
      var_return := 0;
      if substr(par_source,1,4) = '*NEW' then
         for idx in 1..tbl_customer.count loop
            if tbl_customer(idx).new_code = par_source then
               var_return := tbl_customer(idx).new_id;
               exit;
            end if;
         end loop;
      else
         var_return := mobile_to_number(par_source);
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end mobile_get_customer_id;

   /********************************************************/
   /* This procedure performs the mobile to number routine */
   /********************************************************/
   function mobile_to_number(par_number in varchar2) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the number value
      /*-*/
      var_return := 0;
      begin
         if substr(par_number,length(par_number),1) = '-' then
            var_return := to_number('-' || substr(par_number,1,length(par_number) - 1));
         else
            var_return := to_number(par_number);
         end if;
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end mobile_to_number;

   /******************************************************/
   /* This procedure performs the mobile to date routine */
   /******************************************************/
   function mobile_to_date(par_date in varchar2, par_format in varchar2) return date is

      /*-*/
      /* Local definitions
      /*-*/
      var_return date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the date value
      /*-*/
      var_return := null;
      begin
         var_return := to_date(par_date,par_format);
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end mobile_to_date;

   /******************************************************/
   /* This procedure performs the mobile sysdate routine */
   /******************************************************/
   function mobile_to_timezone(par_date in date) return date is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the timezone date
      /*-*/
      return from_tz(cast(sysdate as timestamp), 'Australia/NSW') at time zone con_timezone;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end mobile_to_timezone;

   /****************************************************/
   /* This procedure performs the mobile event routine */
   /****************************************************/
   procedure mobile_event(par_status in varchar2, par_connected varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_now date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the synchronization log row
      /*-*/
      var_now := mobile_to_timezone(sysdate);
      update sync_log
         set online_secs = round(((var_now - connect_datime) * 86400), 0),
             status_text = par_status,
             connected_flg = decode(par_connected,'Y','Y','N')
       where sync_log_id = var_auth_sync_log_id;

      /*-*/
      /* Commit the database under an autonomous transaction
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end mobile_event;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package private variables
   /*-*/
   var_auth_user_id := -1;
   var_auth_username := null;
   var_auth_firstname := null;
   var_auth_lastname := null;
   var_auth_market_id := null;
   var_auth_business_unit_id := null;
   var_auth_city := null;
   var_auth_sync_log_id := null;

end mobile_data;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mobile_data for sync_app.mobile_data;
