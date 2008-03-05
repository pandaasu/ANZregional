create or replace package plant_customer_address_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_atllad15_interface 
  Owner   : ics_app 

  Description 
  ----------- 
  Customer Address Data for Plant databases 

  1. PAR_SITE (MANDATORY) 

    *ALL - extract and send address customer data to all assigned plant databases 
    *SNACK - extract and send address customer data to MCA and SCO plant databases 
    
  2. PAR_CUST_CODE (MANDATORY) 
    
    Set the customer code to get the address customer data for to send to the 
  specified plant databases 
    *ALL - extract all address customer data to the specified plant databases 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/ 

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2, par_cust_code in varchar2);

end plant_customer_address_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body plant_atllad15_interface as

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  procedure execute_extract(par_interface in varchar2, par_cust_code in varchar2);

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_site in varchar2, par_cust_code in varchar2) is
  
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Validate the parameters
    /*-*/
    if (upper(par_site) != '*SNACK' and 
        upper(par_site) != '*ALL') then
      raise_application_error(-20000, 'Action parameter (' || par_site || ') must be *ALL or *SNACK');
    elsif not (par_cust_code = '*ALL' or length(par_cust_code) > 0) then
      raise_application_error(-20000, 'Package: plant_atllad15_interface parameter:' || par_cust_code || ' must be *ALL or a customer code.');
    end if;

    /*-*/
    /* Execute extract routines
    /*-*/
    if upper(par_site) = '*ALL' or upper(par_site) = '*SNACK' then
       execute_extract('LADPDB03.5', par_cust_code); -- MCA/Ballarat 
       execute_extract('LADPDB03.6', par_cust_code); -- SCO/Scoresby 
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
      /* Finalise the outbound loader when required 
      /*-*/
      if lics_outbound_loader.is_created = true then
       lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
       lics_outbound_loader.finalise_interface;
      end if;

      /*-*/
      /* Raise an exception to the calling application 
      /*-*/
      raise_application_error(-20000, 'FATAL ERROR - ATLLAD15 Adress Customer - ' || substr(SQLERRM, 1, 1024));

  /*-------------*/
  /* End routine */
  /*-------------*/
  end execute;
  
  
  
  procedure execute_extract(par_interface in varchar2, par_cust_code in varchar2) is
    /*-*/
    /* Local definitions
    /*-*/
    var_instance number(15,0);
    var_start boolean;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_addr_cust is
      select customer_code, 
        address_version, 
        to_char(valid_from_date,'yyyymmdd') as valid_from_date, 
        to_char(valid_to_date,'yyyymmdd') as valid_to_date,
        title,
        name, 
        name_02, 
        name_03, 
        name_04, 
        city, 
        district, 
        city_post_code,
        po_box_post_code, 
        company_post_code, 
        po_box, 
        po_box_minus_number,
        po_box_city, 
        po_box_region, 
        po_box_country, 
        po_box_country_iso,
        transportation_zone, 
        street,
        house_number, 
        location, 
        building, 
        floor,
        room_number, 
        country, 
        country_iso, 
        language, 
        language_iso, 
        region_code,
        search_term_01, 
        search_term_02, 
        phone_number, 
        phone_extension,
        phone_full_number, 
        fax_number, 
        fax_extension, 
        fax_full_number
      from bds_addr_customer t01
      where (ltrim(t01.customer_code, '0') = ltrim(par_cust_code,'0') or par_cust_code = '*ALL')
        and exists 
        (
          select 1
          from bds_cust_sales_area t02
          where t02.sales_org_code in ('147', '149')
            and t02.customer_code = t01.customer_code
        );
    rec_addr_cust csr_addr_cust%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
 begin

    /*-*/
    /* Initialise variables
    /*-*/
    var_start := true;

    /*-*/
    /* Open Cursor for output
    /*-*/
    open csr_addr_cust;
    loop
       fetch csr_addr_cust into rec_addr_cust;
       if (csr_addr_cust%notfound) then
          exit;
       end if;

       /*-*/
       /* Create Outbound Interface if record(s) exist
       /*-*/
       if (var_start) then

          var_instance := lics_outbound_loader.create_interface('LADPDB',null,'LADCAD01.dat');

          var_start := false;

       end if;

       /*-*/
       /* Append Data Lines
       /*-*/
       lics_outbound_loader.append_data('HDR' ||
                                        rpad(to_char(nvl(rec_addr_cust.sap_material_code,' ')),18, ' ') ||
                                        nvl(rec_addr_cust.material_desc_ch,' ')||rpad(' ',40-length(nvl(rec_addr_cust.material_desc_ch,' ')),' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.material_desc_en,' ')),40, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.mars_rprsnttv_item_code,' ')),18, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.net_weight,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.gross_weight,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.matl_length,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.width,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.height,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.pcs_per_case,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.outers_per_case,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.cases_per_pallet,' ')),16, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_essnc_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_essnc_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_essnc_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_flag_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_flag_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_flag_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_sub_flag_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_sub_flag_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.brand_sub_flag_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bus_sgmnt_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bus_sgmnt_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bus_sgmnt_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.mkt_sgmnt_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.mkt_sgmnt_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.mkt_sgmnt_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_ctgry_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_ctgry_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_ctgry_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_type_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_type_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_type_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.cnsmr_pack_frmt_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.cnsmr_pack_frmt_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.cnsmr_pack_frmt_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.ingred_vrty_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.ingred_vrty_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.ingred_vrty_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_size_grp_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_size_grp_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_size_grp_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_pack_size_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_pack_size_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.prdct_pack_size_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.sales_organisation_135,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.sales_organisation_234,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.base_uom_code,' ')),3, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.material_type_code,' ')),4, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.material_type_desc,' ')),40, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.material_sts_code,' ')),8, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bdt_code,' ')),2, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bdt_desc,' ')),30, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.bdt_abbrd_desc,' ')),12, ' ') ||
                                        rpad(to_char(nvl(rec_addr_cust.tax_classification,' ')),1, ' '));


       /*-*/
       /* Open Cursor for Inventory Line Output
       /*-*/
       open csr_matl_invntry;
       loop
          fetch csr_matl_invntry into rec_matl_invntry;
          if (csr_matl_invntry%notfound) then
             exit;
          end if;

          /*-*/
          /* Append Data Lines
          /*-*/
          lics_outbound_loader.append_data('INV' ||
                                           rpad(to_char(nvl(rec_matl_invntry.sap_company_code,' ')),6, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.sap_plant_code,' ')),4, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.inv_exp_date,' ')),8, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.inv_unreleased_qty,' ')),16, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.inv_reserved_qty,' ')),16, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.inv_class01,' ')),3, ' ') ||
                                           rpad(to_char(nvl(rec_matl_invntry.inv_class02,' ')),3, ' '));

       end loop;
       close csr_matl_invntry;

    end loop;
    close csr_addr_cust;

    /*-*/
    /* Finalise Interface
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

       /*-*/
       /* Rollback the database
       /*-*/
       rollback;

       /*-*/
       /* Finalise the outbound loader when required
       /*-*/
       if lics_outbound_loader.is_created = true then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;

       /*-*/
       /* Raise an exception to the calling application
       /*-*/
       raise_application_error(-20000, 'FATAL ERROR - LADCAD01 MATERIAL - ' || substr(SQLERRM, 1, 1024));

 /*-------------*/
 /* End routine */
 /*-------------*/
 end execute;

end plant_atllad15_interface;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym plant_atllad15_interface for site_app.plant_atllad15_interface;
grant execute on plant_atllad15_interface to public;
