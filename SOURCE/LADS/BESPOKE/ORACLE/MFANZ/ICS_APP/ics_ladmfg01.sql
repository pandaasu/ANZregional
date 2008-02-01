/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_ladmfg01
 Owner   : ics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Interface Control System - ladmfg01 - Vendor to MFGPRO

 This interface only sends all vendor updates to the MFGPRO system once when they are made
 in LADS. The vendor is inserted into the cross reference table when not found.

 This interface is called from both the vendor interface monitor (LADS_ATLLAD19_MONITOR)
 and the address interface monitor (LADS_ATLLAD15_MONITOR). The reason for this being
 that the vendor and address data arrive in LADS on different IDOC messages. As this
 interface relies on both vendor and related address information a test is made to
 ensure both sets of data are present before processing. As the vendor and address data
 can arrive in any sequence into LADS both interfaces must call this package.

 YYYY/MM   Author            Description
 -------   ------            -----------
 2004/06   Steve Gregan      Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_ladmfg01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_lifnr in varchar2);

end ics_ladmfg01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_ladmfg01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_lifnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_string varchar2(4000);
      var_lookup varchar2(64);
      var_vendor varchar2(8);
      var_credit_terms varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_det_01 is
         select min(t01.xrf_source) as xrf_source
           from lads_xrf_det t01
          where t01.xrf_code = 'MFA_VENDOR'
            and t01.xrf_target = var_lookup;
      rcd_lads_xrf_det_01 csr_lads_xrf_det_01%rowtype;

      cursor csr_lads_xrf_det_02 is
         select t01.xrf_target
           from lads_xrf_det t01
          where t01.xrf_code = 'ATLAS_MFGPRO_TERMS'
            and t01.xrf_source = var_lookup;
      rcd_lads_xrf_det_02 csr_lads_xrf_det_02%rowtype;

      cursor csr_lads_ven_hdr is
	 select 'Y' as found_flag
	   from lads_ven_hdr t01
          where t01.lifnr = par_lifnr;
      rcd_lads_ven_hdr csr_lads_ven_hdr%rowtype;

      cursor csr_lads_adr_hdr is
	 select 'Y' as found_flag
	   from lads_adr_hdr t01
          where t01.obj_type = 'LFA1'
            and t01.obj_id = par_lifnr
            and t01.context = 1;
      rcd_lads_adr_hdr csr_lads_adr_hdr%rowtype;

      cursor csr_ven_mfgpro is
	select
	   t01.lifnr,
           t01.stceg,
           t02.waers,
           t02.verkf,
           t02.zterm,
	   t03.name,
	   t03.city,
	   t03.district,
	   t03.postl_cod1,
           t03.house_no,
	   t03.street,
	   t03.region,
	   t03.country,
	   t03.langu,
           t03.po_box_cit,
           t03.postl_cod2,
           t03.po_box,
           t03.pobox_ctry,
	   t04.telephone,
	   t05.fax_no
	from lads_ven_hdr t01,
             (select lifnr, waers,verkf, zterm from lads_ven_poh where pohseq = 1) t02,
             (select obj_id, name, city, district, postl_cod1, house_no, street, region, country, langu, po_box_cit, postl_cod2, po_box, pobox_ctry
                from lads_adr_det where obj_type = 'LFA1' and context = 1 and detseq = 1) t03,
             (select obj_id, telephone from lads_adr_tel where obj_type = 'LFA1' and context = 1 and telseq = 1) t04,
             (select obj_id, fax_no from lads_adr_fax where obj_type = 'LFA1' and context = 1 and faxseq = 1) t05
        where t01.lifnr = t02.lifnr(+)
          and t01.lifnr = t03.obj_id(+)
          and t01.lifnr = t04.obj_id(+)
          and t01.lifnr = t05.obj_id(+)
          and t01.lifnr = par_lifnr;
      rcd_ven_mfgpro csr_ven_mfgpro%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Check for existing vendor in LADS
      /* **note** address could come before vendor
      /*-*/
      open csr_lads_ven_hdr;
      fetch csr_lads_ven_hdr into rcd_lads_ven_hdr;
      if csr_lads_ven_hdr%notfound then
         rcd_lads_ven_hdr.found_flag := 'N';
      end if;
      close csr_lads_ven_hdr;

      /*-*/
      /* Check for existing vendor address in LADS
      /* **note** vendor could come before address
      /*-*/
      open csr_lads_adr_hdr;
      fetch csr_lads_adr_hdr into rcd_lads_adr_hdr;
      if csr_lads_adr_hdr%notfound then
         rcd_lads_adr_hdr.found_flag := 'N';
      end if;
      close csr_lads_adr_hdr;

      /*-*/
      /* Process when both vendor and address in LADS
      /*-*/
      if rcd_lads_ven_hdr.found_flag = 'Y' and
         rcd_lads_adr_hdr.found_flag = 'Y' then

         /*-*/
         /* Retrieve the vendor data
         /*-*/
         open csr_ven_mfgpro;
         fetch csr_ven_mfgpro into rcd_ven_mfgpro;
         if csr_ven_mfgpro%found then

            /*-*/
            /* Check for existing vendor cross reference
            /*-*/
            var_vendor := substr(rcd_ven_mfgpro.lifnr,3,8);
            var_lookup := substr(rcd_ven_mfgpro.lifnr,3,8);
            open csr_lads_xrf_det_01;
            fetch csr_lads_xrf_det_01 into rcd_lads_xrf_det_01;
            if csr_lads_xrf_det_01%found
            and not(rcd_lads_xrf_det_01.xrf_source is null) then
               var_vendor := rcd_lads_xrf_det_01.xrf_source;
            else
               insert into lads_xrf_det values('MFA_VENDOR',var_vendor,var_vendor);
               commit;
            end if;
            close csr_lads_xrf_det_01;

            /*-*/
            /* Check for credit terms cross reference
            /*-*/
            var_credit_terms := 'I07';
            var_lookup := rcd_ven_mfgpro.zterm;
            open csr_lads_xrf_det_02;
            fetch csr_lads_xrf_det_02 into rcd_lads_xrf_det_02;
            if csr_lads_xrf_det_02%found then
               var_credit_terms := rcd_lads_xrf_det_02.xrf_target;
            end if;
            close csr_lads_xrf_det_02;

            /*-*/
            /* Initialise the output string
            /*-*/
            var_string := rpad(nvl(var_vendor,' '),8,' ') ||
                          rpad(' ',1,' ') ||
                          rpad('no',3,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.name,1,28),' '),28,' ');
            if substr(trim(rcd_ven_mfgpro.house_no) || trim(rcd_ven_mfgpro.street),1,28) is null then
               var_string := var_string ||
                             rpad('PO BOX ' || rcd_ven_mfgpro.po_box,28,' ');
            else
               var_string := var_string ||
                             rpad(substr(trim(rcd_ven_mfgpro.house_no) || ' ' || trim(rcd_ven_mfgpro.street),1,28),28,' ');
            end if;
            var_string := var_string ||
                          rpad(' ',28,' ') ||
                          rpad(' ',28,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.city,1,20),nvl(substr(rcd_ven_mfgpro.po_box_cit,1,20),' ')),20,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.region,1,4),' '),4,' ') ||
                          rpad(nvl(rcd_ven_mfgpro.postl_cod1,nvl(rcd_ven_mfgpro.postl_cod2,' ')),10,' ') ||
                          lpad('0',2,' ') ||
                          rpad('AUS',3,' ') ||
                          rpad('AUSTRALIA',28,' ') ||
                          rpad(' ',20,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.verkf,1,24),' '),24,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.telephone,1,20),' '),20,' ') ||
                          rpad(' ',4,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.fax_no,1,20),' '),20,' ') ||
                          rpad(' ',24,' ') ||
                          rpad(' ',20,' ') ||
                          rpad(' ',4,' ') ||
                          rpad(' ',20,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.name,1,28),' '),28,' ') ||
                          rpad(' ',4,' ') ||
                          rpad('99990000',8,' ') ||
                          rpad(' ',4,' ') ||
                          rpad('05300000',8,' ') ||
                          rpad(' ',4,' ') ||
                          rpad(' ',20,' ') ||
                          rpad(' ',40,' ') ||
                          rpad('C1',2,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.waers,1,3),'AUD'),3,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.verkf,1,24),' '),24,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.verkf,1,24),' '),24,' ') ||
                          lpad('1',2,' ') ||
                          rpad(' ',2,' ') ||
                          rpad(substr(var_credit_terms,1,8),8,' ') ||
                          rpad(' ',6,' ') ||
                          rpad(' ',8,' ') ||
                          rpad('no',3,' ') ||
                          rpad('no',3,' ') ||
                          rpad('yes',3,' ') ||
                          rpad(nvl(substr(rcd_ven_mfgpro.stceg,1,18),' '),18,' ') ||
                          rpad(' ',10,' ') ||
                          rpad('no',3,' ') ||
                          rpad('no',3,' ') ||
                          rpad('AUST',16,' ') ||
                          rpad('T1',3,' ') ||
                          rpad('OTH',8,' ') ||
                          rpad('no',3,' ');

            /*-*/
            /* Create the new interface (LADMFG01)
            /*-*/
            var_instance := lics_outbound_loader.create_interface('LADMFG01');

            /*-*/
            /* Append interface data
            /*-*/
            lics_outbound_loader.append_data(var_string);

            /*-*/
            /* Finalise the interface
            /*-*/
            lics_outbound_loader.finalise_interface;

            /*-*/
            /* Create the new interface (LADMFG02)
            /*-*/
            var_instance := lics_outbound_loader.create_interface('LADMFG02');

            /*-*/
            /* Append interface data
            /*-*/
            lics_outbound_loader.append_data(var_string);

            /*-*/
            /* Finalise the interface
            /*-*/
            lics_outbound_loader.finalise_interface;

         end if;
         close csr_ven_mfgpro;

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

end ics_ladmfg01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_ladmfg01;
create public synonym ics_ladmfg01 for ics_app.ics_ladmfg01;
grant execute on ics_ladmfg01 to public;