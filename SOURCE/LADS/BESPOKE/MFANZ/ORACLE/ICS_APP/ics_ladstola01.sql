create or replace package ics_ladstola01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_ladstola01
 Owner   : ics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Interface Control System - ladstola01 - Lads to Tolas Material

 YYYY/MM   Author            Description
 -------   ------            -----------
 2004/05   Steve Gregan      Created
 2008/12   Ricardo Carneiro  Added rounding

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_ladstola01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_ladstola01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_work varchar2(18);
      var_string varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_food_tolas_fgmatl_case_01 is
	select *
	from food_tolas_fgmatl_case t01
       where t01.chng_date >= to_char(sysdate-7,'YYYYMMDD')
	order by t01.matl_code;
      rcd_food_tolas_fgmatl_case_01 csr_food_tolas_fgmatl_case_01%rowtype;

      cursor csr_food_tolas_fgmatl_show_01 is
	select *
	from food_tolas_fgmatl_showbox t01
       where t01.chng_date >= to_char(sysdate-7,'YYYYMMDD')
	order by t01.matl_code;
      rcd_food_tolas_fgmatl_show_01 csr_food_tolas_fgmatl_show_01%rowtype;

      cursor csr_food_tolas_fgmatl_pack_01 is
	select *
	from food_tolas_fgmatl_pack t01
       where t01.chng_date >= to_char(sysdate-7,'YYYYMMDD')
	order by t01.matl_code;
      rcd_food_tolas_fgmatl_pack_01 csr_food_tolas_fgmatl_pack_01%rowtype;

      cursor csr_food_tolas_fgmatl_piece_01 is
	select *
	from food_tolas_fgmatl_piece t01
       where t01.chng_date >= to_char(sysdate-7,'YYYYMMDD')
	order by t01.matl_code;
      rcd_food_tolas_fgmatl_piece_01 csr_food_tolas_fgmatl_piece_01%rowtype;

      cursor csr_food_tolas_inb_matl_01 is
	select *
	from food_tolas_inb_matl t01
       where t01.chng_date >= to_char(sysdate-7,'YYYYMMDD')
	order by t01.matl_code;
      rcd_food_tolas_inb_matl_01 csr_food_tolas_inb_matl_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADTOL01');

      /*-*/
      /* Retrieve the finished goods case material rows
      /*-*/
      open csr_food_tolas_fgmatl_case_01;
      loop
         fetch csr_food_tolas_fgmatl_case_01 into rcd_food_tolas_fgmatl_case_01;
         if csr_food_tolas_fgmatl_case_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for numeric material number
         /*-*/
         begin
            var_work := to_char(to_number(trim(rcd_food_tolas_fgmatl_case_01.matl_code)),'FM999999999999999990');
         exception
            when others then
               var_work:= rcd_food_tolas_fgmatl_case_01.matl_code;
         end;

         /*-*/
         /* Set HDR interface data
         /*-*/
         var_string := rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.rcrd_type),' '),3,' ') ||
	               rpad(nvl(trim(var_work),' '),8,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.matl_desc),' '),40,' ') ||
	               lpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.crtn_date),' '),8,'0') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.plant),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.matl_type),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.prdct_ctgry),' '),2,' ');
		 if nvl(round(rcd_food_tolas_fgmatl_case_01.gross_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_case_01.gross_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_case_01.gross_wght,0),'FM0000000000.000');
         end if;	
		 
		 if nvl(round(rcd_food_tolas_fgmatl_case_01.net_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_case_01.net_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_case_01.net_wght,0),'FM0000000000.000');
         end if;
		 	   
		 var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.gross_wght_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.batch_mngmnt_rqrmnt_indctr),' '),1,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.order_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.base_uom),' '),3,' ');
         if nvl(rcd_food_tolas_fgmatl_case_01.shelf_life,0) = 0 then
            var_string := var_string || '9999';
         else
            var_string := var_string || to_char(rcd_food_tolas_fgmatl_case_01.shelf_life,'FM0000');
         end if;
         var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.spcl_prcrmnt_type),' '),2,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.dltn_indctr),' '),1,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.sales_unit_to_base_uom,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.units_per_inner,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.inners_per_crtn,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.units_per_crtn,0),'FM000000V000') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.rsu_ean),' '),18,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_case_01.ean_code),' '),18,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.crtns_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.lyrs_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.hght,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.length,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_case_01.width,0),'FM00000000V0');

         /*-*/
         /* Append the HDR interface data
         /*-*/
         lics_outbound_loader.append_data(var_string);

      end loop;
      close csr_food_tolas_fgmatl_case_01;

      /*-*/
      /* Retrieve the finished goods showbox material rows
      /*-*/
      open csr_food_tolas_fgmatl_show_01;
      loop
         fetch csr_food_tolas_fgmatl_show_01 into rcd_food_tolas_fgmatl_show_01;
         if csr_food_tolas_fgmatl_show_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for numeric material number
         /*-*/
         begin
            var_work := to_char(to_number(trim(rcd_food_tolas_fgmatl_show_01.matl_code)),'FM999999999999999990');
         exception
            when others then
               var_work:= rcd_food_tolas_fgmatl_show_01.matl_code;
         end;

         /*-*/
         /* Set HDR interface data
         /*-*/
         var_string := rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.rcrd_type),' '),3,' ') ||
	               rpad(nvl(trim(var_work),' '),8,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.matl_desc),' '),40,' ') ||
	               lpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.crtn_date),' '),8,'0') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.plant),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.matl_type),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.prdct_ctgry),' '),2,' ');
				   
		 if nvl(round(rcd_food_tolas_fgmatl_show_01.gross_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_show_01.gross_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_show_01.gross_wght,0),'FM0000000000.000');
         end if;	
		 
		 if nvl(round(rcd_food_tolas_fgmatl_show_01.net_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_show_01.net_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_show_01.net_wght,0),'FM0000000000.000');
         end if;
				   

	     var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.gross_wght_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.batch_mngmnt_rqrmnt_indctr),' '),1,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.order_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.base_uom),' '),3,' ');
         if nvl(rcd_food_tolas_fgmatl_show_01.shelf_life,0) = 0 then
            var_string := var_string || '9999';
         else
            var_string := var_string || to_char(rcd_food_tolas_fgmatl_show_01.shelf_life,'FM0000');
         end if;
         var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.spcl_prcrmnt_type),' '),2,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.dltn_indctr),' '),1,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.sales_unit_to_base_uom,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.units_per_inner,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.inners_per_crtn,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.units_per_crtn,0),'FM000000V000') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.rsu_ean),' '),18,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_show_01.ean_code),' '),18,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.crtns_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.lyrs_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.hght,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.lngth,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_show_01.width,0),'FM00000000V0');

         /*-*/
         /* Append the HDR interface data
         /*-*/
         lics_outbound_loader.append_data(var_string);

      end loop;
      close csr_food_tolas_fgmatl_show_01;

      /*-*/
      /* Retrieve the finished goods pack material rows
      /*-*/
      open csr_food_tolas_fgmatl_pack_01;
      loop
         fetch csr_food_tolas_fgmatl_pack_01 into rcd_food_tolas_fgmatl_pack_01;
         if csr_food_tolas_fgmatl_pack_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for numeric material number
         /*-*/
         begin
            var_work := to_char(to_number(trim(rcd_food_tolas_fgmatl_pack_01.matl_code)),'FM999999999999999990');
         exception
            when others then
               var_work:= rcd_food_tolas_fgmatl_pack_01.matl_code;
         end;

         /*-*/
         /* Set HDR interface data
         /*-*/
         var_string := rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.rcrd_type),' '),3,' ') ||
	               rpad(nvl(trim(var_work),' '),8,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.matl_desc),' '),40,' ') ||
	               lpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.crtn_date),' '),8,'0') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.plant),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.matl_type),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.prdct_ctgry),' '),2,' ') ;
				   
		 if nvl(round(rcd_food_tolas_fgmatl_pack_01.gross_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_pack_01.gross_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_pack_01.gross_wght,0),'FM0000000000.000');
         end if;	
		 
		 if nvl(round(rcd_food_tolas_fgmatl_pack_01.net_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_pack_01.net_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_pack_01.net_wght,0),'FM0000000000.000');
         end if;
				   

	     var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.gross_wght_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.batch_mngmnt_rqrmnt_indctr),' '),1,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.order_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.base_uom),' '),3,' ');
         if nvl(rcd_food_tolas_fgmatl_pack_01.shelf_life,0) = 0 then
            var_string := var_string || '9999';
         else
            var_string := var_string || to_char(rcd_food_tolas_fgmatl_pack_01.shelf_life,'FM0000');
         end if;
         var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.spcl_prcrmnt_type),' '),2,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.dltn_indctr),' '),1,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.sales_unit_to_base_uom,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.units_per_inner,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.inners_per_crtn,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.units_per_crtn,0),'FM000000V000') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.rsu_ean),' '),18,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_pack_01.ean_code),' '),18,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.crtns_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.lyrs_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.hght,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.lngth,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_pack_01.width,0),'FM00000000V0');

         /*-*/
         /* Append the HDR interface data
         /*-*/
         lics_outbound_loader.append_data(var_string);

      end loop;
      close csr_food_tolas_fgmatl_pack_01;

      /*-*/
      /* Retrieve the finished goods piece material rows
      /*-*/
      open csr_food_tolas_fgmatl_piece_01;
      loop
         fetch csr_food_tolas_fgmatl_piece_01 into rcd_food_tolas_fgmatl_piece_01;
         if csr_food_tolas_fgmatl_piece_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for numeric material number
         /*-*/
         begin
            var_work := to_char(to_number(trim(rcd_food_tolas_fgmatl_piece_01.matl_code)),'FM999999999999999990');
         exception
            when others then
               var_work:= rcd_food_tolas_fgmatl_piece_01.matl_code;
         end;

         /*-*/
         /* Set HDR interface data
         /*-*/
         var_string := rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.rcrd_type),' '),3,' ') ||
	               rpad(nvl(trim(var_work),' '),8,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.matl_desc),' '),40,' ') ||
	               lpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.crtn_date),' '),8,'0') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.plant),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.matl_type),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.prdct_ctgry),' '),2,' ');
				   
		 if nvl(round(rcd_food_tolas_fgmatl_piece_01.gross_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_piece_01.gross_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_piece_01.gross_wght,0),'FM0000000000.000');
         end if;	
		 
		 if nvl(round(rcd_food_tolas_fgmatl_piece_01.net_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_fgmatl_piece_01.net_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_fgmatl_piece_01.net_wght,0),'FM0000000000.000');
         end if;
				   

	     var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.gross_wght_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.batch_mngmnt_rqrmnt_indctr),' '),1,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.order_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.base_uom),' '),3,' ');
         if nvl(rcd_food_tolas_fgmatl_piece_01.shelf_life,0) = 0 then
            var_string := var_string || '9999';
         else
            var_string := var_string || to_char(rcd_food_tolas_fgmatl_piece_01.shelf_life,'FM0000');
         end if;
         var_string := var_string || rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.spcl_prcrmnt_type),' '),2,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.dltn_indctr),' '),1,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.sales_unit_to_base_uom,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.units_per_inner,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.inners_per_crtn,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.units_per_crtn,0),'FM000000V000') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.rsu_ean),' '),18,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_fgmatl_piece_01.ean_code),' '),18,' ') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.crtns_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.lyrs_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.hght,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.lngth,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_fgmatl_piece_01.width,0),'FM00000000V0');

         /*-*/
         /* Append the HDR interface data
         /*-*/
         lics_outbound_loader.append_data(var_string);

      end loop;
      close csr_food_tolas_fgmatl_piece_01;

      /*-*/
      /* Retrieve the inbound material rows
      /*-*/
      open csr_food_tolas_inb_matl_01;
      loop
         fetch csr_food_tolas_inb_matl_01 into rcd_food_tolas_inb_matl_01;
         if csr_food_tolas_inb_matl_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for numeric material number
         /*-*/
         begin
            var_work := to_char(to_number(trim(rcd_food_tolas_inb_matl_01.matl_code)),'FM999999999999999990');
         exception
            when others then
               var_work:= rcd_food_tolas_inb_matl_01.matl_code;
         end;

         /*-*/
         /* Set HDR interface data
         /*-*/
         var_string := rpad(nvl(trim(rcd_food_tolas_inb_matl_01.rcrd_type),' '),3,' ') ||
	               rpad(nvl(trim(var_work),' '),8,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.matl_desc),' '),40,' ') ||
	               lpad(nvl(trim(rcd_food_tolas_inb_matl_01.crtn_date),' '),8,'0') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.plant),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.matl_type),' '),4,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.prdct_ctgry),' '),2,' ');
				   
		 if nvl(round(rcd_food_tolas_inb_matl_01.gross_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_inb_matl_01.gross_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_inb_matl_01.gross_wght,0),'FM0000000000.000');
         end if;	
		 
		 if nvl(round(rcd_food_tolas_inb_matl_01.net_wght,3),0) = 0 then
            var_string := var_string || to_char(nvl(ceil(rcd_food_tolas_inb_matl_01.net_wght*1000)/1000,0),'FM0000000000.000');  
         else
            var_string := var_string || to_char(nvl(rcd_food_tolas_inb_matl_01.net_wght,0),'FM0000000000.000');
         end if;
				   

	     var_string := var_string || rpad(nvl(trim(rcd_food_tolas_inb_matl_01.declrd_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.batch_mngmnt_rqrmnt_indctr),' '),1,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.order_uom),' '),3,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.base_uom),' '),3,' ');
         if nvl(rcd_food_tolas_inb_matl_01.shelf_life,0) = 0 then
            var_string := var_string || '9999';
         else
            var_string := var_string || to_char(rcd_food_tolas_inb_matl_01.shelf_life,'FM0000');
         end if;
         var_string := var_string || rpad(nvl(trim(rcd_food_tolas_inb_matl_01.spcl_prcrmnt_type),' '),2,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.dltn_indctr),' '),1,' ') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.sales_unit_to_base_uom,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.units_per_inner,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.inners_per_crtn,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.units_per_crtn,0),'FM000000V000') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.rsu_ean),' '),18,' ') ||
	               rpad(nvl(trim(rcd_food_tolas_inb_matl_01.ean_code),' '),18,' ') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.crtns_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.lyrs_per_pllt,0),'FM000000V000') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.hght,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.lngth,0),'FM00000000V0') ||
	               to_char(nvl(rcd_food_tolas_inb_matl_01.width,0),'FM00000000V0');

         /*-*/
         /* Append the HDR interface data
         /*-*/
         lics_outbound_loader.append_data(var_string);

      end loop;
      close csr_food_tolas_inb_matl_01;

      /*-*/
      /* Append the CTL interface data
      /*-*/
      lics_outbound_loader.append_data('CTL' || to_char(var_instance,'FM000000000000000'));

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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

end ics_ladstola01;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_ladstola01 for ics_app.ics_ladstola01;

grant execute on ics_ladstola01 to public;