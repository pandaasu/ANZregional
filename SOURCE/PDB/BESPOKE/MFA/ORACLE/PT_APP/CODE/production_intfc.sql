create or replace procedure pt_app.production_intfc_ics 
(
  par_xactn_type in       varchar2,
  par_xactn_date in       date,
  par_xactn_time in       number,
  par_plant_code in       varchar2,
  par_sender_name in      varchar2,
  par_zpppi_batch in      varchar2,
  par_proc_order in       number,
  par_stor_loc_code in    number,
  par_dispn_code in       varchar2,
  par_use_by_date in      date,
  par_material_code in    varchar2,
  par_uom in              varchar2,
  par_plt_code in         varchar2,
  par_qty in              number,
  par_full_plt_flag in    varchar2,
  par_whse_code in        varchar2,
  par_whse_locn_code in   varchar2,
  par_work_centre in      varchar2,
  par_user_id in          varchar2,
  par_rework_code in      varchar2,
  par_hold_code_1 in      number,
  par_hold_code_2 in      number,
  par_hold_code_3 in      number,
  par_hold_code_4 in      number,
  par_hold_code_5 in      number,
  par_hold_comment in     varchar2,
  par_last_gr_flag in     varchar2,
  par_seq_id in           number
) as
/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/**
 System  : pt_app 
 View   : production_intfc
 Owner   : pt_app 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - Production Interface

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2008/10   Trevor Keon    Modified to use pt_cisatl17_gr_ics for sending interface

*******************************************************************************/
   
  var_err_msg           varchar2(4000);
  var_result_msg        varchar2(1000);
  var_transaction_type  varchar2(10);
  
  var_retval_intfc_id   number(8);
  var_xactn_seq         number(8);
  var_result            number(8);
  
  var_test_flag         boolean := false;
  var_last_gr_flag      boolean := false;
  var_err_flag          boolean := false;
  
  var_process_exception exception;
  idoc_exception        exception;
  
begin

  if ( par_xactn_type not in ('CREATE','CANCEL','RWKCREATE','RWKCANCEL','HOLD','HOLDCANCEL','PRC_CREATE','PRC_CANCEL') ) then
    var_err_msg := 'Unknown Transaction Type ['||par_xactn_type||']';
    raise var_process_exception;
  end if;

  if ( par_zpppi_batch is null and par_use_by_date is not null ) then
    var_err_msg := 'Transaction Failed: Batch Code required where Best Before Date is provided.';
    raise var_process_exception;
  end if;

  if ( par_xactn_type in ('CREATE','CANCEL','RWKCREATE','RWKCANCEL','HOLD','HOLDCANCEL') ) then

    begin
      insert into pt.pts_intfc
      (
        xactn_type,
        xactn_date,
        xactn_time,
        plant_code,
        sender_name,
        zpppi_batch,
        proc_order,
        stor_loc_code,
        dispn_code,
        use_by_date,
        plt_code,
        material_code,
        uom,
        qty,
        full_plt_flag,
        whse_code,
        whse_locn_code,
        work_centre,
        user_id,
        rework_code,
        created_by,
        created_date,
        hold_code_1,
        hold_code_2,
        hold_code_3,
        hold_code_4,
        hold_code_5,
        hold_comment,
        last_gr_flag
      )
      values 
      (
        par_xactn_type,
        par_xactn_date,
        par_xactn_time,
        par_plant_code,
        par_sender_name,
        par_zpppi_batch,
        par_proc_order,
        par_stor_loc_code,
        par_dispn_code,
        par_use_by_date,
        par_plt_code,
        par_material_code,
        par_uom,
        par_qty,
        par_full_plt_flag,
        par_whse_code,
        par_whse_locn_code,
        par_work_centre,
        par_user_id,
        par_rework_code,
        '',
        '',
        par_hold_code_1,
        par_hold_code_2,
        par_hold_code_3,
        par_hold_code_4,
        par_hold_code_5,
        par_hold_comment,
        par_last_gr_flag
      );
    exception
      when others then
        var_err_msg := 'insert into pt.pts_trans FAILED, RETURN [' || sqlerrm(sqlcode) || ']';
        var_err_flag := true;
    end;

    -- Added By Craig George, 08 Dec 2004
    -- Citect appears to be making several near instantaneous calls
    -- These calls are from different machines, but contain the same data
    -- Adding a commit statement to ensure calls will fail to insert
    commit;

    if (var_err_flag) then -- insert into Error Table
    
      begin
        insert into pt.pts_intfc_err
        (
          xactn_seq,
          xactn_type,
          xactn_date,
          xactn_time,
          plant_code,
          sender_name,
          zpppi_batch,
          proc_order,
          stor_loc_code,
          dispn_code,
          use_by_date,
          plt_code,
          material_code,
          uom,
          qty,
          full_plt_flag,
          whse_code,
          whse_locn_code,
          work_centre,
          user_id,
          rework_code,
          created_by,
          created_date,
          last_gr_flag,
          hold_code_1,
          hold_code_2,
          hold_code_3,
          hold_code_4,
          hold_code_5,
          hold_comment,
          err_msg,
          procg_code
        )
        values 
        (
          '',
          par_xactn_type,
          par_xactn_date,
          par_xactn_time,
          par_plant_code,
          par_sender_name,
          par_zpppi_batch,
          par_proc_order,
          par_stor_loc_code,
          par_dispn_code,
          par_use_by_date,
          par_plt_code,
          par_material_code,
          par_uom,
          par_qty,
          par_full_plt_flag,
          par_whse_code,
          par_whse_locn_code,
          par_work_centre,
          par_user_id,
          par_rework_code,
          '',
          '',
          par_last_gr_flag,
          par_hold_code_1,
          par_hold_code_2,
          par_hold_code_3,
          par_hold_code_4,
          par_hold_code_5,
          par_hold_comment,
          '<pts_intfc_view_trg> Pallet Code ['
          ||par_plt_code||'] Transaction Type ['
          ||par_xactn_type||'] : '||var_err_msg,
          'ERROR'
        );
        
      exception
        when others then
          var_err_msg := 'insert into pt.pts_intfc_err FAILED, RETURN [' || sqlerrm(sqlcode) || ']';
          raise var_process_exception;
      end;

      -- Added By Craig George, 18 March 2005
      -- Need to exit before creation of IDOC
      -- Duplication of data was being sent to SAP
      -- Upoon failure of insert into PTS_INTFC, an insert into error table occurs
      -- Currently an exeption is only created upon failure of insert into the ERROR table
      -- No need to provide a message, there was one created on initial insert failure
      commit;
      raise var_process_exception;

    end if;


    begin
    
      if ( par_xactn_type in ('CREATE','CANCEL') and substr(par_proc_order,1,2) <> '99' ) then
        -- Added by Craig George, 16 Jun 2005
        -- HOLD IDOCs for end of period in SAP
        if not IDOC_HOLD then
        
          if par_xactn_type = 'CREATE' then
            var_transaction_type := 'Z_PI1';
          else
            var_transaction_type := 'Z_PI2';
          end if;

          if (par_last_gr_flag = 'Y') then
            var_last_gr_flag := true;
          end if;
          
          begin
          
            update pt.pts_intfc
            set sent_flag = 'Y'
            where plt_code = upper(par_plt_code)
              and xactn_type = upper(par_xactn_type)
              and proc_order = par_proc_order;
            
          exception
            when others then
              var_err_msg := '<production_intfc> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
              rollback;
              raise var_process_exception;
          end;  

          pt_cisatl17_gr_ics.execute(var_result,
            var_result_msg,
            var_transaction_type,
            var_retval_intfc_id,
            par_plant_code,
            par_sender_name || ' ' || par_plt_code,
            var_test_flag,
            par_proc_order,
            par_xactn_date,
            par_xactn_time,
            par_material_code,
            par_qty,
            par_uom,
            par_stor_loc_code,
            par_dispn_code,
            par_zpppi_batch,
            var_last_gr_flag,
            to_char(par_use_by_date,'yyyymmdd'),
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );
       
          commit;
       
          -- Added by Craig George, 03 July 2005
          -- Should make tracking of problems easier
          begin
            -- When a pallet is created, the extraction sequence is null
            -- So we need to get it
            select xactn_seq 
            into var_xactn_seq 
            from pts_intfc 
            where plt_code = par_plt_code
              and upper(xactn_type) = upper(par_xactn_type);

            insert into pts_xactn_intfc_xref (xactn_seq, intfc_id, proc_order, xactn_type) 
            values (var_xactn_seq, var_retval_intfc_id, par_proc_order, par_xactn_type);

          exception
            when others then
              var_err_msg := '***** Insert into PTS_XACTN_INTFC_XREF FAILED *****' 
              || chr(13) || 'Process Order:   ' || par_proc_order
              || chr(13) || 'Sequence ID:     ' || var_xactn_seq 
              || chr(13) || 'Extraction Type: ' || par_xactn_type
              || chr(13) || 'Interface ID:    ' || var_retval_intfc_id 
              || chr(13) || 'Oracle Err Msg:  ' || sqlerrm(sqlcode);

              mailout(var_err_msg, ' mfa.isi.applications.support@esosn1','PT_APP');
          end;
       
        end if;
      end if;
    exception
      when others then
        var_err_msg := 'Call to CREATE_IDOC Failed [' || sqlerrm || ']';
        rollback;
        raise idoc_exception;
    end;
  end if;

  begin
    if ( par_xactn_type not in ('CREATE','CANCEL') OR substr(par_proc_order,1,2) = '99' ) then
    
      update pt.pts_intfc
      set sent_flag = 'X'
      where plt_code = upper(par_plt_code)
        and xactn_type = upper(par_xactn_type)
        and proc_order = par_proc_order;
      
    end if;
      
  exception
    when others then
      var_err_msg := '<production_intfc> Error updating sent flag to X on pts_intfc: [' || sqlerrm || ']';
      raise var_process_exception;
  end;
  
  if ( par_xactn_type in ('PRC_CREATE', 'PRC_CANCEL') ) then
  
    begin
      insert into pt.process_intfc 
      (
        xactn_type,
        xactn_date,
        xactn_time,
        plant_code,
        sender_name,
        zpppi_batch,
        proc_order,
        stor_loc_code,
        dispn_code,
        use_by_date,
        material_code,
        uom,
        qty,
        user_id,
        last_gr_flag,
        seq_id
      )
      values 
      (
        par_xactn_type,
        par_xactn_date,
        par_xactn_time,
        par_plant_code,
        par_sender_name,
        par_zpppi_batch,
        par_proc_order,
        par_stor_loc_code,
        par_dispn_code,
        par_use_by_date,
        par_material_code,
        par_uom,
        par_qty,
        par_user_id,
        par_last_gr_flag,
        par_seq_id
      );

    exception
      when others then
        var_err_msg := '<production_intfc> Error inserting into process_intfc: [' || sqlerrm || ']';
        raise var_process_exception;
    end;

    -- Added By Craig George, 08 Dec 2004
    -- Citect appears to be making several near instantaneous calls
    -- These calls are from different machines, but contain the same data
    -- Adding a commit statement to ensure calls will fail to insert
    commit;


    begin
      -- Added by Craig George, 16 Jun 2005
      -- HOLD IDOCs for end of period in SAP
      if not IDOC_HOLD then

        if (substr(par_proc_order,1,2) <> '99') then
        
          if par_xactn_type = 'PRC_CREATE' then
            var_transaction_type := 'Z_PI1';
          else
            var_transaction_type := 'Z_PI2';
          end if;

          if (par_last_gr_flag = 'Y') then
            var_last_gr_flag := true;
          end if;
    
          begin
          
            update pt.process_intfc
            set sent_flag = 'Y'
            where proc_order = par_proc_order
              and xactn_type = upper(par_xactn_type)
              and seq_id = par_seq_id;
              
          exception
            when others then
              var_err_msg := '<production_intfc> Error updating sent flag on process_intfc [' || sqlerrm || ']';
              rollback;
              raise var_process_exception;
          end;
          
          pt_cisatl17_gr_ics.execute(var_result,
            var_result_msg,
            var_transaction_type,
            var_retval_intfc_id,
            par_plant_code,
            par_sender_name || ' ' || par_plt_code,
            var_test_flag,
            par_proc_order,
            par_xactn_date,
            par_xactn_time,
            par_material_code,
            par_qty,
            par_uom,
            par_stor_loc_code,
            par_dispn_code,
            par_zpppi_batch,
            var_last_gr_flag,
            to_char(par_use_by_date,'yyyymmdd'),
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );          
      
          commit;
   
          -- Added by Craig George, 18 March 2005
          -- Should make tracking of problems easier
          begin
            insert into pts_xactn_intfc_xref (xactn_seq, intfc_id, proc_order, xactn_type) 
            values (par_seq_id, var_retval_intfc_id, par_proc_order, par_xactn_type);

          exception
            when others then
              var_err_msg := '***** insert into PTS_XACTN_INTFC_XREF FAILED *****' 
              || chr(13) || 'Process Order:   ' || par_proc_order
              || chr(13) || 'Sequence ID:     ' || par_seq_id 
              || chr(13) || 'Extraction Type: ' || par_xactn_type
              || chr(13) || 'Interface ID:    ' || var_retval_intfc_id 
              || chr(13) || 'Oracle Err Msg:  ' || sqlerrm(sqlcode);

              mailout(var_err_msg, ' mfa.isi.applications.support@esosn1','PT_APP');
          end;
    
        end if;
      end if;
    exception
      when others then
        var_err_msg := 'Call to CREATE_IDOC Failed [' || sqlerrm || ']';
        rollback;
        raise idoc_exception;
    end;

    begin
    
      if ( substr(par_proc_order,1,2) = '99' ) then
      
        update pt.process_intfc
        set sent_flag = 'X'
        where proc_order = par_proc_order
          and xactn_type = upper(par_xactn_type)
          and seq_id = par_seq_id;
          
      end if;
       
    exception
      when others then
        var_err_msg := '<production_intfc> Error updating sent flag to X on process_intfc: [' || sqlerrm || ']';
        raise var_process_exception;
    end;

  end if;

commit;

exception
  when var_process_exception then
    raise_application_error(-20001, var_err_msg);
  when idoc_exception then
    raise_application_error(-20000, var_err_msg);
  when others then
    rollback;
    var_err_msg := 'ERROR OCCURED'||sqlerrm(sqlcode);
    raise_application_error(-20000, var_err_msg);
end;
/

/**/
/* Authority 
/**/
grant execute on pt_app.production_intfc_ics to public;

/**/
/* Synonym 
/**/
create or replace public synonym production_intfc_ics for pt_app.production_intfc_ics;  
