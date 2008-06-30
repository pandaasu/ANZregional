create or replace force view manu_app.cntl_rec_stat_vw as
  select ltrim(proc_order, '0') as proc_order,
    decode(teco_stat, 'YES', 'X', '') as closed
  from cntl_rec
  where teco_stat = 'YES' 
    and substr(proc_order, 1, 1) between '0' and '9';

grant select on manu_app.cntl_rec_stat_vw to appsupport;
grant select on manu_app.cntl_rec_stat_vw to fcs_reader;
grant select on manu_app.cntl_rec_stat_vw to manu_maint;
grant select on manu_app.cntl_rec_stat_vw to manu_user;
