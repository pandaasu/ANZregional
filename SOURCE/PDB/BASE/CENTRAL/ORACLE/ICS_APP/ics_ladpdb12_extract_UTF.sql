--
-- ICS_LADPDB12_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ics_ladpdb12_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ics_ladpdb12_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Vendor Company Data for Plant databases 

  EXECUTE - 
    Send Vendor Company data since last successful send 
    
  EXECUTE - 
    Send Vendor Company data based on the specified action.       

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all vendor comp data since last successful send
    *VENDOR - send vendor comp data matching a given vendor code
    *HISTORY - all modified since modified date 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *VENDOR = vendor code 
      - *HISTORY = number of days

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to (configured in Data Store Configuration).
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand
      - *MCH = HUA Plant DB (China)

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 
  2008/09   Trevor Keon    Change criteria so deleted items are sent
  2010/09   Ben Halicki    Updated to send for configured company codes only
  2011/08   Vivian Huang   Modified for outbound interface trigger
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ics_ladpdb12_extract;
/


--
-- ICS_LADPDB12_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladpdb12_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;  
  var_vendor_code bds_vend_comp.vendor_code%type;
  
  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB12';  
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute is
  begin
    /*-*/
    /* Set global variables  
    /*-*/    
    var_update_lastrun := true;
          
    execute('*ALL',null,'*ALL');
  end;  

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_site      varchar2(10);
    var_start     boolean := false;
    var_intfc     varchar2(20);
    
    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_intfc is
        select 
            dsv_group as site, 
            dsv_value as intfc_extn 
        from 
            table (lics_datastore.retrieve_group('PDB','INTFC_EXTN',NULL)) t01
        where 
            (var_site = '*ALL' or '*' || t01.dsv_group = var_site);
            
    rcd_intfc csr_intfc%rowtype;              
    
    cursor csr_trigger is
        select dsv_value as intfc_trigger 
          from table (lics_datastore.retrieve_value('PDB',rcd_intfc.site,'INTFC_TRIGGER')) t01;
    rcd_trigger csr_trigger%rowtype;     
  
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*VENDOR' 
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *VENDOR or *HISTORY');
    end if;
    
    if ( var_action = '*VENDOR' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *VENDOR actions.');
    elsif ( var_action = '*HISTORY' and (var_data is null or to_number(var_data) <= 0) ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;     
    
    open csr_intfc;
    loop
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
        
        /*-*/
        /* Get last run date  
        /*-*/    
        if ( var_update_lastrun = true ) then
            var_lastrun_date := lics_last_run_control.get_last_run(var_intfc);
        end if;
        
        var_start_date := sysdate;
        var_start := execute_extract(var_action, var_data, rcd_intfc.site);      

        /*-*/
        /* ensure data was returned in the cursor before creating interfaces 
        /* to send to the specified site(s) 
        /*-*/           
        if ( var_start = true ) then
           open csr_trigger;
           fetch csr_trigger into rcd_trigger;
           if csr_trigger%notfound then
              rcd_trigger.intfc_trigger := 'Y';
           end if;
           close csr_trigger;
           execute_send(var_intfc, rcd_trigger.intfc_trigger);
        end if;
        
        if ( var_update_lastrun = true ) then
            lics_last_run_control.set_last_run(var_intfc,var_start_date);
        end if;  
        
    end loop;
    
    /*-*/
    /* if no valid sites were found, raise exception
    /*-*/
    if (csr_intfc%rowcount=0 and var_site='*ALL') then
        raise_application_error(-20000, 'No valid plant databases have been configured via Data Store Configuration.');
    end if;
    
    if (csr_intfc%rowcount=0 and var_site!='*ALL') then
        raise_application_error(-20000, 'Site parameter (' || par_site || ') has not been configured via Data Store Configuration.');
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
    /* Save the exception 
    /*-*/
    var_exception := substr(sqlerrm, 1, 1024);

    /*-*/
    /* Finalise the outbound loader when required 
    /*-*/
    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.add_exception(var_exception);
      lics_outbound_loader.finalise_interface;
    end if;

    /*-*/
    /* Raise an exception to the calling application 
    /*-*/
    raise_application_error(-20000, 'ics_ladpdb12_extract - ' || 'vendor_code: ' || var_vendor_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_vend_comp is
      select t01.vendor_code as vendor_code, 
        t02.company_code as company_code, 
        to_char(t02.create_date,'yyyymmddhh24miss') as create_date, 
        t02.create_user as create_user,
        t02.posting_block_flag as posting_block_flag, 
        t02.deletion_flag as deletion_flag, 
        t02.assignment_sort_key as assignment_sort_key,
        t02.reconciliation_account as reconciliation_account, 
        t02.authorisation_group as authorisation_group, 
        t02.interest_calc_ind as interest_calc_ind,
        t02.payment_method as payment_method, 
        t02.clearing_flag as clearing_flag, 
        t02.payment_block_flag as payment_block_flag, 
        t02.payment_terms as payment_terms,
        t02.shipper_account as shipper_account, 
        t02.vendor_clerk as vendor_clerk, 
        t02.planning_group as planning_group,  
        t02.account_clerk_code as account_clerk_code,
        t02.head_office_account as head_office_account, 
        t02.alternative_payee_account as alternative_payee_account, 
        to_char(t02.interest_calc_key_date,'yyyymmddhh24miss') as interest_calc_key_date,
        t02.interest_calc_freq as interest_calc_freq, 
        to_char(t02.nterest_calc_run_date,'yyyymmddhh24miss') as nterest_calc_run_date,
        t02.local_process_flag as local_process_flag,
        t02.bill_of_exchange_limit as bill_of_exchange_limit, 
        t02.probable_check_paid_time as probable_check_paid_time, 
        t02.inv_crd_check_flag as inv_crd_check_flag,
        t02.tolerance_group_code as tolerance_group_code, 
        t02.house_bank_key as house_bank_key, 
        t02.pay_item_separate_flag as pay_item_separate_flag,
        t02.withhold_tax_certificate as withhold_tax_certificate, 
        to_char(t02.withhold_tax_valid_date,'yyyymmddhh24miss') as withhold_tax_valid_date, 
        t02.withhold_tax_code as withhold_tax_code,
        t02.subsidy_flag as subsidy_flag, 
        t02.minority_indicator as minority_indicator, 
        t02.previous_record_number as previous_record_number,
        t02.payment_grouping_code as payment_grouping_code, 
        t02.dunning_notice_group_code as dunning_notice_group_code, 
        t02.recipient_type as recipient_type,
        t02.withhold_tax_exemption as withhold_tax_exemption, 
        t02.withhold_tax_country as withhold_tax_country, 
        t02.edi_payment_advice as edi_payment_advice,
        t02.release_approval_group as release_approval_group, 
        t02.accounting_fax as accounting_fax, 
        t02.accounting_url as accounting_url, 
        t02.credit_payment_terms as credit_payment_terms, 
        t02.income_tax_activity_code as income_tax_activity_code, 
        t02.employ_tax_distbn_type as employ_tax_distbn_type,
        t02.periodic_account_statement as periodic_account_statement, 
        to_char(t02.certification_date,'yyyymmddhh24miss') as certification_date,
        t02.invoice_tolerance_group as invoice_tolerance_group, 
        t02.personnel_number as personnel_number, 
        t02.deletion_block_flag as deletion_block_flag,
        t02.accounting_phone as accounting_phone, 
        t02.execution_flag as execution_flag, 
        t02.vendor_name_01 as vendor_name_01, 
        t02.vendor_name_02 as vendor_name_02,
        t02.vendor_name_03 as vendor_name_03, 
        t02.vendor_name_04 as vendor_name_04
      from bds_vend_header t01,
        bds_vend_comp t02
      where t01.vendor_code = t02.vendor_code
        and t02.company_code in 
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_COMPANIES'))
        )
        and 
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
          or (par_action = '*VENDOR' and ltrim(t01.vendor_code,'0') = ltrim(par_data,'0'))
          or (par_action = '*HISTORY' and trunc(t01.bds_lads_date) >= trunc(sysdate-to_number(par_data)))
        );        
        
    rcd_bds_vend_comp csr_bds_vend_comp%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_vend_comp;
    loop
    
      fetch csr_bds_vend_comp into rcd_bds_vend_comp;
      exit when csr_bds_vend_comp%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current customer code for error message purposes 
      /*-*/
      var_vendor_code := rcd_bds_vend_comp.vendor_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_vend_comp.vendor_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.company_code),' '),6,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.create_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.create_user),' '),12,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.posting_block_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.deletion_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.assignment_sort_key),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.reconciliation_account),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.authorisation_group),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.interest_calc_ind),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.payment_method),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.clearing_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.payment_block_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.payment_terms),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.shipper_account),' '),12,' ')
        || nvl(rcd_bds_vend_comp.vendor_clerk,' ') || rpad(' ',15-length(nvl(rcd_bds_vend_comp.vendor_clerk,' ')),' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.planning_group),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.account_clerk_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.head_office_account),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.alternative_payee_account),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.interest_calc_key_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.interest_calc_freq),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.nterest_calc_run_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.local_process_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.bill_of_exchange_limit),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.probable_check_paid_time),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.inv_crd_check_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.tolerance_group_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.house_bank_key),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.pay_item_separate_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.withhold_tax_certificate),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.withhold_tax_valid_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.withhold_tax_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.subsidy_flag),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.minority_indicator),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.previous_record_number),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.payment_grouping_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.dunning_notice_group_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.recipient_type),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.withhold_tax_exemption),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.withhold_tax_country),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.edi_payment_advice),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.release_approval_group),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.accounting_fax),' '),31,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.accounting_url),' '),130,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.credit_payment_terms),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.income_tax_activity_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.employ_tax_distbn_type),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.periodic_account_statement),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.certification_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.invoice_tolerance_group),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.personnel_number),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.deletion_block_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.accounting_phone),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.execution_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.vendor_name_01),' '),35,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.vendor_name_02),' '),35,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.vendor_name_03),' '),35,' ')
        || rpad(nvl(to_char(rcd_bds_vend_comp.vendor_name_04),' '),35,' ');

    end loop;
    close csr_bds_vend_comp;

    return var_result;
    
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
          if upper(par_trigger) = 'Y' then
             var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
          else
             var_instance := lics_outbound_loader.create_interface(par_interface);
          end if;
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end ics_ladpdb12_extract;
/


--
-- ICS_LADPDB12_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB12_EXTRACT FOR ICS_APP.ICS_LADPDB12_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB12_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB12_EXTRACT TO LICS_APP;

