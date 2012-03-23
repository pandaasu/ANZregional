declare

   v_efex_cust_id         efex_cust.efex_cust_id%type;
   v_call_date            date;
   v_next_call_date       date;
   v_count                number := 0;

   cursor csr_missing is
      select t01.call_date as call_start_time,
         t02.cust_dtl_code,
         t04.mars_week as call_yyyyppw,
         t01.user_id as efex_assoc_caller_id,
         '147' as company_code,         -- Update company code as required (1 market id = 147, 5 market id = 149) 
         t01.sales_terr_user_id as efex_assoc_id,
         t01.efex_cust_id,
         t03.sales_terr_code,
         t01.sales_terr_id as efex_sales_terr_id,
         t01.sgmnt_id as efex_sgmnt_id,
         t01.bus_unit_id as efex_bus_unit_id,
         t05.call_type_code,
         trunc(t01.call_date) as call_date,
         t01.end_date as call_end_time,
         round(case when (t01.end_date is null) then null
            when (t01.end_date < t01.call_date) then null
            else (t01.end_date - t01.call_date)*1440 end) as call_duration,
         '1' as callback_flg_code,
         '1' as call
      from efex_call t01,
         efex_cust_dtl_dim t02,
         efex_sales_terr_dim t03,
         mars_date t04,
         efex_call_type t05
      where t01.efex_cust_id = t02.efex_cust_id
        and t01.sales_terr_id = t03.efex_sales_terr_id
        and trunc(t01.call_date) = t04.calendar_date
        and t01.call_type = t05.call_type
        and t01.user_id = '8499'        -- Update User as required
        and t02.last_rec_flg = 'Y'
        and t03.last_rec_flg = 'Y'
        and t04.mars_period = '201201'  -- Update Period as required
        and t05.efex_mkt_id = '1'       -- Update Market as required
        and not exists
        (
          select *
          from efex_call_fact t99
          where trunc(t01.call_date) = t99.call_date
            and t01.efex_cust_id = t99.efex_cust_id
            and t01.user_id = t99.efex_assoc_caller_id
        );        
   rcd_missing csr_missing%rowtype;        

   cursor csr_next_call_date is
   select min(route_plan_date) as next_call_date
   from efex_route_plan_fact
   where efex_cust_id = v_efex_cust_id
     and route_plan_date > v_call_date;

begin

  for rcd_missing in csr_missing
  loop
  
    begin
    
      v_efex_cust_id := rcd_missing.efex_cust_id;
      v_call_date := rcd_missing.call_start_time;
      v_count := v_count + 1;
      
      open csr_next_call_date;
      fetch csr_next_call_date into v_next_call_date;
      close csr_next_call_date;
      
      dbms_output.put_line('Inserting for Customer [' || rcd_missing.efex_cust_id || '], User [' || rcd_missing.efex_assoc_caller_id || '] and Date [' || to_char(rcd_missing.call_date, 'yyyymmdd') || ']');
      dbms_output.put_line('Next Call date - ' || to_char(v_next_call_date, 'yyyymmdd')); 

      -- Comment out insert statement and validate output from above code.  Also confirm the total count at the end to ensure
      -- expected number of inserts.

      insert into efex_call_fact
      (
         call_start_time,
         cust_dtl_code,
         call_yyyyppw,
         efex_assoc_caller_id,
         company_code,
         efex_assoc_id,
         efex_cust_id,
         sales_terr_code,
         efex_sales_terr_id,
         efex_sgmnt_id,
         efex_bus_unit_id,
         call_type_code,
         call_date,
         call_end_time,
         call_duration,
         callback_flg_code,
         call,
         next_call_date
      )
      values
      (
         rcd_missing.call_start_time,
         rcd_missing.cust_dtl_code,
         rcd_missing.call_yyyyppw,
         rcd_missing.efex_assoc_caller_id,
         rcd_missing.company_code,
         rcd_missing.efex_assoc_id,
         rcd_missing.efex_cust_id,
         rcd_missing.sales_terr_code,
         rcd_missing.efex_sales_terr_id,
         rcd_missing.efex_sgmnt_id,
         rcd_missing.efex_bus_unit_id,
         rcd_missing.call_type_code,
         rcd_missing.call_date,
         rcd_missing.call_end_time,
         rcd_missing.call_duration,
         rcd_missing.callback_flg_code,
         rcd_missing.call,
         v_next_call_date
      );
    
    end;
  
  end loop;
  
  dbms_output.put_line('Total Entires - ' || v_count);
  commit;

end;


