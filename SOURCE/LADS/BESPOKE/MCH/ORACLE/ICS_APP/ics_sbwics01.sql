/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : BW / CARE 
  Package : ics_sbwics01 
  Owner   : ics_app  
  Author  : Trevor Keon 

  Description 
  ----------- 
  BW to CARE - Material sales by quantity  

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  22-Apr-2008  Trevor Keon      Created 
  22-Jul-2008  Trevor Keon      Changed precision for case_qty
*******************************************************************************/

create or replace package ics_app.ics_sbwics01 as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ics_sbwics01; 

create or replace package body ics_app.ics_sbwics01 as

  procedure append_data;

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
  procedure process_record_det(par_record in varchar2);


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
  var_index       number(8,0);
  var_filename    varchar2(20) := 'SALCAR01.TXT';  
  var_interface   varchar2(20) := 'ICSCAR01';

  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;  
    
  type hdr_type is record
    (
      v_id              varchar2(3),
      timestamp         varchar2(14),
      moe               varchar2(20),
      mars_period       varchar2(6),
      record_count      number(10),
      grd               varchar2(3)
    );
  
  type det_type is record
    (
      v_id                      varchar2(3),
      trad_unit_code            varchar2(18),
      case_qty                  number
    ); 
  
  rcd_hdr hdr_type;
  rcd_det det_type;  

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
    lics_inbound_utility.set_definition('HDR','TIMESTAMP',14);
    lics_inbound_utility.set_definition('HDR','MOE',20);
    lics_inbound_utility.set_definition('HDR','MARS_PERIOD',6);
    lics_inbound_utility.set_definition('HDR','RECORD_COUNT',10);
    lics_inbound_utility.set_definition('HDR','GRD',3);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','TRAD_UNIT_CODE',18);
    lics_inbound_utility.set_definition('DET','CASE_QTY',20);
    
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
    /* Process the data based on record v_identifier  
    /*-*/
    var_record_identifier := substr(par_record,1,3);
    
    case var_record_identifier
      when 'HDR' then process_record_hdr(par_record);
      when 'DET' then process_record_det(par_record);
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
      lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
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
    append_data;
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
      /*-*/
      if ( lics_outbound_loader.is_created = true ) then
        lics_outbound_loader.finalise_interface;
      end if;
      
      commit;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end complete_transaction;

  /************************************************************/
  /* This procedure performs the sending routine */
  /************************************************************/
  procedure append_data is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin
  
    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
        var_instance := lics_outbound_loader.create_interface(var_interface, null, var_filename);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;
    
    tbl_definition.delete;
    
  /*-------------*/
  /* End routine */
  /*-------------*/    
  end append_data;

  /**************************************************/
  /* This procedure performs the record HDR routine */
  /**************************************************/
  procedure process_record_hdr(par_record in varchar2) is              
                         
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Reset transaction variables 
    /*-*/
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;
        
    append_data;
    
    /*-*/
    /* PARSE - Parse the data record 
    /*-*/    
    lics_inbound_utility.parse_record('HDR', par_record);

    /*-*/
    /* RETRIEVE - Retrieve the field values 
    /*-*/
    rcd_hdr.v_id := 'HDR';
    rcd_hdr.timestamp := lics_inbound_utility.get_variable('TIMESTAMP');
    rcd_hdr.moe := lics_inbound_utility.get_variable('MOE');
    rcd_hdr.mars_period := lics_inbound_utility.get_variable('MARS_PERIOD');
    rcd_hdr.record_count := lics_inbound_utility.get_number('RECORD_COUNT',null);
    rcd_hdr.grd := lics_inbound_utility.get_variable('GRD');
        
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

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
    if ( rcd_hdr.timestamp is null) then
      lics_inbound_utility.add_exception('Missing Required Field - HDR.TIMESTAMP');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.moe is null) then
      lics_inbound_utility.add_exception('Missing Required Field - HDR.MOE');
      var_trn_error := true;
    end if;  
    
    if ( rcd_hdr.mars_period is null) then
      lics_inbound_utility.add_exception('Missing Required Field - HDR.MARS_PERIOD');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.record_count is null) then
      lics_inbound_utility.add_exception('Missing Required Field - HDR.RECORD_COUNT');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.grd is null) then
      lics_inbound_utility.add_exception('Missing Required Field - HDR.GRD');
      var_trn_error := true;
    end if;               
        
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    var_index := tbl_definition.count + 1;
              
    tbl_definition(var_index).value := rpad(nvl(to_char(rcd_hdr.v_id),' '),3,' ')
      || rpad(nvl(to_char(rcd_hdr.timestamp),' '),14,' ')
      || rpad(nvl(to_char(rcd_hdr.moe),' '),20,' ')
      || rpad(nvl(to_char(rcd_hdr.mars_period),' '),6,' ')
      || lpad(nvl(to_char(rcd_hdr.record_count),'0'),10,' ')
      || rpad(nvl(to_char(rcd_hdr.grd),' '),3,' ');       
        
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
   
  /**************************************************/
  /* This procedure performs the record DET routine */
  /**************************************************/
  procedure process_record_det(par_record in varchar2) is

    /*-*/
    /* Local variables 
    /*-*/
    var_valid boolean;

    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_mat_mcu_rsu is
      select t01.matl_code, 
        t01.mcu_count, 
        t01.rsu_count
      from
      (
        select t02.matnr as matl_code,
          decode(t03.rsu_meinh,null,1,decode(t02.umrez,1,t03.mcu_umren,t02.umrez*t03.mcu_umren)) as mcu_count,
          decode(t03.rsu_meinh,null,decode(t02.umrez,1,t03.mcu_umren,t02.umrez*t03.mcu_umren),decode(t02.umrez,1,t03.rsu_umren,t02.umrez*t03.rsu_umren)) as rsu_count
        from 
        (
          select matnr, meinh,
            nvl(umren,1) as umren,
            nvl(umrez,1) as umrez
          from lads_mat_uom
          where meinh = 'CS'
        ) t02,
        (
          select t04.matnr as matnr,
            nvl(max(decode(t04.rnkseq,1,t04.umren)),0) as mcu_umrez,
            nvl(max(decode(t04.rnkseq,1,t04.umren)),0) as mcu_umren,
            max(decode(t04.rnkseq,1,t04.meinh)) as mcu_meinh,
            nvl(max(decode(t04.rnkseq,2,t04.umrez)),0) as rsu_umrez,
            nvl(max(decode(t04.rnkseq,2,t04.umren)),0) as rsu_umren,
            max(decode(t04.rnkseq,2,t04.meinh)) as rsu_meinh
          from 
          (
            select t05.matnr as matnr,
              t05.rnkseq as rnkseq,
              max(t05.meinh) as meinh,
              max(t05.umren) as umren,
              max(t05.umrez) as umrez
            from 
            (
              select matnr, 
                meinh,
                umren, 
                umrez, 
                dense_rank() over (partition by matnr order by umren asc) as rnkseq
              from lads_mat_uom
              where meinh != 'EA'
                and meinh != 'CS'
                and umrez = 1
            ) t05
            group by t05.matnr, t05.rnkseq
          ) t04
          group by t04.matnr
        ) t03
        where t02.matnr = t03.matnr(+)
      ) t01
      where ltrim(t01.matl_code,'0') = ltrim(rcd_det.trad_unit_code,'0')
      order by t01.matl_code;
      
    rcd_mat_mcu_rsu csr_mat_mcu_rsu%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
  
    var_valid := false;
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('DET', par_record);

    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */
    /*--------------------------------------*/
    rcd_det.v_id := 'DET';
    rcd_det.trad_unit_code := lics_inbound_utility.get_variable('TRAD_UNIT_CODE');
    rcd_det.case_qty := lics_inbound_utility.get_number('CASE_QTY',null);
            
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
    if ( rcd_det.trad_unit_code is null ) then
       lics_inbound_utility.add_exception('Missing Required Field - DET.TRAD_UNIT_CODE');
       var_trn_error := true;
    end if;
    
    if ( rcd_det.case_qty is null ) then
       lics_inbound_utility.add_exception('Missing Required Field - DET.CASE_QTY');
       var_trn_error := true;
    end if;
                
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
       return;
    end if;
    
    /*-*/
    /* Get the MCU and RSU counts for the material 
    /*-*/    
    open csr_mat_mcu_rsu;
    loop
    
      fetch csr_mat_mcu_rsu into rcd_mat_mcu_rsu;
      exit when csr_mat_mcu_rsu%notfound;

      var_index := tbl_definition.count + 1;
      var_valid := true;
      
      tbl_definition(var_index).value := rpad(nvl(to_char(rcd_det.v_id),' '),3,' ')
        || rpad(nvl(to_char(rcd_det.trad_unit_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_det.case_qty),'0'),20,' ')
        || rpad(nvl(to_char(rcd_mat_mcu_rsu.rsu_count),'0'),4,' ')
        || rpad(nvl(to_char(rcd_mat_mcu_rsu.mcu_count),'0'),4,' ');

    end loop;
    close csr_mat_mcu_rsu;
    
    /*-*/
    /* Set the MCU and RSU count to 0 if no data was found  
    /*-*/      
    if ( var_valid = false ) then
      var_index := tbl_definition.count + 1;
      
      tbl_definition(var_index).value := rpad(nvl(to_char(rcd_det.v_id),' '),3,' ')
        || rpad(nvl(to_char(rcd_det.trad_unit_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_det.case_qty),'0'),20,' ')
        || rpad('0',4,' ')
        || rpad('0',4,' ');
    end if;  

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
  
end ics_sbwics01;

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.ics_sbwics01 to appsupport;
grant execute on ics_app.ics_sbwics01 to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ics_sbwics01 for ics_app.ics_sbwics01;