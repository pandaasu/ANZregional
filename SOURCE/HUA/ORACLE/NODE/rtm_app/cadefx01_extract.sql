create or replace package rtm_app.cadefx01_extract as
  /******************************************************************************/
  /* Package Definition                                                         */
  /******************************************************************************/
  /**
   Package : CADEFX01_Extract
   Owner   : rtm_app

   Description
   --------------------------
   Route Plan Data Generation


   YYYY/MM   Author         Description
   -------   ------         -----------
   2009/02   Danny Xing    Created

  *******************************************************************************/

  /*-*/
  /* Public declarations
  /*-*/
  procedure execute;

end cadefx01_extract;
/

create or replace package body rtm_app.cadefx01_extract as

  v_date_start date;
  v_date_end date;
  v_valid_flag varchar2(1);
  v_created_by varchar2(20):='XINGDAN';
  v_updated_by varchar2(20):='XINGDAN';
  
  procedure execute is
  
    cursor csr_routeplan is
      select t1.sales_prsn_code,
        t1.sales_prsn_name,
        t1.date_start,
        t1.date_end,
        t1.rtp_week,
        t1.rtp_day,
        t1.rtp_seq,
        t1.cust_code,
        t1.cust_name,
        t1.row_no,
        nvl(t1.rtp_status,'A') as rtp_status
      from rtm.efex_rt_pln_init_data t1
      where trunc(t1.created_on) >= trunc(sysdate)-7;
    rec_routeplan csr_routeplan%rowtype;
      
    cursor csr_date_range(p_date_start in date, p_date_end in date, p_week in number, p_day in number) is
      select calendar_date
      from mars_date md
      where md.calendar_date between p_date_start and p_date_end
        and substrb(md.mars_week,7,1)= p_week
        and decode(decode(mod(md.period_day_num, 7),0,7,mod(md.period_day_num, 7))-1,0,7,decode(mod(md.period_day_num, 7),0,7,mod(md.period_day_num, 7))-1) = p_day;
    rec_date_range csr_date_range%rowtype;
     
  begin

    delete from rtm.efex_rt_pln_final_data;
    commit;
    
    open csr_routeplan;
    loop
      fetch csr_routeplan into rec_routeplan;
      exit when csr_routeplan%notfound;
      
      v_valid_flag := 'Y';
      
      begin
        begin
          select calendar_date
          into v_date_start
          from mars_date
          where year_num = substrb(rec_routeplan.date_start,1,4)
            and period_num = substrb(rec_routeplan.date_start,5,2)
            and period_day_num = substrb(rec_routeplan.date_start,7,1)*7-7+substrb(rec_routeplan.date_start,8,1)+1;
        exception when others then
          insert into danny_test values('1','v_date_start','not_found');
          v_valid_flag := 'N';
        end;
        
        begin
          select calendar_date
          into v_date_end
          from mars_date
          where year_num = substrb(rec_routeplan.date_end,1,4)
            and period_num = substrb(rec_routeplan.date_end,5,2)
            and period_day_num = substrb(rec_routeplan.date_end,7,1)*7-7+substrb(rec_routeplan.date_end,8,1)+1;
        exception when others then
          insert into danny_test values('21','v_date_end','not_found');
          v_valid_flag := 'N';
        end;
        
      if ( substrb(rec_routeplan.date_start,1,4) = substrb(rec_routeplan.date_end,1,4) 
        and substrb(rec_routeplan.date_end,5,2) > substrb(rec_routeplan.date_start,5,2)+6 ) then        
        begin
          select calendar_date
          into v_date_end
          from mars_date
          where year_num = substrb(rec_routeplan.date_start,1,4)
            and period_num = substrb(rec_routeplan.date_start,5,2)+6
            and period_day_num = substrb(rec_routeplan.date_end,7,1)*7-7+substrb(rec_routeplan.date_end,8,1)+1;
        exception when others then
          insert into danny_test values('22','v_date_end','not_found');
          v_valid_flag := 'N';
        end;
      end if;
      
      if ( substrb(rec_routeplan.date_start,1,4) < substrb(rec_routeplan.date_end,1,4) 
        and substrb(rec_routeplan.date_end,5,1)+13 > substrb(rec_routeplan.date_start,5,1)+6 ) then
        begin
          select calendar_date
          into v_date_end
          from mars_date
          where year_num = substrb(rec_routeplan.date_start,1,4)
            and period_num = substrb(rec_routeplan.date_start,5,2)+6
            and period_day_num = substrb(rec_routeplan.date_end,7,1)*7-7+substrb(rec_routeplan.date_end,8,1)+1;
        exception when others then
          insert into danny_test values('23','v_date_end','not_found');
          v_valid_flag:='N';
        end;
      end if;
      
      if ( substrb(rec_routeplan.date_start,1,4) < substrb(rec_routeplan.date_end,1,4)-1 ) then
        begin
          select calendar_date
          into v_date_end
          from mars_date
          where year_num = substrb(rec_routeplan.date_start,1,4)
            and period_num = substrb(rec_routeplan.date_start,5,2)+6
            and period_day_num = substrb(rec_routeplan.date_end,7,1)*7-7+substrb(rec_routeplan.date_end,8,1)+1;
        exception when others then
          insert into danny_test values('24','v_date_end','not_found');
          v_valid_flag:='N';
        end;
      end if;
      
      if v_valid_flag='Y' then
        begin
          open csr_date_range(v_date_start, v_date_end, rec_routeplan.rtp_week, rec_routeplan.rtp_day);
          loop
            fetch csr_date_range into rec_date_range;
            exit when csr_date_range%notfound;
            
            begin
              insert into rtm.efex_rt_pln_final_data
              (
                sales_prsn_associate_code,
                route_plan_date,
                route_plan_order,
                customer_code,
                updated_by,
                updated_on,
                created_by,
                created_on,
                row_no,
                status
              )
              values 
              (
                rec_routeplan.sales_prsn_code,
                rec_date_range.calendar_date,
                rec_routeplan.rtp_seq,
                rec_routeplan.cust_code,
                v_created_by,
                sysdate,
                v_updated_by,
                sysdate,
                rec_routeplan.row_no,
                rec_routeplan.rtp_status
              );
            exception when others then
              insert into danny_test values('99','insert','error');        
            end;
          end loop;
          close csr_date_range;
        end;
      end if;
      end;
    end loop;
    close csr_routeplan;
    commit;
  exception
    when others then
      rollback;
  end execute;
end cadefx01_extract;
/

grant execute, debug on rtm_app.cadefx01_extract to lics_app;