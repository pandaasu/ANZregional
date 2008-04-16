/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_reference_data_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Reference Data for Plant databases 

  1. PAR_Z_TABNAME (MANDATORY) 

    The table name updated. Determines which type of reference data to send.

  2. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/

create or replace package ics_app.plant_reference_data_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_z_tabname in varchar2, par_site in varchar2 default '*ALL');

end plant_reference_data_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_reference_data_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_z_tabname in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception   varchar2(4000);
    var_site        varchar2(10);
    var_z_tabname   varchar2(10);
    var_start       boolean := false;
         
  begin
  
    var_z_tabname := upper(nvl(trim(par_z_tabname), '*NULL'));
    
    tbl_definition.delete;
    
    if ( var_z_tabname = '*NULL' ) then
      raise_application_error(-20000, 'Z_TABNAME parameter (' || par_z_tabname || ') must not be null.');
    end if;

    case
      /*----------------------------------------------------*/
      /* Characteristic Reference Tables                    */
      /*----------------------------------------------------*/
      when (var_z_tabname = '/MARS/MD_CHC001' or
        var_z_tabname = '/MARS/MD_CHC002' or
        var_z_tabname = '/MARS/MD_CHC008' or
        var_z_tabname = '/MARS/MD_CHC010' or
        var_z_tabname = '/MARS/MD_CHC011' or
        var_z_tabname = '/MARS/MD_CHC012' or
        var_z_tabname = '/MARS/MD_CHC015' or
        var_z_tabname = '/MARS/MD_CHC017' or
        var_z_tabname = '/MARS/MD_CHC018' or
        var_z_tabname = '/MARS/MD_CHC019' or
        var_z_tabname = '/MARS/MD_CHC020' or
        var_z_tabname = '/MARS/MD_CHC022' or
        var_z_tabname = '/MARS/MD_CHC023' or
        var_z_tabname = '/MARS/MD_CHC024' or
        var_z_tabname = '/MARS/MD_CHC025' or
        var_z_tabname = '/MARS/MD_CHC026' or
        var_z_tabname = '/MARS/MD_CHC027' or
        var_z_tabname = '/MARS/MD_CHC028' or
        var_z_tabname = '/MARS/MD_CHC029' or
        var_z_tabname = '/MARS/MD_CHC030' or
        var_z_tabname = '/MARS/MD_CHC031' or
        var_z_tabname = '/MARS/MD_CHC032' or
        var_z_tabname = '/MARS/MD_CHC040' or
        var_z_tabname = '/MARS/MD_CHC042' or
        var_z_tabname = '/MARS/MD_CHC046' or
        var_z_tabname = '/MARS/MD_CHC047' or
        var_z_tabname = '/MARS/MD_CHC003' or
        var_z_tabname = '/MARS/MD_CHC004' or
        var_z_tabname = '/MARS/MD_CHC005' or
        var_z_tabname = '/MARS/MD_CHC007' or
        var_z_tabname = '/MARS/MD_CHC009' or
        var_z_tabname = '/MARS/MD_CHC013' or
        var_z_tabname = '/MARS/MD_CHC014' or
        var_z_tabname = '/MARS/MD_CHC016' or
        var_z_tabname = '/MARS/MD_CHC021' or
        var_z_tabname = '/MARS/MD_CHC038' or
        var_z_tabname = '/MARS/MD_CHC006' or
        var_z_tabname = '/MARS/MD_VERP01' or
        var_z_tabname = '/MARS/MD_VERP02' or
        var_z_tabname = '/MARS/MD_ROH01' or
        var_z_tabname = '/MARS/MD_ROH02' or
        var_z_tabname = '/MARS/MD_ROH03' or
        var_z_tabname = '/MARS/MD_ROH04' or
        var_z_tabname = '/MARS/MD_ROH05') then plant_refrnc_charistic_extract.execute(par_site);
      /*----------------------------------------------------*/
      /* Plant Reference Tables                             */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'T001W') then plant_refrnc_plant_extract.execute('*ALL', null, par_site);
      /*----------------------------------------------------*/
      /* BOM Alternate Versions Reference Tables            */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'T415A') then plant_bom_alternative_extract.execute(par_site);
      /*----------------------------------------------------*/
      /* Purchasing Source (Vendor/Material) Reference Table*/
      /*----------------------------------------------------*/
      when (var_z_tabname = 'EORD') then plant_refrnc_prch_src_extract.execute(par_site);
      /*----------------------------------------------------*/
      /* Production Resources (Details/Descriptions)        */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'CRTX' or var_z_tabname = 'CRHD') then plant_prodctn_resrc_extract.execute('*ALL', null, par_site);
      /*-*/
      else raise_application_error(-20000, 'Z_TABNAME parameter (' || var_z_tabname || ') is not known.');
    end case;
    
  end execute;

end plant_reference_data_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_reference_data_extract to appsupport;
grant execute on ics_app.plant_reference_data_extract to lads_app;
grant execute on ics_app.plant_reference_data_extract to lics_app;
grant execute on ics_app.plant_reference_data_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_reference_data_extract for ics_app.plant_reference_data_extract;
