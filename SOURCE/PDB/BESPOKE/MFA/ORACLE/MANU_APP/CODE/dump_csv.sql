DROP FUNCTION MANU_APP.DUMP_CSV;

CREATE OR REPLACE FUNCTION MANU_APP.Dump_Csv( p_query     IN VARCHAR2,
                                      p_separator IN VARCHAR2 DEFAULT ',',
                                      p_dir       IN VARCHAR2 ,
                                      p_filename  IN VARCHAR2 )
RETURN NUMBER
IS

    /*************************************************************
    this generic function is used in conjunction with deamand_planning_extract 
    to save the data to a csv file on the servers default directory.
    
    J Phillipson 23 Aug 2004 
    **************************************************************/
    
    
    l_output        utl_file.file_type;
    l_theCursor     INTEGER DEFAULT dbms_sql.open_cursor;
    l_columnValue   VARCHAR2(2000);
    l_status        INTEGER;
    l_colCnt        NUMBER DEFAULT 0;
    l_separator     VARCHAR2(10) DEFAULT '';
    l_cnt           NUMBER DEFAULT 0;
    l_line          LONG;
    l_descTbl       dbms_sql.desc_tab;
    l_pad           VARCHAR2(1);
    l_count         NUMBER;
   
    
BEGIN
    
    l_output := utl_file.fopen( p_dir, p_filename, 'w' );

    dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.native );
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

    --DBMS_OUTPUT.PUT_LINE('Directory = ' || p_dir || '- File=' || p_filename);
    --DBMS_OUTPUT.PUT_LINE('Query = ' || SUBSTR(p_query,1,200));
    
    FOR i IN 1 .. l_colCnt LOOP
           dbms_sql.define_column( l_theCursor, i,
                                   l_columnValue, 4000 );
           
           IF i = 8 THEN
              L_descTbl(i).col_max_len := 16;
           ELSE
              L_descTbl(i).col_max_len := 8;
           END IF;
    END LOOP;


  

    -- run the cursor 
    l_status := dbms_sql.EXECUTE(l_theCursor);
    
    LOOP
        EXIT WHEN ( dbms_sql.fetch_rows(l_theCursor) <= 0 );
           l_line := NULL;
           FOR i IN 1 .. l_colCnt LOOP
               dbms_sql.column_value( l_theCursor, i,
                                      l_columnValue );
                
               
               l_pad := ' ';           
               l_line := l_line || RPAD( NVL(SUBSTR(l_columnValue,1,L_descTbl(i).col_max_len),'0'),l_descTbl(i).col_max_len, l_pad );
           END LOOP;
           utl_file.put_line( l_output, l_line );
           l_cnt := l_cnt+1;
           
    END LOOP;
    dbms_sql.close_cursor(l_theCursor);

    utl_file.fclose( l_output );
   
    
    RETURN l_cnt;
    
EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20000, 'File location is invalid.');
    
  WHEN UTL_FILE.INVALID_MODE THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20001, 'The open_mode parameter in FOPEN is invalid.');

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20002, 'File handle is invalid.');

  WHEN UTL_FILE.INVALID_OPERATION THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20003, 'File could not be opened or operated on as requested.');

  WHEN UTL_FILE.READ_ERROR THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20004, 'Operating system error occurred during the read operation.');

  WHEN UTL_FILE.WRITE_ERROR THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20005, 'Operating system error occurred during the write operation.');

  WHEN UTL_FILE.INTERNAL_ERROR THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20006, 'Unspecified PL/SQL error.');

 
 
  WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE_APPLICATION_ERROR(-20009, 'The MAX_LINESIZE value for FOPEN() is invalid; it should ' || 
                                    'be within the range 1 to 32767.');


  WHEN OTHERS THEN
    UTL_FILE.FCLOSE(l_output);
    RAISE;

END Dump_Csv;
/


DROP PUBLIC SYNONYM DUMP_CSV;

CREATE PUBLIC SYNONYM DUMP_CSV FOR MANU_APP.DUMP_CSV;


