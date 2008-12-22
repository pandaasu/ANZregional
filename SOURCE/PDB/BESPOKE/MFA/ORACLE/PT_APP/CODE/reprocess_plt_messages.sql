create or replace procedure pt_app.reprocess_plt_messages_ics as
/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/**
 System  : pt_app 
 View   : reprocess_plt_messages_ics
 Owner   : pt_app 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - Reprocess Pallet Messages

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2008/10   Trevor Keon    Modified to use pt_cisatl17_gr_ics for sending interface

*******************************************************************************/
  var_err_msg			      varchar2(4000);
  var_result_msg        varchar2(1000);
  var_transaction_type  varchar2(10);
  var_email_address		  varchar2(50) := 'ANZ Plant DB Support - FOOD@esosn1';
     
  var_retval_intfc_id		number(8);
  var_result            number(8);
     
  var_test_flag			    boolean := false;
  var_last_gr_flag			boolean := false;
  var_recs_found			  boolean := false;

  var_process_exception exception;

  cursor pallet_csr is
    select *
    from pt.pts_intfc
    where sent_flag is null
      and xactn_type in ('CREATE','CANCEL');
  pallet_rcd pallet_csr%rowtype;

begin

  dbms_output.put_line('Start');

  -- Added by Craig George, 16 Jun 2005
  -- HOLD IDOCs for end of period in SAP
  if ( not idoc_hold ) then
    dbms_output.put_line('Idocs not on hold');

    /* Open pallet cursor to find all unsent receipts */
    open pallet_csr;
    loop
      -- dbms_output.put_line('in loop ==> ');
      fetch pallet_csr into pallet_rcd;
      exit when pallet_csr%notfound;

      if ( pallet_rcd.last_gr_flag = 'Y' ) then
        var_last_gr_flag := true;
      end if;

      -- Modified By Craig George, 17 Jun 2005
      -- so that we don't reprocess a pallet at the same time that the original interface is running
      -- IF (rec#pts_intfc.created_date < sysdate -30/1440 ) THEN

      -- Modified by Craig George, 24 Aug 2005
      -- Look at the extraction date also,
      -- because that is the date being inserted by the trigger, into CREATED_DATE
			if ( (pallet_rcd.created_date < sysdate -30/1440) and (pallet_rcd.xactn_date < sysdate -30/1440) ) then

				if ( substr(pallet_rcd.proc_order,1,2) <> '99' ) then
					dbms_output.put_line('Re-processing pallet ==> ' || pallet_rcd.plt_code);
          
					if ( pallet_rcd.xactn_type = 'CREATE' ) then
						var_transaction_type := 'Z_PI1';
					else
						var_transaction_type := 'Z_PI2';
					end if;
          
          pt_cisatl17_gr_ics.execute(var_result,
            var_result_msg,
            var_transaction_type,
            var_retval_intfc_id,
						pallet_rcd.plant_code,
						pallet_rcd.sender_name || ' ' || pallet_rcd.plt_code,
            var_test_flag,
						pallet_rcd.proc_order,
						pallet_rcd.xactn_date,
						pallet_rcd.xactn_time,
						pallet_rcd.material_code,
						pallet_rcd.qty,
						pallet_rcd.uom,
						pallet_rcd.stor_loc_code,
						pallet_rcd.dispn_code,
						pallet_rcd.zpppi_batch,
            var_last_gr_flag,
						to_char(pallet_rcd.use_by_date,'yyyymmdd'),
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );  

          update pt.pts_intfc
          set sent_flag = 'Y'
          where xactn_seq = pallet_rcd.xactn_seq;

					dbms_output.put_line(pallet_rcd.xactn_seq);

					-- added by craig george, 03 jul 2005
					-- should make tracking of problems easier
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
              pallet_rcd.xactn_seq, 
              var_retval_intfc_id, 
              pallet_rcd.proc_order, 
              pallet_rcd.xactn_type, 
              'Y'
            );

					exception
            when others then
              var_err_msg :=	'***** Insert into pts_xactn_intfc_xref failed (reprocessing) *****'
                      || chr(13) || 'process order:   ' || pallet_rcd.proc_order
                      || chr(13) || 'sequence id:     ' || pallet_rcd.xactn_seq
                      || chr(13) || 'extraction type: ' || pallet_rcd.xactn_type
                      || chr(13) || 'interface id:    ' || var_retval_intfc_id
                      || chr(13) || 'oracle err msg:  ' || sqlerrm(sqlcode);

					  mailout (var_err_msg, 'mfa.isi.applications.support@esosn1','pt_app');
					end;
				else        
					update pt.pts_intfc
					set sent_flag = 'X'
					where xactn_seq = pallet_rcd.xactn_seq;          
				end if;

				var_last_gr_flag := false;
				commit;
        
			end if;		-- load delay
		end loop;
		close pallet_csr;
	end if;		-- idoc hold
exception
  when others then
    rollback;
    var_err_msg := 'Error occured in PLT message reprocess.  Details [' || sqlerrm(sqlcode) || ']';
    mailout (var_err_msg, var_email_address, 'pt_app');
    raise_application_error(-20000, var_err_msg);
end;
/
