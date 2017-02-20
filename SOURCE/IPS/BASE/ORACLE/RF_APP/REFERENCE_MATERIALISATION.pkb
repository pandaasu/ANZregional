create or replace 
PACKAGE BODY        "REFERENCE_MATERIALISATION" AS
  pc_package_name  common.st_package_name := 'REFERENCE_MATERIALISATION';

  --------------------------------------------------------------------------------
  /*This procedure is used only to copy table data as specified to solve Ora-1555 issue */
  /* Added by David Zhang */
  PROCEDURE cp_big_tbl_data
  IS
  /* DEST==>'LADS_CLA_CHR', SRC==>'PLAN_LADS_CLA_CHR',... */
   TYPE tabNameCurTyp IS REF CURSOR;
   tabNameCur   tabNameCurTyp;

   TYPE tabRecTyp IS TABLE OF lads_cla_chr%ROWTYPE;
   tabRec       tabRecTyp;
   
   v_processing_msg       common.st_message_string;
   limit_in             CONSTANT PLS_INTEGER := 1000;
    
  BEGIN
     logit.log('==> Start at '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
     OPEN tabNameCur FOR 'SELECT * FROM  PLAN_LADS_CLA_CHR' ;
     
     LOOP
       FETCH tabNameCur BULK COLLECT INTO tabRec LIMIT limit_in;
       
       FOR idx IN 1..tabRec.COUNT
       LOOP
         INSERT INTO lads_cla_chr
         VALUES tabRec(idx);
       END LOOP;
       
       EXIT WHEN tabRec.COUNT < limit_in;
       
     END LOOP;
     CLOSE tabNameCur;
     COMMIT;
     logit.log('==> Completed at '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        v_processing_msg := 'RF_APP.reference_materialisation.cp_big_tbl_data failed inserting LADS_CLA_CHR.'||common.create_sql_error_msg;
        logit.log_error (common.create_error_msg (v_processing_msg) );
        RAISE common.ge_error;
  END;

  FUNCTION materialise_table (
    i_dest_table  IN      common.st_oracle_name,
    i_source_obj  IN      common.st_oracle_name,
    o_changes     OUT     common.st_counter,
    o_result_msg  OUT     common.st_message_string)
    RETURN common.st_result IS
    -- Query to detect any primary keys.
    CURSOR csr_primary_key IS
      SELECT t3.column_name
      FROM all_synonyms t1, all_constraints t2, all_cons_columns t3
      WHERE t1.synonym_name = i_dest_table AND
       t1.table_name = t2.table_name AND
       t2.constraint_type = 'P' AND
       t1.table_owner = t2.owner AND
       t2.owner = t3.owner AND
       t2.table_name = t2.table_name AND
       t2.constraint_name = t3.constraint_name
      ORDER BY t3.POSITION;

    TYPE t_column_rec IS RECORD (
      column_name  common.st_oracle_name,
      POSITION     common.st_counter
    );

    TYPE t_columns IS TABLE OF t_column_rec
      INDEX BY common.st_counter;

    -- Query to get the columns within the query.
    CURSOR csr_table IS
      SELECT t2.column_name, t2.data_type, t2.data_length, t2.data_precision, t2.data_scale, t2.nullable
      FROM all_synonyms t1, all_tab_columns t2
      WHERE t1.table_owner = t2.owner AND t1.table_name = t2.table_name AND t1.synonym_name = i_dest_table
      ORDER BY t2.column_id;

    TYPE t_table IS TABLE OF csr_table%ROWTYPE;

    TYPE t_csrs IS TABLE OF INTEGER
      INDEX BY common.st_counter;
      
    v_column_name          common.st_oracle_name;
    v_primary_key_columns  t_columns;
    v_table                t_table;
    v_compare_columns      t_columns;
    v_processing_msg       common.st_message_string;
    v_return               common.st_result;
    v_return_msg           common.st_message_string;
    v_sql                  common.st_sql;
    v_columns              common.st_sql;
    csr_rowids             common.t_ref_cursor;
    v_rowid                ROWID;
    v_delete_sql           common.st_sql;
    
    /* Added by David Zhang */
    v_deleted              common.st_count;           -- number of rows to be deleted    
    
  BEGIN
    logit.enter_method (pc_package_name, 'MATERIALISE_TABLE');
    logit.LOG ('Destination Table : ' || i_dest_table);
    logit.LOG ('Source Object : ' || i_source_obj);
    logit.LOG ('Attempting to get an exclusive lock on the table.');
    COMMIT;

    BEGIN
      EXECUTE IMMEDIATE 'lock table ' || i_dest_table || ' in exclusive mode';
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        v_processing_msg := 'Unable gain exclusive lock on destination table. ' || common.create_sql_error_msg;
        logit.log_error (common.create_error_msg (v_processing_msg) );
        RAISE common.ge_error;
    END;

    logit.LOG ('Gained exclusive lock on the table.');
    o_changes := 0;

    -- First check to see if the destination table has a primary key.
    OPEN csr_primary_key;

    LOOP
      FETCH csr_primary_key
      INTO v_column_name;

      EXIT WHEN csr_primary_key%NOTFOUND;
      v_primary_key_columns (v_primary_key_columns.COUNT + 1).column_name := v_column_name;
    END LOOP;

    CLOSE csr_primary_key;

    -- Now lookup the columns to be included in the query.
    OPEN csr_table;

    FETCH csr_table
    BULK COLLECT INTO v_table;

    CLOSE csr_table;

    -- Now make sure that the table existed with some columns.
    IF v_table.COUNT = 0 THEN
      v_processing_msg := 'Table ' || i_dest_table || ' did not exist with any columns.';
      RAISE common.ge_error;
    END IF;

    -- Now generate the columns list for select and insert statements.
    v_columns := '';

    FOR v_counter IN 1 .. v_table.COUNT
    LOOP
      v_columns := v_columns || v_table (v_counter).column_name;

      IF v_counter < v_table.COUNT THEN
        v_columns := v_columns || ',';
      END IF;
    END LOOP;

    -- Now if there is no primary key just perform a delete and insert.
    IF v_primary_key_columns.COUNT = 0 THEN
      logit.LOG ('No primary key found for destination table will delete and replace.');
      -- Now generate and execute the delete.
      logit.LOG ('Deleting all data from destination table : ' || i_dest_table);

      BEGIN
--    Modified by David Zhang. Rewrite due to Oracle error on deletion of large size table records (e.g., 8223860 rows): 
--       Unable to delete destination table LADS_CLA_CHR.SQL ERROR: [ORA-01555: snapshot too old: rollback segment number 6 with name "_SYSSMU6$" too small]
       
--        EXECUTE IMMEDIATE 'delete from ' || i_dest_table;
--        logit.LOG ('Deleted '||i_dest_table||' Records : ' || SQL%ROWCOUNT);
--        
--        COMMIT;
         
      EXECUTE IMMEDIATE 'select count(*) from '||i_dest_table||' ' into v_deleted;

      v_sql :='BEGIN RF.SCHEMA_MANAGEMENT.truncate_table(' ||''''|| i_dest_table ||''''|| '); END;';        
      
      EXECUTE IMMEDIATE v_sql;      

      logit.LOG ('Deleted '||i_dest_table||' Records : ' || v_deleted);

      EXCEPTION
        WHEN OTHERS THEN
          /* ROLLBACK; */ /* Commented it as no longer needed due to DDL operation. Modified by David Zhang. */ 
          v_processing_msg := 'Unable to delete destination table '||i_dest_table ||'.'|| common.create_sql_error_msg;
          RAISE common.ge_error;
      END;

      IF UPPER(i_dest_table) = 'LADS_CLA_CHR' THEN
        logit.LOG ('Inserting data into destination table : ' || i_dest_table || ' from object : ' || i_source_obj);
       
        SELECT COUNT(*) INTO o_changes
          FROM PLAN_LADS_CLA_CHR;
        
        /* DEST==>'LADS_CLA_CHR', SRC==>'PLAN_LADS_CLA_CHR',... */
        cp_big_tbl_data(); 
     
        logit.LOG ('Inserted Records : ' || o_changes); 
     
      ELSE /* Process other 'small' tables */
        v_sql := 'insert into ' || i_dest_table || ' (' || v_columns || ') select ' || v_columns || ' from ' || i_source_obj;
        -- Now execute the insert statement.
        logit.LOG ('Inserting data into destination table : ' || i_dest_table || ' from object : ' || i_source_obj);

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            o_changes := SQL%ROWCOUNT;
            logit.LOG ('Inserted Records : ' || SQL%ROWCOUNT);
            COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
             v_processing_msg := 'Unable to insert data into destination table. ' || common.create_sql_error_msg;
             RAISE common.ge_error;
        END;   
        
      END IF;
      
    ELSE
      -- Now compile the list of compare columns.
      logit.LOG ('Creating the list of columns to compare.');

      DECLARE
        v_found            BOOLEAN;
        v_table_counter    common.st_counter;
        v_key_counter      common.st_counter;
        v_compare_counter  common.st_counter;
      BEGIN
        v_table_counter := 1;
        v_compare_counter := 0;

        LOOP
          EXIT WHEN v_table_counter > v_table.COUNT;
          v_key_counter := 1;
          v_found := FALSE;

          LOOP
            EXIT WHEN v_key_counter > v_primary_key_columns.COUNT OR v_found = TRUE;

            IF v_table (v_table_counter).column_name = v_primary_key_columns (v_key_counter).column_name THEN
              v_found := TRUE;
              v_primary_key_columns (v_key_counter).POSITION := v_table_counter;
            END IF;

            v_key_counter := v_key_counter + 1;
          END LOOP;

          IF v_found = FALSE THEN
            v_compare_counter := v_compare_counter + 1;
            v_compare_columns (v_compare_counter).column_name := v_table (v_table_counter).column_name;
            v_compare_columns (v_compare_counter).POSITION := v_table_counter;
          END IF;

          v_table_counter := v_table_counter + 1;
        END LOOP;
      END;

      -- Now read all the current row ids into memory for the destination table.
      v_return := rowit.reset_rowid_tracking (v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to set row id tracking. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;

      -- Now add the row ids.
      BEGIN
        OPEN csr_rowids FOR 'select rowid from ' || i_dest_table;

        LOOP
          FETCH csr_rowids
          INTO v_rowid;

          EXIT WHEN csr_rowids%NOTFOUND;
          v_return := rowit.add_rowid (v_rowid, v_return_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := 'Unable to add row id to tracking system. ' || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;
        END LOOP;

        CLOSE csr_rowids;
      EXCEPTION
        WHEN common.ge_error THEN
          CLOSE csr_rowids;

          RAISE;
        WHEN OTHERS THEN
          v_processing_msg := 'Unable to find all row ids from the destination table. ' || common.create_sql_error_msg;
          RAISE common.ge_error;
      END;

      -- Now open the cursor and process accordingly
      DECLARE
        v_source_select  INTEGER;
        v_dest_select    INTEGER;
        v_insert         INTEGER;
        v_update_csrs    t_csrs;

        PROCEDURE open_cursors IS
          v_counter  common.st_counter;
        BEGIN
          logit.LOG ('Opening Cursors.');
          v_source_select := dbms_sql.open_cursor;
          v_dest_select := dbms_sql.open_cursor;
          v_insert := dbms_sql.open_cursor;
          v_counter := 1;

          LOOP
            EXIT WHEN v_counter > v_compare_columns.COUNT;
            v_update_csrs (v_counter) := dbms_sql.open_cursor;
            v_counter := v_counter + 1;
          END LOOP;
        END;

        PROCEDURE parse_cursors IS
          v_counter         common.st_counter;
          v_where_clause    common.st_sql;
          v_insert_columns  common.st_sql;
        BEGIN
          logit.LOG ('Creating Where Clause.');
          v_counter := 1;
          v_where_clause := ' WHERE ';

          LOOP
            EXIT WHEN v_counter > v_primary_key_columns.COUNT;
            v_where_clause := v_where_clause || v_primary_key_columns (v_counter).column_name || ' = :i_' || v_primary_key_columns (v_counter).position;

            IF v_counter < v_primary_key_columns.COUNT THEN
              v_where_clause := v_where_clause || ' AND ';
            END IF;

            v_counter := v_counter + 1;
          END LOOP;
          
          logit.LOG ('Creating Insert Columns');
          v_insert_columns := '';
          v_counter := 1;

          LOOP
            EXIT WHEN v_counter > v_table.COUNT;
            v_insert_columns := v_insert_columns || ':i_' || v_counter;

            IF v_counter < v_table.COUNT THEN
              v_insert_columns := v_insert_columns || ',';
            END IF;

            v_counter := v_counter + 1;
          END LOOP;
          
          logit.LOG ('Parsing Cursors.');
          dbms_sql.parse (v_source_select, 'select ' || v_columns || ' from ' || i_source_obj, dbms_sql.native);
          v_sql := 'select ' || v_columns || ',rowid from ' || i_dest_table || v_where_clause;
          dbms_sql.parse (v_dest_select, v_sql, dbms_sql.native);
          v_sql := 'insert into ' || i_dest_table || ' (' || v_columns || ') values (' || v_insert_columns || ')';
          dbms_sql.parse (v_insert, v_sql, dbms_sql.native);
          -- Now parse all the update statements.
          v_counter := 1;

          LOOP
            EXIT WHEN v_counter > v_compare_columns.COUNT;
            v_sql :=
                 'update '
              || i_dest_table
              || ' set '
              || v_compare_columns (v_counter).column_name
              || ' = :i_'
              || v_compare_columns (v_counter).position
              || v_where_clause;
            dbms_sql.parse (v_update_csrs (v_counter), v_sql, dbms_sql.native);
            v_counter := v_counter + 1;
          END LOOP;
          
        EXCEPTION
          WHEN OTHERS THEN
            v_processing_msg := 'Unable to parse queries. ' || common.create_sql_error_msg;
            RAISE common.ge_error;
        END;

        PROCEDURE close_cursors IS
          v_counter  common.st_counter;
        BEGIN
          logit.LOG ('Close Cursors');
          dbms_sql.close_cursor (v_source_select);
          dbms_sql.close_cursor (v_dest_select);
          dbms_sql.close_cursor (v_insert);
          v_counter := 1;

          LOOP
            EXIT WHEN v_counter > v_update_csrs.COUNT;
            dbms_sql.close_cursor (v_update_csrs (v_counter) );
            v_counter := v_counter + 1;
          END LOOP;
        END;

        PROCEDURE define_columns IS
          v_number    NUMBER;
          v_varchar2  VARCHAR2 (4000);
          v_date      DATE;
          v_rowid     ROWID;
          v_counter   common.st_counter;
        BEGIN
          logit.LOG ('Define Columns');
          -- Define the row id column on destination table.
          dbms_sql.define_column_rowid (v_dest_select, v_table.COUNT + 1, v_rowid);
          -- Now define the rest of the columns.
          v_counter := 1;

          LOOP
            EXIT WHEN v_counter > v_table.COUNT;

            IF v_table (v_counter).data_type = 'VARCHAR2' THEN
              dbms_sql.define_column (v_dest_select, v_counter, v_varchar2, v_table (v_counter).data_length);
              dbms_sql.define_column (v_source_select, v_counter, v_varchar2, v_table (v_counter).data_length);
            ELSIF v_table (v_counter).data_type = 'NUMBER' THEN
              dbms_sql.define_column (v_dest_select, v_counter, v_number);
              dbms_sql.define_column (v_source_select, v_counter, v_number);
            ELSIF v_table (v_counter).data_type = 'DATE' THEN
              dbms_sql.define_column (v_dest_select, v_counter, v_date);
              dbms_sql.define_column (v_source_select, v_counter, v_date);
            ELSE
              v_processing_msg :=
                'Unable to define column :' || v_table (v_counter).column_name || ' as the data type : ' || v_table (v_counter).data_type
                || ' was unrecognized.';
              RAISE common.ge_error;
            END IF;

            v_counter := v_counter + 1;
          END LOOP;
        END;

        PROCEDURE process_data IS
          v_rows              PLS_INTEGER;
          v_rowid             ROWID;
          v_source_varchar2   VARCHAR2 (4000);
          v_source_date       DATE;
          v_source_number     NUMBER;
          v_dest_varchar2     VARCHAR2 (4000);
          v_dest_date         DATE;
          v_dest_number       NUMBER;
          v_key_counter       common.st_counter;
          v_insert_counter    common.st_counter;
          v_compare_counter   common.st_counter;
          v_update_required   BOOLEAN;
          v_update_performed  BOOLEAN;
          v_row_counter       common.st_counter;
        BEGIN
          logit.LOG ('Now perform the data processing.');
          -- Now execute the query.
          v_rows := dbms_sql.EXECUTE (v_source_select);

          -- Now fetch rows
          WHILE dbms_sql.fetch_rows (v_source_select) > 0
          LOOP
            -- Now fetch and bind the primary key.
            v_key_counter := 1;

            LOOP
              EXIT WHEN v_key_counter > v_primary_key_columns.COUNT;

              IF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'VARCHAR2' THEN
                dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_varchar2);
                dbms_sql.bind_variable (v_dest_select, 'i_' || v_primary_key_columns (v_key_counter).position, v_source_varchar2);
              ELSIF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'NUMBER' THEN
                dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_number);
                dbms_sql.bind_variable (v_dest_select, 'i_' || v_primary_key_columns (v_key_counter).position, v_source_number);
              ELSIF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'DATE' THEN
                dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_date);
                dbms_sql.bind_variable (v_dest_select, 'i_' || v_primary_key_columns (v_key_counter).position, v_source_date);
              ELSE
                v_processing_msg := 'Unknown data type during fetch of primary key.';
                RAISE common.ge_error;
              END IF;

              v_key_counter := v_key_counter + 1;
            END LOOP;

            -- Now execute the fetch on the destination table.
            v_rows := dbms_sql.EXECUTE (v_dest_select);

            IF dbms_sql.fetch_rows (v_dest_select) > 0 THEN
              -- Now mark the row id found.
              dbms_sql.column_value_rowid (v_dest_select, v_table.COUNT + 1, v_rowid);
              v_return := rowit.mark_rowid_found (v_rowid, v_return_msg);

              IF v_return <> common.gc_success THEN
                v_processing_msg := 'Unable to mark row id as found in tracking system. ' || common.nest_err_msg (v_return_msg);
                RAISE common.ge_error;
              END IF;

              -- Now perform the comparison and update any changed records.
              v_update_performed := FALSE;
              v_compare_counter := 1;

              LOOP
                v_update_required := FALSE;
                EXIT WHEN v_compare_counter > v_compare_columns.COUNT;

                IF v_table (v_compare_columns (v_compare_counter).POSITION).data_type = 'VARCHAR2' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_compare_columns (v_compare_counter).POSITION, v_source_varchar2);
                  dbms_sql.COLUMN_VALUE (v_dest_select, v_compare_columns (v_compare_counter).POSITION, v_dest_varchar2);

                  IF common.are_equal (v_source_varchar2, v_dest_varchar2) = FALSE THEN
                    dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_compare_columns (v_compare_counter).position, v_source_varchar2);
                    v_update_required := TRUE;
                  END IF;
                ELSIF v_table (v_compare_columns (v_compare_counter).POSITION).data_type = 'NUMBER' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_compare_columns (v_compare_counter).POSITION, v_source_number);
                  dbms_sql.COLUMN_VALUE (v_dest_select, v_compare_columns (v_compare_counter).POSITION, v_dest_number);

                  IF common.are_equal (v_source_number, v_dest_number) = FALSE THEN
                    dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_compare_columns (v_compare_counter).position, v_source_number);
                    v_update_required := TRUE;
                  END IF;
                ELSIF v_table (v_compare_columns (v_compare_counter).POSITION).data_type = 'DATE' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_compare_columns (v_compare_counter).POSITION, v_source_date);
                  dbms_sql.COLUMN_VALUE (v_dest_select, v_compare_columns (v_compare_counter).POSITION, v_dest_date);

                  IF common.are_equal (v_source_date, v_dest_date) = FALSE THEN
                    dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_compare_columns (v_compare_counter).position, v_source_date);
                    v_update_required := TRUE;
                  END IF;
                ELSE
                  v_processing_msg := 'Unknown data type during fetch of primary key.';
                  RAISE common.ge_error;
                END IF;

                -- Now if any update is required bind the primary key then execute.
                IF v_update_required = TRUE THEN
                  -- Now fetch and bind the primary key.
                  v_key_counter := 1;

                  LOOP
                    EXIT WHEN v_key_counter > v_primary_key_columns.COUNT;

                    IF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'VARCHAR2' THEN
                      dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_varchar2);
                      dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_primary_key_columns (v_key_counter).position, v_source_varchar2);
                    ELSIF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'NUMBER' THEN
                      dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_number);
                      dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_primary_key_columns (v_key_counter).position, v_source_number);
                    ELSIF v_table (v_primary_key_columns (v_key_counter).POSITION).data_type = 'DATE' THEN
                      dbms_sql.COLUMN_VALUE (v_source_select, v_primary_key_columns (v_key_counter).POSITION, v_source_date);
                      dbms_sql.bind_variable (v_update_csrs (v_compare_counter), 'i_' || v_primary_key_columns (v_key_counter).position, v_source_date);
                    ELSE
                      v_processing_msg := 'Unknown data type during binding of update where clause.';
                      RAISE common.ge_error;
                    END IF;

                    v_key_counter := v_key_counter + 1;
                  END LOOP;

                  -- Now perform the updat.e
                  v_rows := dbms_sql.EXECUTE (v_update_csrs (v_compare_counter) );

                  IF v_rows > 0 THEN
                    v_update_performed := TRUE;
                  END IF;
                END IF;

                v_compare_counter := v_compare_counter + 1;
              END LOOP;

              -- Update the change counter if any updates were performed.
              IF v_update_performed = TRUE THEN
                o_changes := o_changes + 1;
              END IF;
            ELSE
              -- Perform an insert of the record into the table.
              v_insert_counter := 1;

              LOOP
                EXIT WHEN v_insert_counter > v_table.COUNT;

                IF v_table (v_insert_counter).data_type = 'VARCHAR2' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_insert_counter, v_source_varchar2);
                  dbms_sql.bind_variable (v_insert, 'i_' || v_insert_counter, v_source_varchar2);
                ELSIF v_table (v_insert_counter).data_type = 'NUMBER' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_insert_counter, v_source_number);
                  dbms_sql.bind_variable (v_insert, 'i_' || v_insert_counter, v_source_number);
                ELSIF v_table (v_insert_counter).data_type = 'DATE' THEN
                  dbms_sql.COLUMN_VALUE (v_source_select, v_insert_counter, v_source_date);
                  dbms_sql.bind_variable (v_insert, 'i_' || v_insert_counter, v_source_date);
                ELSE
                  v_processing_msg := 'Unknown data type during fetch of primary key.';
                  RAISE common.ge_error;
                END IF;

                v_insert_counter := v_insert_counter + 1;
              END LOOP;

              -- Now perform the insert.
              v_rows := dbms_sql.EXECUTE (v_insert);
              o_changes := o_changes + v_rows;
            END IF;
          END LOOP;
        EXCEPTION
          WHEN COMMON.GE_ERROR THEN
            logit.log_error (v_processing_msg);
            RAISE COMMON.GE_ERROR;
          WHEN OTHERS THEN
            v_processing_msg := 'Unable to perform the data processing. ' || common.create_sql_error_msg;
            logit.log_error (common.create_error_msg (v_processing_msg) );
            RAISE common.ge_error;
        END;
      BEGIN
        -- Open the cursors.
        open_cursors;
        -- Parse the cursors.
        parse_cursors;
        -- Define select columns
        define_columns;
        -- Now process data.
        process_data;
        -- Close the cursors.
        close_cursors;
      EXCEPTION
        WHEN common.ge_error THEN
          close_cursors;
          RAISE common.ge_error;
        WHEN OTHERS THEN
          v_processing_msg := 'During dynamic update. ' || common.create_sql_error_msg;
          logit.log_error (common.create_error_msg (v_processing_msg) );
          close_cursors;
          RAISE common.ge_error;
      END;

      -- Now delete any rows that were not found.
      logit.LOG ('Now deleting any not found rows.');

      DECLARE
        v_counter  common.st_counter;
      BEGIN
        v_return := rowit.go_to_start (v_return_msg);

        IF v_return = common.gc_error THEN
          v_processing_msg := 'Unable to go to start of row id to tracking system. ' || common.nest_err_msg (v_return_msg);
          logit.log_error (common.create_error_msg (v_processing_msg) );
          RAISE common.ge_error;
        END IF;

        v_counter := 0;
        v_delete_sql := 'delete from ' || i_dest_table || ' where rowid = :i_rowid';

        LOOP
          v_return := rowit.get_next_not_found_rowid (v_rowid, v_return_msg);
          EXIT WHEN v_return = common.gc_failure;

          IF v_return <> common.gc_success THEN
            v_processing_msg := 'Unable to get next not found rowid from row id to tracking system. ' || common.nest_err_msg (v_return_msg);
            logit.log_error (common.create_error_msg (v_processing_msg) );
            RAISE common.ge_error;
          END IF;

          -- Now delete the row id.
          BEGIN
            EXECUTE IMMEDIATE v_delete_sql
            USING v_rowid;

            o_changes := o_changes + 1;
            v_counter := v_counter + 1;
          EXCEPTION
            WHEN OTHERS THEN
              v_processing_msg := 'Unable to deleted old row id from destination table. ' || common.create_sql_error_msg;
              logit.log_error (common.create_error_msg (v_processing_msg) );
              RAISE common.ge_error;
          END;
        END LOOP;

        logit.LOG ('Successfully deleted ' || v_counter || ' not found rows.');
      END;
    END IF;

    -- Log the total number of changes and commit.
    logit.LOG ('Total Row Changes : ' || o_changes);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      ROLLBACK;
      o_result_msg := common.create_error_msg ('Unable to materialise table. ') || v_processing_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to materialise table. ') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END materialise_table;
END reference_materialisation; 