create or replace package bpip_bom as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function allocation(par_company in varchar2, par_material in varchar2, par_date in varchar2) return bpip_allocation_table pipelined;

end bpip_bom;
/

/****************/
/* Package Body */
/****************/
create or replace package body bpip_bom as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************************/
   /* This procedure performs the performs the allocation routine */
   /***************************************************************/
   function allocation(par_company in varchar2, par_material in varchar2, par_date in varchar2) return bpip_allocation_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_comp varchar2(30 char);
      var_code varchar2(30 char);
      var_number number;
      var_date varchar2(8 char);
      var_date01 date;
      var_result common.st_result;
      var_result_msg common.st_message_string;
      var_where_used recipe_functions.t_where_used;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the parameters
      /*-*/
      var_comp := par_company;
      var_code := par_material;
      begin
         var_number := to_number(var_code);
         var_code := to_char(var_number,'fm000000000000000000000000000000');
         var_code := substr(var_code,18*-1,18);
      exception
         when others then
            null;
      end;
      var_date := par_date;
      if var_date is null then
         var_date := to_char(sysdate,'yyyymmdd');
      end if;
      var_date01 := to_date(var_date,'yyyymmdd');

      /*-*/
      /* Retrieve the current BOM allocation
      /*-*/
      var_result := recipe_functions.where_used_allocation(var_comp,var_code,var_date01,'QTY',true,var_where_used,var_result_msg);
      if var_result != common.gc_success then
         raise_application_error(-20000, var_result_msg);
      end if;
      for idx in 1..var_where_used.count loop
         pipe row(bpip_allocation_object('**QTY**',
                                         var_where_used(idx).plant,
                                         var_where_used(idx).matl_code,
                                         var_where_used(idx).proportion,
                                         substr(var_where_used(idx).bom_path,1,1024)));
      end loop;

      /*-*/
      /* Retrieve the new BOM net weight allocation
      /*-*/
      var_result := recipe_functions.where_used_allocation(var_comp,var_code,var_date01,'NWT',true,var_where_used,var_result_msg);
      if var_result != common.gc_success then
         raise_application_error(-20000, var_result_msg);
      end if;
      for idx in 1..var_where_used.count loop
         pipe row(bpip_allocation_object('**NET_WEIGHT**',
                                         var_where_used(idx).plant,
                                         var_where_used(idx).matl_code,
                                         var_where_used(idx).proportion,
                                         substr(var_where_used(idx).bom_path,1,1024)));
      end loop;

      /*-*/
      /* Retrieve the new BOM gross weight allocation
      /*-*/
      var_result := recipe_functions.where_used_allocation(var_comp,var_code,var_date01,'GWT',true,var_where_used,var_result_msg);
      if var_result != common.gc_success then
         raise_application_error(-20000, var_result_msg);
      end if;
      for idx in 1..var_where_used.count loop
         pipe row(bpip_allocation_object('**GROSS_WEIGHT**',
                                         var_where_used(idx).plant,
                                         var_where_used(idx).matl_code,
                                         var_where_used(idx).proportion,
                                         substr(var_where_used(idx).bom_path,1,1024)));
      end loop;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end allocation;

end bpip_bom;
/

/******************/
/* Package Grants */
/******************/
grant execute on bp_app.bpip_bom to public;
/
