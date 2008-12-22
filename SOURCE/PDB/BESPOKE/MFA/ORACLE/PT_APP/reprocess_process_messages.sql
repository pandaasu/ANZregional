create or replace procedure pt_app.reprocess_process_messages_ics as
/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/**
 System  : pt_app 
 View   : reprocess_process_messages_ics
 Owner   : pt_app 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - Reprocess Process Messages

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2008/10   Trevor Keon    Modified to use pt_cisatl17_gr_ics for sending interface

*******************************************************************************/
  var_err_msg            varchar2(4000);
  var_result_msg         varchar2(1000);
  var_transaction_type   varchar2(10);
  var_email_address      varchar2(50) := 'ANZ Plant DB Support - FOOD@esosn1';
     
  var_retval_intfc_id    number(8);
  var_result             number(8);

  var_test_flag          boolean := false;
  var_last_gr_flag       boolean := false;
  var_recs_found         boolean := false;

  var_process_exception  exception;
   
  cursor process_csr is
    select *
    from pt.process_intfc
    where sent_flag is null;
  process_rcd process_csr%rowtype;

begin

  dbms_output.put_line('Start');

  -- Added by Craig George, 16 Jun 2005
  -- HOLD IDOCs for end of period in SAP
  if ( not idoc_hold ) then
    dbms_output.put_line('Idocs not on hold');

    /* Open pallet cursor to find all unsent receipts */
    open process_csr;
    loop
      -- dbms_output.put_line('in loop ==> ');
      fetch process_csr into process_rcd;
      exit when process_csr%notfound;

      if ( process_rcd.last_gr_flag = 'Y' ) then
        var_last_gr_flag := true;
      end if;

      -- Changes by J.Drew 15/11/2004 to include a check on date to try and only reprocess pallets in the past
      -- so that we don't reprocess a pallet at the same time that the original interface is running
      -- Modified By Craig George, 17 Jun 2005
      -- IF (rec#process_intfc.created_date < sysdate - 30/1440 ) THEN

      -- Modified by Craig George, 24 Aug 2005
      -- Look at the extraction date also,
      -- because that is the date being inserted by the trigger, into CREATED_DATE
      if ( (process_rcd.created_date < sysdate - 30/1440) and (process_rcd.xactn_date < sysdate - 30/1440) ) then
        dbms_output.put_line('Re-processing process order/seq id ==> ' || process_rcd.proc_order || ' - ' || process_rcd.seq_id);

        if ( substr(process_rcd.proc_order,1,2) <> '99' ) then
          if ( process_rcd.xactn_type = 'CREATE' ) then
            var_transaction_type := 'Z_PI1';
          else
            var_transaction_type := 'Z_PI2';
          end if;
          
          pt_cisatl17_gr_ics.execute(var_result,
            var_result_msg,
            var_transaction_type,
            var_retval_intfc_id,
						process_rcd.plant_code,
						process_rcd.sender_name || ' ' || process_rcd.seq_id,
            var_test_flag,
						process_rcd.proc_order,
						process_rcd.xactn_date,
						process_rcd.xactn_time,
						process_rcd.material_code,
						process_rcd.qty,
						process_rcd.uom,
						process_rcd.stor_loc_code,
						process_rcd.dispn_code,
						process_rcd.zpppi_batch,
            var_last_gr_flag,
						to_char(process_rcd.use_by_date,'yyyymmdd'),
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );           

          update pt.process_intfc
          set sent_flag = 'Y'
          where proc_order = process_rcd.proc_order
            and seq_id  = process_rcd.seq_id;

          -- Added by Craig George, 03 Jul 2005
          -- Should make tracking of problems easier
          begin
            insert into pts_xactn_intfc_xref 
            (
              xactn_seq, 
              intfc_id, 
              proc_order, 
              xactn_type, 
              reprocessed
            ) 
            values             
            (
              process_rcd.seq_id, 
              var_retval_intfc_id, 
              process_rcd.proc_order, 
              process_rcd.xactn_type, 
              'Y'
            );
          exception
            when others then
              var_err_msg := '***** Insert into pts_xactn_intfc_xref failed (reprocessing) *****' 
                || chr(13) || 'process order:   ' || process_rcd.proc_order
                || chr(13) || 'sequence id:     ' || process_rcd.seq_id 
                || chr(13) || 'extraction type: ' || process_rcd.xactn_type
                || chr(13) || 'interface id:    ' || var_retval_intfc_id 
                || chr(13) || 'oracle err msg:  ' || sqlerrm(sqlcode);

              mailout (var_err_msg, 'mfa.isi.applications.support@esosn1','pt_app');
          end;
        else
          update pt.process_intfc
          set sent_flag = 'X'
          where proc_order = process_rcd.proc_order
            and seq_id  = process_rcd.seq_id;
        end if;

      var_last_gr_flag := false;
      commit;

      end if;  -- load delay

    end loop;
    close process_csr;

  end if;  -- idoc hold

exception
  when others then
    rollback;
    var_err_msg := 'Error occured in PLT message reprocess.  Details [' || sqlerrm(sqlcode) || ']';
    mailout (var_err_msg, var_email_address, 'pt_app');
    raise_application_error(-20000, var_err_msg);
end;
/
