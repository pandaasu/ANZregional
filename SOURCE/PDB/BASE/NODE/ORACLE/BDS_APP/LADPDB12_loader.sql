/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb12_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound Vendor comp data loader

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  04-Apr-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.ladpdb12_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb12_loader; 
/

create or replace package body bds_app.ladpdb12_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_hdr(par_record in varchar2);

  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
  
  rcd_hdr bds_refrnc_hdr_altrnt%rowtype;

  /************************************************/
  /* This procedure performs the on start routine */
  /************************************************/
  procedure on_start is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Initialise the transaction variables 
    /*-*/
    var_trn_start := false;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
    
    /*-*/  
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','VENDOR_CODE', 10);
    lics_inbound_utility.set_definition('HDR','COMPANY_CODE', 6);
    lics_inbound_utility.set_definition('HDR','CREATE_DATE', 14);
    lics_inbound_utility.set_definition('HDR','CREATE_USER', 12);
    lics_inbound_utility.set_definition('HDR','POSTING_BLOCK_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','DELETION_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','ASSIGNMENT_SORT_KEY', 3);
    lics_inbound_utility.set_definition('HDR','RECONCILIATION_ACCOUNT', 10);
    lics_inbound_utility.set_definition('HDR','AUTHORISATION_GROUP', 4);
    lics_inbound_utility.set_definition('HDR','INTEREST_CALC_IND', 2);
    lics_inbound_utility.set_definition('HDR','PAYMENT_METHOD', 10);
    lics_inbound_utility.set_definition('HDR','CLEARING_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','PAYMENT_BLOCK_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','PAYMENT_TERMS', 4);
    lics_inbound_utility.set_definition('HDR','SHIPPER_ACCOUNT', 12);
    lics_inbound_utility.set_definition('HDR','VENDOR_CLERK', 15);
    lics_inbound_utility.set_definition('HDR','PLANNING_GROUP', 10);
    lics_inbound_utility.set_definition('HDR','ACCOUNT_CLERK_CODE', 2);
    lics_inbound_utility.set_definition('HDR','HEAD_OFFICE_ACCOUNT', 10);
    lics_inbound_utility.set_definition('HDR','ALTERNATIVE_PAYEE_ACCOUNT', 10);
    lics_inbound_utility.set_definition('HDR','INTEREST_CALC_KEY_DATE', 14);
    lics_inbound_utility.set_definition('HDR','INTEREST_CALC_FREQ', 38);
    lics_inbound_utility.set_definition('HDR','NTEREST_CALC_RUN_DATE', 14);
    lics_inbound_utility.set_definition('HDR','LOCAL_PROCESS_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','BILL_OF_EXCHANGE_LIMIT', 38);
    lics_inbound_utility.set_definition('HDR','PROBABLE_CHECK_PAID_TIME', 38);
    lics_inbound_utility.set_definition('HDR','INV_CRD_CHECK_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','TOLERANCE_GROUP_CODE', 4);
    lics_inbound_utility.set_definition('HDR','HOUSE_BANK_KEY', 5);
    lics_inbound_utility.set_definition('HDR','PAY_ITEM_SEPARATE_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','WITHHOLD_TAX_CERTIFICATE', 10);
    lics_inbound_utility.set_definition('HDR','WITHHOLD_TAX_VALID_DATE', 14);
    lics_inbound_utility.set_definition('HDR','WITHHOLD_TAX_CODE', 2);
    lics_inbound_utility.set_definition('HDR','SUBSIDY_FLAG', 2);
    lics_inbound_utility.set_definition('HDR','MINORITY_INDICATOR', 3);
    lics_inbound_utility.set_definition('HDR','PREVIOUS_RECORD_NUMBER', 10);
    lics_inbound_utility.set_definition('HDR','PAYMENT_GROUPING_CODE', 2);
    lics_inbound_utility.set_definition('HDR','DUNNING_NOTICE_GROUP_CODE', 2);
    lics_inbound_utility.set_definition('HDR','RECIPIENT_TYPE', 2);
    lics_inbound_utility.set_definition('HDR','WITHHOLD_TAX_EXEMPTION', 1);
    lics_inbound_utility.set_definition('HDR','WITHHOLD_TAX_COUNTRY', 3);
    lics_inbound_utility.set_definition('HDR','EDI_PAYMENT_ADVICE', 1);
    lics_inbound_utility.set_definition('HDR','RELEASE_APPROVAL_GROUP', 4);
    lics_inbound_utility.set_definition('HDR','ACCOUNTING_FAX',31);
    lics_inbound_utility.set_definition('HDR','ACCOUNTING_URL', 130);
    lics_inbound_utility.set_definition('HDR','CREDIT_PAYMENT_TERMS', 4);
    lics_inbound_utility.set_definition('HDR','INCOME_TAX_ACTIVITY_CODE', 2);
    lics_inbound_utility.set_definition('HDR','EMPLOY_TAX_DISTBN_TYPE', 2);
    lics_inbound_utility.set_definition('HDR','PERIODIC_ACCOUNT_STATEMENT', 1);
    lics_inbound_utility.set_definition('HDR','CERTIFICATION_DATE', 14);
    lics_inbound_utility.set_definition('HDR','INVOICE_TOLERANCE_GROUP', 4);
    lics_inbound_utility.set_definition('HDR','PERSONNEL_NUMBER', 38);
    lics_inbound_utility.set_definition('HDR','DELETION_BLOCK_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','ACCOUNTING_PHONE', 30);
    lics_inbound_utility.set_definition('HDR','EXECUTION_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','VENDOR_NAME_01', 35);
    lics_inbound_utility.set_definition('HDR','VENDOR_NAME_02', 35);
    lics_inbound_utility.set_definition('HDR','VENDOR_NAME_03', 35);
    lics_inbound_utility.set_definition('HDR','VENDOR_NAME_04', 35);
      
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
    var_record_identifier varchar2(3);

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
    /*-*/
    /* Process the data based on record identifier  
    /*-*/
    var_record_identifier := substr(par_record,1,3);
    
    case var_record_identifier
      when 'HDR' then process_record_hdr(par_record);
      else lics_inbound_utility.add_exception('Record identifier (' || var_record_identifier || ') not recognised');
    end case;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

  /*-*/
  /* Exception trap 
  /*-*/
    when others then
      lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));
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
    /* Complete the Transaction 
    /*-*/
    complete_transaction;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end on_end;


   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
  procedure complete_transaction is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* No data processed 
    /*-*/
    if ( var_trn_start = false ) then
      rollback;
      return;
    end if;

    /*-*/
    /* Commit/rollback the transaction as required 
    /*-*/
    if ( var_trn_ignore = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    elsif ( var_trn_error = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    else
      /*-*/
      /* Commit the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      commit;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end complete_transaction;
  
  procedure process_record_hdr(par_record in varchar2) is
    
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
  
    /*-*/
    /* Complete the previous transactions 
    /*-*/
    complete_transaction;

    /*-*/
    /* Reset transaction variables 
    /*-*/
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_hdr.vendor_code := lics_inbound_utility.get_variable('VENDOR_CODE');
    rcd_hdr.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
    rcd_hdr.create_date := lics_inbound_utility.get_variable('CREATE_DATE');
    rcd_hdr.create_user := lics_inbound_utility.get_variable('CREATE_USER');
    rcd_hdr.posting_block_flag := lics_inbound_utility.get_variable('POSTING_BLOCK_FLAG');
    rcd_hdr.deletion_flag := lics_inbound_utility.get_variable('DELETION_FLAG');
    rcd_hdr.assignment_sort_key := lics_inbound_utility.get_variable('ASSIGNMENT_SORT_KEY');
    rcd_hdr.reconciliation_account := lics_inbound_utility.get_variable('RECONCILIATION_ACCOUNT');
    rcd_hdr.authorisation_group := lics_inbound_utility.get_variable('AUTHORISATION_GROUP');
    rcd_hdr.interest_calc_ind := lics_inbound_utility.get_variable('INTEREST_CALC_IND');
    rcd_hdr.payment_method := lics_inbound_utility.get_variable('PAYMENT_METHOD');
    rcd_hdr.clearing_flag := lics_inbound_utility.get_variable('CLEARING_FLAG');
    rcd_hdr.payment_block_flag := lics_inbound_utility.get_variable('PAYMENT_BLOCK_FLAG');
    rcd_hdr.payment_terms := lics_inbound_utility.get_variable('PAYMENT_TERMS');
    rcd_hdr.shipper_account := lics_inbound_utility.get_variable('SHIPPER_ACCOUNT');
    rcd_hdr.vendor_clerk := lics_inbound_utility.get_variable('VENDOR_CLERK');
    rcd_hdr.planning_group := lics_inbound_utility.get_variable('PLANNING_GROUP');
    rcd_hdr.account_clerk_code := lics_inbound_utility.get_variable('ACCOUNT_CLERK_CODE');
    rcd_hdr.head_office_account := lics_inbound_utility.get_variable('HEAD_OFFICE_ACCOUNT');
    rcd_hdr.alternative_payee_account := lics_inbound_utility.get_variable('ALTERNATIVE_PAYEE_ACCOUNT');
    rcd_hdr.interest_calc_key_date := lics_inbound_utility.get_variable('INTEREST_CALC_KEY_DATE');
    rcd_hdr.interest_calc_freq := lics_inbound_utility.get_variable('INTEREST_CALC_FREQ');
    rcd_hdr.nterest_calc_run_date := lics_inbound_utility.get_variable('NTEREST_CALC_RUN_DATE');
    rcd_hdr.local_process_flag := lics_inbound_utility.get_variable('LOCAL_PROCESS_FLAG');
    rcd_hdr.bill_of_exchange_limit := lics_inbound_utility.get_variable('BILL_OF_EXCHANGE_LIMIT');
    rcd_hdr.probable_check_paid_time := lics_inbound_utility.get_variable('PROBABLE_CHECK_PAID_TIME');
    rcd_hdr.inv_crd_check_flag := lics_inbound_utility.get_variable('INV_CRD_CHECK_FLAG');
    rcd_hdr.tolerance_group_code := lics_inbound_utility.get_variable('TOLERANCE_GROUP_CODE');
    rcd_hdr.house_bank_key := lics_inbound_utility.get_variable('HOUSE_BANK_KEY');
    rcd_hdr.pay_item_separate_flag := lics_inbound_utility.get_variable('PAY_ITEM_SEPARATE_FLAG');
    rcd_hdr.withhold_tax_certificate := lics_inbound_utility.get_variable('WITHHOLD_TAX_CERTIFICATE');
    rcd_hdr.withhold_tax_valid_date := lics_inbound_utility.get_variable('WITHHOLD_TAX_VALID_DATE');
    rcd_hdr.withhold_tax_code := lics_inbound_utility.get_variable('WITHHOLD_TAX_CODE');
    rcd_hdr.subsidy_flag := lics_inbound_utility.get_variable('SUBSIDY_FLAG');
    rcd_hdr.minority_indicator := lics_inbound_utility.get_variable('MINORITY_INDICATOR');
    rcd_hdr.previous_record_number := lics_inbound_utility.get_variable('PREVIOUS_RECORD_NUMBER');
    rcd_hdr.payment_grouping_code := lics_inbound_utility.get_variable('PAYMENT_GROUPING_CODE');
    rcd_hdr.dunning_notice_group_code := lics_inbound_utility.get_variable('DUNNING_NOTICE_GROUP_CODE');
    rcd_hdr.recipient_type := lics_inbound_utility.get_variable('RECIPIENT_TYPE');
    rcd_hdr.withhold_tax_exemption := lics_inbound_utility.get_variable('WITHHOLD_TAX_EXEMPTION');
    rcd_hdr.withhold_tax_country := lics_inbound_utility.get_variable('WITHHOLD_TAX_COUNTRY');
    rcd_hdr.edi_payment_advice := lics_inbound_utility.get_variable('EDI_PAYMENT_ADVICE');
    rcd_hdr.release_approval_group := lics_inbound_utility.get_variable('RELEASE_APPROVAL_GROUP');
    rcd_hdr.accounting_fax := lics_inbound_utility.get_variable('ACCOUNTING_FAX');
    rcd_hdr.accounting_url := lics_inbound_utility.get_variable('ACCOUNTING_URL');
    rcd_hdr.credit_payment_terms := lics_inbound_utility.get_variable('CREDIT_PAYMENT_TERMS');
    rcd_hdr.income_tax_activity_code := lics_inbound_utility.get_variable('INCOME_TAX_ACTIVITY_CODE');
    rcd_hdr.employ_tax_distbn_type := lics_inbound_utility.get_variable('EMPLOY_TAX_DISTBN_TYPE');
    rcd_hdr.periodic_account_statement := lics_inbound_utility.get_variable('PERIODIC_ACCOUNT_STATEMENT');
    rcd_hdr.certification_date := lics_inbound_utility.get_variable('CERTIFICATION_DATE');
    rcd_hdr.invoice_tolerance_group := lics_inbound_utility.get_variable('INVOICE_TOLERANCE_GROUP');
    rcd_hdr.personnel_number := lics_inbound_utility.get_variable('PERSONNEL_NUMBER');
    rcd_hdr.deletion_block_flag := lics_inbound_utility.get_variable('DELETION_BLOCK_FLAG');
    rcd_hdr.accounting_phone := lics_inbound_utility.get_variable('ACCOUNTING_PHONE');
    rcd_hdr.execution_flag := lics_inbound_utility.get_variable('EXECUTION_FLAG');
    rcd_hdr.vendor_name_01 := lics_inbound_utility.get_variable('VENDOR_NAME_01');
    rcd_hdr.vendor_name_02 := lics_inbound_utility.get_variable('VENDOR_NAME_02');
    rcd_hdr.vendor_name_03 := lics_inbound_utility.get_variable('VENDOR_NAME_03');
    rcd_hdr.vendor_name_04 := lics_inbound_utility.get_variable('VENDOR_NAME_04');    
    
    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;

    /*----------------------------------------*/
    /* VALIDATION - Validate the field values */
    /*----------------------------------------*/

    /*-*/
    /* Validate the primary keys 
    /*-*/
    if ( rcd_hdr.vendor_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.VENDOR_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.company_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.COMPANY_CODE');
      var_trn_error := true;
    end if;
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;
    
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    /*------------------------------*/
    /* UPDATE - Update the database */
    /*------------------------------*/        
    update bds_vend_comp
    set vendor_code = rcd_hdr.vendor_code,
      company_code = rcd_hdr.company_code,
      create_date = rcd_hdr.create_date,
      create_user = rcd_hdr.create_user,
      posting_block_flag = rcd_hdr.posting_block_flag,
      deletion_flag = rcd_hdr.deletion_flag,
      assignment_sort_key = rcd_hdr.assignment_sort_key,
      reconciliation_account = rcd_hdr.reconciliation_account,
      authorisation_group = rcd_hdr.authorisation_group,
      interest_calc_ind = rcd_hdr.interest_calc_ind,
      payment_method = rcd_hdr.payment_method,
      clearing_flag = rcd_hdr.clearing_flag,
      payment_block_flag = rcd_hdr.payment_block_flag,
      payment_terms = rcd_hdr.payment_terms,
      shipper_account = rcd_hdr.shipper_account,
      vendor_clerk = rcd_hdr.vendor_clerk,
      planning_group = rcd_hdr.planning_group,
      account_clerk_code = rcd_hdr.account_clerk_code,
      head_office_account = rcd_hdr.head_office_account,
      alternative_payee_account = rcd_hdr.alternative_payee_account,
      interest_calc_key_date = rcd_hdr.interest_calc_key_date,
      interest_calc_freq = rcd_hdr.interest_calc_freq,
      nterest_calc_run_date = rcd_hdr.nterest_calc_run_date,
      local_process_flag = rcd_hdr.local_process_flag,
      bill_of_exchange_limit = rcd_hdr.bill_of_exchange_limit,
      probable_check_paid_time = rcd_hdr.probable_check_paid_time,
      inv_crd_check_flag = rcd_hdr.inv_crd_check_flag,
      tolerance_group_code = rcd_hdr.tolerance_group_code,
      house_bank_key = rcd_hdr.house_bank_key,
      pay_item_separate_flag = rcd_hdr.pay_item_separate_flag,
      withhold_tax_certificate = rcd_hdr.withhold_tax_certificate,
      withhold_tax_valid_date = rcd_hdr.withhold_tax_valid_date,
      withhold_tax_code = rcd_hdr.withhold_tax_code,
      subsidy_flag = rcd_hdr.subsidy_flag,
      minority_indicator = rcd_hdr.minority_indicator,
      previous_record_number = rcd_hdr.previous_record_number,
      payment_grouping_code = rcd_hdr.payment_grouping_code,
      dunning_notice_group_code = rcd_hdr.dunning_notice_group_code,
      recipient_type = rcd_hdr.recipient_type,
      withhold_tax_exemption = rcd_hdr.withhold_tax_exemption,
      withhold_tax_country = rcd_hdr.withhold_tax_country,
      edi_payment_advice = rcd_hdr.edi_payment_advice,
      release_approval_group = rcd_hdr.release_approval_group,
      accounting_fax = rcd_hdr.accounting_fax,
      accounting_url = rcd_hdr.accounting_url,
      credit_payment_terms = rcd_hdr.credit_payment_terms,
      income_tax_activity_code = rcd_hdr.income_tax_activity_code,
      employ_tax_distbn_type = rcd_hdr.employ_tax_distbn_type,
      periodic_account_statement = rcd_hdr.periodic_account_statement,
      certification_date = rcd_hdr.certification_date,
      invoice_tolerance_group = rcd_hdr.invoice_tolerance_group,
      personnel_number = rcd_hdr.personnel_number,
      deletion_block_flag = rcd_hdr.deletion_block_flag,
      accounting_phone = rcd_hdr.accounting_phone,
      execution_flag = rcd_hdr.execution_flag,
      vendor_name_01 = rcd_hdr.vendor_name_01,
      vendor_name_02 = rcd_hdr.vendor_name_02,
      vendor_name_03 = rcd_hdr.vendor_name_03,
      vendor_name_04 = rcd_hdr.vendor_name_04
    where vendor_code = rcd_hdr.vendor_code
      and company_code = rcd_hdr.company_code;
    
    if ( sql%notfound ) then    
      insert into bds_vend_comp
      (
        vendor_code, 
        company_code, 
        create_date, 
        create_user,
        posting_block_flag, 
        deletion_flag, 
        assignment_sort_key,
        reconciliation_account, 
        authorisation_group, 
        interest_calc_ind,
        payment_method, 
        clearing_flag, 
        payment_block_flag, 
        payment_terms,
        shipper_account, 
        vendor_clerk, 
        planning_group, 
        account_clerk_code,
        head_office_account, 
        alternative_payee_account, 
        interest_calc_key_date,
        interest_calc_freq, 
        nterest_calc_run_date, 
        local_process_flag,
        bill_of_exchange_limit, 
        probable_check_paid_time, 
        inv_crd_check_flag,
        tolerance_group_code, 
        house_bank_key, 
        pay_item_separate_flag,
        withhold_tax_certificate, 
        withhold_tax_valid_date, 
        withhold_tax_code,
        subsidy_flag, 
        minority_indicator, 
        previous_record_number,
        payment_grouping_code, 
        dunning_notice_group_code, 
        recipient_type,
        withhold_tax_exemption, 
        withhold_tax_country, 
        edi_payment_advice,
        release_approval_group, 
        accounting_fax, accounting_url,
        credit_payment_terms, 
        income_tax_activity_code, 
        employ_tax_distbn_type,
        periodic_account_statement, 
        certification_date,
        invoice_tolerance_group, 
        personnel_number, 
        deletion_block_flag,
        accounting_phone, 
        execution_flag, 
        vendor_name_01, 
        vendor_name_02,
        vendor_name_03, 
        vendor_name_04
      )
      values 
      (
        rcd_hdr.vendor_code,
        rcd_hdr.company_code,
        rcd_hdr.create_date,
        rcd_hdr.create_user,
        rcd_hdr.posting_block_flag,
        rcd_hdr.deletion_flag,
        rcd_hdr.assignment_sort_key,
        rcd_hdr.reconciliation_account,
        rcd_hdr.authorisation_group,
        rcd_hdr.interest_calc_ind,
        rcd_hdr.payment_method,
        rcd_hdr.clearing_flag,
        rcd_hdr.payment_block_flag,
        rcd_hdr.payment_terms,
        rcd_hdr.shipper_account,
        rcd_hdr.vendor_clerk,
        rcd_hdr.planning_group,
        rcd_hdr.account_clerk_code,
        rcd_hdr.head_office_account,
        rcd_hdr.alternative_payee_account,
        rcd_hdr.interest_calc_key_date,
        rcd_hdr.interest_calc_freq,
        rcd_hdr.nterest_calc_run_date,
        rcd_hdr.local_process_flag,
        rcd_hdr.bill_of_exchange_limit,
        rcd_hdr.probable_check_paid_time,
        rcd_hdr.inv_crd_check_flag,
        rcd_hdr.tolerance_group_code,
        rcd_hdr.house_bank_key,
        rcd_hdr.pay_item_separate_flag,
        rcd_hdr.withhold_tax_certificate,
        rcd_hdr.withhold_tax_valid_date,
        rcd_hdr.withhold_tax_code,
        rcd_hdr.subsidy_flag,
        rcd_hdr.minority_indicator,
        rcd_hdr.previous_record_number,
        rcd_hdr.payment_grouping_code,
        rcd_hdr.dunning_notice_group_code,
        rcd_hdr.recipient_type,
        rcd_hdr.withhold_tax_exemption,
        rcd_hdr.withhold_tax_country,
        rcd_hdr.edi_payment_advice,
        rcd_hdr.release_approval_group,
        rcd_hdr.accounting_fax,
        rcd_hdr.accounting_url,
        rcd_hdr.credit_payment_terms,
        rcd_hdr.income_tax_activity_code,
        rcd_hdr.employ_tax_distbn_type,
        rcd_hdr.periodic_account_statement,
        rcd_hdr.certification_date,
        rcd_hdr.invoice_tolerance_group,
        rcd_hdr.personnel_number,
        rcd_hdr.deletion_block_flag,
        rcd_hdr.accounting_phone,
        rcd_hdr.execution_flag,
        rcd_hdr.vendor_name_01,
        rcd_hdr.vendor_name_02,
        rcd_hdr.vendor_name_03,
        rcd_hdr.vendor_name_04
      );
    end if;
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
    
end ladpdb12_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb12_loader to appsupport;
grant execute on bds_app.ladpdb12_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb12_loader for bds_app.ladpdb12_loader;