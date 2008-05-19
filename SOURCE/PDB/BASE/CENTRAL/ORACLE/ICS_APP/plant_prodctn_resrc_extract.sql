/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_prodctn_resrc_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Production Resource Data for Plant databases 

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all material data  
    *RESRC - send production resource data matching a given resource id  
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *RESRC = resource id 

  3. PAR_SITE (OPTIONAL) 
  
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

create or replace package ics_app.plant_prodctn_resrc_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_prodctn_resrc_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_prodctn_resrc_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_resrc_id bds_prodctn_resrc_en.resrc_id%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  
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
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*RESRC' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *RESRC');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;
    
    if ( var_action = '*RESRC' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *RESRC actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB06.1');
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB06.2');
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB06.3');
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB06.4');
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB06.5');   
      end if;
      if (par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB06.6');   
      end if;
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
    raise_application_error(-20000, 'plant_prodctn_resrc_extract - ' || 'resrc_id: ' || var_resrc_id || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;

  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_prodctn_resrc_en is
      select t01.resrc_id as resrc_id, 
        t01.resrc_code as resrc_code, 
        t01.resrc_text as resrc_text, 
        t01.resrc_plant_code as resrc_plant_code
      from bds_prodctn_resrc_en t01
      where t01.resrc_deletion_flag is null
        and substr(upper(resrc_text), 0, 6) <> 'DO NOT'
        and 
        (
          par_action = '*ALL'
          or (par_action = '*RESRC' and t01.resrc_id = par_data)
        );
        
    rcd_prodctn_resrc_en csr_prodctn_resrc_en%rowtype;

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
    open csr_prodctn_resrc_en;
    loop
    
      fetch csr_prodctn_resrc_en into rcd_prodctn_resrc_en;
      exit when csr_prodctn_resrc_en%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_id),' '),8,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_code),' '),8,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_text),' '),40,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_plant_code),' '),4,' ');

    end loop;
    close csr_prodctn_resrc_en;

    return var_result;
  
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
        var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end plant_prodctn_resrc_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_prodctn_resrc_extract to appsupport;
grant execute on ics_app.plant_prodctn_resrc_extract to lads_app;
grant execute on ics_app.plant_prodctn_resrc_extract to lics_app;
grant execute on ics_app.plant_prodctn_resrc_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_prodctn_resrc_extract for ics_app.plant_prodctn_resrc_extract;
