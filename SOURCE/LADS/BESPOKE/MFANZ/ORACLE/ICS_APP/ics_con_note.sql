/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_con_note
 Owner   : ics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Interface Control System - ics_con_note - Consignment Note Lookup

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_con_note as

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve(par_belnr in varchar2, par_vbeln in varchar2) return varchar2;

end ics_con_note;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_con_note as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /************************************************/
   /* This procedure performs the retrieve routine */
   /************************************************/
   function retrieve(par_belnr in varchar2, par_vbeln in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_belnr lads_inv_hdr.belnr%type;
      var_vbeln lads_del_hdr.vbeln%type;
      var_return varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_inv_hdr_01 is
         select *
           from lads_inv_hdr t01
          where t01.belnr = var_belnr;
      rcd_lads_inv_hdr_01 csr_lads_inv_hdr_01%rowtype;

      cursor csr_lads_inv_ref_01 is
         select t01.refnr
           from lads_inv_ref t01
          where t01.belnr = var_belnr
            and t01.qualf = '012';
      rcd_lads_inv_ref_01 csr_lads_inv_ref_01%rowtype;

      cursor csr_lads_inv_ref_02 is
         select t01.belnr
           from lads_inv_ref t01
          where t01.refnr = var_vbeln
            and t01.qualf = '012';
      rcd_lads_inv_ref_02 csr_lads_inv_ref_02%rowtype;

      cursor csr_lads_del_hdr_01 is
         select *
           from lads_del_hdr t01
          where t01.vbeln = var_vbeln;
      rcd_lads_del_hdr_01 csr_lads_del_hdr_01%rowtype;

      cursor csr_lads_shp_dlv_01 is
         select t01.tknum,
                t01.vstel
           from lads_shp_dlv t01
          where t01.vbeln = var_vbeln;
      rcd_lads_shp_dlv_01 csr_lads_shp_dlv_01%rowtype;

      cursor csr_lads_shp_dlv_02 is
         select min(t01.vbeln) as con_note
           from lads_shp_dlv t01
          where t01.tknum = rcd_lads_shp_dlv_01.tknum
            and t01.vstel = rcd_lads_shp_dlv_01.vstel;
      rcd_lads_shp_dlv_02 csr_lads_shp_dlv_02%rowtype;

      cursor csr_lads_shp_har_01 is
         select t01.name1
           from lads_shp_har t01
          where t01.tknum = rcd_lads_shp_dlv_01.tknum
            and t01.partner_q = 'SP';
      rcd_lads_shp_har_01 csr_lads_shp_har_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return value
      /*-*/
      var_return := null;

      /*-*/
      /* Initialise the parameter values
      /*-*/
      var_belnr := par_belnr;
      var_vbeln := par_vbeln;
      if var_belnr is null and var_vbeln is null then
         var_return := 'Either invoice number or delivery number must be supplied';
      end if;
      if not(var_belnr is null) and not(var_vbeln is null) then
         var_return := 'Only invoice number or delivery number can be supplied';
      end if;
      if not(var_return is null) then
         return var_return;
      end if;

      /*-*/
      /* Retrieve the invoice when requested
      /*-*/
      if not(var_belnr is null) then

         open csr_lads_inv_hdr_01;
         fetch csr_lads_inv_hdr_01 into rcd_lads_inv_hdr_01;
         if csr_lads_inv_hdr_01%notfound then
            var_return := 'Invoice number ' || var_belnr || ' not found';
         else
            open csr_lads_inv_ref_01;
            fetch csr_lads_inv_ref_01 into rcd_lads_inv_ref_01;
            if csr_lads_inv_ref_01%notfound then
               var_return := 'Unable to find delivery reference for invoice number ' || var_belnr;
            else
               var_vbeln := rcd_lads_inv_ref_01.refnr;
            end if;
            close csr_lads_inv_ref_01;
         end if;
         close csr_lads_inv_hdr_01;
         if not(var_return is null) then
            return var_return;
         end if;

      /*-*/
      /* Retrieve the delivery when requested
      /*-*/
      elsif not(var_vbeln is null) then

         open csr_lads_del_hdr_01;
         fetch csr_lads_del_hdr_01 into rcd_lads_del_hdr_01;
         if csr_lads_del_hdr_01%notfound then
            var_return := 'Delivery number ' || var_vbeln || ' not found';
         else
            open csr_lads_inv_ref_02;
            fetch csr_lads_inv_ref_02 into rcd_lads_inv_ref_02;
            if csr_lads_inv_ref_02%notfound then
               var_return := 'Unable to find invoice number for delivery reference ' || var_vbeln;
            else
               var_belnr := rcd_lads_inv_ref_02.belnr;
            end if;
            close csr_lads_inv_ref_02;
         end if;
         close csr_lads_del_hdr_01;
         if not(var_return is null) then
            return var_return;
         end if;

      end if;

      /*-*/
      /* Retrieve the shipment detail and consignment note
      /*-*/
      open csr_lads_shp_dlv_01;
      fetch csr_lads_shp_dlv_01 into rcd_lads_shp_dlv_01;
      if csr_lads_shp_dlv_01%notfound then
         var_return := 'Shipment delivery not found for delivery number ' || var_vbeln;
      else
         open csr_lads_shp_dlv_02;
         fetch csr_lads_shp_dlv_02 into rcd_lads_shp_dlv_02;
         if csr_lads_shp_dlv_02%notfound or rcd_lads_shp_dlv_02.con_note is null then
            var_return := 'Unable to find shipment delivery for shipment number ' || rcd_lads_shp_dlv_01.tknum || ' ship point ' || rcd_lads_shp_dlv_01.vstel;
         end if;
         close csr_lads_shp_dlv_02;
         open csr_lads_shp_har_01;
         fetch csr_lads_shp_har_01 into rcd_lads_shp_har_01;
         if csr_lads_shp_har_01%notfound then
            rcd_lads_shp_har_01.name1 := 'Carrier not found';
         end if;
         close csr_lads_shp_har_01;
      end if;
      close csr_lads_shp_dlv_01;
      if not(var_return is null) then
         return var_return;
      end if;

      /*-*/
      /* Set the return value
      /*-*/
      var_return := 'Invoice number(' || var_belnr || ') ' ||
                    'Delivery number(' || var_vbeln || ') ' ||
                    'Shipment number(' || rcd_lads_shp_dlv_01.tknum || ') ' ||
                    'Consignment note(' || rcd_lads_shp_dlv_02.con_note || ') ' ||
                    'Carrier(' || rcd_lads_shp_har_01.name1 || ')';

      /*-*/
      /* Return
      /*-*/
      return var_return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ICS_CON_NOTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve;

end ics_con_note;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_con_note for ics_app.ics_con_note;
grant execute on ics_con_note to public;