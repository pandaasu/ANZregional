DROP PROCEDURE PT_APP.CREATE_CSV_INTFC_ERR;

CREATE OR REPLACE PROCEDURE PT_APP.CREATE_CSV_INTFC_ERR(vin_err_date IN DATE default sysdate - 61/1440) IS
/******************************************************************************
	NAME:		CREATE_CSV_INTFC_ERR
	PURPOSE:	Mail errors from the pallet tag interfce at FOOD

	PARAMETERS:	Blah. Blah
				eg.	execute CG_TEMPLATE_PROCEDURE;
				The normal method of execution would be as follows.
				eg.	execute CG_TEMPLATE_PROCEDURE(sysdate + 364);

	NOTES:
******************************************************************************/
  -- Error Handling
  err_num			number;
  err_msg			varchar2(200);
  v_phase			NUMBER;

  -- Exceptions
  v_invalid_dates		EXCEPTION;
  e_invalid_material		EXCEPTION;

  -- Processing Feedback
  v_msg_str			varchar2(8000);
  v_mail_msg			varchar2(32000);
  f_out 			UTL_FILE.FILE_TYPE;
  f_name			VARCHAR2(45) := '/tmp/create_csv_intfc_err.txt';

  -- Mail Message Details
  v_mail_msg_subject		VARCHAR2(50) := 'Pallet Tag Interface Errors - Food';
  v_database			VARCHAR2(9);
  mail_to			VARCHAR2(35) := 'MFA.Pallet.Tagger.Errors@esonts1';		-- 'craig.george@esonts1';
  mail_support			VARCHAR2(40) := 'MFA.ISI.Applications.Support@esonts1';

  v_records_deleted		number := 0;
  v_records_inserted		number := 0;
  v_records_processed		number := 0;
  v_insert_errors		number := 0;
  v_invalid_material_errors	number := 0;
  v_errors_encountered		number:=0;
  v_error_rec_count		number:=0;
  v_plt_reproc_count		number:=0;
  v_proc_reproc_count		number:=0;
  v_dup_trans_sap_count		number:=0;

  -- Cursor Variables
  v_owner			varchar2(30);
  v_table_name			varchar2(30);
  v_tablespace_name		varchar2(30);


--  v_separator		VARCHAR2(10) := ', ';
  v_separator		VARCHAR2(10) := '	';

-- CURSORS

  cursor c_csv is
	select CREATED_DATE
	, MATERIAL_CODE
	, PLT_CODE
	, QTY
	, XACTN_SEQ
	, ZPPPI_BATCH
	, ERR_MSG
	from PTS_INTFC_ERR
	where CREATED_DATE >= vin_err_date
	group by CREATED_DATE
	, MATERIAL_CODE
	, PLT_CODE
	, QTY
	, XACTN_SEQ
	, ZPPPI_BATCH
	, ERR_MSG
	;

  cursor c_plt is
	select CREATED_DATE
	, MATERIAL_CODE
	, PLT_CODE
	, QTY
	, XACTN_SEQ
	, ZPPPI_BATCH
	from PTS_INTFC
	where SENT_FLAG is null
	group by CREATED_DATE
	, MATERIAL_CODE
	, PLT_CODE
	, QTY
	, XACTN_SEQ
	, ZPPPI_BATCH
	;

  cursor c_proc is
	select CREATED_DATE
	, MATERIAL_CODE
	, PLANT_CODE
	, ZPPPI_BATCH
	, PROC_ORDER
	, SEQ_ID
	, XACTN_TYPE
	, QTY
	from PROCESS_INTFC
	where SENT_FLAG is null
	group by CREATED_DATE
	, MATERIAL_CODE
	, PLANT_CODE
	, ZPPPI_BATCH
	, PROC_ORDER
	, SEQ_ID
	, XACTN_TYPE
	, QTY
	;

  cursor c_duptrans is
	select CREATED_DATE
	, PROC_ORDER
	, XACTN_SEQ
	, XACTN_TYPE
	, INTFC_ID
	, PLT_CODE
	, MATERIAL_CODE
	, QTY
	, ZPPPI_BATCH
	from PTS_CHECK_DUP_TRANS
	where CREATED_DATE >= sysdate - 1
	group by CREATED_DATE
	, PROC_ORDER
	, XACTN_SEQ
	, XACTN_TYPE
	, INTFC_ID
	, PLT_CODE
	, MATERIAL_CODE
	, QTY
	, ZPPPI_BATCH
	;
	
BEGIN
	v_phase := 1;
	f_out := UTL_FILE.FOPEN ('/tmp', f_name, 'w');

	v_phase := 2;
	UTL_FILE.FFLUSH (f_out);
	v_msg_str := 'Start:              ' || to_char(sysdate,'HH24:Mi:SS ==> DY DD MON YYYY');
	v_mail_msg := v_msg_str || chr(13);

	v_msg_str := v_mail_msg_subject || chr(13) ;
	v_mail_msg := v_mail_msg || v_msg_str || chr(13);


	-- Get the database name. Used by mail message
	BEGIN
		select name into v_database from v$database;
	EXCEPTION
	WHEN OTHERS THEN
		--UTL_FILE.PUT_LINE(f_out, 'UNABLE TO DETERMINE DATABASE NAME:  ' || SUBSTR(SQLERRM,1,80));
		v_database := 'NotKnown';
		v_mail_msg := v_mail_msg || chr(13) || 'UNABLE TO DETERMINE DATABASE NAME:  ' || SUBSTR(SQLERRM,1,80);
	END;


	v_msg_str := chr(13) ||	'ERRORS' || chr(13) || '======';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);

	v_msg_str := chr(13) || 'ERROR_DATE	        MATL_CODE	PALLET/PROCESS CODE	QTY	XACTN	BATCH NUMBER	ERROR MESSAGE';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);


	FOR src in c_csv LOOP

		v_records_processed := v_records_processed + 1;
		v_error_rec_count := v_error_rec_count + 1;
		
		v_phase:= 21;
		v_msg_str :=	to_char(src.CREATED_DATE, 'DD/MM/YYYY HH24:MI:SS')
				|| v_separator
				|| '"' || src.MATERIAL_CODE || '"'
				|| v_separator
				|| rpad('"' || src.PLT_CODE || '"', 20, ' ')
				|| v_separator
				--|| '"' || src.QTY || '"'
				|| trunc(src.QTY, '99999')
				|| v_separator
				|| '"' || src.XACTN_SEQ || '"'
				|| v_separator
				|| rpad('"' || src.ZPPPI_BATCH || '"', 15, ' ')
				|| v_separator
				--|| '"' || src.ERR_MSG || '"'
				|| '"' || replace(src.ERR_MSG, chr(10) , ' ') || '"'
				;

		UTL_FILE.PUT_LINE(f_out, v_msg_str);
	END LOOP;


	v_msg_str := chr(13) ||	'PALLETS TO BE RE-PROCESSED' || chr(13) || '==========================';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);

	FOR src in c_plt LOOP

		v_records_processed := v_records_processed + 1;
		v_plt_reproc_count := v_plt_reproc_count + 1;
		
		v_phase:= 22;
		v_msg_str :=	to_char(src.CREATED_DATE, 'DD/MM/YYYY HH24:MI:SS')
				|| v_separator
				|| '"' || src.MATERIAL_CODE || '"'
				|| v_separator
				|| '"' || src.PLT_CODE || '"'
				|| v_separator
				|| '"' || src.ZPPPI_BATCH || '"'
				|| v_separator
				|| trunc(src.QTY, '99999')
				|| v_separator
				|| '"' || src.XACTN_SEQ || '"'
				;

		UTL_FILE.PUT_LINE(f_out, v_msg_str);
	END LOOP;


	v_msg_str := chr(13) ||	'PROCESSES TO BE RE-PROCESSED' || chr(13) || '============================';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);

	FOR src in c_proc LOOP

		v_records_processed := v_records_processed + 1;
		v_proc_reproc_count := v_proc_reproc_count + 1;
		
		v_phase:= 23;
		v_msg_str :=	to_char(src.CREATED_DATE, 'DD/MM/YYYY HH24:MI:SS')
				|| v_separator
				|| '"' || src.MATERIAL_CODE || '"'
				|| v_separator
				|| '"' || src.PROC_ORDER || '"'
				|| v_separator
				|| '"' || src.SEQ_ID || '"'
				|| v_separator
				|| '"' || src.XACTN_TYPE || '"'
				|| v_separator
				|| '"' || src.PLANT_CODE || '"'
				|| v_separator
				|| '"' || src.ZPPPI_BATCH || '"'
				|| v_separator
				|| trunc(src.QTY, '99999')
				;

		UTL_FILE.PUT_LINE(f_out, v_msg_str);
	END LOOP;


	v_msg_str := chr(13) ||	'DUPLICATE TRANSACTION TO SAP' || chr(13) || '============================';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);

	v_msg_str := chr(13) || 'ERROR_DATE             PROC_ORDER       XACTN_SEQ         XACTN_TYPE    INTFC_ID               PALLET NUMBER     MATL_CODE          QTY BATCH NUMBER';
	UTL_FILE.PUT_LINE(f_out, v_msg_str);

	FOR src in c_duptrans LOOP

		v_records_processed := v_records_processed + 1;
		v_dup_trans_sap_count := v_dup_trans_sap_count + 1;
		
		v_phase:= 23;
		v_msg_str :=	to_char(src.CREATED_DATE, 'DD/MM/YYYY HH24:MI:SS')
				|| v_separator
				|| lpad(trunc(src.PROC_ORDER, '99999999'), 9, ' ')
				|| v_separator
				|| lpad(trunc(src.XACTN_SEQ, '99999999'), 9, ' ')
				|| v_separator
				|| lpad('"' || src.XACTN_TYPE || '"', 12, ' ')
				|| v_separator
				|| lpad(trunc(src.INTFC_ID, '99999999'), 8, ' ')
				|| v_separator
				|| lpad('"' || src.PLT_CODE || '"', 20, ' ')
				|| v_separator
				|| lpad('"' || src.MATERIAL_CODE || '"', 10, ' ')
				|| v_separator
				|| lpad(trunc(src.QTY, '99999'), 7, ' ')
				|| v_separator
				|| '"' || src.ZPPPI_BATCH || '"'
				;

		UTL_FILE.PUT_LINE(f_out, v_msg_str);
	END LOOP;

	
	v_phase := 90;
--	v_mail_msg := v_mail_msg || chr(13);
	v_mail_msg := v_mail_msg || chr(13) || 'Records Processed:              ' || v_records_processed;
	v_mail_msg := v_mail_msg || chr(13) || 'Errors Processed:               ' || v_error_rec_count;
	v_mail_msg := v_mail_msg || chr(13) || 'Pallets to be reprocessed:      ' || v_plt_reproc_count;
	v_mail_msg := v_mail_msg || chr(13) || 'Processed to be reprocesses:    ' || v_proc_reproc_count;
	v_mail_msg := v_mail_msg || chr(13) || 'Duplicate transaction to SAP:   ' || v_dup_trans_sap_count;	  -- There could be 2 or more records for each transaction
	v_mail_msg := v_mail_msg || chr(13);


	UTL_FILE.PUT_LINE(f_out, ' ');
	v_msg_str := 'Successfull completion';
	v_mail_msg := v_mail_msg || chr(13) || v_msg_str;
	v_msg_str := 'End:                ' || to_char(sysdate,'HH24:Mi:SS ==> DY DD MON YYYY');
	v_mail_msg := v_mail_msg || chr(13) || v_msg_str;
	v_mail_msg := v_mail_msg || chr(13);



	v_phase := 100;
	UTL_FILE.FCLOSE(f_out);

	v_phase := 110;
	if v_records_processed > 0 then
	  	Mail_files(v_database || '_db', mail_to, v_mail_msg_subject, v_mail_msg, 9999999,f_name,null, null,0);
	end if;

	EXCEPTION
	WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 140);
	v_msg_str :=	   'Generic Error at row:  ' || v_records_processed || chr(13)
			|| 'Phase:                 ' || v_phase || chr(13)
			|| 'Ora Msg:               ' || err_msg;

	v_mail_msg := v_mail_msg || chr(13) || v_msg_str || chr(13) || chr(13);

--	v_mail_msg := v_mail_msg || chr(13);
--	v_mail_msg := v_mail_msg || v_msg_str;
--	v_mail_msg := v_mail_msg || chr(13);

	UTL_FILE.FCLOSE(f_out);
	Mail_files(v_database || '_db', mail_support, v_mail_msg_subject || ' ==> FAILURE', v_mail_msg, 9999999,f_name,null, null,0);
	dbms_output.put_line('Fatal Error at v_phase:   ' || v_phase || '  ==>  ' || err_num || '  ' || err_msg);
	commit;

END CREATE_CSV_INTFC_ERR;
/


