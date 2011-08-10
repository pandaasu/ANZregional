--
-- ICS_LADPDB17_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP."ICS_LADPDB17_EXTRACT" as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB17_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Stock Transfer Orders and Purchase Orders extract interface for Plant Databases

  EXECUTE - 
    Send Stock Transfer Orders / Purchase Orders since last successful send 
    
  EXECUTE - 
    Send Stock Transfer Orders / Purchase Orders based on the specified action.     

  1. PAR_ACTION (MANDATORY) 
    - *ALL = extract all STO and POs for given plant
    - *DOCUMENT = extract specific STO/PO document
    - *HISTORY - all modified since specified date

  2. PAR_DATA (MANDATORY) 
  
    Data related to the action specified:
      - *ALL = null 
      - *DOCUMENT = STO / PO Number
      - *HISTORY = number of days 

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to 
        (configured using VALID_PLANTS directive in ICS Data Store Configuration)
        
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand
      - *MCH = HUA Plant DB (China)
  
  YYYY/MM    Author       Version    Description 
  -------    ------       -------    ----------- 
  2010/06   Ben Halicki   1.0        Created this package
  2011/08   Ben Halicki   1.0        Added MQFT trigger logic
  
*******************************************************************************/ 

  /*-*/
  /* Public declarations 
  /* par_material either null or a material code 
  /*-*/
  
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ICS_LADPDB17_EXTRACT;
/


--
-- ICS_LADPDB17_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP."ICS_LADPDB17_EXTRACT" 
as
/******************************************************************************
   NAME: ICS_LADPDB17_EXTRACT 
*****************************************************************************/

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
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB17';
      
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
  
  end execute; 

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
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*DOCUMENT'
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *DOCUMENT or *HISTORY');
    end if;

    if ( var_action = '*DOCUMENT' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *DOCUMENT actions.');
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
    raise_application_error(-20000, 'ICS_LADPDB17_EXTRACT - ' || var_exception);
    
   /*-------------*/
   /* End routine */
   /*-------------*/
  end;
  
  /* private routines */
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean is
    
    /* local variable declaration */
    var_index number(8,0);
    var_result boolean;
  
    /* local cursor declaration */
    cursor csr_lads_sto_po_hdr is
        select 
            t01.belnr as sto_po_number,
            t01.bsart as document_type,
            t01.curcy as currency,
            t02.orgid as sto_po_type,
            t03.partn as vendor_number,
            decode(t04.datum,null,'19000101',t04.datum) as document_date,
            t05.orgid as purchasing_company,
            t06.orgid as purchasing_org,
            t07.orgid as purchasing_group,
            t08.kunnr as cust_code
        from 
            lads_sto_po_hdr t01,
            lads_sto_po_org t02,
            lads_sto_po_pnr t03,
            lads_sto_po_dat t04,
            lads_sto_po_org t05,
            lads_sto_po_org t06,
            lads_sto_po_org t07,
            lads_cus_hdr t08,
            (
                select distinct t01.belnr
                from lads_sto_po_gen t01 where 
                    t01.werks in 
                    (
                        select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
                    )
            ) t09
        where 
            t01.lads_status = '1'                                             -- valid
            and t01.belnr = t02.belnr(+)
            and t02.qualf(+) = '013'                            -- purchase order type  
            and t01.belnr = t03.belnr(+)
            and t03.parvw(+) = 'LF'                                          -- vendor  
            and t01.belnr = t04.belnr(+)
            and t04.iddat(+) = '012'     -- document date is date document was created
            and t01.belnr = t05.belnr(+)
            and t05.qualf(+) = '011'                             -- purchasing company
            and t01.belnr = t06.belnr(+)
            and t06.qualf(+) = '014'                        -- purchasing organisation
            and t01.belnr = t07.belnr(+)
            and t07.qualf(+) = '009'                               -- purchasing group
            and t03.partn = t08.lifnr(+)   
            and t01.belnr = t09.belnr
            and
            (
                (par_action = '*ALL' and (var_lastrun_date is null or t01.lads_date >= var_lastrun_date))
                or (par_action = '*DOCUMENT' and ltrim(t01.belnr,'0') = ltrim(par_data,'0'))
                or (par_action = '*HISTORY' and trunc(t01.lads_date) >= trunc(sysdate-to_number(par_data)))
            );
    
    rcd_lads_sto_po_hdr csr_lads_sto_po_hdr%rowtype;  
    
    cursor csr_lads_sto_po_det is
        select 
            t01.belnr as sto_po_nmbr, 
            t02.posex as line_nmbr, 
            t03.idtnr as matl_code,
            t04.dlvry_date, 
            t02.menge as qty, 
            t02.menee as qty_uom,
            t02.netwr as item_value_net, 
            t02.werks as plant,
            t02.lgort as storage_loc,
            t02.action as actn_code,
            t02.elikz as dlvry_comp,
            t02.uebto as over_del_tolrnce,
            t02.insmk as stock_type
        from 
            lads_sto_po_hdr t01,
            lads_sto_po_gen t02,
            lads_sto_po_oid t03,
        (
            select   
                belnr, 
                genseq, 
                max (edatu) as dlvry_date
            from 
                lads_sto_po_sch
            group by 
                belnr, 
                genseq
        ) t04
        where 
            t01.lads_status = '1'                                           -- valid
            and t01.belnr = t02.belnr
            and t02.belnr = t03.belnr
            and t02.genseq = t03.genseq
            and t03.qualf = '001'                                   -- material data
            and t02.belnr = t04.belnr(+)
            and t02.genseq = t04.genseq(+)
            and t01.belnr = rcd_lads_sto_po_hdr.sto_po_number;
                       
  rcd_lads_sto_po_det csr_lads_sto_po_det%rowtype;  
      
  BEGIN
    /* initialise variables */
    var_result := false;
    tbl_definition.delete;
           
    /* open cursors for output */
    open csr_lads_sto_po_hdr;
    loop
        fetch csr_lads_sto_po_hdr into rcd_lads_sto_po_hdr;
        exit when csr_lads_sto_po_hdr%notfound;
        
        var_index:=tbl_definition.count + 1;
        var_result := true;
        
        /* store variables for error reporting */
        tbl_definition(var_index).value := 'HDR'
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.sto_po_number),' '),35,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.document_type),' '),4,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.currency),' '),3,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.sto_po_type),' '),35,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.vendor_number),' '),17,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.document_date),' '),8,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.purchasing_company),' '),35,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.purchasing_org),' '),35,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.purchasing_group),' '),35,' ')
            || rpad(nvl(to_char(rcd_lads_sto_po_hdr.cust_code),' '),10,' ');            
        
        /* attach detail rows */
        open csr_lads_sto_po_det;
        loop
            fetch csr_lads_sto_po_det into rcd_lads_sto_po_det;
            exit when csr_lads_sto_po_det%NOTFOUND;
                
            var_index:=tbl_definition.count + 1;
            var_result := true;
            
            /* store detail row */
            tbl_definition(var_index).value := 'DET'
                || rpad(nvl(to_char(rcd_lads_sto_po_det.sto_po_nmbr),' '),35,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.line_nmbr),' '),6,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.matl_code),' '),35,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.dlvry_date),' '),8,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.qty),' '),15,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.qty_uom),' '),3,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.item_value_net),' '),18,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.plant),' '),4,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.storage_loc),' '),4,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.actn_code),' '),3,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.dlvry_comp),' '),1,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.over_del_tolrnce),' '),5,' ')
                || rpad(nvl(to_char(rcd_lads_sto_po_det.stock_type),' '),1,' ');
                            
        end loop;
        close csr_lads_sto_po_det;
                    
    end loop;
    close csr_lads_sto_po_hdr;
    
    return var_result;
    
  END;
  
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2) is
    
    /* local variable declaration */
    var_instance number(15,0);
    
  BEGIN
    for idx in 1..tbl_definition.count loop
        
        /* create outbound loader */
        if (lics_outbound_loader.is_created = false) then
          if upper(par_trigger) = 'Y' then
             var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
          else
             var_instance := lics_outbound_loader.create_interface(par_interface);
          end if;
        end if;  
        
        lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;
    
    /* send data*/
    if (lics_outbound_loader.is_created = true) then
        lics_outbound_loader.finalise_interface;
    end if;
    
    commit;
    
  END execute_send;
  
end ICS_LADPDB17_EXTRACT;
/


--
-- ICS_LADPDB17_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB17_EXTRACT FOR ICS_APP.ICS_LADPDB17_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB17_EXTRACT TO LICS_APP;

