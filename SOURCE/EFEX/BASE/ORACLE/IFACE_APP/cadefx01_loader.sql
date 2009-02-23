/******************/
/* Package Header */
/******************/
create or replace package iface_app.cadefx01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : cadefx01_loader
    Owner   : iface_app

    Description
    -----------
    Efex - CADEFX01 - China Route Plan Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end cadefx01_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.cadefx01_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   sav_username varchar2(10);
   sav_plandate varchar2(8);
   rcd_route_plan route_plan%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the transaction variables
      /*-*/
      var_trn_error := false;
      sav_username := '*START';
      sav_plandate := '*START';

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('RTE','SALES_PRSN_ASSOCIATE_CODE',10);
      lics_inbound_utility.set_definition('RTE','ROUTE_PLAN_DATE',8);
      lics_inbound_utility.set_definition('RTE','ROUTE_PLAN_ORDER',2);
      lics_inbound_utility.set_definition('RTE','CUSTOMER_CODE',10);
      lics_inbound_utility.set_definition('RTE','STATUS',1);
      lics_inbound_utility.set_definition('RTE','MODIFIED_USER',10);
      lics_inbound_utility.set_definition('RTE','MODIFIED_DATE',8);

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
      var_username varchar2(10);
      var_plandate varchar2(8);
      var_customer_code varchar2(50);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_users is 
         select t01.user_id
           from users t01
          where t01.username = upper(var_username);
      rcd_users csr_users%rowtype;

      cursor csr_customer is 
         select t01.customer_id
           from customer t01
          where t01.customer_code = var_customer_code
            and t01.market_id = 4;
      rcd_customer csr_customer%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('RTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve temporary values
      /*-*/
      var_username := lics_inbound_utility.get_variable('SALES_PRSN_ASSOCIATE_CODE');
      var_plandate := lics_inbound_utility.get_variable('ROUTE_PLAN_DATE');
      var_customer_code := lics_inbound_utility.get_variable('CUSTOMER_CODE');

      /*-*/
      /* Commit the previous route plan when required
      /*-*/
      if (sav_username != var_username or
          sav_plandate != var_plandate) then
         if sav_username != '*START' then
            if var_trn_error = true then
               rollback;
            else
               commit;
            end if;
         end if;
         var_trn_error := false;
      end if;

      /*-*/
      /* Retrieve field values
      /*-*/
      open csr_users;
      fetch csr_users into rcd_users;
      if csr_users%notfound then
         lics_inbound_utility.add_exception('User ('||upper(var_username)||') does not exist');
         var_trn_error := true;
      end if;
      close csr_users;
      open csr_customer;
      fetch csr_customer into rcd_customer;
      if csr_customer%notfound then
         lics_inbound_utility.add_exception('Customer ('||var_customer_code||') does not exist');
         var_trn_error := true;
      end if;
      close csr_customer;
      rcd_route_plan.user_id := rcd_users.user_id;
      rcd_route_plan.route_plan_date := lics_inbound_utility.get_date('ROUTE_PLAN_DATE','yyyymmdd');
      rcd_route_plan.route_plan_order := lics_inbound_utility.get_number('ROUTE_PLAN_ORDER',null);
      rcd_route_plan.customer_id := rcd_customer.customer_id;
      rcd_route_plan.status := lics_inbound_utility.get_variable('STATUS');
      rcd_route_plan.modified_user := lics_inbound_utility.get_variable('MODIFIED_USER');
      rcd_route_plan.modified_date := lics_inbound_utility.get_date('MODIFIED_DATE','yyyymmdd');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Start the new route plan when required
      /*-*/
      if (sav_username != var_username or
          sav_plandate != var_plandate) then
         sav_username := var_username;
         sav_plandate := var_plandate;
         if var_trn_error = false then
            update route_plan
               set status = 'X',
                   modified_user = upper(user),
                   modified_date = trunc(sysdate)
             where user_id = rcd_route_plan.user_id
               and route_plan_date = rcd_route_plan.route_plan_date;
         end if;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into route_plan values rcd_route_plan;
      exception
         when dup_val_on_index then
            update route_plan
               set customer_id = rcd_route_plan.customer_id,
                   status = rcd_route_plan.status,
                   modified_user = rcd_route_plan.modified_user,
                   modified_date = rcd_route_plan.modified_date
             where user_id = rcd_route_plan.user_id
               and route_plan_date = rcd_route_plan.route_plan_date
               and route_plan_order = rcd_route_plan.route_plan_order;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin


      /*-*/
      /* Commit/rollback the previous route plan as required
      /*-*/
      if sav_username != '*START' then
         if var_trn_error = true then
            rollback;
         else
            commit;
         end if;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end cadefx01_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym cadefx01_loader for iface_app.cadefx01_loader;
grant execute on iface_app.cadefx01_loader to lics_app;
