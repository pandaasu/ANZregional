-- This script is to be executed in DF_APP.  It will install the NZ Apollo 
-- Supply Report.

-- 1. Run the following command to install the report into the planning system. 
declare
  v_result_msg common.st_message_string;
  v_result common.st_result;
begin
  dbms_output.put_line('Installing NZ Apollo Supply Report');
  report_nz_apollo_supply.install(v_result,v_result_msg);
  dbms_output.put_line('Result : ' || v_result || ' - ' || v_result_msg); 
  commit;
end;

-- 2. This script adds grants to the planning system to allow it to execute the reports.
grant execute on report_nz_apollo_supply to pf_app;
grant execute on report_nz_apollo_supply to pf_reader;

-- 3. Create a public synonym for this report.
create or replace public synonym report_nz_apollo_supply for df_app.report_nz_apollo_supply;

-- 4. Then go into the planning system and go to the security object section.
-- Select Demand Readers Group
-- Add a REP_LIST REPORT_NZ_APOLLO_SUPPY READ GRANTED entry.  
