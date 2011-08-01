--
-- LADPDB19_LOADER  (Package) 
--
CREATE OR REPLACE PACKAGE BDS_APP.ladpdb19_loader
as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : Plant Database
 Package : ladpdb19_loader
 Owner   : bds_app
 Author  : Ben Halicki

 Description
 -----------
 Plant Database - Plant Maintenance Functional Locations Interface

 dd-mmm-yyyy   Author              Description
 -----------   ------              -----------
 05-04-2010   Ben Halicki          Created this package

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data (par_record in varchar2);
   procedure on_end;

end ladpdb19_loader;
/


--
-- LADPDB19_LOADER  (Synonym) 
--
CREATE PUBLIC SYNONYM LADPDB19_LOADER FOR BDS_APP.LADPDB19_LOADER;


GRANT EXECUTE ON BDS_APP.LADPDB19_LOADER TO APPSUPPORT;

GRANT EXECUTE ON BDS_APP.LADPDB19_LOADER TO LICS_APP;


--
-- LADPDB19_LOADER  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY BDS_APP.ladpdb19_loader as

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

  /* global constants */
  con_intfc varchar2(20) := 'LADPDB19';

  type idoc_control is record(idoc_name varchar2(30),
                              idoc_number number(16,0),
                              idoc_timestamp varchar2(14));

  rcd_lads_control            idoc_control;
  rcd_bds_functnl_locn_hdr    bds_functnl_locn_hdr%rowtype;

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
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* Delete reference data entries
    /*-*/

    /*-*/
    /* Initialise the inbound definitions
    /*-*/
    lics_inbound_utility.clear_definition;

    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','FUNCTNL_LOCN_CODE',40);
    lics_inbound_utility.set_definition('HDR','FUNCTNL_LOCN_DESC',40);
    lics_inbound_utility.set_definition('HDR','PLANT_CODE',4);
    lics_inbound_utility.set_definition('HDR','SORT_FIELD',30);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NAME',20);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NUMBER',16);
    lics_inbound_utility.set_definition('HDR','IDOC_CREATE_DATE',8);
    lics_inbound_utility.set_definition('HDR','IDOC_CREATE_TIME',6);

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

  /**************************************************/
  /* This procedure performs the record HDR routine */
  /**************************************************/
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

    /*-*/
    /* Extract and validate the control IDOC name
    /*-*/
    rcd_lads_control.idoc_name := lics_inbound_utility.get_variable('SAP_IDOC_NAME');

    /*-*/
    /* Extract and validate the control IDOC number
    /*-*/
    rcd_lads_control.idoc_number := lics_inbound_utility.get_number('SAP_IDOC_NUMBER','9999999999999999');
    if lics_inbound_utility.has_errors = true then
       var_trn_error := true;
    end if;
    if rcd_lads_control.idoc_number is null then
       lics_inbound_utility.add_exception('Field - HDR.SAP_IDOC_NUMBER - Must not be null');
       var_trn_error := true;
    end if;

    rcd_lads_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_CREATE_DATE') || lics_inbound_utility.get_variable('IDOC_CREATE_TIME');
    if rcd_lads_control.idoc_timestamp is null then
       lics_inbound_utility.add_exception('Field - HDR.IDOC_TIMESTAMP - Must not be null');
       var_trn_error := true;
    end if;

    rcd_bds_functnl_locn_hdr.functnl_locn_code := lics_inbound_utility.get_variable('FUNCTNL_LOCN_CODE');
    rcd_bds_functnl_locn_hdr.functnl_locn_desc := lics_inbound_utility.get_variable('FUNCTNL_LOCN_DESC');
    rcd_bds_functnl_locn_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_bds_functnl_locn_hdr.sort_field := lics_inbound_utility.get_variable('SORT_FIELD');
    rcd_bds_functnl_locn_hdr.sap_idoc_name := rcd_lads_control.idoc_name;
    rcd_bds_functnl_locn_hdr.sap_idoc_number := rcd_lads_control.idoc_number;
    rcd_bds_functnl_locn_hdr.sap_idoc_timestamp := rcd_lads_control.idoc_timestamp;
    rcd_bds_functnl_locn_hdr.bds_lads_date := sysdate;
    rcd_bds_functnl_locn_hdr.bds_lads_status := '1';

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
    if ( rcd_bds_functnl_locn_hdr.functnl_locn_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.functnl_locn_code');
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

    begin

        /* update tables based on primary key */
        insert into bds_functnl_locn_hdr
        (
            functnl_locn_code,
            functnl_locn_desc,
            plant_code,
            sort_field,
            sap_idoc_name,
            sap_idoc_number,
            sap_idoc_timestamp,
            bds_lads_date,
            bds_lads_status
        )
        values
        (
            rcd_bds_functnl_locn_hdr.functnl_locn_code,
            rcd_bds_functnl_locn_hdr.functnl_locn_desc,
            rcd_bds_functnl_locn_hdr.plant_code,
            rcd_bds_functnl_locn_hdr.sort_field,
            rcd_bds_functnl_locn_hdr.sap_idoc_name,
            rcd_bds_functnl_locn_hdr.sap_idoc_number,
            rcd_bds_functnl_locn_hdr.sap_idoc_timestamp,
            rcd_bds_functnl_locn_hdr.bds_lads_date,
            rcd_bds_functnl_locn_hdr.bds_lads_status
        );

    exception
    when dup_val_on_index then

        update bds_functnl_locn_hdr set
            functnl_locn_code = rcd_bds_functnl_locn_hdr.functnl_locn_code,
            functnl_locn_desc = rcd_bds_functnl_locn_hdr.functnl_locn_desc,
            plant_code = rcd_bds_functnl_locn_hdr.plant_code,
            sort_field = rcd_bds_functnl_locn_hdr.sort_field,
            sap_idoc_name = rcd_bds_functnl_locn_hdr.sap_idoc_name,
            sap_idoc_number = rcd_bds_functnl_locn_hdr.sap_idoc_number,
            sap_idoc_timestamp = rcd_bds_functnl_locn_hdr.sap_idoc_timestamp,
            bds_lads_date = rcd_bds_functnl_locn_hdr.bds_lads_date,
            bds_lads_status = rcd_bds_functnl_locn_hdr.bds_lads_status
        where functnl_locn_code = rcd_bds_functnl_locn_hdr.functnl_locn_code;

    end;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;

end ladpdb19_loader;
/


--
-- LADPDB19_LOADER  (Synonym) 
--
CREATE PUBLIC SYNONYM LADPDB19_LOADER FOR BDS_APP.LADPDB19_LOADER;


GRANT EXECUTE ON BDS_APP.LADPDB19_LOADER TO APPSUPPORT;

GRANT EXECUTE ON BDS_APP.LADPDB19_LOADER TO LICS_APP;
