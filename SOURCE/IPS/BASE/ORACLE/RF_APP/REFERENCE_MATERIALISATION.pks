create or replace 
PACKAGE          "REFERENCE_MATERIALISATION" AS
  /******************************************************************************
   NAME:       REFERENCE_MATERIALISATION
   PURPOSE:    This package is used to provide a generic flattening program to
               taking a source table and flatterning it into a destination table.
  ******************************************************************************/

  /*******************************************************************************
   NAME:      MATERALISE_TABLE
   PURPOSE:   This function is used to materalise a table.  It takes in the
              destination table, a source table or view, and returns the number
              of rows, changed, inserted or deleted.  The program looks for
              a primary key on the destination table, and if it has one it
              performs updates inserts and deletes accorginly.  If it doesn't
              it deletes the table and reinserts all records back into the table.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   15/07/2006 Chris Horn           Created function specificaton.

   NOTES:
  ********************************************************************************/
  FUNCTION materialise_table (
    i_dest_table  IN      common.st_oracle_name,
    i_source_obj  IN      common.st_oracle_name,
    o_changes     OUT     common.st_counter,
    o_result_msg  OUT     common.st_message_string)
    RETURN common.st_result;
END reference_materialisation; 
 
 