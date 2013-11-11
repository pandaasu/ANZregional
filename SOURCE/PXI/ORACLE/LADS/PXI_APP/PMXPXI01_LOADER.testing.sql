begin
  pmxpxi03_loader.execute(102);
end;

select * from pmx_price_conditions order by buy_start_date
  
select * from pmx_359_promotions where customer_hierarchy = '40007954' and material = '104073' order by batch_seq, batch_rec_seq asc