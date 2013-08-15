create or replace 
PACKAGE body LOGRWOD03_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_field_account constant fflu_common.st_name := 'Account';
  pc_field_cluster constant fflu_common.st_name := 'Cluster';
  pc_field_ean constant fflu_common.st_name := 'EAN';
  pc_field_ean_name constant fflu_common.st_name := 'EAN Name';
  pc_field_linear_space constant fflu_common.st_name := 'Market';
  pc_field_category constant fflu_common.st_name := 'Category';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_sub_brand constant fflu_common.st_name := 'Sub Brand';
  pc_field_segment constant fflu_common.st_name := 'Segment';
  pc_field_manufacturer constant fflu_common.st_name := 'Manufacturer';
  pc_field_single_multi constant fflu_common.st_name := 'Single Multi';
  pc_field_packsize constant fflu_common.st_name := 'Pack Size';
  pc_field_packtype constant fflu_common.st_name := 'Pack Type';

/*******************************************************************************
  Interface Suffix's
*******************************************************************************/  
  pc_suffix_coles      constant fflu_common.st_interface := '1';
  pc_suffix_woolworths constant fflu_common.st_interface := '2';

/*******************************************************************************
  Data Animal Types
*******************************************************************************/  
  pc_account_coles      constant logr_wod_share_of_shelf.account%type := 'Coles';
  pc_account_woolworths constant logr_wod_share_of_shelf.account%type := 'Woolworths';
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_prev_mars_period logr_wod_share_of_shelf.mars_period%type;
  pv_account logr_wod_share_of_shelf.account%type;
  pv_user fflu_common.st_user;
 
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_prev_mars_period := null;
    pv_account := null;
    pv_user := null;
    -- Now determine what the interface sufix was and hence the data animal type. 
    case fflu_utils.get_interface_suffix
      when pc_suffix_coles then pv_account := pc_account_coles;
      when pc_suffix_woolworths then pv_account := pc_account_woolworths;
      else 
        fflu_data.log_interface_error('Interface Suffix',fflu_utils.get_interface_suffix,'Unknown Interface Suffix.');
    end case;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_number_field_csv(pc_field_mars_period,1,'Period',null,190001,999913,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_account,2,'Account',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_cluster,3,'Cluster',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_ean,4,'EAN',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_ean_name,5,'EAN Name',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_csv(pc_field_linear_space,6,'Linear Space (CM)',null,0.001,10000,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_category,7,'Category',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_brand,8,'Brand',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_sub_brand,9,'Subbrand',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_segment,10,'Segment',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_manufacturer,11,'Manufacturer',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_single_multi,12,'Single/Multi',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_packsize,13,'Packsize',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_packtype,14,'Packtype',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    -- Now access the user name.  Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
end on_start;


/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    v_ok boolean;
    v_mars_period number(6,0);
    cursor csr_mars_period(i_mars_period in number) is 
      select mars_period
      from mars_date 
      where mars_period = i_mars_period;
  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set an OK Tracking variable.
      v_ok := true;
      -- Now validate the mars date supplied is valid.
      open csr_mars_period(fflu_data.get_number_field(pc_field_mars_period));
      fetch csr_mars_period into v_mars_period;
      if csr_mars_period%notfound = true then 
        fflu_data.log_field_error(pc_field_mars_period,'Mars Period did not appear to be valid.');
        v_ok := false;
      end if;
      close csr_mars_period;
      -- Check if this is the first data row and if the current mars period is set. 
      if pv_prev_mars_period is null and v_mars_period is not null then 
        pv_prev_mars_period := v_mars_period;
        -- Clear out any previous data for this same mars period.
        delete from logr_wod_share_of_shelf where mars_period = pv_prev_mars_period and account = pv_account;
      else
        -- Now check that each supplied mars period is the same as the first one that was supplied in the file. 
        if pv_prev_mars_period <> v_mars_period then 
          fflu_data.log_field_error(pc_field_mars_period,'Mars period was different to first period found in data file. [' || pv_prev_mars_period || '].');
          v_ok := false;
        end if;
      end if;
      -- Now perform a sense check that the category if it contains Dog or Cat that it matches the interface suffix for this file.
      if fflu_data.get_char_field(pc_field_account) <> pv_account then
        fflu_data.log_field_error(pc_field_account,'Was expecting ' || pv_account || ' data for this interface.');
        v_ok := false;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into logr_wod_share_of_shelf (
          mars_period, 
          account,
          clster, 
          ean, 
          ean_name, 
          linear_space, 
          catgry,
          brand,
          sub_brand,
          sgmnt,
          manufacturer,
          single_multi, 
          packsize,
          packtype,
          last_updtd_user, 
          last_updtd_time
        ) values (
          v_mars_period,
          pv_account,
          initcap(fflu_data.get_char_field(pc_field_cluster)),
          fflu_data.get_char_field(pc_field_ean),
          upper(fflu_data.get_char_field(pc_field_ean_name)),
          fflu_data.get_number_field(pc_field_linear_space),
          initcap(fflu_data.get_char_field(pc_field_category)),
          initcap(fflu_data.get_char_field(pc_field_brand)),
          initcap(fflu_data.get_char_field(pc_field_sub_brand)),
          initcap(fflu_data.get_char_field(pc_field_segment)),
          initcap(fflu_data.get_char_field(pc_field_manufacturer)),
          initcap(fflu_data.get_char_field(pc_field_single_multi)),
          initcap(fflu_data.get_char_field(pc_field_packsize)),
          initcap(fflu_data.get_char_field(pc_field_packtype)),
          pv_user,
          sysdate
        );
      end if;
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Data');
  end on_data;
  
  
/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/  
  procedure on_end is 
  begin 
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_data.log_interface_exception('On End');
      rollback;
  end on_end;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/  
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;
  
/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/  
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_double_quote;
  end on_get_csv_qualifier;

-- Initialise this package.  
begin
  pv_prev_mars_period := null;
  pv_account := null;
  pv_user := null;
END LOGRWOD03_LOADER;