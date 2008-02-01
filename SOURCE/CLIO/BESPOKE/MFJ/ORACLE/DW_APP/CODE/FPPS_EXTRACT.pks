CREATE OR REPLACE PACKAGE FPPS_EXTRACT IS
/***************************************************************************************
  NAME:      RUN_SALES_EXTRACT
  PURPOSE:   Creates extract file to be sent to FPPS.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   19/07/2001 Mei-Ling Lim         Created this procedure.
  1.1 	16/04/2002 Ben Engel			Modified for Japan FPPS implementation
  2.0   07/01/2003 Ben Engel			Modified for Japan Clio Datawarehouse
  2.1   17/02/2003 Scott R. Harding		Modified query and format
  2.2   19/02/2003 Scott R. Harding		Modified query to include BCP
  2.3   24/02/2003 Scott R. Harding		Modified query to outer join item code
  2.4   25/02/2003 Scott R. Harding		Included date/time stamp in first row of output
  2.5   17/07/2005 Steve Gregan                 Changed column names (ICS/LADS install)

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------
  1    IN     VARCHAR2 File Specification                   /tmp/fpps_mkt_gsv_extract.dat

  RETURN VALUE:
  CALLED BY:
  CALLS:
  EXAMPLE USE: FPPS_EXTRACT.RUN_SALES_EXTRACT('/tmp/fpps_mkt_gsv_extract.dat');

  ASSUMPTIONS:
  LIMITATIONS:
  ALGORITHM:
  NOTES:
**************************************************************************************/
PROCEDURE RUN_SALES_EXTRACT(
  pc_extract_date in VARCHAR2
  );

END FPPS_EXTRACT;
/

